import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

val releaseTaskRequested = gradle.startParameter.taskNames.any {
    it.contains("release", ignoreCase = true)
}

if (releaseTaskRequested) {
    if (!keystorePropertiesFile.exists()) {
        throw GradleException(
            "Release signing is not configured. Create android/key.properties " +
                "with the production upload keystore details before building a release."
        )
    }

    val requiredSigningProperties = listOf(
        "storeFile",
        "storePassword",
        "keyAlias",
        "keyPassword",
    )
    val missingProperties = requiredSigningProperties.filter {
        keystoreProperties.getProperty(it).isNullOrBlank()
    }
    if (missingProperties.isNotEmpty()) {
        throw GradleException(
            "Release signing configuration is incomplete. Missing: " +
                missingProperties.joinToString()
        )
    }

    val configuredKeystore = rootProject.file(
        keystoreProperties.getProperty("storeFile")
    )
    if (!configuredKeystore.isFile) {
        throw GradleException(
            "Release keystore was not found at the configured storeFile path."
        )
    }
}

android {
    namespace = "com.digitalnative.dn_audio"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.digitalnative.dn_audio"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = keystoreProperties.getProperty("storeFile")?.let {
                rootProject.file(it)
            }
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
