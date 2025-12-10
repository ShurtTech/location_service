# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Workmanager - Keep all classes for background execution
-keep class androidx.work.** { *; }
-keep class * extends androidx.work.Worker
-keep class * extends androidx.work.InputMerger
-dontwarn androidx.work.**

# Geolocator - Keep location services
-keep class com.baseflow.geolocator.** { *; }
-keepclassmembers class com.baseflow.geolocator.** { *; }
-dontwarn com.baseflow.geolocator.**

# Permission Handler
-keep class com.baseflow.permissionhandler.** { *; }
-keepclassmembers class com.baseflow.permissionhandler.** { *; }

# SharedPreferences
-keep class android.content.SharedPreferences { *; }
-keep class android.content.SharedPreferences$** { *; }

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}
-keepclassmembers class kotlin.Metadata {
    public <methods>;
}

# Keep entry point for background callback
-keep class com.example.location_tracking.MainActivity { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep custom exceptions
-keep public class * extends java.lang.Exception

# Remove logging in release (optional)
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}
