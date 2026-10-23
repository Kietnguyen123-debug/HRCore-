allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 1. Thiết lập thư mục build chuẩn của Flutter (ngoài thư mục android)
val rootBuildDir = rootProject.projectDir.parentFile.resolve("build")
rootProject.layout.buildDirectory.set(rootBuildDir)

subprojects {
    // Trỏ thư mục build của từng subproject (app, plugins) vào thư mục build gốc
    project.layout.buildDirectory.set(rootBuildDir.resolve(project.name))

    // 2. Cấu hình SDK và tương thích ngược bên trong block subprojects duy nhất
    afterEvaluate {
        if (project.hasProperty("android")) {
            val android = project.extensions.getByName("android")
            if (android is com.android.build.gradle.BaseExtension) {
                // Tối ưu hóa cho Android 16 (SDK 36)
                android.compileSdkVersion(36)
                // Đảm bảo minSdk luôn là 24 (Android 7.0) cho mọi module
                val minSdk = android.defaultConfig.minSdk
                if (minSdk != null && minSdk > 24) {
                    android.defaultConfig.minSdk = 24
                }
            }
        }
    }
}

// 3. Lệnh này phải nằm cuối cùng để không gây lỗi "already evaluated"
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
