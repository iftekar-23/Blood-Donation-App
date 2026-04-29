# BloodLink — Setup & Run Guide

## 1. Prerequisites

- Flutter SDK (3.x stable): https://docs.flutter.dev/get-started/install
- Firebase CLI: `npm install -g firebase-tools`
- FlutterFire CLI: `dart pub global activate flutterfire_cli`
- Android Studio or Xcode (for emulator/device)

---

## 2. Firebase Project Setup

### Step 1 — Create Firebase Project
1. Go to https://console.firebase.google.com
2. Click **Add project** → name it (e.g. `bloodlink-app`)
3. Disable Google Analytics (optional) → **Create project**

### Step 2 — Enable Authentication
1. In Firebase Console → **Authentication** → **Get started**
2. Under **Sign-in method** → enable **Email/Password**

### Step 3 — Create Firestore Database
1. **Firestore Database** → **Create database**
2. Choose **Start in test mode** (for development)
3. Select a region → **Done**

### Step 4 — Enable Firebase Storage
1. **Storage** → **Get started**
2. Start in test mode → choose region → **Done**

### Step 5 — Firestore Security Rules (Production)
Replace test rules with:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    match /blood_requests/{requestId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.requesterId;
    }
  }
}
```

### Step 6 — Firestore Indexes
Create a composite index for blood requests:
- Collection: `blood_requests`
- Fields: `status` (Ascending), `createdAt` (Descending)

---

## 3. Connect Flutter App to Firebase

```bash
# Login to Firebase
firebase login

# In the project root
cd blood_donation_app
flutterfire configure
```

Select your Firebase project when prompted. This auto-generates `lib/firebase_options.dart` with your real credentials, replacing the placeholder file.

---

## 4. Install Dependencies

```bash
flutter pub get
```

---

## 5. Run the App

```bash
# Android
flutter run

# iOS (Mac only)
flutter run -d ios

# Specific device
flutter devices
flutter run -d <device_id>
```

---

## 6. Project Structure

```
lib/
├── main.dart                        # App entry point
├── firebase_options.dart            # Firebase config (auto-generated)
├── core/
│   ├── constants/app_constants.dart # App-wide constants
│   ├── theme/app_theme.dart         # Light & dark themes
│   └── router/app_router.dart       # GoRouter navigation
├── features/
│   ├── auth/
│   │   ├── models/user_model.dart
│   │   ├── services/auth_service.dart
│   │   ├── providers/auth_provider.dart
│   │   └── screens/
│   │       ├── splash_screen.dart
│   │       ├── sign_in_screen.dart
│   │       └── register_screen.dart
│   ├── donors/
│   │   ├── services/donor_service.dart
│   │   ├── providers/donor_provider.dart
│   │   └── screens/
│   │       ├── home_screen.dart
│   │       └── donate_screen.dart
│   ├── requests/
│   │   ├── models/blood_request_model.dart
│   │   ├── services/request_service.dart
│   │   ├── providers/request_provider.dart
│   │   └── screens/
│   │       ├── blood_request_screen.dart
│   │       └── my_requests_screen.dart
│   └── profile/
│       ├── providers/profile_provider.dart
│       └── screens/profile_screen.dart
└── widgets/
    ├── loading_button.dart
    ├── donor_card.dart
    └── app_drawer.dart
```

---

## 7. Regenerate Riverpod Code (after any provider changes)

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 8. Android Permissions

Add to `android/app/src/main/AndroidManifest.xml` inside `<manifest>`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.CALL_PHONE"/>
```

## 9. iOS Permissions

Add to `ios/Runner/Info.plist`:
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Used to upload your profile photo</string>
<key>NSCameraUsageDescription</key>
<string>Used to take a profile photo</string>
```
