import java.util.Properties

// Release signing details, kept outside version control. A build on a machine
// without key.properties still works: it falls back to the debug key below,
// which is what keeps `flutter run --release` usable during development while
// making a genuinely signed build a matter of dropping one file in place.
val keystoreProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) {
        file.inputStream().use { load(it) }
    }
}
val hasReleaseKeystore = keystoreProperties.getProperty("storeFile") != null

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

flutter {
    source = "../.."
}

android {
    namespace = "com.krishnaailinks.marutiwater"
    // Pinned to 36 rather than taken from flutter.compileSdkVersion, which is
    // 35 on Flutter 3.32. targetSdk cannot exceed compileSdk, and targetSdk is
    // pinned to 36 below for the Play requirement.
    compileSdk = 36
    // Pinned to the highest version required by the bundled plugins; NDK
    // versions are backward compatible.
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.krishnaailinks.marutiwater"
        minSdk = flutter.minSdkVersion
        // Pinned rather than taken from flutter.targetSdkVersion, which is 35
        // on Flutter 3.32. From 31 August 2026 Google Play requires API 36 for
        // every new app and every update, so a build left on the toolchain
        // default would be rejected at upload with no local signal at all.
        // Verified against developer.android.com/google/play/requirements/
        // target-sdk on 30 August 2026. An extension to 1 November 2026 can be
        // requested, but there is nothing here that needs one.
        targetSdk = 36
        versionCode = flutter.versionCode
        // The build number, not just the semantic version. Flutter drops the
        // "+n" from versionName, so Android's app info showed 0.1.0 for every
        // build ever made while the app's own More screen showed 0.1.0+2 --
        // two answers to "which build is this?", and the one a person reaches
        // for first was the useless one. They agree now.
        versionName = "${flutter.versionName}+${flutter.versionCode}"
    }

    // Two environments, two application ids, so the client's live app and a
    // test build can sit on one phone at the same time. The Supabase project
    // each one talks to is NOT decided here -- it comes from
    // --dart-define-from-file, and Env.isFlavorConsistent refuses to start a
    // build whose two halves disagree.
    flavorDimensions += "env"

    productFlavors {
        create("dev") {
            dimension = "env"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "Maruti Water Dev")
        }
        create("prod") {
            dimension = "env"
            resValue("string", "app_name", "Maruti Water")
        }
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                // No keystore on this machine. Debug keys keep the build
                // running, but the output is NOT distributable.
                logger.warn(
                    "android/key.properties not found: signing the release " +
                        "build with debug keys. This APK cannot be published."
                )
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

// Only configure the flavour actually being built.
//
// WHY THIS IS HERE
//
// The Flutter Gradle plugin creates one compileFlutterBuild<Variant> task per
// variant, and every one of them regenerates lib/l10n/generated/, because
// pubspec.yaml sets `generate: true`. With a single flavour nobody noticed.
// With dev and prod, two tasks declare the same three files as their output,
// and `flutter build appbundle` fails at configuration time:
//
//   Task ':app:compileFlutterBuildProdRelease' uses this output of task
//   ':app:compileFlutterBuildDevRelease' without declaring an explicit or
//   implicit dependency.
//
// Two obvious fixes do not work. mustRunAfter does not settle it, because the
// complaint is about two tasks owning the same files rather than about their
// order; and the generated directory cannot move out of the way, because
// `flutter gen-l10n` refuses to run at all unless `generate: true` is set, which
// is the very flag that creates the overlap.
//
// What does settle it is not configuring the other flavour. A build of the dev
// bundle has no business creating prod tasks, the two variants share nothing
// but that generated directory, and with only one of them present there is
// nothing left to collide. The flavour is read from the requested task name —
// `bundleDevRelease`, `assembleProdRelease` — which is what the Flutter tool
// invokes.
//
// Deliberately conservative: if the task names name no flavour, or name both,
// every variant stays enabled and Android Studio's sync sees the whole project.
androidComponents {
    val requested = gradle.startParameter.taskNames
        .joinToString(" ")
        .lowercase()
    val named = listOf("dev", "prod").filter { requested.contains(it) }

    if (named.size == 1) {
        val keep = named.single()
        beforeVariants { variant ->
            if (!variant.flavorName.equals(keep, ignoreCase = true)) {
                variant.enable = false
            }
        }
    }
}
