allprojects {
    repositories {
        google()
        mavenCentral()
    }
    tasks.withType<JavaCompile> {
        sourceCompatibility = "17"
        targetCompatibility = "17"
    }
}
plugins {
    id("com.android.library") // Remove the version declaration
}

android {
    namespace = "com.example.muslimjin"
    compileSdkVersion(35) // Update the compileSdkVersion to 35
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}