import java.util.Locale.getDefault

plugins {
    id("stratastax.kotlin")
    id("stratastax.publishing")
    id("stratastax.repositories")
    id("stratastax.spotless")
}

val dockerImageName: String
    get() = "database-schema:${version.toString().lowercase(getDefault())}"

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

val generateSchemaDocs = tasks.register<Exec>("generateSchemaDocs") {
    group = "documentation"
    description = "Generates ERD + Markdown schema documentation via tbls, using a throwaway Postgres."
    dependsOn(tasks.jar)
    commandLine("sh", "./generate-docs.sh")
}

val dockerBuild = tasks.register<Exec>("dockerBuild") {
    group = "docker"
    description = "Build the docker image for schema migration."
    commandLine("sh", "./docker-build.sh", dockerImageName)
}

val dockerPublish = tasks.register<Exec>("dockerPublish") {
    group = "docker"
    description = "Tag and push the docker image to Repsy repository."
    dependsOn(dockerBuild)

    val secrets = loadSecrets()
    
    val registryUrl = secrets["repsyRepository"]
        ?: project.findProperty("repsyRepository")?.toString()
        ?: System.getenv("REPSY_REPOSITORY")
        ?: throw GradleException("No Repsy repository URL provided.")

    val user = secrets["repsyUsername"]
        ?: project.findProperty("repsyUsername")?.toString()
        ?: System.getenv("REPSY_USERNAME")
        ?: throw GradleException("No Repsy username provided.")

    val pass = secrets["repsyPassword"]
        ?: project.findProperty("repsyPassword")?.toString()
        ?: System.getenv("REPSY_PASSWORD")
        ?: throw GradleException("No Repsy password provided.")

    val remoteTag = version.toString().lowercase(getDefault())

    commandLine("sh", "./docker-publish.sh", dockerImageName, registryUrl, remoteTag, user, pass)
}

tasks.named("check") {
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
