# Start.io SDK
-keep class com.startapp.** { *; }
-keep class com.truenet.** { *; }
-keepattributes Exceptions, InnerClasses, Signature, Deprecated, SourceFile, LineNumberTable, *Annotation*, EnclosingMethod
-dontwarn android.webkit.JavascriptInterface
-dontwarn com.startapp.**
-dontwarn org.jetbrains.annotations.**
-dontwarn kotlin.**
-dontwarn kotlin.Metadata

# Suppress Kotlin metadata warnings from Start.io SDK
# These classes use newer Kotlin versions than R8 supports
-keepclassmembers class com.startapp.sdk.ads.external.config.** {
    ** $annotationName;
}