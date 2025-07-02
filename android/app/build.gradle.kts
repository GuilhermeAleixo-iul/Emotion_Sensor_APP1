plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    packagingOptions {
        resources.excludes.addAll(
            listOf(
                "META-INF/DEPENDENCIES",
                "META-INF/LICENSE",
                "META-INF/LICENSE.txt",
                "META-INF/NOTICE",
                "META-INF/NOTICE.txt",
                "META-INF/ASL2.0"
            )
        )
        resources.pickFirsts.add("**/libc++_shared.so")
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
            packagingOptions {
                resources.excludes.addAll(
                    listOf(
                        "META-INF/DEPENDENCIES",
                        "META-INF/LICENSE",
                        "META-INF/NOTICE"
                    )
                )
            }
        }
    }
}





    dependencies {

        implementation("com.shimmerresearch:shimmerbluetoothmanager:0.11.3_beta") {
            exclude(group = "io.netty")
            exclude(group = "com.google.protobuf")
            exclude(group = "org.apache.commons.math")
        }





        implementation("com.shimmerresearch:shimmerdriver:0.11.3_beta") {
            exclude(group = "io.netty")
            exclude(group = "com.google.protobuf")
        }


        implementation("com.shimmerresearch:shimmerandroidinstrumentdriver:3.2.2_beta@aar")
    }

    flutter {
        source = "../.."
    }
