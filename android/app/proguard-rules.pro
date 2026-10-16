# Optional classes referenced by dependencies but not shipped with the app.
# TFLite GPU delegate options (tflite_flutter) — only needed if the GPU delegate artifact is added.
-dontwarn org.tensorflow.lite.gpu.GpuDelegateFactory$Options
# BlockHound integration pulled in by grpc-netty-shaded (Shimmer driver) — debug-only tooling.
-dontwarn reactor.blockhound.integration.BlockHoundIntegration

# Keep TFLite classes accessed via JNI.
-keep class org.tensorflow.lite.** { *; }

# Shimmer SDK relies on reflection/serialization; don't let R8 strip or rename it.
-keep class com.shimmerresearch.** { *; }
-dontwarn com.shimmerresearch.**

# Referenced by Shimmer's gRPC/logging code paths but intentionally excluded in
# build.gradle.kts (netty, protobuf) or optional runtime backends not used on Android.
-dontwarn com.google.protobuf.**
-dontwarn io.netty.**
-dontwarn org.eclipse.jetty.**
-dontwarn org.apache.logging.**
-dontwarn org.apache.log4j.**
-dontwarn org.slf4j.impl.**
-dontwarn sun.misc.Cleaner
