import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("org.jetbrains.kotlin.jvm")
}

val libs = extensions.getByType<VersionCatalogsExtension>().named("libs")
val javaVersion = libs.findVersion("java").get().requiredVersion

java {
    toolchain { languageVersion = JavaLanguageVersion.of(javaVersion) }
    sourceCompatibility = JavaVersion.toVersion(javaVersion)
}

kotlin {
    compilerOptions {
        jvmTarget = JvmTarget.fromTarget(javaVersion)
        javaParameters = true
        freeCompilerArgs.addAll("-Xjsr305=strict")
    }
}
