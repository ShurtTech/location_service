plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.location_tracking"
    compileSdk = 35  // Updated to latest
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17  // Updated to Java 17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"  // Updated to Java 17
    }

    defaultConfig {
        applicationId = "com.example.location_tracking"
        minSdk = flutter.minSdkVersion
        targetSdk = 35  // Updated
        versionCode = 1
        versionName = "1.0.0"
        
        multiDexEnabled = true
        
        ndk {
            abiFilters += listOf("armeabi-v7a", "arm64-v8a", "x86_64")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
            
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        
        debug {
            isDebuggable = true
            isMinifyEnabled = false
        }
    }
    
    packaging {
        resources {
            excludes += listOf(
                "/META-INF/{AL2.0,LGPL2.1}",
                "/META-INF/DEPENDENCIES",
                "/META-INF/LICENSE",
                "/META-INF/LICENSE.txt",
                "/META-INF/NOTICE",
                "/META-INF/NOTICE.txt",
                "/META-INF/*.kotlin_module"
            )
        }
    }
    
    lint {
        disable += listOf("InvalidPackage")
        checkReleaseBuilds = false
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
    implementation("androidx.work:work-runtime-ktx:2.9.0")
    implementation("org.jetbrains.kotlin:kotlin-stdlib:2.1.0")
    implementation("androidx.core:core-ktx:1.15.0")

    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
