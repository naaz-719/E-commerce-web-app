##################################
# Firebase
##################################
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

##################################
# Firebase Messaging
##################################
-keep class com.google.firebase.messaging.** { *; }

##################################
# Flutter plugins
##################################
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**

##################################
# Razorpay
##################################
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**

##################################
# GetX
##################################
-keep class **.controller.** { *; }
-keep class **.bindings.** { *; }
-keepclassmembers class * {
    @androidx.lifecycle.* <methods>;
}

##################################
# Flutter EasyLoading
##################################
-keep class com.alibaba.** { *; }
-dontwarn com.alibaba.**

##################################
# General JSON Parsing (e.g., Gson)
##################################
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
