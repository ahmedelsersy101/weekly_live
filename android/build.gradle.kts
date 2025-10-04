plugins {
    // ما بنحطش هنا الـ plugins (بتكون في settings.gradle.kts)
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 🔹 تغيير مكان build directory
val newBuildDir: Directory = rootProject.layout.buildDirectory
    .dir("../../build")
    .get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(name)
    layout.buildDirectory.set(newSubprojectBuildDir)

    evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
