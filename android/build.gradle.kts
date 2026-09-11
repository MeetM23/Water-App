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
            "compileSdkVersion" to 35,
            "minSdkVersion" to 21,
            "targetSdkVersion" to 35,
            "ndkVersion" to "27.0.12077973"
        ))
    }

    afterEvaluate {
        val android = extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)
        android?.compileSdk = 35
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

