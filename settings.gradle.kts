includeBuild("gradle-build")
include("stratastax-openapi")
include("stratastax-schema")

pluginManagement {
    repositories {
        mavenCentral()
        gradlePluginPortal()
        mavenLocal()
    }
}