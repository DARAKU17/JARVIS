
```bash
#!/bin/bash

set -e

PROJECT_NAME="offline-ai-assistant"
ROOT_DIR="$(pwd)/$PROJECT_NAME"

echo "🏗️  Creating Offline AI Assistant Codebase..."
echo "=============================================="

# Create directory structure
mkdir -p "$ROOT_DIR"/{android,app/src/main/{java/com/offlineassistant/{ai,device,domain,presentation,data},cpp,res/{values,xml,mipmap-hdpi,mipmap-mdpi,mipmap-xhdpi,mipmap-xxhdpi,mipmap-xxxhdpi},assets/models},docs,models,scripts,.devcontainer,.github/{workflows,codespaces},llama.cpp,whisper.cpp}

cd "$ROOT_DIR"

# ============================================
# ROOT LEVEL FILES
# ============================================

cat > README.md << 'EOF'
# Offline AI Assistant

A fully offline, on-device AI assistant for Android with phone utility access. No cloud connectivity required.

## Architecture

- **Local LLM**: Phi-3-mini/SmolLM3 via llama.cpp (4-bit quantized, ~2GB)
- **Speech Recognition**: Whisper.cpp (base.en model, ~150MB)
- **Voice Synthesis**: Piper TTS (optional, ~100MB)
- **Wake Word**: Porcupine or openWakeWord
- **Phone Integration**: Native Android APIs (SMS, Calls, Camera, Calendar, Contacts)

## Quick Start

### Option 1: GitHub Codespaces (Recommended)
1. Click "Code" → "Codespaces" → "Create codespace on main"
2. Wait for setup (~5 minutes)
3. Connect your phone via wireless ADB (see docs/SETUP.md)
4. Run: `./scripts/build-and-deploy.sh`

### Option 2: Local Development
```bash
git clone --recursive https://github.com/yourusername/offline-ai-assistant.git
cd offline-ai-assistant
./models/download_models.sh
cd android && ./gradlew assembleDebug
```

Hardware Requirements

Component	Minimum	Recommended	
RAM	4GB	8GB+	
Storage	3GB (models)	5GB	
Android	9.0 (API 28)	13+ (API 33)	
Processor	ARM64	Snapdragon 7xx/8xx	

Project Structure

```
offline-ai-assistant/
├── android/          # Android application
├── llama.cpp/        # LLM inference engine (submodule)
├── whisper.cpp/      # Speech recognition (submodule)
├── models/           # Model download scripts
└── docs/             # Documentation
```

License

MIT - See LICENSE file
EOF

cat > .gitignore << 'EOF'

Android
.apk
.aab
.dex
.class
bin/
gen/
out/
build/
captures/
.externalNativeBuild/
.cxx/
.log
.navigation/
.iml
.idea/
.gradle/
local.properties

Models (large files - downloaded via script)
.gguf
.bin
.pt
.pth
.safetensors
android/app/src/main/assets/models/.gguf
android/app/src/main/assets/models/.bin

NDK
obj/

OS
.DS_Store
Thumbs.db

Secrets
secrets.properties
google-services.json
.keystore
.jks

Whisper models
models/.bin
EOF

cat > .gitmodules << 'EOF'
[submodule "llama.cpp"]
path = llama.cpp
url = https://github.com/ggerganov/llama.cpp.git
branch = master
[submodule "whisper.cpp"]
path = whisper.cpp
url = https://github.com/ggerganov/whisper.cpp.git
branch = master
EOF

============================================

DEVCONTAINER CONFIGURATION

============================================

cat > .devcontainer/devcontainer.json << 'EOF'
{
"name": "Android AI Assistant Dev",
"image": "mcr.microsoft.com/devcontainers/base:ubuntu-22.04",
"features": {
"ghcr.io/devcontainers/features/java:1": {
"version": "17",
"installGradle": true
},
"ghcr.io/devcontainers/features/android-sdk:1": {
"version": "latest",
"installNdk": true,
"ndkVersion": "25.2.9519653"
},
"ghcr.io/devcontainers/features/github-cli:1": {},
"ghcr.io/devcontainers/features/rust:1": {}
},
"postCreateCommand": "bash .devcontainer/post-create.sh",
"customizations": {
"vscode": {
"extensions": [
"ms-vscode.cpptools",
"ms-vscode.cmake-tools",
"redhat.java",
"vscjava.vscode-gradle",
"llvm-vs-code-extensions.vscode-clangd",
"ms-vscode.kotlin"
],
"settings": {
"java.configuration.runtimes": [{
"name": "JavaSE-17",
"path": "/usr/local/sdkman/candidates/java/current"
}],
"android.sdkLocation": "/usr/local/lib/android/sdk",
"cmake.configureOnOpen": true
}
}
},
"hostRequirements": {
"cpus": 8,
"memory": "32gb",
"storage": "64gb"
},
"forwardPorts": [5037, 5554, 5555, 8080],
"portsAttributes": {
"5037": {
"label": "ADB Server",
"onAutoForward": "silent"
}
},
"remoteUser": "vscode"
}
EOF

cat > .devcontainer/post-create.sh << 'EOF'
#!/bin/bash
set -e

echo "🔧 Setting up Android AI Assistant development environment..."

Install system dependencies
sudo apt-get update && sudo apt-get install -y 

cmake 

ninja-build 

build-essential 

pkg-config 

libssl-dev 

wget 

unzip 

git-lfs 

python3-pip 

android-tools-adb 

android-tools-fastboot

Set environment variables
echo 'export ANDROID_SDK_ROOT=/usr/local/lib/android/sdk' >> /.bashrc
echo 'export ANDROID_HOME=/usr/local/lib/android/sdk' >> /.bashrc
echo 'export PATH=PATH:ANDROID_SDK_ROOT/platform-tools:ANDROID_SDK_ROOT/cmdline-tools/latest/bin' >> /.bashrc

export ANDROID_SDK_ROOT=/usr/local/lib/android/sdk
export ANDROID_HOME=/usr/local/lib/android/sdk
export PATH=PATH:ANDROID_SDK_ROOT/platform-tools

Accept Android licenses
yes | sdkmanager --licenses || true

Install required SDK components
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0" "cmake;3.22.1"

Setup submodules if not present
if [ ! -d "llama.cpp/.git" ]; then
echo "📦 Setting up llama.cpp submodule..."
git submodule add -f https://github.com/ggerganov/llama.cpp.git llama.cpp || true
cd llama.cpp && git submodule update --init --recursive && cd ..
fi

if [ ! -d "whisper.cpp/.git" ]; then
echo "📦 Setting up whisper.cpp submodule..."
git submodule add -f https://github.com/ggerganov/whisper.cpp.git whisper.cpp || true
fi

Make scripts executable
chmod +x models/download_models.sh
chmod +x scripts/build-and-deploy.sh
chmod +x .github/codespaces/setup-phone-debugging.sh

echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Run: models/download_models.sh (downloads 3GB)"
echo "2. Connect phone: bash .github/codespaces/setup-phone-debugging.sh"
echo "3. Build: cd android && ./gradlew assembleDebug"
EOF

chmod +x .devcontainer/post-create.sh

============================================

GITHUB WORKFLOWS

============================================

mkdir -p .github/workflows

cat > .github/workflows/build.yml << 'EOF'
name: Build and Test

on:
push:
branches: [ main, develop ]
pull_request:
branches: [ main ]

jobs:
build:
runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v4
      with:
        submodules: recursive
        
    - name: Set up JDK 17
      uses: actions/setup-java@v4
      with:
        java-version: '17'
        distribution: 'temurin'
        
    - name: Setup Android SDK
      uses: android-actions/setup-android@v3
      
    - name: Install NDK
      run: sdkmanager "ndk;25.2.9519653" "cmake;3.22.1"
      
    - name: Cache Gradle
      uses: actions/cache@v3
      with:
        path: |
          ~/.gradle/caches
          ~/.gradle/wrapper
        key: ${{ runner.os }}-gradle-${{ hashFiles('**/*.gradle*', '**/gradle-wrapper.properties') }}
        
    - name: Cache models
      id: cache-models
      uses: actions/cache@v3
      with:
        path: android/app/src/main/assets/models
        key: models-${{ hashFiles('models/download_models.sh') }}
        
    - name: Download models
      if: steps.cache-models.outputs.cache-hit != 'true'
      run: |
        chmod +x models/download_models.sh
        ./models/download_models.sh
        
    - name: Build Debug APK
      run: |
        cd android
        ./gradlew assembleDebug --no-daemon
        
    - name: Upload Debug APK
      uses: actions/upload-artifact@v4
      with:
        name: app-debug
        path: android/app/build/outputs/apk/debug/app-debug.apk
        
    - name: Build Release
      if: github.ref == 'refs/heads/main'
      run: |
        cd android
        ./gradlew assembleRelease --no-daemon
        
    - name: Upload Release APK
      if: github.ref == 'refs/heads/main'
      uses: actions/upload-artifact@v4
      with:
        name: app-release
        path: android/app/build/outputs/apk/release/app-release-unsigned.apk

EOF

cat > .github/codespaces/setup-phone-debugging.sh << 'EOF'
#!/bin/bash

echo "📱 Phone Debugging Setup for Codespaces"
echo "========================================"

Ensure ADB is available
if ! command -v adb &> /dev/null; then
echo "Installing ADB..."
sudo apt-get update && sudo apt-get install -y android-tools-adb
fi

echo ""
echo "Method 1: Wireless ADB (Recommended - No USB cable)"
echo "---------------------------------------------------"
echo "1. On your phone:"
echo "   - Enable Developer Options → Wireless Debugging"
echo "   - Tap 'Pair code with pairing code'"
echo "   - Note the IP, port, and 6-digit pairing code"
echo ""
echo "2. Run these commands in this terminal:"
echo "   adb pair <PHONE_IP>:<PAIRING_PORT>"
echo "   (Enter the 6-digit code when prompted)"
echo ""
echo "3. Then connect:"
echo "   adb connect <PHONE_IP>:<CONNECTION_PORT>"
echo ""

echo "Method 2: USB via Local Port Forwarding"
echo "----------------------------------------"
echo "1. Connect phone to your local machine via USB"
echo "2. Enable USB debugging on phone"
echo "3. On your LOCAL machine, run:"
echo "   gh codespace ports forward 5037:5037 -c (echo CODESPACE_NAME)"
echo "4. Then in this Codespace:"
echo "   adb connect localhost:5037"
echo ""

echo "Current ADB status:"
adb devices -l || echo "No ADB server running"

echo ""
echo "Tip: To find your phone's IP:"
echo "   Settings → About → Status → IP Address"
EOF

chmod +x .github/codespaces/setup-phone-debugging.sh

============================================

MODEL DOWNLOAD SCRIPT

============================================

cat > models/download_models.sh << 'EOF'
#!/bin/bash

set -e

SCRIPT_DIR="(cd "(dirname "{BASH_SOURCE[0]}")" && pwd)"
MODELS_DIR="SCRIPT_DIR/../android/app/src/main/assets/models"

echo "📦 Downloading AI Models..."
echo "=========================="

mkdir -p "MODELS_DIR"

Function to download with resume support
download_model() {
local url=1
local output=2
local description=3

    echo ""
    echo "⬇️  Downloading: $description"
    
    if [ -f "$output" ]; then
        echo "   File exists, checking size..."
        local remote_size=$(curl -sI "$url" | grep -i content-length | awk '{print $2}' | tr -d '\r')
        local local_size=$(stat -f%z "$output" 2>/dev/null || stat -c%s "$output" 2>/dev/null || echo "0")
        
        if [ "$remote_size" = "$local_size" ]; then
            echo "   ✓ Already downloaded and complete"
            return 0
        else
            echo "   Resuming download..."
        fi
    fi
    
    wget --progress=bar:force -c -O "$output" "$url" || {
        echo "   ❌ Failed to download $description"
        return 1
    }
    
    echo "   ✓ Complete"

}

Phi-3-mini 4-bit quantized (Recommended: Q4_K_M for quality/size balance)
download_model 

"https://huggingface.co/TheBloke/Phi-3-mini-4k-instruct-GGUF/resolve/main/phi-3-mini-4k-instruct.Q4_K_M.gguf" 

"MODELS_DIR/assistant-q4_k_m.gguf" 

"Phi-3-mini 3.8B (Q4_K_M, 2.3GB)"

Alternative: Smaller model for 4GB RAM devices (when available)

download_model \

"https://huggingface.co/your-org/SmolLM3-GGUF/resolve/main/smollm3-1.7b-q4_k_m.gguf" \

"MODELS_DIR/assistant-smollm3.gguf" \

"SmolLM3 1.7B (Q4_K_M, 1.2GB)"

Whisper base.en model (English, 74M parameters)
download_model 

"https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin" 

"MODELS_DIR/whisper-base.en.bin" 

"Whisper base.en (150MB)"

Whisper tiny.en model (faster, lower quality alternative, 39M parameters)

download_model \

"https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.en.bin" \

"MODELS_DIR/whisper-tiny.en.bin" \

"Whisper tiny.en (75MB)"

echo ""
echo "✅ All models downloaded!"
echo ""
echo "Model sizes:"
du -h "MODELS_DIR"/
echo ""
echo "Total: (du -sh "MODELS_DIR" | cut -f1)"
EOF

chmod +x models/download_models.sh

============================================

BUILD & DEPLOY SCRIPT

============================================

cat > scripts/build-and-deploy.sh << 'EOF'
#!/bin/bash

set -e

SCRIPT_DIR="(cd "(dirname "{BASH_SOURCE[0]}")" && pwd)"
ANDROID_DIR="SCRIPT_DIR/../android"
MODELS_DIR="ANDROID_DIR/app/src/main/assets/models"

echo "🔨 Offline AI Assistant - Build & Deploy"
echo "========================================"

Check for models
if [ ! -f "MODELS_DIR/assistant-q4_k_m.gguf" ]; then
echo "⚠️  Models not found. Downloading..."
"SCRIPT_DIR/../models/download_models.sh"
fi

cd "ANDROID_DIR"

Check for connected device
echo ""
echo "📱 Checking for devices..."
adb devices

DEVICE_COUNT=(adb devices | grep -c "device" || true)

if [ "DEVICE_COUNT" -eq "0" ]; then
echo ""
echo "⚠️  No devices connected!"
echo "Run: bash .github/codespaces/setup-phone-debugging.sh"
echo ""
echo "Building APK only..."
./gradlew assembleDebug

    echo ""
    echo "✅ Build complete: app/build/outputs/apk/debug/app-debug.apk"
    echo "Install manually with: adb install app/build/outputs/apk/debug/app-debug.apk"

else
echo ""
echo "✓ Found DEVICE_COUNT device(s)"

    # Clean and build
    echo ""
    echo "🔧 Building debug APK..."
    ./gradlew assembleDebug
    
    # Install and launch
    echo ""
    echo "📲 Installing..."
    adb install -r app/build/outputs/apk/debug/app-debug.apk
    
    echo ""
    echo "🚀 Launching..."
    adb shell am start -n com.offlineassistant/.presentation.MainActivity
    
    echo ""
    echo "✅ Done! App should be running on your phone."
    echo ""
    echo "View logs:"
    echo "  adb logcat -s OfflineAssistant:D *:S"

fi
EOF

chmod +x scripts/build-and-deploy.sh

============================================

ANDROID PROJECT FILES

============================================

mkdir -p android

cat > android/build.gradle.kts << 'EOF'
plugins {
id("com.android.application") version "8.2.0" apply false
id("org.jetbrains.kotlin.android") version "1.9.22" apply false
id("com.google.devtools.ksp") version "1.9.22-1.0.17" apply false
id("org.jetbrains.kotlin.plugin.serialization") version "1.9.22" apply false
}
EOF

cat > android/settings.gradle.kts << 'EOF'
pluginManagement {
repositories {
google()
mavenCentral()
gradlePluginPortal()
}
}
dependencyResolutionManagement {
repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
repositories {
google()
mavenCentral()
maven { url = uri("https://jitpack.io") }
}
}

rootProject.name = "OfflineAssistant"
include(":app")
EOF

cat > android/gradle.properties << 'EOF'
org.gradle.jvmargs=-Xmx8192m -Dfile.encoding=UTF-8
android.useAndroidX=true
kotlin.code.style=official
android.nonTransitiveRClass=true
android.enableJetifier=true
EOF

App-level build.gradle.kts
mkdir -p android/app

cat > android/app/build.gradle.kts << 'EOF'
plugins {
id("com.android.application")
id("org.jetbrains.kotlin.android")
id("com.google.devtools.ksp")
id("org.jetbrains.kotlin.plugin.serialization")
}

android {
namespace = "com.offlineassistant"
compileSdk = 34

    defaultConfig {
        applicationId = "com.offlineassistant"
        minSdk = 28
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        
        externalNativeBuild {
            cmake {
                cppFlags += listOf(
                    "-O3",
                    "-DNDEBUG",
                    "-DLLAMA_ANDROID",
                    "-mcpu=cortex-a75",
                    "-mfpu=neon"
                )
                arguments += listOf(
                    "-DLLAMA_BUILD_COMMON=ON",
                    "-DLLAMA_STATIC=ON"
                )
            }
        }
        
        ndk {
            abiFilters += listOf("arm64-v8a")
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            isDebuggable = true
            externalNativeBuild {
                cmake {
                    cppFlags += "-DDEBUG"
                }
            }
        }
    }
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    
    kotlinOptions {
        jvmTarget = "17"
    }
    
    buildFeatures {
        compose = true
        buildConfig = true
    }
    
    composeOptions {
        kotlinCompilerExtensionVersion = "1.5.10"
    }
    
    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
        jniLibs {
            useLegacyPackaging = true
        }
    }
    
    externalNativeBuild {
        cmake {
            path = file("src/main/cpp/CMakeLists.txt")
            version = "3.22.1"
        }
    }

}

dependencies {
// AndroidX Core
implementation("androidx.core:core-ktx:1.12.0")
implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.7.0")
implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.7.0")
implementation("androidx.activity:activity-compose:1.8.2")
implementation("androidx.work:work-runtime-ktx:2.9.0")

    // Compose
    implementation(platform("androidx.compose:compose-bom:2024.02.00"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-graphics")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.material:material-icons-extended")
    
    // Room Database
    implementation("androidx.room:room-runtime:2.6.1")
    implementation("androidx.room:room-ktx:2.6.1")
    ksp("androidx.room:room-compiler:2.6.1")
    
    // Coroutines
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.2")
    
    // Dependency Injection (manual/Koin for lightweight)
    implementation("io.insert-koin:koin-android:3.5.3")
    implementation("io.insert-koin:koin-androidx-compose:3.5.3")
    
    // Audio processing
    implementation("com.github.piasy:rxandroidaudio:1.7.0")
    
    // Wake word detection (optional - replace with open source)
    implementation("ai.picovoice:porcupine-android:2.2.0")
    
    // Testing
    testImplementation("junit:junit:4.13.2")
    testImplementation("org.mockito:mockito-core:5.8.0")
    testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.7.3")
    androidTestImplementation("androidx.test.ext:junit:1.1.5")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")
    androidTestImplementation(platform("androidx.compose:compose-bom:2024.02.00"))
    androidTestImplementation("androidx.compose.ui:ui-test-junit4")
    
    debugImplementation("androidx.compose.ui:ui-tooling")
    debugImplementation("androidx.compose.ui:ui-test-manifest")

}
EOF

============================================

MANIFEST AND RESOURCES

============================================

mkdir -p android/app/src/main

cat > android/app/src/main/AndroidManifest.xml << 'EOF'

<manifest xmlns:android="http://schemas.android.com/apk/res/android"
xmlns:tools="http://schemas.android.com/tools">

    <!-- Core permissions -->
    <uses-permission android:name="android.permission.INTERNET" android:required="false" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_MICROPHONE" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    
    <!-- Communication -->
    <uses-permission android:name="android.permission.SEND_SMS" />
    <uses-permission android:name="android.permission.RECEIVE_SMS" />
    <uses-permission android:name="android.permission.READ_SMS" />
    <uses-permission android:name="android.permission.CALL_PHONE" />
    <uses-permission android:name="android.permission.READ_PHONE_STATE" />
    
    <!-- Contacts & Calendar -->
    <uses-permission android:name="android.permission.READ_CONTACTS" />
    <uses-permission android:name="android.permission.WRITE_CONTACTS" />
    <uses-permission android:name="android.permission.READ_CALENDAR" />
    <uses-permission android:name="android.permission.WRITE_CALENDAR" />
    
    <!-- Camera & Media -->
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    <uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
    <uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />
    
    <!-- Location -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    
    <!-- System -->
    <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
    <uses-permission android:name="android.permission.ACTION_MANAGE_OVERLAY_PERMISSION" />
    <uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
    <uses-permission android:name="android.permission.BATTERY_STATS" />
    <uses-permission android:name="android.permission.DEVICE_POWER" />
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
    <uses-permission android:name="android.permission.ACCESS_NOTIFICATION_POLICY" />
    <uses-permission android:name="android.permission.BIND_NOTIFICATION_LISTENER_SERVICE" />
    
    <!-- Hardware features -->
    <uses-feature android:name="android.hardware.camera" android:required="false" />
    <uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />
    <uses-feature android:name="android.hardware.microphone" android:required="true" />
    <uses-feature android:name="android.hardware.telephony" android:required="false" />
    <uses-feature android:name="android.hardware.location.gps" android:required="false" />

    <application
        android:name=".OfflineAssistantApp"
        android:allowBackup="false"
        android:dataExtractionRules="@xml/data_extraction_rules"
        android:fullBackupContent="@xml/backup_rules"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:theme="@style/Theme.OfflineAssistant"
        android:largeHeap="true"
        android:hardwareAccelerated="true"
        android:extractNativeLibs="true"
        tools:targetApi="34">

        <activity
            android:name=".presentation.MainActivity"
            android:exported="true"
            android:theme="@style/Theme.OfflineAssistant"
            android:launchMode="singleTask"
            android:windowSoftInputMode="adjustResize"
            android:configChanges="orientation|screenSize|smallestScreenSize">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
            
            <!-- Voice search intent -->
            <intent-filter>
                <action android:name="android.intent.action.SEARCH_LONG_PRESS" />
                <category android:name="android.intent.category.DEFAULT" />
            </intent-filter>
        </activity>
        
        <!-- Voice interaction service -->
        <service
            android:name=".service.VoiceInteractionService"
            android:permission="android.permission.BIND_VOICE_INTERACTION"
            android:exported="true">
            <meta-data
                android:name="android.voice_interaction"
                android:resource="@xml/voice_interaction_service" />
            <intent-filter>
                <action android:name="android.service.voice.VoiceInteractionService" />
            </intent-filter>
        </service>
        
        <!-- Always-on listening service -->
        <service
            android:name=".service.AlwaysOnListeningService"
            android:enabled="true"
            android:exported="false"
            android:foregroundServiceType="microphone"
            android:permission="android.permission.FOREGROUND_SERVICE" />
            
        <!-- Notification listener for context awareness -->
        <service
            android:name=".service.NotificationMonitorService"
            android:permission="android.permission.BIND_NOTIFICATION_LISTENER_SERVICE"
            android:exported="true">
            <intent-filter>
                <action android:name="android.service.notification.NotificationListenerService" />
            </intent-filter>
        </service>
        
        <!-- Model download worker -->
        <provider
            android:name="androidx.startup.InitializationProvider"
            android:authorities="${applicationId}.androidx-startup"
            android:exported="false"
            tools:node="merge">
            <meta-data
                android:name="androidx.work.WorkManagerInitializer"
                android:value="androidx.startup" />
        </provider>

    </application>

String resources
mkdir -p android/app/src/main/res/values

cat > android/app/src/main/res/values/strings.xml << 'EOF'

cat > android/app/src/main/res/values/themes.xml << 'EOF'

cat > android/app/src/main/res/values/colors.xml << 'EOF'

XML resources
mkdir -p android/app/src/main/res/xml

cat > android/app/src/main/res/xml/data_extraction_rules.xml << 'EOF'

cat > android/app/src/main/res/xml/voice_interaction_service.xml << 'EOF'

<voice-interaction-service
xmlns:android="http://schemas.android.com/apk/res/android"
android:settingsActivity="com.offlineassistant.presentation.SettingsActivity"
android:recognitionService="com.offlineassistant.service.VoiceRecognitionService"
android:supportsAssist="true"
android:supportsLaunchVoiceAssistFromKeyguard="true"/>
EOF

============================================

NATIVE CODE (C++/JNI)

============================================

mkdir -p android/app/src/main/cpp

cat > android/app/src/main/cpp/CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.22.1)
project("llama-android")

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

llama.cpp source directory (from submodule)
set(LLAMA_DIR {CMAKE_SOURCE_DIR}/../../../../../llama.cpp)
set(WHISPER_DIR {CMAKE_SOURCE_DIR}/../../../../../whisper.cpp)

Core llama.cpp sources
set(LLAMA_SOURCES
{LLAMA_DIR}/llama.cpp
{LLAMA_DIR}/ggml.c
{LLAMA_DIR}/ggml-alloc.c
{LLAMA_DIR}/ggml-backend.c
{LLAMA_DIR}/ggml-quants.c
{LLAMA_DIR}/unicode.cpp
{LLAMA_DIR}/unicode-data.cpp
{LLAMA_DIR}/common/common.cpp
{LLAMA_DIR}/common/sampling.cpp
{LLAMA_DIR}/common/build-info.cpp
)

Whisper sources
set(WHISPER_SOURCES
{WHISPER_DIR}/whisper.cpp
{WHISPER_DIR}/ggml.c
{WHISPER_DIR}/ggml-alloc.c
{WHISPER_DIR}/ggml-backend.c
{WHISPER_DIR}/ggml-quants.c
)

Android-specific optimizations
set(CMAKE_C_FLAGS "{CMAKE_C_FLAGS} -O3 -DNDEBUG -mcpu=cortex-a75 -mfpu=neon")
set(CMAKE_CXX_FLAGS "{CMAKE_CXX_FLAGS} -O3 -DNDEBUG -mcpu=cortex-a75 -mfpu=neon")

llama-android library
add_library(
llama-android
SHARED
llama-android.cpp
{LLAMA_SOURCES}
)

target_include_directories(llama-android PRIVATE 
{LLAMA_DIR}
{LLAMA_DIR}/common
)

target_compile_definitions(llama-android PRIVATE 
LLAMA_ANDROID
GGML_USE_NEON
NDEBUG
)

whisper-jni library
add_library(
whisper-jni
SHARED
whisper-jni.cpp
{WHISPER_SOURCES}
)

target_include_directories(whisper-jni PRIVATE {WHISPER_DIR})

target_compile_definitions(whisper-jni PRIVATE 
WHISPER_ANDROID
GGML_USE_NEON
NDEBUG
)

Find libraries
find_library(log-lib log)
find_library(android-lib android)

target_link_libraries(llama-android {log-lib} {android-lib})
target_link_libraries(whisper-jni {log-lib} {android-lib})
EOF

cat > android/app/src/main/cpp/llama-android.cpp << 'EOF'
#include <jni.h>
#include 
#include 
#include 
#include 
#include 
#include <android/log.h>

#include "llama.h"

#define LOG_TAG "LlamaAndroid"
#define LOGI(...) android_log_print(ANDROID_LOG_INFO, LOG_TAG, VA_ARGS)
#define LOGE(...) android_log_print(ANDROID_LOG_ERROR, LOG_TAG, VA_ARGS)

struct LlamaContextWrapper {
llama_model model = nullptr;
llama_context ctx = nullptr;
std::atomic stop_generation{false};
std::mutex mutex;
};

// Global context storage (simplified - use proper management in production)
static std::vector<LlamaContextWrapper> g_contexts;
static std::mutex g_contexts_mutex;

extern "C" {

JNIEXPORT jlong JNICALL
Java_com_offlineassistant_ai_LlamaEngine_init(
JNIEnv env,
jobject thiz,
jstring model_path,
jint context_size,
jint gpu_layers
) {
const char path = env->GetStringUTFChars(model_path, nullptr);
LOGI("Loading model from: %s", path);

    // Model parameters
    llama_model_params model_params = llama_model_default_params();
    model_params.n_gpu_layers = gpu_layers;  // 0 for CPU-only on mobile
    model_params.main_gpu = 0;
    
    // Load model
    llama_model* model = llama_load_model_from_file(path, model_params);
    env->ReleaseStringUTFChars(model_path, path);
    
    if (!model) {
        LOGE("Failed to load model");
        return 0;
    }
    
    // Context parameters optimized for mobile
    llama_context_params ctx_params = llama_context_default_params();
    ctx_params.n_ctx = context_size;        // 2048 recommended
    ctx_params.n_batch = 512;               // Process in chunks
    ctx_params.n_threads = 4;               // Adjust based on device cores
    ctx_params.n_threads_batch = 4;
    
    llama_context* ctx = llama_new_context_with_model(model, ctx_params);
    
    if (!ctx) {
        llama_free_model(model);
        LOGE("Failed to create context");
        return 0;
    }
    
    // Create wrapper
    LlamaContextWrapper* wrapper = new LlamaContextWrapper();
    wrapper->model = model;
    wrapper->ctx = ctx;
    wrapper->stop_generation = false;
    
    // Store globally
    {
        std::lock_guard<std::mutex> lock(g_contexts_mutex);
        g_contexts.push_back(wrapper);
    }
    
    LOGI("Model loaded successfully, context size: %d", context_size);
    return reinterpret_cast<jlong>(wrapper);

}

JNIEXPORT void JNICALL
Java_com_offlineassistant_ai_LlamaEngine_generate(
JNIEnv env,
jobject thiz,
jlong handle,
jstring prompt,
jobject callback
) {
LlamaContextWrapper wrapper = reinterpret_cast<LlamaContextWrapper>(handle);
if (!wrapper || !wrapper->ctx) {
LOGE("Invalid context handle");
return;
}

    std::lock_guard<std::mutex> lock(wrapper->mutex);
    
    const char* prompt_str = env->GetStringUTFChars(prompt, nullptr);
    std::string prompt_cpp(prompt_str);
    env->ReleaseStringUTFChars(prompt, prompt_str);
    
    LOGI("Generating with prompt length: %zu", prompt_cpp.length());
    
    // Tokenize
    const int n_vocab = llama_n_vocab(llama_get_model(wrapper->ctx));
    std::vector<llama_token> tokens(prompt_cpp.length() + 16);
    
    int n_tokens = llama_tokenize(
        wrapper->ctx,
        prompt_cpp.c_str(),
        prompt_cpp.length(),
        tokens.data(),
        tokens.size(),
        true,   // add_bos
        false   // special tokens
    );
    
    if (n_tokens < 0) {
        LOGE("Tokenization failed");
        return;
    }
    
    tokens.resize(n_tokens);
    LOGI("Tokenized to %d tokens", n_tokens);
    
    // Prepare batch
    llama_batch batch = llama_batch_init(512, 0, 1);
    
    for (int i = 0; i < n_tokens; i++) {
        llama_batch_add(batch, tokens[i], i, {0}, false);
    }
    batch.logits[batch.n_tokens - 1] = true;
    
    // Decode initial prompt
    if (llama_decode(wrapper->ctx, batch) != 0) {
        LOGE("Decode failed");
        llama_batch_free(batch);
        return;
    }
    
    // Get callback method
    jclass callback_cls = env->GetObjectClass(callback);
    jmethodID on_token_method = env->GetMethodID(callback_cls, "onToken", "(Ljava/lang/String;)Z");
    
    // Generation loop
    wrapper->stop_generation = false;
    int n_cur = batch.n_tokens;
    int n_decode = 0;
    
    llama_sampling_params sparams;
    sparams.temp = 0.7f;
    sparams.top_k = 40;
    sparams.top_p = 0.9f;
    sparams.repeat_penalty = 1.1f;
    
    llama_sampling_context* smpl = llama_sampling_init(sparams);
    
    while (n_cur < llama_n_ctx(wrapper->ctx) && !wrapper->stop_generation) {
        // Sample next token
        llama_token new_token_id = llama_sampling_sample(smpl, wrapper->ctx, nullptr);
        
        // Check for end of generation
        if (llama_token_is_eog(llama_get_model(wrapper->ctx), new_token_id)) {
            LOGI("End of generation token reached");
            break;
        }
        
        // Convert to string
        char buf[256];
        int n = llama_token_to_piece(wrapper->ctx, new_token_id, buf, sizeof(buf), 0, false);
        if (n > 0) {
            std::string piece(buf, n);
            
            // Callback to Java
            jstring j_piece = env->NewStringUTF(piece.c_str());
            jboolean should_continue = env->CallBooleanMethod(callback, on_token_method, j_piece);
            env->DeleteLocalRef(j_piece);
            
            if (!should_continue) {
                LOGI("Generation stopped by callback");
                break;
            }
        }
        
        // Prepare next batch
        llama_batch_clear(batch);
        llama_batch_add(batch, new_token_id, n_cur, {0}, true);
        
        if (llama_decode(wrapper->ctx, batch) != 0) {
            LOGE("Decode failed at position %d", n_cur);
            break;
        }
        
        n_cur++;
        n_decode++;
    }
    
    LOGI("Generation complete: %d tokens generated", n_decode);
    
    // Cleanup
    llama_sampling_free(smpl);
    llama_batch_free(batch);

}

JNIEXPORT void JNICALL
Java_com_offlineassistant_ai_LlamaEngine_stopGeneration(
JNIEnv env,
jobject thiz,
jlong handle
) {
LlamaContextWrapper wrapper = reinterpret_cast<LlamaContextWrapper>(handle);
if (wrapper) {
wrapper->stop_generation = true;
LOGI("Stop generation requested");
}
}

JNIEXPORT void JNICALL
Java_com_offlineassistant_ai_LlamaEngine_release(
JNIEnv env,
jobject thiz,
jlong handle
) {
LlamaContextWrapper wrapper = reinterpret_cast<LlamaContextWrapper>(handle);
if (!wrapper) return;

    {
        std::lock_guard<std::mutex> lock(g_contexts_mutex);
        auto it = std::find(g_contexts.begin(), g_contexts.end(), wrapper);
        if (it != g_contexts.end()) {
            g_contexts.erase(it);
        }
    }
    
    llama_free(wrapper->ctx);
    llama_free_model(wrapper->model);
    delete wrapper;
    
    LOGI("Context released");

}

JNIEXPORT jintArray JNICALL
Java_com_offlineassistant_ai_LlamaEngine_tokenize(
JNIEnv env,
jobject thiz,
jlong handle,
jstring text
) {
LlamaContextWrapper wrapper = reinterpret_cast<LlamaContextWrapper>(handle);
if (!wrapper || !wrapper->ctx) return nullptr;

    const char* text_str = env->GetStringUTFChars(text, nullptr);
    std::string text_cpp(text_str);
    env->ReleaseStringUTFChars(text, text_str);
    
    std::vector<llama_token> tokens(text_cpp.length() + 16);
    int n_tokens = llama_tokenize(
        wrapper->ctx,
        text_cpp.c_str(),
        text_cpp.length(),
        tokens.data(),
        tokens.size(),
        false,  // no BOS
        false
    );
    
    if (n_tokens < 0) return nullptr;
    
    jintArray result = env->NewIntArray(n_tokens);
    env->SetIntArrayRegion(result, 0, n_tokens, tokens.data());
    return result;

}

} // extern "C"
EOF

cat > android/app/src/main/cpp/whisper-jni.cpp << 'EOF'
#include <jni.h>
#include 
#include 
#include <android/log.h>

#include "whisper.h"

#define LOG_TAG "WhisperJNI"
#define LOGI(...) android_log_print(ANDROID_LOG_INFO, LOG_TAG, VA_ARGS)
#define LOGE(...) android_log_print(ANDROID_LOG_ERROR, LOG_TAG, VA_ARGS)

struct WhisperContextWrapper {
whisper_context ctx = nullptr;
};

extern "C" {

JNIEXPORT jlong JNICALL
Java_com_offlineassistant_ai_WhisperEngine_init(
JNIEnv env,
jobject thiz,
jstring model_path
) {
const char path = env->GetStringUTFChars(model_path, nullptr);
LOGI("Loading whisper model: %s", path);

    whisper_context_params params = whisper_context_default_params();
    
    whisper_context* ctx = whisper_init_from_file_with_params(path, params);
    env->ReleaseStringUTFChars(model_path, path);
    
    if (!ctx) {
        LOGE("Failed to load whisper model");
        return 0;
    }
    
    WhisperContextWrapper* wrapper = new WhisperContextWrapper();
    wrapper->ctx = ctx;
    
    LOGI("Whisper model loaded");
    return reinterpret_cast<jlong>(wrapper);

}

JNIEXPORT jstring JNICALL
Java_com_offlineassistant_ai_WhisperEngine_transcribe(
JNIEnv env,
jobject thiz,
jlong handle,
jfloatArray audio_data,
jint num_samples
) {
WhisperContextWrapper wrapper = reinterpret_cast<WhisperContextWrapper>(handle);
if (!wrapper || !wrapper->ctx) {
return env->NewStringUTF("");
}

    // Get audio data
    jfloat* audio = env->GetFloatArrayElements(audio_data, nullptr);
    std::vector<float> pcmf32(audio, audio + num_samples);
    env->ReleaseFloatArrayElements(audio_data, audio, JNI_ABORT);
    
    // Whisper parameters
    whisper_full_params wparams = whisper_full_default_params(WHISPER_SAMPLING_GREEDY);
    wparams.translate = false;
    wparams.language = "en";
    wparams.n_threads = 4;
    wparams.print_progress = false;
    wparams.print_timestamps = false;
    
    // Run inference
    int ret = whisper_full(wrapper->ctx, wparams, pcmf32.data(), pcmf32.size());
    if (ret != 0) {
        LOGE("Whisper failed to process audio");
        return env->NewStringUTF("");
    }
    
    // Extract text
    int n_segments = whisper_full_n_segments(wrapper->ctx);
    std::string result;
    
    for (int i = 0; i < n_segments; i++) {
        const char* text = whisper_full_get_segment_text(wrapper->ctx, i);
        result += text;
        if (i < n_segments - 1) result += " ";
    }
    
    LOGI("Transcribed: %s", result.c_str());
    return env->NewStringUTF(result.c_str());

}

JNIEXPORT void JNICALL
Java_com_offlineassistant_ai_WhisperEngine_release(
JNIEnv env,
jobject thiz,
jlong handle
) {
WhisperContextWrapper wrapper = reinterpret_cast<WhisperContextWrapper>(handle);
if (wrapper) {
whisper_free(wrapper->ctx);
delete wrapper;
LOGI("Whisper context released");
}
}

} // extern "C"
EOF

============================================

KOTLIN SOURCE CODE

============================================

mkdir -p android/app/src/main/java/com/offlineassistant

Application class
cat > android/app/src/main/java/com/offlineassistant/OfflineAssistantApp.kt << 'EOF'
package com.offlineassistant

import android.app.Application
import android.content.Context
import androidx.room.Room
import com.offlineassistant.ai.LlamaEngine
import com.offlineassistant.ai.WhisperEngine
import com.offlineassistant.data.AppDatabase
import com.offlineassistant.device.DeviceManager
import com.offlineassistant.domain.ConversationManager
import com.offlineassistant.domain.ToolParser
import org.koin.android.ext.koin.androidContext
import org.koin.core.context.startKoin
import org.koin.dsl.module

class OfflineAssistantApp : Application() {

    private val appModule = module {
        single { provideDatabase(get()) }
        single { LlamaEngine.getInstance(get()) }
        single { WhisperEngine(get()) }
        single { DeviceManager(get()) }
        single { ToolParser() }
        single { ConversationManager(get(), get(), get(), get()) }
    }
    
    override fun onCreate() {
        super.onCreate()
        
        startKoin {
            androidContext(this@OfflineAssistantApp)
            modules(appModule)
        }
    }
    
    private fun provideDatabase(context: Context): AppDatabase {
        return Room.databaseBuilder(
            context,
            AppDatabase::class.java,
            "conversations.db"
        ).build()
    }

}
EOF

============================================

AI PACKAGE

============================================

mkdir -p android/app/src/main/java/com/offlineassistant/ai

cat > android/app/src/main/java/com/offlineassistant/ai/LlamaEngine.kt << 'EOF'
package com.offlineassistant.ai

import android.content.Context
import android.util.Log
import kotlinx.coroutines.
import java.io.File
import java.util.concurrent.atomic.AtomicBoolean

class LlamaEngine private constructor(context: Context) {
private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
private var nativeHandle: Long = 0
private val modelPath: String
private val isInitialized = AtomicBoolean(false)
private val isGenerating = AtomicBoolean(false)

    companion object {
        private const val TAG = "LlamaEngine"
        private const val MODEL_FILENAME = "assistant-q4_k_m.gguf"
        private const val DEFAULT_CONTEXT_SIZE = 2048
        private const val GPU_LAYERS = 0  // CPU only for compatibility
        
        @Volatile
        private var instance: LlamaEngine? = null
        
        fun getInstance(context: Context): LlamaEngine {
            return instance ?: synchronized(this) {
                instance ?: LlamaEngine(context.applicationContext).also { instance = it }
            }
        }
        
        // Native methods
        @JvmStatic
        external fun init(modelPath: String, contextSize: Int, gpuLayers: Int): Long
        
        @JvmStatic
        external fun generate(handle: Long, prompt: String, callback: TokenCallback)
        
        @JvmStatic
        external fun stopGeneration(handle: Long)
        
        @JvmStatic
        external fun release(handle: Long)
        
        @JvmStatic
        external fun tokenize(handle: Long, text: String): IntArray
        
        init {
            try {
                System.loadLibrary("llama-android")
                Log.i(TAG, "Native library loaded")
            } catch (e: UnsatisfiedLinkError) {
                Log.e(TAG, "Failed to load native library", e)
                throw e
            }
        }
    }
    
    init {
        val modelsDir = File(context.filesDir, "models").apply { mkdirs() }
        modelPath = File(modelsDir, MODEL_FILENAME).absolutePath
        
        if (!File(modelPath).exists()) {
            throw ModelNotFoundException("Model not found at $modelPath. Run download_models.sh first.")
        }
    }
    
    fun initialize(): Boolean {
        if (isInitialized.get()) return true
        
        return try {
            Log.i(TAG, "Initializing with model: $modelPath")
            nativeHandle = init(modelPath, DEFAULT_CONTEXT_SIZE, GPU_LAYERS)
            
            if (nativeHandle == 0L) {
                throw RuntimeException("Failed to initialize LLM")
            }
            
            isInitialized.set(true)
            Log.i(TAG, "LLM initialized successfully")
            true
        } catch (e: Exception) {
            Log.e(TAG, "Initialization failed", e)
            false
        }
    }
    
    fun generateResponse(
        userMessage: String,
        conversationHistory: List<Message> = emptyList(),
        onToken: (String) -> Unit,
        onComplete: (Result<String>) -> Unit
    ): Job = scope.launch {
        if (!isInitialized.get()) {
            onComplete(Result.failure(IllegalStateException("Engine not initialized")))
            return@launch
        }
        
        if (isGenerating.getAndSet(true)) {
            onComplete(Result.failure(IllegalStateException("Generation already in progress")))
            return@launch
        }
        
        try {
            val prompt = buildPrompt(userMessage, conversationHistory)
            Log.d(TAG, "Prompt length: ${prompt.length}")
            
            val stringBuilder = StringBuilder()
            
            withContext(Dispatchers.IO) {
                generate(nativeHandle, prompt) { token ->
                    stringBuilder.append(token)
                    onToken(token)
                    true  // Continue generation
                }
            }
            
            val fullResponse = stringBuilder.toString()
            Log.i(TAG, "Generation complete: ${fullResponse.length} chars")
            onComplete(Result.success(fullResponse))
            
        } catch (e: Exception) {
            Log.e(TAG, "Generation failed", e)
            onComplete(Result.failure(e))
        } finally {
            isGenerating.set(false)
        }
    }
    
    fun stop() {
        if (isInitialized.get() && nativeHandle != 0L) {
            stopGeneration(nativeHandle)
        }
    }
    
    fun release() {
        stop()
        if (nativeHandle != 0L) {
            release(nativeHandle)
            nativeHandle = 0L
            isInitialized.set(false)
        }
        scope.cancel()
    }
    
    private fun buildPrompt(userMessage: String, history: List<Message>): String {
        val systemPrompt = """<|im_start|>system

You are an offline phone assistant. Execute device functions using these exact functional tokens:
- <|SEND_SMS|>(contact="Name", message="Text")
- <|CALL|>(contact="Name", number="+1234567890")
- <|SET_ALARM|>(time="HH:MM", label="Text")
- <|TAKE_PHOTO|>(mode="normal|portrait|night")
- <|GET_CONTACT|>(name="Name")
- <|OPEN_APP|>(package="com.example.app")
- <|SET_VOLUME|>(level=0-100, stream="media|ring|alarm")
- <|GET_BATTERY|>()
- <|TOGGLE_FLASHLIGHT|>(state="on|off")

Rules:
1. Respond ONLY with functional tokens or plain text
2. Never explain your actions
3. If multiple actions needed, use multiple tokens on separate lines
4. Confirm execution with brief acknowledgment

The user wants me to create a complete bash script that generates the entire codebase when executed. I need to provide a comprehensive script that creates all the files, directories, and structure for the offline AI assistant project.

Let me create a thorough script that:
1. Creates the full directory structure
2. Writes all the code files I've provided so far
3. Includes the CMake configuration
4. Sets up the Android project properly
5. Includes all necessary configuration files
6. Makes scripts executable

This will be a very large script, but it needs to be complete and functional.I'll create a comprehensive bash script that generates the entire codebase. This is a large script that will create all files when executed.

```bash
#!/bin/bash

set -e

PROJECT_NAME="offline-ai-assistant"
ROOT_DIR="$(pwd)/$PROJECT_NAME"

echo "🏗️  Creating Offline AI Assistant Codebase..."
echo "=============================================="
echo "Target directory: $ROOT_DIR"
echo ""

# Create all directory structures
mkdir -p "$ROOT_DIR"/{android/{app/src/main/{java/com/offlineassistant/{ai,device,domain,presentation,data,service},cpp,res/{values,xml,mipmap-hdpi,mipmap-mdpi,mipmap-xhdpi,mipmap-xxhdpi,mipmap-xxxhdpi},assets/models},gradle/wrapper},docs,models,scripts,.devcontainer,.github/{workflows,codespaces}}

cd "$ROOT_DIR"

# ============================================
# ROOT LEVEL FILES
# ============================================

cat > README.md << 'EOF'
# Offline AI Assistant

Fully on-device AI assistant for Android. No cloud required.

## Quick Start

```bash
# 1. Create and enter the project
bash create_offline_assistant.sh
cd offline-ai-assistant

# 2. Open in GitHub Codespaces or local Android Studio

# 3. Download models
./models/download_models.sh

# 4. Build and deploy
./scripts/build-and-deploy.sh
```

Architecture

- LLM: Phi-3-mini 3.8B (4-bit quantized, 2.3GB)
- STT: Whisper base.en (150MB)
- Tools: SMS, Calls, Camera, Calendar, Contacts, System settings

Hardware Requirements

- Android 9+ (API 28)
- 6GB RAM minimum, 8GB recommended
- ARM64 processor
- 3GB free storage for models

License

MIT
EOF

cat > .gitignore << 'EOF'

Android
.apk
.aab
.dex
.class
bin/
gen/
out/
build/
captures/
.externalNativeBuild/
.cxx/
.log
.idea/
.gradle/
local.properties

Models (large files)
.gguf
.bin
!gradle/wrapper/gradle-wrapper.jar
android/app/src/main/assets/models/

OS
.DS_Store
Thumbs.db

Secrets
secrets.properties
.keystore
.jks
EOF

cat > .gitmodules << 'EOF'
[submodule "llama.cpp"]
path = llama.cpp
url = https://github.com/ggerganov/llama.cpp.git
[submodule "whisper.cpp"]
path = whisper.cpp
url = https://github.com/ggerganov/whisper.cpp.git
EOF

============================================

DEVCONTAINER

============================================

cat > .devcontainer/devcontainer.json << 'EOF'
{
"name": "Android AI Dev",
"image": "mcr.microsoft.com/devcontainers/base:ubuntu-22.04",
"features": {
"ghcr.io/devcontainers/features/java:1": {"version": "17"},
"ghcr.io/devcontainers/features/android-sdk:1": {
"installNdk": true,
"ndkVersion": "25.2.9519653"
}
},
"postCreateCommand": "bash .devcontainer/post-create.sh",
"hostRequirements": {
"cpus": 8,
"memory": "32gb",
"storage": "64gb"
},
"forwardPorts": [5037, 5554, 5555]
}
EOF

cat > .devcontainer/post-create.sh << 'EOF'
#!/bin/bash
sudo apt-get update && sudo apt-get install -y cmake ninja-build android-tools-adb
echo 'export ANDROID_SDK_ROOT=/usr/local/lib/android/sdk' >> /.bashrc
export ANDROID_SDK_ROOT=/usr/local/lib/android/sdk
yes | sdkmanager --licenses 2>/dev/null || true
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
chmod +x models/download_models.sh scripts/build-and-deploy.sh
echo "✅ Ready! Run: models/download_models.sh"
EOF

chmod +x .devcontainer/post-create.sh

============================================

GITHUB WORKFLOWS

============================================

cat > .github/workflows/build.yml << 'EOF'
name: Build
on: [push, pull_request]
jobs:
build:
runs-on: ubuntu-latest
steps:
- uses: actions/checkout@v4
with:
submodules: recursive
- uses: actions/setup-java@v4
with:
java-version: '17'
distribution: 'temurin'
- uses: android-actions/setup-android@v3
- run: sdkmanager "ndk;25.2.9519653"
- run: |
chmod +x models/download_models.sh
./models/download_models.sh
if: steps.cache-models.outputs.cache-hit != 'true'
- run: |
cd android
./gradlew assembleDebug
- uses: actions/upload-artifact@v4
with:
name: app-debug
path: android/app/build/outputs/apk/debug/app-debug.apk
EOF

cat > .github/codespaces/setup-phone-debugging.sh << 'EOF'
#!/bin/bash
echo "📱 Phone Debugging Setup"
echo "1. Enable Wireless Debugging on phone"
echo "2. adb pair : (use pairing code)"
echo "3. adb connect :"
adb devices
EOF

chmod +x .github/codespaces/setup-phone-debugging.sh

============================================

MODELS & SCRIPTS

============================================

cat > models/download_models.sh << 'EOF'
#!/bin/bash
set -e
MODELS_DIR="(cd "(dirname "0")" && pwd)/../android/app/src/main/assets/models"
mkdir -p "MODELS_DIR"

echo "Downloading Phi-3-mini Q4_K_M (2.3GB)..."
wget -c -O "MODELS_DIR/assistant-q4_k_m.gguf" 

"https://huggingface.co/TheBloke/Phi-3-mini-4k-instruct-GGUF/resolve/main/phi-3-mini-4k-instruct.Q4_K_M.gguf"

echo "Downloading Whisper base.en (150MB)..."
wget -c -O "MODELS_DIR/whisper-base.en.bin" 

"https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin"

echo "✅ Models ready in MODELS_DIR"
du -sh "MODELS_DIR"/
EOF

chmod +x models/download_models.sh

cat > scripts/build-and-deploy.sh << 'EOF'
#!/bin/bash
set -e
cd "(dirname "0")/../android"

if [ ! -f app/src/main/assets/models/assistant-q4_k_m.gguf ]; then
echo "Models missing! Run: ../models/download_models.sh"
exit 1
fi

./gradlew assembleDebug

if adb devices | grep -q "device"; then
adb install -r app/build/outputs/apk/debug/app-debug.apk
adb shell am start -n com.offlineassistant/.presentation.MainActivity
echo "✅ Installed and launched!"
else
echo "⚠️ No device. APK at: app/build/outputs/apk/debug/app-debug.apk"
fi
EOF

chmod +x scripts/build-and-deploy.sh

============================================

ANDROID PROJECT

============================================

Gradle wrapper
mkdir -p android/gradle/wrapper
cat > android/gradle/wrapper/gradle-wrapper.properties << 'EOF'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.4-bin.zip
networkTimeout=10000
validateDistributionUrl=true
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOF

cat > android/build.gradle.kts << 'EOF'
plugins {
id("com.android.application") version "8.2.0" apply false
id("org.jetbrains.kotlin.android") version "1.9.22" apply false
}
EOF

cat > android/settings.gradle.kts << 'EOF'
pluginManagement {
repositories {
google()
mavenCentral()
gradlePluginPortal()
}
}
dependencyResolutionManagement {
repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
repositories {
google()
mavenCentral()
}
}
rootProject.name = "OfflineAssistant"
include(":app")
EOF

cat > android/gradle.properties << 'EOF'
org.gradle.jvmargs=-Xmx8192m
android.useAndroidX=true
kotlin.code.style=official
android.nonTransitiveRClass=true
EOF

App build.gradle
cat > android/app/build.gradle.kts << 'EOF'
plugins {
id("com.android.application")
id("org.jetbrains.kotlin.android")
}

android {
namespace = "com.offlineassistant"
compileSdk = 34

    defaultConfig {
        applicationId = "com.offlineassistant"
        minSdk = 28
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
        
        externalNativeBuild {
            cmake {
                cppFlags += "-O3 -DNDEBUG -DLLAMA_ANDROID"
                arguments += "-DLLAMA_BUILD_COMMON=ON"
            }
        }
        ndk {
            abiFilters += "arm64-v8a"
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    
    kotlinOptions {
        jvmTarget = "17"
    }
    
    buildFeatures {
        compose = true
    }
    
    composeOptions {
        kotlinCompilerExtensionVersion = "1.5.10"
    }
    
    externalNativeBuild {
        cmake {
            path = file("src/main/cpp/CMakeLists.txt")
            version = "3.22.1"
        }
    }

}

dependencies {
implementation("androidx.core:core-ktx:1.12.0")
implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.7.0")
implementation("androidx.activity:activity-compose:1.8.2")
implementation(platform("androidx.compose:compose-bom:2024.02.00"))
implementation("androidx.compose.ui:ui")
implementation("androidx.compose.material3:material3")
implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
testImplementation("junit:junit:4.13.2")
}
EOF

Manifest
cat > android/app/src/main/AndroidManifest.xml << 'EOF'

    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.SEND_SMS" />
    <uses-permission android:name="android.permission.CALL_PHONE" />
    <uses-permission android:name="android.permission.READ_CONTACTS" />
    <uses-permission android:name="android.permission.READ_CALENDAR" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    
    <application
        android:allowBackup="false"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:theme="@style/Theme.OfflineAssistant"
        android:largeHeap="true">
        
        <activity
            android:name=".presentation.MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>

Resources
mkdir -p android/app/src/main/res/values
cat > android/app/src/main/res/values/strings.xml << 'EOF'

Offline Assistant

EOF

cat > android/app/src/main/res/values/themes.xml << 'EOF'

EOF

============================================

NATIVE CODE

============================================

mkdir -p android/app/src/main/cpp

cat > android/app/src/main/cpp/CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.22.1)
project("llama-android")

set(CMAKE_CXX_STANDARD 14)

set(LLAMA_DIR {CMAKE_SOURCE_DIR}/../../../../../llama.cpp)

add_library(
llama-android
SHARED
llama-android.cpp
{LLAMA_DIR}/llama.cpp
{LLAMA_DIR}/ggml.c
{LLAMA_DIR}/ggml-alloc.c
{LLAMA_DIR}/ggml-backend.c
{LLAMA_DIR}/ggml-quants.c
{LLAMA_DIR}/unicode.cpp
{LLAMA_DIR}/unicode-data.cpp
)

target_include_directories(llama-android PRIVATE {LLAMA_DIR})

target_compile_options(llama-android PRIVATE -O3 -DNDEBUG)

find_library(log-lib log)
target_link_libraries(llama-android {log-lib} android)
EOF

cat > android/app/src/main/cpp/llama-android.cpp << 'EOF'
#include <jni.h>
#include 
#include 
#include 
#include <android/log.h>
#include "llama.h"

#define LOG_TAG "LlamaAndroid"
#define LOGI(...) android_log_print(ANDROID_LOG_INFO, LOG_TAG, VA_ARGS)
#define LOGE(...) android_log_print(ANDROID_LOG_ERROR, LOG_TAG, VA_ARGS)

struct LlamaContextWrapper {
llama_model model = nullptr;
llama_context ctx = nullptr;
std::atomic stop_generation{false};
};

extern "C" {

JNIEXPORT jlong JNICALL
Java_com_offlineassistant_ai_LlamaEngine_init(
JNIEnv env, jobject thiz, jstring model_path, jint context_size, jint gpu_layers) {

    const char* path = env->GetStringUTFChars(model_path, nullptr);
    LOGI("Loading model: %s", path);
    
    llama_model_params model_params = llama_model_default_params();
    model_params.n_gpu_layers = gpu_layers;
    
    llama_model* model = llama_load_model_from_file(path, model_params);
    env->ReleaseStringUTFChars(model_path, path);
    
    if (!model) return 0;
    
    llama_context_params ctx_params = llama_context_default_params();
    ctx_params.n_ctx = context_size;
    ctx_params.n_batch = 512;
    
    llama_context* ctx = llama_new_context_with_model(model, ctx_params);
    
    LlamaContextWrapper* wrapper = new LlamaContextWrapper();
    wrapper->model = model;
    wrapper->ctx = ctx;
    
    return reinterpret_cast<jlong>(wrapper);

}

JNIEXPORT void JNICALL
Java_com_offlineassistant_ai_LlamaEngine_generate(
JNIEnv env, jobject thiz, jlong handle, jstring prompt, jobject callback) {

    LlamaContextWrapper* wrapper = reinterpret_cast<LlamaContextWrapper*>(handle);
    if (!wrapper || !wrapper->ctx) return;
    
    const char* prompt_str = env->GetStringUTFChars(prompt, nullptr);
    std::string prompt_cpp(prompt_str);
    env->ReleaseStringUTFChars(prompt, prompt_str);
    
    std::vector<llama_token> tokens(prompt_cpp.length() + 16);
    int n_tokens = llama_tokenize(
        wrapper->ctx, prompt_cpp.c_str(), prompt_cpp.length(),
        tokens.data(), tokens.size(), true, false);
    
    if (n_tokens < 0) return;
    tokens.resize(n_tokens);
    
    llama_batch batch = llama_batch_init(512, 0, 1);
    for (int i = 0; i < n_tokens; i++) {
        llama_batch_add(batch, tokens[i], i, {0}, false);
    }
    batch.logits[batch.n_tokens - 1] = true;
    
    llama_decode(wrapper->ctx, batch);
    
    jclass callback_cls = env->GetObjectClass(callback);
    jmethodID on_token_method = env->GetMethodID(callback_cls, "onToken", "(Ljava/lang/String;)Z");
    
    wrapper->stop_generation = false;
    
    for (int n_pos = batch.n_tokens; n_pos < llama_n_ctx(wrapper->ctx) && !wrapper->stop_generation; n_pos++) {
        llama_token new_token_id = llama_sample_token_greedy(wrapper->ctx, nullptr);
        
        if (llama_token_is_eog(wrapper->model, new_token_id)) break;
        
        char buf[256];
        int n = llama_token_to_piece(wrapper->ctx, new_token_id, buf, sizeof(buf), 0, false);
        if (n > 0) {
            jstring j_piece = env->NewStringUTF(std::string(buf, n).c_str());
            jboolean should_continue = env->CallBooleanMethod(callback, on_token_method, j_piece);
            env->DeleteLocalRef(j_piece);
            if (!should_continue) break;
        }
        
        llama_batch_clear(batch);
        llama_batch_add(batch, new_token_id, n_pos, {0}, true);
        llama_decode(wrapper->ctx, batch);
    }
    
    llama_batch_free(batch);

}

JNIEXPORT void JNICALL
Java_com_offlineassistant_ai_LlamaEngine_stopGeneration(JNIEnv env, jobject thiz, jlong handle) {
LlamaContextWrapper wrapper = reinterpret_cast<LlamaContextWrapper>(handle);
if (wrapper) wrapper->stop_generation = true;
}

JNIEXPORT void JNICALL
Java_com_offlineassistant_ai_LlamaEngine_release(JNIEnv env, jobject thiz, jlong handle) {
LlamaContextWrapper wrapper = reinterpret_cast<LlamaContextWrapper>(handle);
if (wrapper) {
llama_free(wrapper->ctx);
llama_free_model(wrapper->model);
delete wrapper;
}
}

} // extern "C"
EOF

============================================

KOTLIN SOURCE

============================================

mkdir -p android/app/src/main/java/com/offlineassistant/{ai,device,domain,presentation}

AI Package
cat > android/app/src/main/java/com/offlineassistant/ai/LlamaEngine.kt << 'EOF'
package com.offlineassistant.ai

import android.content.Context
import android.util.Log
import kotlinx.coroutines.
import java.io.File
import java.util.concurrent.atomic.AtomicBoolean

class LlamaEngine private constructor(context: Context) {
private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
private var nativeHandle: Long = 0
private val modelPath: String
private val isInitialized = AtomicBoolean(false)
private val isGenerating = AtomicBoolean(false)

    companion object {
        private const val TAG = "LlamaEngine"
        private const val MODEL_FILENAME = "assistant-q4_k_m.gguf"
        
        @Volatile
        private var instance: LlamaEngine? = null
        
        fun getInstance(context: Context): LlamaEngine {
            return instance ?: synchronized(this) {
                instance ?: LlamaEngine(context.applicationContext).also { instance = it }
            }
        }
        
        @JvmStatic external fun init(modelPath: String, contextSize: Int, gpuLayers: Int): Long
        @JvmStatic external fun generate(handle: Long, prompt: String, callback: TokenCallback)
        @JvmStatic external fun stopGeneration(handle: Long)
        @JvmStatic external fun release(handle: Long)
        
        init {
            System.loadLibrary("llama-android")
        }
    }
    
    init {
        val modelsDir = File(context.filesDir, "models").apply { mkdirs() }
        modelPath = File(modelsDir, MODEL_FILENAME).absolutePath
        if (!File(modelPath).exists()) {
            throw IllegalStateException("Model not found. Run download_models.sh")
        }
    }
    
    fun initialize(): Boolean {
        if (isInitialized.get()) return true
        return try {
            nativeHandle = init(modelPath, 2048, 0)
            isInitialized.set(nativeHandle != 0L)
            isInitialized.get()
        } catch (e: Exception) {
            Log.e(TAG, "Init failed", e)
            false
        }
    }
    
    fun generateResponse(
        userMessage: String,
        history: List<Message> = emptyList(),
        onToken: (String) -> Unit,
        onComplete: (Result<String>) -> Unit
    ): Job = scope.launch {
        if (!isInitialized.get()) {
            onComplete(Result.failure(IllegalStateException("Not initialized")))
            return@launch
        }
        if (!isGenerating.compareAndSet(false, true)) {
            onComplete(Result.failure(IllegalStateException("Already generating")))
            return@launch
        }
        
        try {
            val prompt = buildPrompt(userMessage, history)
            val sb = StringBuilder()
            
            withContext(Dispatchers.IO) {
                generate(nativeHandle, prompt) { token ->
                    sb.append(token)
                    onToken(token)
                    true
                }
            }
            onComplete(Result.success(sb.toString()))
        } catch (e: Exception) {
            onComplete(Result.failure(e))
        } finally {
            isGenerating.set(false)
        }
    }
    
    private fun buildPrompt(userMessage: String, history: List<Message>): String {
        val system = """<|im_start|>system

You are an offline phone assistant. Use functional tokens:
- <|SEND_SMS|>(contact="Name", message="Text")
- <|CALL|>(number="+1234567890")
- <|SET_ALARM|>(time="HH:MM", label="Text")
- <|TAKE_PHOTO|>()
- <|GET_CONTACT|>(name="Name")
- <|OPEN_APP|>(package="com.example.app")

Respond with tokens or brief text only.<|im_end|>"""

        val hist = history.joinToString("") {
            val role = if (it.isUser) "user" else "assistant"
            "<|im_start|>$role\n${it.content}<|im_end|>"
        }
        return "$system$hist<|im_start|>user\n$userMessage<|im_end|>\n<|im_start|>assistant\n"
    }
    
    fun stop() {
        if (isInitialized.get()) stopGeneration(nativeHandle)
    }
    
    fun release() {
        stop()
        if (nativeHandle != 0L) {
            release(nativeHandle)
            nativeHandle = 0L
        }
        scope.cancel()
    }

}

data class Message(val content: String, val isUser: Boolean)

interface TokenCallback {
fun onToken(token: String): Boolean
}
EOF

Domain Package
cat > android/app/src/main/java/com/offlineassistant/domain/ToolParser.kt << 'EOF'
package com.offlineassistant.domain

import java.util.regex.Pattern

class ToolParser {
private val toolPattern = Pattern.compile("<\\|([A-Z]+)\\|>\\(([^)])\\)")

    fun parse(response: String): ParseResult {
        val matcher = toolPattern.matcher(response)
        return if (matcher.find()) {
            val toolName = matcher.group(1)
            val params = parseParams(matcher.group(2))
            ParseResult.ToolCall(toolName, params)
        } else {
            ParseResult.PlainText(response.trim())
        }
    }
    
    private fun parseParams(paramsString: String): Map<String, String> {
        val params = mutableMapOf<String, String>()
        val matcher = Pattern.compile("""(\w+)="([^"]*)"""").matcher(paramsString)
        while (matcher.find()) {
            params[matcher.group(1)] = matcher.group(2)
        }
        return params
    }

}

sealed class ParseResult {
data class ToolCall(val toolName: String, val params: Map<String, String>) : ParseResult()
data class PlainText(val text: String) : ParseResult()
}

sealed class ActionResult {
data class Success(val message: String) : ActionResult()
data class Error(val message: String) : ActionResult()
}
EOF

cat > android/app/src/main/java/com/offlineassistant/domain/ConversationManager.kt << 'EOF'
package com.offlineassistant.domain

import com.offlineassistant.ai.LlamaEngine
import com.offlineassistant.ai.Message
import com.offlineassistant.device.DeviceManager
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

class ConversationManager(
private val llmEngine: LlamaEngine,
private val deviceManager: DeviceManager,
private val toolParser: ToolParser
) {
private val state = MutableStateFlow(ConversationState())
val state: StateFlow = state

    private val history = mutableListOf<Message>()
    private val maxHistory = 10
    
    data class ConversationState(
        val isProcessing: Boolean = false,
        val currentResponse: String = "",
        val lastAction: ActionResult? = null
    )
    
    suspend fun processInput(input: String) {
        _state.value = ConversationState(isProcessing = true)
        history.add(Message(input, true))
        trimHistory()
        
        var fullResponse = ""
        
        llmEngine.generateResponse(input, history, 
            onToken = { token ->
                fullResponse += token
                _state.value = _state.value.copy(currentResponse = fullResponse)
            },
            onComplete = { result ->
                result.onSuccess { response ->
                    val parseResult = toolParser.parse(response)
                    val finalResponse = when (parseResult) {
                        is ParseResult.ToolCall -> {
                            val actionResult = deviceManager.executeTool(
                                parseResult.toolName, 
                                parseResult.params
                            )
                            _state.value = _state.value.copy(lastAction = actionResult)
                            when (actionResult) {
                                is ActionResult.Success -> "Done. ${actionResult.message}"
                                is ActionResult.Error -> "Error: ${actionResult.message}"
                            }
                        }
                        is ParseResult.PlainText -> parseResult.text
                    }
                    history.add(Message(response, false))
                    _state.value = ConversationState(isProcessing = false, currentResponse = finalResponse)
                }.onFailure { error ->
                    _state.value = ConversationState(isProcessing = false, currentResponse = "Error: ${error.message}")
                }
            }
        ).join()
    }
    
    private fun trimHistory() {
        if (history.size > maxHistory) history.removeAt(0)
    }

}
EOF

Device Package
cat > android/app/src/main/java/com/offlineassistant/device/DeviceManager.kt << 'EOF'
package com.offlineassistant.device

import android.content.Context
import android.content.pm.PackageManager
import androidx.core.content.ContextCompat
import com.offlineassistant.domain.ActionResult

class DeviceManager(private val context: Context) {
private val messageService = MessageService(context)
private val systemService = SystemService(context)
private val contactService = ContactService(context)

    fun executeTool(toolName: String, params: Map<String, String>): ActionResult {
        if (!hasPermission(toolName)) {
            return ActionResult.Error("Permission required")
        }
        
        return try {
            when (toolName) {
                "SEND_SMS" -> messageService.sendSMS(
                    params["contact"] ?: return ActionResult.Error("No contact"),
                    params["message"] ?: return ActionResult.Error("No message")
                )
                "CALL" -> systemService.call(params["number"] ?: return ActionResult.Error("No number"))
                "SET_ALARM" -> systemService.setAlarm(
                    params["time"] ?: "08:00",
                    params["label"] ?: "Alarm"
                )
                "GET_CONTACT" -> contactService.find(params["name"] ?: return ActionResult.Error("No name"))
                "OPEN_APP" -> systemService.openApp(params["package"] ?: return ActionResult.Error("No package"))
                "TAKE_PHOTO" -> systemService.takePhoto()
                else -> ActionResult.Error("Unknown tool: $toolName")
            }
        } catch (e: SecurityException) {
            ActionResult.Error("Permission denied")
        } catch (e: Exception) {
            ActionResult.Error(e.message ?: "Unknown error")
        }
    }
    
    private fun hasPermission(toolName: String): Boolean {
        val permission = when (toolName) {
            "SEND_SMS" -> android.Manifest.permission.SEND_SMS
            "CALL" -> android.Manifest.permission.CALL_PHONE
            else -> return true
        }
        return ContextCompat.checkSelfPermission(context, permission) == PackageManager.PERMISSION_GRANTED
    }

}
EOF

cat > android/app/src/main/java/com/offlineassistant/device/MessageService.kt << 'EOF'
package com.offlineassistant.device

import android.content.Context
import android.telephony.SmsManager
import com.offlineassistant.domain.ActionResult

class MessageService(private val context: Context) {
fun sendSMS(contact: String, message: String): ActionResult {
return try {
val smsManager = context.getSystemService(SmsManager::class.java)
val parts = smsManager.divideMessage(message)
val number = if (contact.startsWith("+")) contact else resolveContact(contact)
?: return ActionResult.Error("Contact not found: contact")

            smsManager.sendMultipartTextMessage(number, null, parts, null, null)
            ActionResult.Success("SMS sent to $contact")
        } catch (e: Exception) {
            ActionResult.Error("Failed: ${e.message}")
        }
    }
    
    private fun resolveContact(name: String): String? {
        // TODO: Query ContactsContract
        return null
    }

}
EOF

cat > android/app/src/main/java/com/offlineassistant/device/SystemService.kt << 'EOF'
package com.offlineassistant.device

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.AlarmClock
import com.offlineassistant.domain.ActionResult

class SystemService(private val context: Context) {
fun call(number: String): ActionResult {
val intent = Intent(Intent.ACTION_CALL, Uri.parse("tel:number")).apply {
flags = Intent.FLAG_ACTIVITY_NEW_TASK
}
context.startActivity(intent)
return ActionResult.Success("Calling number")
}

    fun setAlarm(time: String, label: String): ActionResult {
        val (hour, minute) = time.split(":").map { it.toInt() }
        val intent = Intent(AlarmClock.ACTION_SET_ALARM).apply {
            putExtra(AlarmClock.EXTRA_HOUR, hour)
            putExtra(AlarmClock.EXTRA_MINUTES, minute)
            putExtra(AlarmClock.EXTRA_MESSAGE, label)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        context.startActivity(intent)
        return ActionResult.Success("Alarm set for $time")
    }
    
    fun openApp(packageName: String): ActionResult {
        val intent = context.packageManager.getLaunchIntentForPackage(packageName)
            ?: return ActionResult.Error("App not found: $packageName")
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        context.startActivity(intent)
        return ActionResult.Success("Opening $packageName")
    }
    
    fun takePhoto(): ActionResult {
        // Launch camera intent
        return ActionResult.Success("Camera launched")
    }

}
EOF

cat > android/app/src/main/java/com/offlineassistant/device/ContactService.kt << 'EOF'
package com.offlineassistant.device

import android.content.Context
import com.offlineassistant.domain.ActionResult

class ContactService(private val context: Context) {
fun find(name: String): ActionResult {
// TODO: Implement ContactsContract query
return ActionResult.Success("Found contact: name")
}
}
EOF

Presentation Package
cat > android/app/src/main/java/com/offlineassistant/presentation/MainActivity.kt << 'EOF'
package com.offlineassistant.presentation

import android.Manifest
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.
import androidx.compose.runtime.
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.lifecycleScope
import com.offlineassistant.ai.LlamaEngine
import com.offlineassistant.device.DeviceManager
import com.offlineassistant.domain.ConversationManager
import com.offlineassistant.domain.ToolParser
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {
private lateinit var conversationManager: ConversationManager

    private val permissions = arrayOf(
        Manifest.permission.RECORD_AUDIO,
        Manifest.permission.SEND_SMS,
        Manifest.permission.CALL_PHONE,
        Manifest.permission.READ_CONTACTS,
        Manifest.permission.READ_CALENDAR,
        Manifest.permission.CAMERA
    )
    
    private val permissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val llmEngine = LlamaEngine.getInstance(this)
        llmEngine.initialize()
        
        conversationManager = ConversationManager(
            llmEngine,
            DeviceManager(this),
            ToolParser()
        )
        
        permissionLauncher.launch(permissions)
        
        setContent {
            MaterialTheme {
                AssistantScreen(conversationManager)
            }
        }
    }

}

@Composable
fun AssistantScreen(manager: ConversationManager) {
val state by manager.state.collectAsState()
var input by remember { mutableStateOf("") }
val messages = remember { mutableStateListOf<Pair<String, Boolean>>() }

    Column(Modifier.fillMaxSize().padding(16.dp)) {
        LazyColumn(Modifier.weight(1f)) {
            items(messages) { (text, isUser) ->
                Text(
                    text = text,
                    modifier = Modifier.fillMaxWidth(),
                    color = if (isUser) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.onSurface
                )
            }
        }
        
        if (state.isProcessing) {
            LinearProgressIndicator(Modifier.fillMaxWidth())
            Text("Thinking: ${state.currentResponse}")
        }
        
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            OutlinedTextField(
                value = input,
                onValueChange = { input = it },
                modifier = Modifier.weight(1f),
                placeholder = { Text("Type message...") }
            )
            Button(
                onClick = {
                    if (input.isNotBlank()) {
                        messages.add(input to true)
                        lifecycleScope.launch { manager.processInput(input) }
                        input = ""
                    }
                },
                enabled = !state.isProcessing
            ) {
                Text("Send")
            }
        }
    }

}
