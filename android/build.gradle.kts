allprojects {
    repositories {

        google()

       // mavenCentral()
        maven {
            //name = "GitHubPackages"
            setUrl("https://maven.pkg.github.com/ShimmerEngineering/Shimmer-Java-Android-API")
            credentials {
                /* Create gradle.properties file in GRADLE_USER_HOME/.gradle/
                (e.g. C:/Users/YourUsername/.gradle/) with the two lines listed below. Fill in your
                Github ID and personal access token - as generated through the Github Developer
                Settings page. The token needs to have "read:packages" scope enabled on it:
                    gpr.usr=GITHUB_USER_ID
                    gpr.key=PERSONAL_ACCESS_TOKEN
                */
                username = project.findProperty("gpr.usr") as? String ?: System.getenv("USERNAME")
                password = project.findProperty("gpr.key") as? String ?: System.getenv("TOKEN")
                /* should the above not work key in your username and password directly e.g.
                  username = "username"
                  password = "password"
                DO NOT commit your username and password
                */
            }
        }
        maven {
            //name = "GitHubPackages"
            setUrl("https://maven.pkg.github.com/ShimmerEngineering/ShimmerAndroidAPI")
            credentials {
                /* Create gradle.properties file in GRADLE_USER_HOME/.gradle/
                (e.g. C:/Users/YourUsername/.gradle/) with the two lines listed below. Fill in your
                Github ID and personal access token - as generated through the Github Developer
                Settings page. The token needs to have "read:packages" scope enabled on it:
                    gpr.usr=GITHUB_USER_ID
                    gpr.key=PERSONAL_ACCESS_TOKEN
                */
                username = project.findProperty("gpr.usr") as? String ?: System.getenv("USERNAME")
                password = project.findProperty("gpr.key") as? String ?: System.getenv("TOKEN")
                /* should the above not work key in your username and password directly e.g.
                  username = "username"
                  password = "password"
                DO NOT commit your username and password
                */
            }
        }
    }
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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}


