allprojects {
    repositories {
        google()
        mavenCentral()
    }
    extra.set("flutterSourceDirectory", rootProject.file("..").absolutePath)
}

val newBuildDir = rootProject.file("../build")
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir = File(newBuildDir, project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}
subprojects {
    if (project.name != "app") {
        project.extra.set("flutter", mapOf(
            "compileSdkVersion" to 36,
            "minSdkVersion" to 21,
            "targetSdkVersion" to 36,
            "ndkVersion" to "27.0.12077973"
        ))
    }

    plugins.withId("com.android.library") {
        val android = project.extensions.findByName("android")
        if (android is org.gradle.api.plugins.ExtensionAware) {
            android.extensions.extraProperties.set("flutter", mapOf(
                "compileSdkVersion" to 36,
                "minSdkVersion" to 21,
                "targetSdkVersion" to 36,
                "ndkVersion" to "27.0.12077973"
            ))
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

