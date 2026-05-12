# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**

# Native methods
-keepclassmembers class * {
    native <methods>;
}

# Serialization (Dio / JSON)
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# SQLite / sqflite
-keep class com.tekartik.sqflite.** { *; }

# Security (biometric, permission_handler)
-keep class androidx.biometric.** { *; }
-keep class androidx.security.** { *; }
