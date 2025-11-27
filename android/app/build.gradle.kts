import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

java {
    toolchain { languageVersion.set(JavaLanguageVersion.of(17)) }
}

kotlin {
    jvmToolchain { languageVersion.set(JavaLanguageVersion.of(17)) }
}

    android {
        namespace = "app.san.voicealarm"
        compileSdk = flutter.compileSdkVersion
        ndkVersion = flutter.ndkVersion

        compileOptions {
            sourceCompatibility = JavaVersion.VERSION_17
            targetCompatibility = JavaVersion.VERSION_17
        }

    kotlinOptions { jvmTarget = "17" }

    defaultConfig {
        applicationId = "app.san.voicealarm"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = 3
        versionName = "3.0.0"
    }

    signingConfigs {
        create("release") {
            val keystoreProps = Properties()
            val keystoreFile = rootProject.file("key.properties")
            if (keystoreFile.exists()) {
                keystoreProps.load(keystoreFile.inputStream())
                println("Signing config loaded:")
                println("storeFile = ${keystoreProps["storeFile"]}")
                println("storePassword = ${keystoreProps["storePassword"]}")
                println("keyAlias = ${keystoreProps["keyAlias"]}")
                println("keyPassword = ${keystoreProps["keyPassword"]}")

                storeFile = file(keystoreProps["storeFile"] as String)
                storePassword = keystoreProps["storePassword"] as String
                keyAlias = keystoreProps["keyAlias"] as String
                keyPassword = keystoreProps["keyPassword"] as String
            } else {
                println("❌ key.properties file not found at: ${keystoreFile.absolutePath}")
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("release")
            packagingOptions {
                doNotStrip("**/*.so")
            }
        }

        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
    kotlinOptions { jvmTarget = "17" }
}

tasks.withType<JavaCompile>().configureEach {
    sourceCompatibility = "17"
    targetCompatibility = "17"
}

flutter {
    source = "../.."
}
