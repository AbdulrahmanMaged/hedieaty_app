@echo off
REM Ensure adb is installed
where adb >nul 2>&1
if %errorlevel% neq 0 (
    echo "adb command not found. Please install Android SDK."
    exit /b 1
)

REM Build the app for testing
echo Building the app for integration testing...
flutter build apk --debug --target=test_driver/integration_test.dart

REM Install the APK
echo Installing the app on the connected Android device...
adb install -r build\app\outputs\flutter-apk\app-debug.apk

REM Run the test
echo Running the integration test...
flutter drive --target=test_driver/integration_test.dart --driver=test_driver/integration_test_driver.dart

REM Fetch logs
echo Fetching logs from the device...
adb logcat -d > test_logs.log

echo Test completed. Logs saved to test_logs.log.
