plugins {
    id("com.android.application")
    id("kotlin-android")
    // Plugin của Flutter
    id("dev.flutter.flutter-gradle-plugin")
    // THÊM DÒNG NÀY: Để kết nối Firebase
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.flutter_app_1771020412"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // ID ứng dụng của bạn
        applicationId = "com.example.flutter_app_1771020412"
        
        // THAY ĐỔI QUAN TRỌNG: Sửa minSdk thành 21 để chạy được Firestore
        minSdk = flutter.minSdkVersion 
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Cấu hình ký số cho bản release (dùng tạm debug key)
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
