plugins {
    id("com.diffplug.spotless")
}

spotless {
    yaml {
        target("src/**/*.yaml")
//        prettier().config(mapOf(
//            "singleQuote" to true,
//            "proseWrap" to "always"
//        ))
    }
}

tasks.named("build") {
    dependsOn("spotlessApply")
}