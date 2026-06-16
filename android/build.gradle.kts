allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // Workaround: algunos plugins legacy (ej. device_calendar) no declaran
    // `namespace` en su build.gradle, lo cual AGP 8+ exige. Lo derivamos del
    // atributo `package` de su AndroidManifest.xml si falta.
    afterEvaluate {
        val androidExt = extensions.findByName("android")
        if (androidExt is com.android.build.gradle.BaseExtension && androidExt.namespace == null) {
            val manifestFile = file("src/main/AndroidManifest.xml")
            if (manifestFile.exists()) {
                val pkg = Regex("package=\"([^\"]+)\"")
                    .find(manifestFile.readText())
                    ?.groupValues?.get(1)
                if (pkg != null) {
                    androidExt.namespace = pkg
                }
            }
        }

        // Workaround: algunos plugins legacy compilan Java en 1.8 mientras
        // Kotlin usa el JDK del toolchain (21), lo que AGP/Kotlin rechazan
        // por inconsistencia. Forzamos JVM 17 en ambos para todos los módulos.
        val androidExt2 = extensions.findByName("android")
        if (androidExt2 is com.android.build.gradle.BaseExtension) {
            androidExt2.compileOptions.sourceCompatibility = JavaVersion.VERSION_17
            androidExt2.compileOptions.targetCompatibility = JavaVersion.VERSION_17
            // Java 17 source/target requires compileSdk >= 30; algunos plugins
            // legacy (ej. device_calendar) declaran compileSdk 29.
            val currentSdk = androidExt2.compileSdkVersion
                ?.removePrefix("android-")?.toIntOrNull() ?: 0
            if (currentSdk < 34) {
                androidExt2.compileSdkVersion(34)
            }
        }
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
            compilerOptions.jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
