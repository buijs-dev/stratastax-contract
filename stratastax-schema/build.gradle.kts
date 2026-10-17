import java.util.Locale.getDefault

plugins {
    id("stratastax.kotlin")
    id("stratastax.publishing")
    id("stratastax.repositories")
    id("stratastax.formatting")
}

description = "The Stratastax database schemas and their Flyway migrations"

/** Every service with its own migrations under db/migration/<service>. */
val services = listOf("engine", "game-catalog")

fun dockerImageName(service: String): String =
    "database-schema-$service:${version.toString().lowercase(getDefault())}"

fun taskSuffix(service: String): String =
    service.split("-").joinToString("") { it.replaceFirstChar(Char::uppercase) }

tasks.jar {
    archiveBaseName.set("schema")
}

publishing {
    publications {
        create<MavenPublication>("schema") {
            artifactId = "schema"
            from(components["java"])
        }
    }
}

val generateSchemaDocs =
    tasks.register("generateSchemaDocs") {
        group = "documentation"
        description = "Generates ERD + Markdown schema documentation for every service."
    }

val verifyMigrations =
    tasks.register("verifyMigrations") {
        group = "verification"
        description = "Verifies the migrations and seed data of every service against a throwaway Postgres."
    }

val dockerBuild =
    tasks.register("dockerBuild") {
        group = "docker"
        description = "Build the schema migration docker image of every service."
    }

val dockerPublish =
    tasks.register("dockerPublish") {
        group = "docker"
        description = "Tag and push the schema migration docker image of every service."
    }

services.forEach { service ->
    val suffix = taskSuffix(service)

    val docs =
        tasks.register<Exec>("generateSchemaDocs$suffix") {
            group = "documentation"
            description =
                "Generates ERD + Markdown schema documentation for $service via tbls, " +
                "from a throwaway Postgres with only the v1 migrations."
            dependsOn(tasks.jar)
            commandLine("bash", "./generate-docs.sh", service)
        }

    generateSchemaDocs.configure { dependsOn(docs) }

    val verify =
        tasks.register<Exec>("verifyMigrations$suffix") {
            group = "verification"
            description =
                "Applies the v1 migrations and the seed data of $service to a throwaway Postgres and checks " +
                "naming, structure and the seed data (see verify-migrations.sh)."
            inputs.dir("src/main/resources/db/migration/$service")
            inputs.dir("src/main/verify-migrations")
            commandLine("bash", "./verify-migrations.sh", service)
        }

    verifyMigrations.configure { dependsOn(verify) }

    val build =
        tasks.register<Exec>("dockerBuild$suffix") {
            group = "docker"
            description = "Build the docker image for the $service schema migration."
            commandLine("sh", "./docker-build.sh", service, dockerImageName(service))
        }

    dockerBuild.configure { dependsOn(build) }

    val publish =
        tasks.register<Exec>("dockerPublish$suffix") {
            group = "docker"
            description = "Tag and push the $service docker image to Repsy repository."
            dependsOn(build)

            doFirst {
                val secrets = loadSecrets()

                val registryUrl =
                    secrets["repsyRepository"]
                        ?: project.findProperty("repsyRepository")?.toString()
                        ?: System.getenv("REPSY_REPOSITORY")
                        ?: throw GradleException("No Repsy repository URL provided.")

                val user =
                    secrets["repsyUsername"]
                        ?: project.findProperty("repsyUsername")?.toString()
                        ?: System.getenv("REPSY_USERNAME")
                        ?: throw GradleException("No Repsy username provided.")

                val pass =
                    secrets["repsyPassword"]
                        ?: project.findProperty("repsyPassword")?.toString()
                        ?: System.getenv("REPSY_PASSWORD")
                        ?: throw GradleException("No Repsy password provided.")

                val remoteTag = version.toString().lowercase(getDefault())

                commandLine(
                    "sh",
                    "./docker-publish.sh",
                    dockerImageName(service),
                    registryUrl,
                    remoteTag,
                    user,
                    pass,
                )
            }
        }

    dockerPublish.configure { dependsOn(publish) }
}

tasks.named("check") {
    dependsOn(verifyMigrations)
    dependsOn(generateSchemaDocs)
}

tasks.named("build") {
    dependsOn(generateSchemaDocs)
    dependsOn(dockerBuild)
}

fun loadSecrets(): Map<String, String> {
    val secretsFile = rootProject.file("secrets.env")
    val secrets = mutableMapOf<String, String>()

    if (secretsFile.exists()) {
        secretsFile.forEachLine { line ->
            if (line.isNotBlank() && line.contains("=")) {
                val (key, value) = line.split("=", limit = 2)
                secrets[key.trim()] = value.trim()
            }
        }
    }

    return secrets
}
