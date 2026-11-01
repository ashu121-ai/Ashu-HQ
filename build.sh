#!/usr/bin/env bash
# Ashu HQ: index.html se Android APK banata hai (GitHub Actions par chalta hai).
set -euo pipefail
ROOT="$(pwd)"

rm -rf app && mkdir app && cd app
npm init -y >/dev/null
npm install @capacitor/core@6 @capacitor/cli@6 @capacitor/android@6 @capacitor/local-notifications@6

mkdir www
cp "$ROOT/index.html" www/index.html

cat > capacitor.config.json <<'EOF'
{
  "appId": "com.ashu.hq",
  "appName": "Ashu HQ",
  "webDir": "www",
  "server": { "androidScheme": "https" },
  "plugins": { "CapacitorHttp": { "enabled": true } }
}
EOF

npx cap add android

python3 - <<'PY'
p = 'android/app/src/main/AndroidManifest.xml'
s = open(p, encoding='utf8').read()
perms = '''    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
    <uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-feature android:name="android.hardware.camera" android:required="false"/>
'''
assert '<application' in s
s = s.replace('<application', perms + '    <application', 1)
open(p, 'w', encoding='utf8').write(s)
PY

npx cap sync android

cd android
chmod +x gradlew
./gradlew assembleDebug --no-daemon

cp app/build/outputs/apk/debug/app-debug.apk "$ROOT/AshuHQ.apk"
echo "APK ready: $ROOT/AshuHQ.apk"
