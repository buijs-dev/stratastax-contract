plugins {
    id("com.github.node-gradle.node")
}

val libs = extensions.getByType<VersionCatalogsExtension>().named("libs")
val nodeVersion = libs.findVersion("node").get().requiredVersion

node {
    download = true
    version = nodeVersion
}