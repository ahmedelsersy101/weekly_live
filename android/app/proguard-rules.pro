# Keep flutter_local_notifications and related classes
-keep class com.dexterous.** { *; }
-keep class com.google.firebase.** { *; }

# Keep Flutter plugin registrant and generated plugin classes
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep Play Core classes used by Flutter's deferred components / splitinstall
-keep class com.google.android.play.core.** { *; }
