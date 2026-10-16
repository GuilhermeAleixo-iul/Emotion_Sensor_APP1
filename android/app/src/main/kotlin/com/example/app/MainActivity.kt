
package com.example.app


import android.Manifest
import android.content.ContentValues
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.os.Handler
import android.os.Looper
import android.os.Message
import android.os.SystemClock
import android.provider.MediaStore
import android.util.Log
import android.widget.Toast
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.shimmerresearch.android.Shimmer
import com.shimmerresearch.android.guiUtilities.ShimmerBluetoothDialog
import com.shimmerresearch.bluetooth.ShimmerBluetooth
import com.shimmerresearch.driver.CallbackObject
import com.shimmerresearch.driver.Configuration
import com.shimmerresearch.driver.FormatCluster
import com.shimmerresearch.driver.ObjectCluster
import com.shimmerresearch.driverUtilities.ChannelDetails
import com.shimmerresearch.exceptions.ShimmerException
import com.shimmerresearch.sensors.SensorGSR
import com.shimmerresearch.sensors.SensorPPG
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException

class MainActivity : FlutterActivity() {
    private var channel = "com.example.emotion_sensor/shimmer"
    private var eventChannel = "com.example.emotion_sensor/shimmer/events"
    private val filesChannel = "com.example.emotion_sensor/files"
    private var eventSinkChannel: EventChannel.EventSink? = null
    var sampleRate: Double? = null

    private var mockHandler: Handler? = null

    /** The pending "connect" call while the permission prompt is showing. */
    private var pendingConnectResult: MethodChannel.Result? = null


    var shimmer: Shimmer? = null //ver depois - sintaxe to initiate
    //var spinner: Spinner? = null
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            when (call.method) {
                "connect" -> {
                    if (hasBluetoothPermissions()) {
                        connectDevice()
                        result.success(null)
                    } else if (pendingConnectResult != null) {
                        result.error("BUSY", "Already asking for Bluetooth permission.", null)
                    } else {
                        pendingConnectResult = result
                        ActivityCompat.requestPermissions(
                            this, bluetoothPermissions(), REQUEST_BLUETOOTH_PERMISSIONS
                        )
                    }
                }
                "startStreaming" -> {
                    startStreaming()
                    //startMockStreaming()
                    result.success(null)
                }
                "stopStreaming" -> {
                    stopStreaming()
                    //stopMockStreaming()
                    result.success(null)
                }
                "disconnect" -> {
                    disconnectDevice()
                    result.success(null)
                }
            }

        }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, filesChannel).setMethodCallHandler { call, result ->
            when (call.method) {
                "saveToDownloads" -> {
                    val fileName = call.argument<String>("fileName")!!
                    val content = call.argument<String>("content")!!
                    val mimeType = call.argument<String>("mimeType") ?: "text/csv"
                    // Off the main thread: a long session is a few MB of CSV.
                    Thread {
                        try {
                            val location = saveToDownloads(fileName, content, mimeType)
                            runOnUiThread { result.success(location) }
                        } catch (e: Exception) {
                            runOnUiThread { result.error("SAVE_FAILED", e.message, null) }
                        }
                    }.start()
                }
                else -> result.notImplemented()
            }
        }
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, eventChannel).setStreamHandler(
            object : EventChannel.StreamHandler{
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSinkChannel = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSinkChannel = null
                }

            }
        )

    }

    override fun onCreate(savedInstanceState: Bundle?) { //main function on Flutter - starting point when I open my app
        super.onCreate(savedInstanceState)
        //setContentView(R.layout.activity_main) - for UI
        // Bluetooth permissions are requested on "connect", when they're needed.

        shimmer = Shimmer(mHandler, this@MainActivity)

        /*spinner = findViewById<View>(R.id.crcSpinner) as Spinner
        spinner!!.isEnabled = false
        // Spinner click listener
        spinner!!.onItemSelectedListener = this
        val categories: MutableList<String> = ArrayList()
        categories.add("Disable crc")
        categories.add("Enable 1 byte CRC")
        categories.add("Enable 2 byte CRC")
        // Creating adapter for spinner
        val dataAdapter = ArrayAdapter(this, R.layout.simple_spinner_item, categories)
        dataAdapter.setDropDownViewResource(R.layout.simple_spinner_dropdown_item)
        // attaching data adapter to spinner
        spinner!!.adapter = dataAdapter */

    }

    /**
     * Writes [content] to Download/EmotionSensor/[fileName] and returns where it
     * went. Android 10+ uses MediaStore, which needs no storage permission.
     * Older versions fall back to the app's own Download folder
     * (Android/data/<package>/files/Download), which also needs no permission.
     */
    private fun saveToDownloads(fileName: String, content: String, mimeType: String): String {
        val folder = "EmotionSensor"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val values = ContentValues().apply {
                put(MediaStore.Downloads.DISPLAY_NAME, fileName)
                put(MediaStore.Downloads.MIME_TYPE, mimeType)
                put(MediaStore.Downloads.RELATIVE_PATH, "${Environment.DIRECTORY_DOWNLOADS}/$folder")
                put(MediaStore.Downloads.IS_PENDING, 1)
            }
            val resolver = contentResolver
            val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
                ?: throw IOException("Could not create $fileName in Downloads")
            try {
                resolver.openOutputStream(uri)?.use { it.write(content.toByteArray()) }
                    ?: throw IOException("Could not open $fileName for writing")
                values.clear()
                values.put(MediaStore.Downloads.IS_PENDING, 0)
                resolver.update(uri, values, null, null)
            } catch (e: Exception) {
                resolver.delete(uri, null, null)
                throw e
            }
            // MediaStore renames on a clash ("name (1).csv"), so report the real name.
            val savedName = resolver.query(uri, arrayOf(MediaStore.Downloads.DISPLAY_NAME), null, null, null)
                ?.use { c -> if (c.moveToFirst()) c.getString(0) else null } ?: fileName
            return "${Environment.DIRECTORY_DOWNLOADS}/$folder/$savedName"
        }
        val dir = File(getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS), folder)
        dir.mkdirs()
        val file = File(dir, fileName)
        file.writeText(content)
        return file.absolutePath
    }

    fun startMockStreaming() {
        mockHandler = Handler(Looper.getMainLooper())
        val totalSamples = minOf(SampleData.sampleGsr.size, SampleData.samplePpg.size)
        val startUptimeMs = SystemClock.uptimeMillis()
        val startWallMs = System.currentTimeMillis().toDouble()
        var sent = 0L

        val runnable = object : Runnable {
            override fun run() {
                if (totalSamples > 0) {
                    // Send every sample that is due by now, so playback keeps
                    // real time. postDelayed() only guarantees a minimum delay;
                    // one sample per tick fell behind 128 Hz and the recording
                    // played (and the app counted seconds) too slowly.
                    val due = (SystemClock.uptimeMillis() - startUptimeMs) * MOCK_RATE_HZ / 1000.0
                    while (sent < due) {
                        // Loop when reaching the end of the recording.
                        val index = (sent % totalSamples).toInt()
                        val mockData = mapOf(
                            // Sample time rather than send time, so samples sent
                            // in the same tick are still 1/128 s apart.
                            "timeStamp" to startWallMs + sent * 1000.0 / MOCK_RATE_HZ,
                            "type" to "sensorData",
                            "sampleRate" to MOCK_RATE_HZ,
                            // Use your CSV values
                            "gsrConductance" to SampleData.sampleGsr[index],
                            "ppgHeartRate" to SampleData.samplePpg[index],
                            // The sample recording is calibrated Shimmer data.
                            "gsrUnit" to Configuration.CHANNEL_UNITS.KOHMS,
                            "ppgUnit" to Configuration.CHANNEL_UNITS.MILLIVOLTS,
                            // Keep your other values randomized if needed
                            "accel" to (Math.random() * 5),
                            "emgMuscleActivity" to (Math.random() * 1000)
                        )

                        eventSinkChannel?.success(mockData)
                        sent++
                    }
                }

                mockHandler?.postDelayed(this, 8)
            }
        }
        mockHandler?.post(runnable)
    }


    fun stopMockStreaming() {
        mockHandler?.removeCallbacksAndMessages(null)
        mockHandler = null
    }

/*
    override fun onItemSelected(parent: AdapterView<*>?, view: View, position: Int, id: Long) {
        if (spinner!!.isEnabled) {
            when (position) {
                0 -> shimmer!!.disableBtCommsCrc()
                1 -> shimmer!!.enableBtCommsOneByteCrc()
                2 -> shimmer!!.enableBtCommsTwoByteCrc()
                else -> {}
            }
        }
    }

    override fun onNothingSelected(parent: AdapterView<*>?) {
        // Another interface callback
    }
*/
    /**
     * What finding and connecting to the Shimmer needs. Android 12+ has
     * dedicated Bluetooth permissions (the manifest marks the scan as never
     * used for location). Older versions need location to discover devices.
     */
    private fun bluetoothPermissions(): Array<String> =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            arrayOf(Manifest.permission.BLUETOOTH_SCAN, Manifest.permission.BLUETOOTH_CONNECT)
        } else {
            arrayOf(Manifest.permission.ACCESS_FINE_LOCATION)
        }

    private fun hasBluetoothPermissions(): Boolean = bluetoothPermissions().all {
        ContextCompat.checkSelfPermission(this, it) == PackageManager.PERMISSION_GRANTED
    }

    override fun onRequestPermissionsResult(
        requestCode: Int, permissions: Array<out String>, grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != REQUEST_BLUETOOTH_PERMISSIONS) return
        val result = pendingConnectResult ?: return
        pendingConnectResult = null
        if (grantResults.isNotEmpty() && grantResults.all { it == PackageManager.PERMISSION_GRANTED }) {
            connectDevice()
            result.success(null)
        } else {
            // Also reached without a prompt when the user chose "Don't allow" before.
            result.error(
                "PERMISSION_DENIED",
                "Bluetooth permission is needed to find the Shimmer. " +
                    "You can allow it in Settings > Apps > app > Permissions.",
                null
            )
        }
    }

    private fun connectDevice() {
        val intent = Intent(
            applicationContext,
            ShimmerBluetoothDialog::class.java
        )
        startActivityForResult(intent, ShimmerBluetoothDialog.REQUEST_CONNECT_SHIMMER)
    }

    private fun disconnectDevice() {
        if (shimmer != null) {
            shimmer!!.disconnect()
        }
    }

    @Throws(InterruptedException::class, IOException::class)
    fun startStreaming() {
        try {
            shimmer!!.startStreaming()
        } catch (e: ShimmerException) {
            e.printStackTrace()
        }
    }

    @Throws(IOException::class)
    fun stopStreaming() {
        shimmer!!.stopStreaming()
    }


    /**
     * Messages from the Shimmer device including sensor data are received here
     */
    private var mHandler: Handler = object : Handler(Looper.getMainLooper()) { //main trede
        override fun handleMessage(msg: Message) {
            when (msg.what) { //similar to switch()
                ShimmerBluetooth.MSG_IDENTIFIER_DATA_PACKET -> if ((msg.obj is ObjectCluster)) {
                    //Print data to Logcat

                    val objectCluster = msg.obj as ObjectCluster

                    //Retrieve all possible formats for the current sensor device:
                    val timeStampCluster = ObjectCluster.returnFormatCluster(
                        objectCluster.getCollectionOfFormatClusters(
                            Configuration.Shimmer3.ObjectClusterSensorName.TIMESTAMP
                        ), "CAL"
                    )
                    val timeStampData = timeStampCluster?.mData ?: -1.0
                    Log.i(LOG_TAG, "Time Stamp: $timeStampData")

                    val accelXCluster = ObjectCluster.returnFormatCluster(
                        objectCluster.getCollectionOfFormatClusters(
                            Configuration.Shimmer3.ObjectClusterSensorName.ACCEL_LN_X
                        ), "CAL"
                    )

                    val accelXData = accelXCluster?.mData ?: -1.0
                    Log.i(
                        LOG_TAG,
                        "Accel LN X: $accelXData"
                    )

                    /*val gsrCluster = ObjectCluster.returnFormatCluster(
                        objectCluster.getCollectionOfFormatClusters(
                            Configuration.Shimmer3.ObjectClusterSensorName.GSR_CONDUCTANCE
                        ), "CAL"
                    )
*/

                    val adcGSRFormats: Collection<FormatCluster> =
                        objectCluster.getCollectionOfFormatClusters(SensorGSR.ObjectClusterSensorName.GSR_RESISTANCE)
                    val gsrformat = (ObjectCluster.returnFormatCluster(
                        adcGSRFormats,
                        ChannelDetails.CHANNEL_TYPE.CAL.toString()
                    ) as FormatCluster) // retrieve the calibrated data

                    val gsrConductance = gsrformat.mData ?: -1.0

                    Log.i(
                        LOG_TAG,
                        "GSR Conductance: $gsrConductance ${gsrformat.mUnits}"
                    )

                   /* val ppgCluster = ObjectCluster.returnFormatCluster(
                        objectCluster.getCollectionOfFormatClusters(
                            Configuration.Shimmer3.ObjectClusterSensorName.PPG_TO_HR1
                        ), "CAL"
                    )*/

                    val adcFormats: Collection<FormatCluster> =
                        objectCluster.getCollectionOfFormatClusters(SensorPPG.ObjectClusterSensorName.PPG_A13)
                    val format = (ObjectCluster.returnFormatCluster(
                        adcFormats,
                        ChannelDetails.CHANNEL_TYPE.CAL.toString()
                    ) as FormatCluster) // retrieve the calibrated data


                    val ppgHeartRate = format?.mData ?: -1.0

                    Log.i(
                        LOG_TAG,
                        "PPG Heart Rate: $ppgHeartRate ${format?.mUnits}, format: ${format?.mFormat}, objects: ${format?.mDataObject}"
                    )

                    val emgCluster = ObjectCluster.returnFormatCluster(
                        objectCluster.getCollectionOfFormatClusters(
                            Configuration.Shimmer3.ObjectClusterSensorName.EMG_CH1_16BIT
                        ), "CAL"
                    )

                    val emgActivity = emgCluster?.mData ?: -1.0

                    Log.i(
                        LOG_TAG,
                        "EMG Muscle Activity: $emgActivity"
                    )


                    if(sampleRate == null) {
                        sampleRate = shimmer!!.samplingRateShimmer
                    }

                    val sensorData = mapOf(
                        "timeStamp" to timeStampData,
                        "accel" to accelXData,
                        "type" to "sensorData",
                        "gsrConductance" to gsrConductance,
                        "ppgHeartRate" to ppgHeartRate,
                        // Units of the calibrated values, e.g. "kOhms" and "mV".
                        "gsrUnit" to gsrformat.mUnits,
                        "ppgUnit" to format?.mUnits,
                        "emgMuscleActivity" to emgActivity,
                        "sampleRate" to if(sampleRate == null) -1.0 else sampleRate
                    )
                        eventSinkChannel?.success(sensorData)
                }

                Shimmer.MESSAGE_TOAST ->  //messages for the users
                    /** Toast messages sent from [Shimmer] are received here. E.g. device xxxx now streaming.
                     * Note that display of these Toast messages is done automatically in the Handler in [com.shimmerresearch.android.shimmerService.ShimmerService]  */
                    Toast.makeText(
                        applicationContext,
                        msg.data.getString(Shimmer.TOAST),
                        Toast.LENGTH_SHORT
                    ).show()

                ShimmerBluetooth.MSG_IDENTIFIER_STATE_CHANGE -> {
                    var state: ShimmerBluetooth.BT_STATE? = null
                    var macAddress = ""

                    if (msg.obj is ObjectCluster) {
                        state = (msg.obj as ObjectCluster).mState
                        macAddress = (msg.obj as ObjectCluster).macAddress
                    } else if (msg.obj is CallbackObject) {
                        state = (msg.obj as CallbackObject).mState
                        macAddress = (msg.obj as CallbackObject).mBluetoothAddress
                    }
                    val conectionData = mapOf(
                        "State" to state.toString(),
                        "type" to "connectionData"
                    )
                    eventSinkChannel?.success(conectionData)

                    when (state) { //it checks what the state is

                        /* ShimmerBluetooth.BT_STATE.CONNECTED -> if (shimmer!!.firmwareVersionCode >= 8) {
                            if (!spinner!!.isEnabled) {
                                when (shimmer!!.currentBtCommsCrcMode) {
                                    BT_CRC_MODE.OFF -> spinner!!.setSelection(0)
                                    BT_CRC_MODE.ONE_BYTE_CRC -> spinner!!.setSelection(1)
                                    BT_CRC_MODE.TWO_BYTE_CRC -> spinner!!.setSelection(2)
                                    else -> {}
                                }
                            }
                            spinner!!.isEnabled = true
                        } */

                        ShimmerBluetooth.BT_STATE.CONNECTING -> {

                        }
                         ShimmerBluetooth.BT_STATE.STREAMING -> {}
                        ShimmerBluetooth.BT_STATE.STREAMING_AND_SDLOGGING -> {}
                        ShimmerBluetooth.BT_STATE.SDLOGGING -> {}
                        ShimmerBluetooth.BT_STATE.DISCONNECTED -> {
                            //spinner!!.isEnabled = false
                            //spinner!!.setSelection(0)
                        }
                        else -> {} //default case
                    }
                }
            }
            super.handleMessage(msg)
        }
    }

    /**
     * Get the result from the paired devices dialog
     * @param requestCode
     * @param resultCode
     * @param data
     */
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        data?.let { intentData ->
            if (requestCode == 2) {
                if (resultCode == RESULT_OK) {
                    //Get the Bluetooth mac address of the selected device:
                    val macAdd = intentData.getStringExtra(ShimmerBluetoothDialog.EXTRA_DEVICE_ADDRESS)
                    //shimmer = Shimmer(mHandler, this@MainActivity)
                    shimmer!!.connect(macAdd, "default") //Connect to the selected device
                    sampleRate = shimmer!!.samplingRateShimmer
                }
            }
        }
        super.onActivityResult(requestCode, resultCode, data)
    }


    companion object {
        private const val LOG_TAG = "ShimmerBasicExample"
        // SampleData was recorded by the Shimmer3 at 128 Hz.
        private const val MOCK_RATE_HZ = 128.0
        private const val REQUEST_BLUETOOTH_PERMISSIONS = 110
    }
}