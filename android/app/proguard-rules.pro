# Giữ lại toàn bộ class và interface của Google Play Services Tasks API
-keep class com.google.android.gms.tasks.** { *; }
-keep interface com.google.android.gms.tasks.** { *; }

# Giữ lại ML Kit Face Detection
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_** { *; }
-dontwarn com.google.mlkit.**
-dontwarn com.google.android.gms.**

# Giữ lại CameraX
-keep class androidx.camera.** { *; }
-dontwarn androidx.camera.**

# Giữ lại Native View và MainActivity của app
-keep class com.example.appdiemdanh.** { *; }
-keep class io.flutter.plugin.platform.** { *; }

# Giữ lại Reflection & Annotations
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod