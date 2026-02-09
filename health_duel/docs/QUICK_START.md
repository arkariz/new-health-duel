# Quick Start Guide

Get Health Duel running on your machine in less than 10 minutes.

## Prerequisites

Before you begin, ensure you have these tools installed:

- **Flutter SDK:** Version 3.7.2 or higher
- **Dart SDK:** Version 3.0.0 or higher (included with Flutter)
- **Git:** Latest version for version control
- **IDE:** Visual Studio Code, Android Studio, or IntelliJ IDEA
- **Firebase CLI:** For Firebase configuration and deployment
- **Platform Tools:**
  - **Android:** Android Studio with SDK, Android Emulator or physical device
  - **iOS:** Xcode 14+ (macOS only), iOS Simulator or physical device

### Verify Your Installation

Run these commands to verify your environment:

```bash
flutter --version
dart --version
git --version
firebase --version
```

Expected output:
```
Flutter 3.7.2 • channel stable
Dart 3.0.0 • DevTools 2.20.1
git version 2.x.x
12.x.x
```

If any command fails, install the missing tool before continuing.

## Step 1: Clone the Repository

Clone the Health Duel repository to your local machine:

```bash
git clone <repository-url> health_duel
cd health_duel
```

## Step 2: Configure Git Dependency

Health Duel uses a custom Flutter package core as a git dependency. Configure
access to the package repository:

### Option A: HTTPS (Recommended for most users)

Edit `pubspec.yaml` and verify the dependency configuration:

```yaml
dependencies:
  flutter_package_core:
    git:
      url: https://github.com/arkariz/flutter-package-core
      ref: main  # or specific tag/branch
```

### Option B: SSH (For contributors with SSH keys)

```yaml
dependencies:
  flutter_package_core:
    git:
      url: git@github.com:arkariz/flutter-package-core.git
      ref: main
```

> **Note:** If you encounter git dependency resolution errors, ensure you have
> network access to the repository and proper authentication configured. Contact
> the project maintainer if issues persist.

## Step 3: Install Dependencies

Install all project dependencies:

```bash
flutter pub get
```

This command:
- Downloads all packages listed in `pubspec.yaml`
- Resolves the git dependency for `flutter_package_core`
- Generates necessary build files

Expected output:
```
Running "flutter pub get" in health_duel...
Resolving dependencies...
+ flutter_package_core from git...
Got dependencies!
```

## Step 4: Firebase Configuration

Health Duel uses Firebase for authentication, database, and cloud messaging.
Configure Firebase for your development environment:

### Generate Firebase Configuration Files

1. Ensure you have access to the Health Duel Firebase project
2. Install FlutterFire CLI if not already installed:

```bash
dart pub global activate flutterfire_cli
```

3. Generate configuration files:

```bash
flutterfire configure
```

This creates:
- `lib/firebase_options.dart` - Platform-specific Firebase configuration
- `android/app/google-services.json` - Android configuration
- `ios/Runner/GoogleService-Info.plist` - iOS configuration

> **Note:** These files contain environment-specific keys. They are in
> `.gitignore` and should never be committed to version control.

## Step 5: Platform-Specific Setup

### Android Setup

1. Open `android/` directory in Android Studio
2. Wait for Gradle sync to complete
3. Verify minimum SDK version in `android/app/build.gradle`:

```gradle
android {
    compileSdkVersion 33
    defaultConfig {
        minSdkVersion 26
        targetSdkVersion 33
    }
}
```

4. For Health Connect integration, verify permissions in `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.health.READ_STEPS"/>
```

### iOS Setup (macOS only)

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select a development team for code signing
3. Verify minimum iOS version in `ios/Podfile`:

```ruby
platform :ios, '14.0'
```

4. Install CocoaPods dependencies:

```bash
cd ios
pod install
cd ..
```

5. For HealthKit integration, verify capabilities are enabled in Xcode:
   - Open `ios/Runner.xcworkspace`
   - Select Runner target → Signing & Capabilities
   - Ensure HealthKit capability is added

## Step 6: Run Your First Build

### Choose Your Target Platform

**For Android:**
```bash
flutter run -d android
```

**For iOS (macOS only):**
```bash
flutter run -d ios
```

**For Chrome (web preview - limited functionality):**
```bash
flutter run -d chrome
```

### Build Process

The first build takes 3-5 minutes as Flutter compiles dependencies. Subsequent
builds are faster due to caching.

Expected console output:
```
Launching lib/main.dart on Android SDK built for x86 in debug mode...
Running Gradle task 'assembleDebug'...
✓ Built build/app/outputs/flutter-apk/app-debug.apk
Installing build/app/outputs/flutter-apk/app-debug.apk...
Syncing files to device Android SDK built for x86...
Flutter run key commands.
r Hot reload.
R Hot restart.
q Quit (terminate the application on the device).
```

## Step 7: Verify Installation

After the app launches, verify these features work:

### Verification Checklist

- [ ] App launches without crashes
- [ ] Home screen displays correctly
- [ ] Login screen is accessible (don't log in yet)
- [ ] No error overlays or red screens appear
- [ ] Hot reload works (press `r` in terminal)

### Basic Hot Reload Test

1. Open `lib/main.dart` in your editor
2. Change the app title or a text string
3. Press `r` in the terminal running `flutter run`
4. The app should update without restarting

If hot reload works, your development environment is configured correctly.

## Common Commands Cheatsheet

Keep these commands handy for daily development:

```bash
# Run app in debug mode
flutter run

# Run with specific device
flutter run -d <device-id>

# List available devices
flutter devices

# Get dependencies
flutter pub get

# Clean build artifacts
flutter clean

# Run code generation (for build_runner)
flutter pub run build_runner build --delete-conflicting-outputs

# Run tests
flutter test

# Run static analysis
flutter analyze

# Format code
dart format .

# Check for outdated dependencies
flutter pub outdated
```

## Troubleshooting

### Git Dependency Fails to Resolve

**Error:** `Git error. Command: git clone`

**Solutions:**
1. Verify network connectivity to GitHub
2. Check authentication (HTTPS token or SSH key)
3. Try alternative URL format (HTTPS vs SSH)
4. Contact project maintainer for repository access

### Firebase Configuration Missing

**Error:** `firebase_options.dart not found`

**Solution:** Run `flutterfire configure` as described in Step 4.

### Android Gradle Build Fails

**Error:** `FAILURE: Build failed with an exception`

**Solutions:**
1. Ensure Android SDK is installed and up to date
2. Run `flutter clean` and rebuild
3. Check `android/build.gradle` for correct Gradle version
4. Invalidate caches in Android Studio

### iOS Pod Install Fails

**Error:** `pod install` returns errors

**Solutions:**
1. Update CocoaPods: `sudo gem install cocoapods`
2. Clean pods: `cd ios && rm -rf Pods Podfile.lock && pod install`
3. Update pod repo: `pod repo update`

### Health Permission Errors

**Error:** Health data permission denied

**Solution:** For development, health permissions are optional. Real device
testing requires proper permission configuration as described in platform-specific
setup sections.

## Next Steps

Congratulations! You have successfully set up Health Duel. Here's what to do next:

### For Developers
1. Read [Foundational Context](00-foundation/FOUNDATIONAL_CONTEXT.md) to understand the project vision
2. Study [Architecture Overview](02-architecture/ARCHITECTURE_OVERVIEW.md) to grasp the system design
3. Review [Contributing Guidelines](CONTRIBUTING.md) before making changes
4. Explore [Development Patterns](03-development/patterns/) for code standards

### For Product Managers
1. Review [Product Requirements Document](01-product/prd-health-duels-1.0.md)
2. Check [User Stories](01-product/user-stories.md) for feature details

### For QA Engineers
1. Set up test environments as described in [Environment Configuration](09-operations/environments/)
2. Review [Testing Strategy](08-testing/) for testing approach

## Getting Help

If you encounter issues not covered in this guide:
1. Check [Environment Configuration](09-operations/environments/) for detailed setup
2. Review relevant documentation in the `docs/` directory
3. Search existing issues in the project repository
4. Ask the development team for assistance

---

**Setup Time:** ~10 minutes (excluding tool installation)
**First Build Time:** 3-5 minutes
**Subsequent Build Time:** < 30 seconds (with hot reload)
