@echo off
echo Getting SHA-1 certificate fingerprints for Google Sign-In setup...
echo.

echo === DEBUG KEYSTORE (for development) ===
cd /d "%USERPROFILE%\.android"
if exist debug.keystore (
    keytool -list -v -keystore debug.keystore -alias androiddebugkey -storepass android -keypass android | findstr SHA1
) else (
    echo Debug keystore not found at %USERPROFILE%\.android\debug.keystore
)

echo.
echo === RELEASE KEYSTORE (for production) ===
echo Please run this command with your release keystore:
echo keytool -list -v -keystore [path-to-your-release-keystore] -alias [your-alias]
echo.

echo Copy the SHA1 fingerprint to Google Cloud Console OAuth credentials
pause
