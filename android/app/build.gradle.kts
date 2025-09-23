plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.trevel_partner"

    compileSdk = 36

    defaultConfig {
        applicationId = "com.example.trevel_partner"
        minSdk = flutter.minSdkVersion
        //noinspection OldTargetApi
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
            isDebuggable = true
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
    implementation("androidx.startup:startup-runtime:1.1.1")
    implementation("androidx.core:core:1.12.0")
    implementation("androidx.lifecycle:lifecycle-process:2.7.0")
    implementation("androidx.work:work-runtime:2.9.0")
    implementation("androidx.concurrent:concurrent-futures:1.1.0")
}
