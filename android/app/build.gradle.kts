import com.android.build.gradle.internal.api.ApkVariantOutputImpl
import org.jetbrains.kotlin.konan.properties.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.gucooing.piliplus"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.gucooing.piliplus"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    packagingOptions.jniLibs.useLegacyPackaging = true

    // 从环境变量或key.properties文件或local.properties文件中读取签名配置
    val keyProperties = Properties().also {
        val properties = rootProject.file("key.properties")
        if (properties.exists())
            it.load(properties.inputStream())
    }

    // 读取local.properties文件
    val localProperties = Properties().also {
        val localFile = rootProject.file("local.properties")
        if (localFile.exists())
            it.load(localFile.inputStream())
    }

    // 优先使用环境变量（GitHub Secrets），如果没有则使用key.properties文件，最后使用local.properties文件
    val config = signingConfigs.create("release") {
        storeFile = file(
            System.getenv("KEYSTORE_FILE") 
            ?: keyProperties.getProperty("storeFile") 
            ?: localProperties.getProperty("KEYSTORE_PATH") 
            ?: "keystore.jks"
        )
        storePassword = System.getenv("KEYSTORE_PASSWORD") 
            ?: keyProperties.getProperty("storePassword") 
            ?: localProperties.getProperty("KEYSTORE_PASSWORD") 
            ?: ""
        keyAlias = System.getenv("KEY_ALIAS") 
            ?: keyProperties.getProperty("keyAlias") 
            ?: localProperties.getProperty("KEY_ALIAS") 
            ?: ""
        keyPassword = System.getenv("KEY_PASSWORD") 
            ?: keyProperties.getProperty("keyPassword") 
            ?: localProperties.getProperty("KEY_PASSWORD") 
            ?: ""
        enableV1Signing = true
        enableV2Signing = true
    }

    buildTypes {
        all {
            signingConfig = config ?: signingConfigs["debug"]
        }
        release {
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            applicationIdSuffix = ".debug"
        }
    }

    applicationVariants.all {
        val variant = this
        variant.outputs.forEach { output ->
            (output as ApkVariantOutputImpl).versionCodeOverride = flutter.versionCode
        }
    }
}

flutter {
    source = "../.."
}
