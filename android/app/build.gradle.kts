import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// 1. خواندن فایل با بررسی وجود داشتن آن
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.Hanno.tanken_DE_Smart"//"com.Hanno.tanken_DE_Smart_Fa"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    signingConfigs {
        create("release") {
            // مقادیر واقعی از android/key.properties خونده می‌شن (که توی
            // .gitignore هست و هیچ‌وقت به گیت‌هاب پوش نمی‌شه) — قبلاً این
            // مقادیر مستقیم و به‌صورت متن ساده اینجا نوشته شده بودن که یعنی
            // با هر پوش، پسورد کیستور توی تاریخچه‌ی گیت لو می‌رفت.
            val storeFileProp = keystoreProperties.getProperty("storeFile")
            if (storeFileProp != null) {
                storeFile = file(storeFileProp)
            }
            storePassword = keystoreProperties.getProperty("storePassword")
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
        }
    }

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.Hanno.tanken_DE_Smart"//"com.Hanno.tanken_DE_Smart_Fa"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

kotlin {
    jvmToolchain(17)
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
}

configurations.all {
    resolutionStrategy.eachDependency {
        if (requested.group == "com.android.billingclient") {
            useVersion("8.0.0")
        }
    }
}