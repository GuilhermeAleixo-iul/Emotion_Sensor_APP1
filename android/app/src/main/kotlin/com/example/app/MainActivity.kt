
package com.example.app


import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.Message
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
import com.shimmerresearch.exceptions.ShimmerException
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.IOException

class MainActivity : FlutterActivity() {
    private var channel = "com.example.emotion_sensor/shimmer"
    private var eventChannel = "com.example.emotion_sensor/shimmer/events"
    private var eventSinkChannel: EventChannel.EventSink? = null


    var shimmer: Shimmer? = null //ver depois - sintaxe to initiate
    //var spinner: Spinner? = null
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            when (call.method) {
                "connect" -> {
                    connectDevice()
                    result.success(null)
                }
                "startStreaming" -> {
                    startStreaming()
                    result.success(null)
                }
                "stopStreaming" -> {
                    stopStreaming()
                    result.success(null)
                }
                "disconnect" -> {
                    disconnectDevice()
                    result.success(null)
                }
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
       checkPermission()

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
    private fun checkPermission(){
        var permissionGranted = true
        var permissionCheck = 0
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) { //asking permition for Bluetooth device
            permissionCheck =
                ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_CONNECT)

            if (permissionCheck != PackageManager.PERMISSION_GRANTED) {
                permissionGranted = false
            }
            permissionCheck =
                ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_SCAN)
            if (permissionCheck != PackageManager.PERMISSION_GRANTED) {
                permissionGranted = false
            }
        } else {
            permissionCheck = ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.ACCESS_BACKGROUND_LOCATION
            )
            if (permissionCheck != PackageManager.PERMISSION_GRANTED) {
                permissionGranted = false
            }
        }
        permissionCheck =
            ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION)
        if (permissionCheck != PackageManager.PERMISSION_GRANTED) {
            permissionGranted = false
        }
        permissionCheck =
            ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION)
        if (permissionCheck != PackageManager.PERMISSION_GRANTED) {
            permissionGranted = false
        }


        if (!permissionGranted) {
            // Should we show an explanation?
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                ActivityCompat.requestPermissions(
                    this,
                    arrayOf(
                        Manifest.permission.BLUETOOTH_CONNECT,
                        Manifest.permission.BLUETOOTH_SCAN,
                        Manifest.permission.ACCESS_COARSE_LOCATION,
                        Manifest.permission.ACCESS_FINE_LOCATION
                    ),
                    110
                )
            } else {
                ActivityCompat.requestPermissions(
                    this,
                    arrayOf(
                        Manifest.permission.ACCESS_COARSE_LOCATION,
                        Manifest.permission.ACCESS_FINE_LOCATION,
                        Manifest.permission.ACCESS_BACKGROUND_LOCATION
                    ),
                    110
                )
            }
        } else {
        }
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
    fun connectDevice() {
        val intent = Intent(
            applicationContext,
            ShimmerBluetoothDialog::class.java
        )
        startActivityForResult(intent, ShimmerBluetoothDialog.REQUEST_CONNECT_SHIMMER)
    }

    fun disconnectDevice() {
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
    var mHandler: Handler = object : Handler(Looper.getMainLooper()) { //main trede
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

                    val gsrCluster = ObjectCluster.returnFormatCluster(
                        objectCluster.getCollectionOfFormatClusters(
                            Configuration.Shimmer3.ObjectClusterSensorName.GSR_CONDUCTANCE
                        ), "CAL"
                    )

                    val gsrConductance = gsrCluster?.mData ?: -1.0

                    Log.i(
                        LOG_TAG,
                        "GSR Conductance: $gsrConductance"
                    )

                    val ppgCluster = ObjectCluster.returnFormatCluster(
                        objectCluster.getCollectionOfFormatClusters(
                            Configuration.Shimmer3.ObjectClusterSensorName.PPG_TO_HR
                        ), "CAL"
                    )

                    val ppgHeartRate = ppgCluster?.mData ?: -1.0

                    Log.i(
                        LOG_TAG,
                        "PPG Heart Rate: $ppgHeartRate"
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



                    val sensorData = mapOf(
                        "timeStamp" to timeStampData,
                        "accel" to accelXData,
                        "type" to "sensorData",
                        "gsrConductance" to gsrConductance,
                        "ppgHeartRate" to ppgHeartRate,
                        "emgMuscleActivity" to emgActivity
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
                }
            }
        }
        super.onActivityResult(requestCode, resultCode, data)
    }


    companion object {
        private const val LOG_TAG = "ShimmerBasicExample"
    }
}