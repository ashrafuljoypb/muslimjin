import com.android.build.gradle.internal.dsl.BaseAppModuleExtension
plugins {
    id("com.android.application") // Declare the AGP version
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.muslimjin"
    compileSdk = 35 // Update the compileSdk to 35
    ndkVersion = flutter.ndkVersion  
    ndkVersion = "28.0.13004108"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true // Add this line
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.muslimjin"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    // defaultConfig {
    //     applicationId = "com.example.muslimjin"
    //     minSdk = 21
    //     targetSdk = 35
    //     versionCode = 1
    //     versionName = "1.0"
    // }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    // buildTypes {
    //     getByName("release") {
    //         isMinifyEnabled = false
    //         proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
    //     }
    // }

}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3") // Add this line
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.8.22") // Use the correct Kotlin version
}
