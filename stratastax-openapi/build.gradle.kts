import com.github.gradle.node.npm.task.NpxTask

plugins {
    base
    id("stratastax.node")
    id("stratastax.publishing")
    id("stratastax.repositories")
    id("stratastax.formatting")
}

description = "The bundled OpenAPI specs of the Stratastax APIs"

val openApiOutputDir = layout.buildDirectory.dir("openapi")

/**
 * Every public contract, bundled into one file each and published under its own classifier:
 * - `openapi`: the platform API (stratastax-engine)
 * - `catalog-openapi`: the game catalog API (stratastax-game-catalog)
 * - `i18n-openapi`: the translations API (the i18n service and its CMS)
 */
val specs =
    mapOf(
        "platform" to ("stratastax.platform.api-v1.yaml" to "openapi"),
        "catalog" to ("stratastax.catalog.api-v1.yaml" to "catalog-openapi"),
        "i18n" to ("stratastax.i18n.api-v1.yaml" to "i18n-openapi"),
    )

val bundles =
    specs.map { (name, spec) ->
        val (fileName, classifier) = spec
        val input = layout.projectDirectory.file("src/$fileName")
        val bundled = openApiOutputDir.map { it.file(fileName) }

        val suffix = name.replaceFirstChar(Char::uppercase)

        val bundle =
            tasks.register<NpxTask>("bundleOpenApi$suffix") {
                group = "openapi"
                description = "Bundle the $name OpenAPI spec into a single file"

                inputs.dir(layout.projectDirectory.dir("src")).withPropertyName("openApiSources")
                outputs.file(bundled)

                dependsOn("npmInstall")

                doFirst { openApiOutputDir.get().asFile.mkdirs() }

                command.set("npx")
                args.set(
                    listOf(
                        "@redocly/cli",
                        "bundle",
                        input.asFile.absolutePath,
                        "-o",
                        bundled.get().asFile.absolutePath,
                    ),
                )
            }

        val lint =
            tasks.register<NpxTask>("lintOpenApi$suffix") {
                group = "openapi"
                description = "Lint the $name OpenAPI spec"
                inputs.file(bundled)
                dependsOn(bundle)
                command.set("npx")
                args.set(
                    listOf(
                        "@redocly/cli",
                        "lint",
                        bundled.get().asFile.absolutePath,
                        "--skip-rule",
                        "security-defined",
                    ),
                )
            }

        Triple(classifier, bundled to bundle, lint)
    }

publishing {
    publications {
        create<MavenPublication>("openapi") {
            artifactId = "openapi"
            bundles.forEach { (classifier, bundle, _) ->
                artifact(bundle.first) {
                    this.classifier = classifier
                    extension = "yaml"
                    builtBy(bundle.second)
                }
            }
        }
    }
}

tasks.named("build") {
    bundles.forEach { (_, _, lint) -> dependsOn(lint) }
}
