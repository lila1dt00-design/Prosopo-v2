# Keep the WebView JS bridges reachable by name and reflection: minifying/renaming
# these would silently break every window.AndroidPy.* / window.AndroidSave.* call
# from index.html, since the WebView looks them up by their original method names.
-keepattributes JavascriptInterface
-keep class com.facetools.app.PyBridge { *; }
-keepclassmembers class com.facetools.app.PyBridge { *; }
-keep class com.facetools.app.MainActivity { *; }
-keep class com.facetools.app.MainActivity$* { *; }
-keepclassmembers class com.facetools.app.MainActivity$* { *; }
-keep class com.facetools.app.ArchiveHelper { *; }
-keep class com.facetools.app.ArchiveHelper$* { *; }

# Chaquopy (com.chaquo.python.*) ships its own consumer rules with the plugin;
# this just keeps our side of the Java<->Python handoff from being stripped.
-keep class com.chaquo.python.** { *; }
-dontwarn com.chaquo.python.**

-dontwarn org.slf4j.**
-dontwarn org.apache.commons.compress.**
-dontwarn org.tukaani.xz.**

# ONNX Runtime uses JNI/reflection
-keep class ai.onnxruntime.** { *; }
-dontwarn ai.onnxruntime.**
