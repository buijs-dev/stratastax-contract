import com.github.gradle.node.npm.task.NpxTask

plugins {
    id("stratastax.node")
    id("stratastax.publishing")
    id("stratastax.repositories")
    id("stratastax.spotless")
}

val openApiInput = layout.projectDirectory.file("src/stratastax.platform.api-v1.yaml")
val openApiOutputDir = layout.buildDirectory.dir("openapi")
val bundledFile = openApiOutputDir.map { it.file("stratastax.platform.api-v1.yaml") }

val bundleOpenApi = tasks.register<NpxTask>("bundleOpenApi") {
    group = "openapi"
    description = "Bundle OpenAPI into single file"

    inputs.file(openApiInput)
    outputs.file(bundledFile)

    dependsOn("npmInstall")

    doFirst {
        openApiOutputDir.get().asFile.mkdirs()
    }

    command.set("npx")
    args.set(listOf("@redocly/cli", "bundle", openApiInput.asFile.absolutePath, "-o", bundledFile.get().asFile.absolutePath))
}

val lintOpenApi = tasks.register<NpxTask>("lintOpenApi") {
    group = "openapi"
    description = "Lint OpenAPI specification"
    inputs.file(bundledFile)
    dependsOn(bundleOpenApi)
    command.set("npx")
    args.set(listOf("@redocly/cli", "lint", bundledFile.get().asFile.absolutePath, "--skip-rule", "security-defined"))
}

publishing {
    publications {
        create<MavenPublication>("openapi") {
            artifactId = "openapi"
            artifact(bundledFile) {
                classifier = "openapi"
                extension = "yaml"
                builtBy(bundleOpenApi)
            }
        }
    }
}

tasks.named("build") {
    dependsOn(lintOpenApi)
}
