pluginManagement {
    val flutterVersionPath = extra["flutter.sdk"]?.toString()
        ?: error("Flutter SDK not found. Define flutter.sdk in local.properties")
    includeBuild("$flutterVersionPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.1.0" apply false
    id("org.jetbrains.kotlin.android") version "1.9.0" apply false
}

include(":app")
