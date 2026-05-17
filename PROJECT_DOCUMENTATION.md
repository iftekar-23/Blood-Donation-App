# BloodLink — Blood Donation App
## Complete Project Documentation

---

## 1. What is this app?

BloodLink is a mobile/web application that connects blood donors with people who need blood. A user registers as either a **Donor** or a **Receiver**. Donors appear in a searchable list. Receivers can post blood requests. Both sides can communicate via phone call.

---

## 2. Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | UI framework — one codebase runs on Android, iOS, and Web |
| Dart | Programming language used by Flutter |
| Firebase Authentication | Handles user login and registration |
| Cloud Firestore | NoSQL database — stores users and blood requests |
| Firebase Storage | Stores profile images |
| Riverpod | State management — controls how data flows through the app |
| GoRouter | Navigation between screens |
| Google Fonts (Poppins) | Clean modern typography |

---

## 3. Project Folder Structure

```
lib/
├── main.dart                  ← App entry point
├── firebase_options.dart      ← Firebase credentials per platform
├── core/
│   ├── constants/             ← Blood groups list, collection names, roles
│   ├── theme/                 ← Colors, button styles, input styles
│   └── router/                ← All routes defined in one place
├── features/
│   ├── auth/                  ← Login, Register, Splash
│   ├── donors/                ← Home screen, Donate screen
│   ├── requests/              ← Blood request form, My requests list
│   └── profile/               ← View and edit profile, image upload
└── widgets/                   ← Reusable UI pieces (drawer, donor card, button)
```

This follows **feature-first clean architecture** — each feature is self-contained with its own model, service, provider, and screens.

---

## 4. How the App Starts

**File: lib/main.dart**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: BloodDonationApp()));
}
```

- `WidgetsFlutterBinding.ensureInitialized()` — prepares the Flutter engine before any async work
- `Firebase.initializeApp()` — reads firebase_options.dart and connects to the Firebase project
- `ProviderScope` — wraps the entire app, required by Riverpod so all providers work globally

---

## 5. Navigation — GoRouter

**File: lib/core/router/app_router.dart**

All routes are defined as constants:

```
/              → Splash Screen
/sign-in       → Sign In Screen
/register      → Register Screen
/home          → Home Screen (donor list)
/profile       → Profile Screen
/blood-request → Blood Request Form
/my-requests   → My Requests List
/donate        → Donate Blood Screen
```

**Route Guard (Redirect Logic):**

```dart
redirect: (context, state) {
  final isLoggedIn = authState.valueOrNull != null;
  if (!isLoggedIn && !isAuthRoute) return AppRoutes.signIn;
  if (isLoggedIn && isAuthRoute) return AppRoutes.home;
  return null;
},
```

- If a user is NOT logged in and tries to access any protected page → redirected to /sign-in
- If a user IS logged in and tries to visit /sign-in or /register → redirected to /home
- This is called a **route guard** or **navigation guard**

---

## 6. Firebase Authentication

**File: lib/features/auth/services/auth_service.dart**

### Registration Flow

```dart
// Step 1: Create account in Firebase Auth
final credential = await _auth.createUserWithEmailAndPassword(
  email: email,
  password: password,
);

// Step 2: Save extra profile data to Firestore
await _db.collection('users').doc(uid).set(user.toMap());
```

Firebase Auth only stores email and password. All other data (name, phone, blood group, role) is stored in Firestore using the user's unique `uid` as the document ID.

### Login Flow

```dart
await _auth.signInWithEmailAndPassword(email: email, password: password);
```

Firebase verifies credentials. On success, it sets the current user and emits an auth state change. GoRouter detects this and navigates to home automatically.

### Logout Flow

```dart
await _auth.signOut();
```

Firebase clears the session. The auth stream emits null. GoRouter redirects to sign-in.

---

## 7. How User Data is Stored in Firestore

Firestore is a **NoSQL document database**. Data is organized in collections of documents (similar to folders containing JSON files).

### Database Structure

```
Firestore Database
│
├── users/                          ← Collection
│   └── {uid}/                      ← Document (one per user)
│       ├── name: "Md Iftekar Ahmed"
│       ├── email: "user@gmail.com"
│       ├── phone: "01700000000"
│       ├── bloodGroup: "B+"
│       ├── role: "Donor"
│       ├── isAvailable: true
│       ├── location: "Dhaka"
│       ├── photoUrl: "https://..."
│       └── createdAt: timestamp
│
└── blood_requests/                 ← Collection
    └── {auto-id}/                  ← Document (one per request)
        ├── requesterId: "uid123"
        ├── requesterName: "Ahmed"
        ├── bloodGroup: "O+"
        ├── location: "Chittagong"
        ├── neededDate: timestamp
        ├── contactInfo: "01800000000"
        ├── status: "pending"
        └── createdAt: timestamp
```

### UserModel Class

**File: lib/features/auth/models/user_model.dart**

This Dart class converts between Firestore data and Flutter objects:

```dart
// Firestore document → Dart object
factory UserModel.fromDoc(DocumentSnapshot doc) { ... }

// Dart object → Firestore map
Map<String, dynamic> toMap() => {
  'name': name,
  'email': email,
  'bloodGroup': bloodGroup,
  ...
}
```

---

## 8. State Management — Riverpod

Riverpod manages all app state. Instead of passing data manually between widgets, providers hold the data and any widget can access it directly.

### Three Types of Providers Used

**1. StreamProvider** — listens to real-time Firestore data:
```dart
@riverpod
Stream<List<UserModel>> filteredDonors(FilteredDonorsRef ref) {
  return service.donorsStream(bloodGroup: filter);
}
```

**2. FutureProvider** — fetches data once asynchronously:
```dart
@riverpod
Future<UserModel?> currentUserProfile(CurrentUserProfileRef ref) async {
  return service.getUserProfile(user.uid);
}
```

**3. NotifierProvider** — holds mutable state (like the blood group filter):
```dart
@riverpod
class BloodGroupFilter extends _$BloodGroupFilter {
  @override
  String build() => '';

  void setFilter(String group) => state = group;
  void clearFilter() => state = '';
}
```

Widgets read providers using `ref.watch()`:
```dart
final donors = ref.watch(filteredDonorsAsync);
```

When data changes, Riverpod automatically rebuilds only the widgets that depend on that provider — not the entire screen.

---

## 9. Real-Time Data — How the Donor List Updates Live

**File: lib/features/donors/services/donor_service.dart**

```dart
Stream<List<UserModel>> donorsStream({String? bloodGroup}) {
  Query query = _db.collection('users')
      .where('role', isEqualTo: 'Donor')
      .where('isAvailable', isEqualTo: true);

  if (bloodGroup != null) {
    query = query.where('bloodGroup', isEqualTo: bloodGroup);
  }

  return query.snapshots().map(
    (snap) => snap.docs.map(UserModel.fromDoc).toList()
  );
}
```

`.snapshots()` keeps a persistent connection to Firestore. Every time a donor's availability changes or a new donor registers, Firestore pushes the update and the list rebuilds automatically — no manual refresh needed.

---

## 10. Profile Image Upload — Firebase Storage

**File: lib/features/profile/providers/profile_provider.dart**

```dart
Future<String> uploadProfileImage(String uid, File imageFile) async {
  final ref = _storage.ref().child('profile_images/$uid.jpg');
  final task = await ref.putFile(imageFile);
  return task.ref.getDownloadURL();
}
```

1. User picks an image from gallery using `image_picker` package
2. Image is uploaded to Firebase Storage at path `profile_images/{uid}.jpg`
3. A public download URL is returned
4. That URL is saved in the user's Firestore document as `photoUrl`
5. `CachedNetworkImage` widget loads the image with local caching

---

## 11. All Screens Explained

| Screen | File | What it does |
|---|---|---|
| SplashScreen | auth/screens/splash_screen.dart | Animated logo for 2.5s, then navigates to sign-in |
| SignInScreen | auth/screens/sign_in_screen.dart | Email/password login with validation |
| RegisterScreen | auth/screens/register_screen.dart | Creates Firebase Auth account + saves to Firestore |
| HomeScreen | donors/screens/home_screen.dart | Real-time donor list with blood group filter |
| DonateScreen | donors/screens/donate_screen.dart | Donor toggles availability on/off |
| BloodRequestScreen | requests/screens/blood_request_screen.dart | Receiver submits blood request form |
| MyRequestsScreen | requests/screens/my_requests_screen.dart | Shows user's requests with status management |
| ProfileScreen | profile/screens/profile_screen.dart | View/edit profile, upload photo |

---

## 12. Role-Based Features

When registering, users choose **Donor** or **Receiver**. This `role` field controls the entire experience:

| Feature | Donor | Receiver |
|---|---|---|
| Appears in donor list | Yes | No |
| Can toggle availability | Yes | No |
| Sees "Donate Blood" in drawer | Yes | No |
| Sees "Request Blood" in drawer | No | Yes |
| FAB on home screen | No | Yes (Request Blood) |

---

## 13. Theme System — Light and Dark Mode

**File: lib/core/theme/app_theme.dart**

The app defines two complete themes using Material Design 3:
- Primary color: Deep Red (#D32F2F)
- All buttons, inputs, app bars, and cards are styled consistently

```dart
themeMode: ThemeMode.system,
```

This automatically follows the device's system setting. No extra code needed — if the user's device is in dark mode, the app switches automatically.

---

## 14. Error Handling Strategy

Every async operation uses try/catch. Errors are shown in a red banner with human-readable messages:

```dart
String _friendlyError(String raw) {
  if (raw.contains('email-already-in-use')) return 'This email is already registered.';
  if (raw.contains('weak-password')) return 'Password is too weak.';
  if (raw.contains('network-request-failed')) return 'No internet connection.';
  if (raw.contains('permission-denied')) return 'Firestore permission denied.';
  return 'Error: $raw'; // shows raw error for unknown cases
}
```

Loading states show a spinner inside buttons so users know an operation is in progress.

---

## 15. Firebase Security Rules

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;        // any logged-in user can read donors
      allow write: if request.auth.uid == userId; // only owner can edit their profile
    }
    match /blood_requests/{requestId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.requesterId;
    }
  }
}
```

These rules run on Firebase's servers — the client app cannot bypass them.

---

## 16. Key Questions & Answers for Presentation

**Q: Why Flutter?**
Flutter allows building one codebase that runs on Android, iOS, and Web simultaneously. It uses Dart and compiles to native code, giving near-native performance.

**Q: Why Firebase instead of a custom backend?**
Firebase provides authentication, real-time database, and file storage out of the box. Building the same from scratch requires a server, REST API, JWT authentication, and file storage infrastructure. Firebase eliminates all of that.

**Q: What is Riverpod and why not setState?**
`setState` only rebuilds one widget and cannot share state across the app. Riverpod provides global state that any widget can access, handles async states (loading/error/data) automatically, and rebuilds only the widgets that depend on changed data.

**Q: What is GoRouter and why not Navigator?**
GoRouter supports URL-based navigation (essential for web), route guards that protect pages from unauthenticated access, and deep linking. The built-in Navigator.push() doesn't support these features cleanly.

**Q: How is the app secure?**
1. Firebase Auth tokens are verified server-side on every Firestore request
2. Firestore security rules prevent users from reading or writing other users' private data
3. The client app cannot fake a different user's identity

**Q: What is a Stream in Flutter?**
A Stream is a sequence of data values delivered over time. Firestore's `.snapshots()` returns a Stream — every time the database changes, a new value is emitted and the UI rebuilds automatically without any manual refresh.

**Q: What is the difference between Firestore and Firebase Storage?**
Firestore stores structured data (text, numbers, booleans, timestamps) as JSON-like documents. Firebase Storage stores binary files (images, videos, PDFs). Profile images go to Storage; the URL pointing to that image is stored in Firestore.

**Q: What is clean architecture?**
Clean architecture separates code into layers — Models (data structure), Services (Firebase calls), Providers (state), and Screens (UI). Each layer has one responsibility. This makes the code easier to test, maintain, and extend.

**Q: How does real-time sync work?**
Firestore maintains a persistent WebSocket connection. When any document in a queried collection changes, Firestore pushes the new data to all connected clients instantly. The app's StreamProvider receives this and Riverpod rebuilds the affected widgets.

---

*BloodLink — Built with Flutter & Firebase*
d


---

# Part 2 — Widgets, CRUD Operations & Step-by-Step Build Guide

---

## Section A: Every Widget Used and Which Screen It Appears In

### 1. Scaffold
- **What it is:** The base structure of every screen. Provides appBar, body, drawer, floatingActionButton slots.
- **Used in:** Every single screen (SplashScreen, SignInScreen, RegisterScreen, HomeScreen, ProfileScreen, DonateScreen, BloodRequestScreen, MyRequestsScreen)
- **Example from HomeScreen:**
```dart
Scaffold(
  appBar: AppBar(...),
  drawer: AppDrawer(),
  body: Column(...),
  floatingActionButton: FloatingActionButton.extended(...),
)
```

---

### 2. AppBar
- **What it is:** The top bar showing the screen title and action icons.
- **Used in:** HomeScreen, RegisterScreen, ProfileScreen, DonateScreen, BloodRequestScreen, MyRequestsScreen
- **Connection:** HomeScreen AppBar has a profile icon button that navigates to ProfileScreen using `context.push(AppRoutes.profile)`

---

### 3. Drawer + AppDrawer (custom widget)
- **What it is:** Side navigation panel that slides in from the left.
- **Used in:** HomeScreen only (via `drawer: const AppDrawer()`)
- **AppDrawer** is our custom reusable widget in `lib/widgets/app_drawer.dart`
- **Connection:** AppDrawer reads `currentUserProfileProvider` to show the user's name and email in the header, and shows different menu items based on the user's role (Donor vs Receiver)

---

### 4. Column
- **What it is:** Arranges children vertically one after another.
- **Used in:** Every screen — the primary layout widget for stacking form fields, buttons, and text vertically
- **Example:** RegisterScreen uses Column to stack Name → Email → Password → Phone → Blood Group → Role fields

---

### 5. Row
- **What it is:** Arranges children horizontally side by side.
- **Used in:**
  - HomeScreen: stats row showing "Available Donors" label + filter chip
  - DonorCard widget: avatar + donor info + call button side by side
  - AppDrawer header: avatar + name/email side by side
  - ProfileScreen: blood group chip + role chip side by side
  - MyRequestsScreen: blood group badge + status badge side by side

---

### 6. ListView.builder
- **What it is:** Efficiently builds a scrollable list — only renders items visible on screen.
- **Used in:** HomeScreen (donor list), MyRequestsScreen (requests list)
- **Connection:** HomeScreen passes each `UserModel` from Firestore to `DonorCard` widget. MyRequestsScreen passes each `BloodRequestModel` to a Card widget.
```dart
ListView.builder(
  itemCount: donors.length,
  itemBuilder: (_, i) => DonorCard(donor: donors[i]),
)
```

---

### 7. Card
- **What it is:** A Material Design container with rounded corners and a shadow/elevation.
- **Used in:** DonorCard widget, MyRequestsScreen (each request), DonateScreen (donor info card, tips card), ProfileScreen (info card)
- **Connection:** Each Card in MyRequestsScreen displays one `BloodRequestModel` document from Firestore

---

### 8. TextFormField
- **What it is:** A text input field with built-in validation support.
- **Used in:** SignInScreen (email, password), RegisterScreen (name, email, password, phone), BloodRequestScreen (location, contact), ProfileScreen edit mode (name, phone, location)
- **Connection:** All fields are connected to `TextEditingController` objects. On form submit, `.text` is read from each controller and sent to Firebase.

---

### 9. DropdownButtonFormField
- **What it is:** A dropdown selector that integrates with Flutter's Form validation.
- **Used in:** RegisterScreen (blood group, role), BloodRequestScreen (blood group needed), ProfileScreen edit mode (blood group)
- **Connection:** HomeScreen uses `DropdownButton` (not form version) for the filter — when changed it calls `ref.read(bloodGroupFilterProvider.notifier).setFilter(v)` which triggers a new Firestore query

---

### 10. ElevatedButton / LoadingButton (custom widget)
- **What it is:** A tappable button. `LoadingButton` is our custom wrapper that shows a spinner when `loading: true`.
- **Used in:** SignInScreen, RegisterScreen, BloodRequestScreen, DonateScreen, ProfileScreen
- **File:** `lib/widgets/loading_button.dart`
- **Connection:** The button's `onPressed` calls the relevant service method (signIn, register, createRequest, etc.) and sets `_loading = true` while waiting

---

### 11. CircularProgressIndicator
- **What it is:** A spinning loading indicator.
- **Used in:**
  - Inside `LoadingButton` when an async operation is running
  - HomeScreen while donor list is loading from Firestore
  - ProfileScreen while user data is loading
  - AppDrawer header while user profile loads
  - SplashScreen at the bottom

---

### 12. CircleAvatar
- **What it is:** A circular container — used for profile pictures and initials.
- **Used in:** AppDrawer header, DonorCard, ProfileScreen
- **Connection:** Shows `CachedNetworkImageProvider(user.photoUrl)` if a photo exists, otherwise shows the first letter of the user's name as text

---

### 13. Container
- **What it is:** A box that can have color, padding, margin, border radius, and decoration.
- **Used in:**
  - SplashScreen: white circle holding the blood icon
  - HomeScreen: red header banner with greeting and filter dropdown
  - SignInScreen/RegisterScreen: red error banner
  - DonorCard: red blood group badge
  - MyRequestsScreen: blood group badge, status badge
  - DonateScreen: gradient availability status card

---

### 14. SingleChildScrollView
- **What it is:** Makes its child scrollable when content overflows the screen height.
- **Used in:** SignInScreen, RegisterScreen, BloodRequestScreen, ProfileScreen, DonateScreen
- **Why:** Form screens have many fields that may not fit on small screens

---

### 15. SafeArea
- **What it is:** Adds padding to avoid system UI elements (status bar, notch, home indicator).
- **Used in:** SignInScreen, SplashScreen, AppDrawer

---

### 16. Form + GlobalKey
- **What it is:** A container that groups TextFormFields and enables collective validation.
- **Used in:** SignInScreen, RegisterScreen, BloodRequestScreen, ProfileScreen edit mode
- **Connection:**
```dart
final _formKey = GlobalKey<FormState>();
// On submit:
if (!_formKey.currentState!.validate()) return; // checks all fields at once
```

---

### 17. Stack
- **What it is:** Layers widgets on top of each other.
- **Used in:** ProfileScreen — places the camera icon badge on top of the CircleAvatar

---

### 18. Positioned
- **What it is:** Places a child at a specific position inside a Stack.
- **Used in:** ProfileScreen — positions the camera icon at bottom-right of the avatar

---

### 19. FloatingActionButton.extended
- **What it is:** A floating button with an icon and label.
- **Used in:** HomeScreen — only visible for Receiver role users, navigates to BloodRequestScreen

---

### 20. IconButton
- **What it is:** A tappable icon.
- **Used in:** SignInScreen/RegisterScreen (password visibility toggle), HomeScreen AppBar (profile navigation), DonorCard (phone call button)

---

### 21. TextButton
- **What it is:** A flat text-only button.
- **Used in:** SignInScreen ("Don't have an account? Register"), RegisterScreen ("Already have an account? Sign In"), ProfileScreen ("Cancel" in edit mode)

---

### 22. ListTile
- **What it is:** A standard row with leading icon, title, and onTap.
- **Used in:** AppDrawer for each menu item (Home, Profile, My Requests, Donate, Logout)

---

### 23. Divider
- **What it is:** A thin horizontal line separator.
- **Used in:** AppDrawer (between menu items and logout), DonateScreen info card

---

### 24. Chip
- **What it is:** A small label pill — used for tags and filters.
- **Used in:** HomeScreen — shows the active blood group filter with an X to clear it

---

### 25. GestureDetector
- **What it is:** Detects touch gestures (tap, long press, etc.) on any widget.
- **Used in:** ProfileScreen — wraps the CircleAvatar so tapping it opens the image picker when in edit mode. BloodRequestScreen — wraps the date field to open the date picker.

---

### 26. AbsorbPointer
- **What it is:** Prevents its child from receiving touch events.
- **Used in:** BloodRequestScreen — wraps the date TextFormField so tapping it triggers GestureDetector instead of opening the keyboard

---

### 27. FadeTransition + ScaleTransition
- **What it is:** Animation widgets that animate opacity and scale respectively.
- **Used in:** SplashScreen — the logo fades in and scales up with an elastic bounce effect using `AnimationController`

---

### 28. LinearGradient (inside BoxDecoration)
- **What it is:** A color gradient from one color to another.
- **Used in:** DonateScreen — the availability status card uses a red gradient when available, grey gradient when unavailable

---

### 29. CachedNetworkImage / CachedNetworkImageProvider
- **What it is:** Loads images from a URL and caches them locally so they don't re-download.
- **Used in:** DonorCard, ProfileScreen
- **Connection:** The URL comes from `user.photoUrl` which is stored in Firestore after uploading to Firebase Storage

---

### 30. SnackBar
- **What it is:** A temporary message that appears at the bottom of the screen.
- **Used in:** DonateScreen (availability toggle feedback), BloodRequestScreen (success/error), ProfileScreen (save success/error)
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Profile updated!'), backgroundColor: Colors.green),
);
```

---

### 31. DatePicker (showDatePicker)
- **What it is:** A built-in Flutter dialog for selecting a date.
- **Used in:** BloodRequestScreen — user picks the date blood is needed

---

### 32. OutlinedButton
- **What it is:** A button with a border outline and transparent background.
- **Used in:** MyRequestsScreen ("Mark Fulfilled", "Cancel" buttons), ProfileScreen logout button

---

### 33. RichText + TextSpan
- **What it is:** Text with mixed styles in one line.
- **Used in:** SignInScreen and RegisterScreen — "Don't have an account? **Register**" where Register is bold and red

---

### 34. Expanded + Flexible
- **What it is:** Makes a child fill available space inside Row/Column.
- **Used in:** DonorCard (donor info takes remaining space), AppDrawer header (name/email column fills space next to avatar), MyRequestsScreen (action buttons split equally)

---

### 35. SizedBox
- **What it is:** A fixed-size empty box used for spacing.
- **Used in:** Every screen — adds vertical/horizontal gaps between widgets instead of using padding everywhere

---

## Section B: CRUD Operations in This Project

CRUD = **C**reate, **R**ead, **U**pdate, **D**elete

---

### CREATE

**1. Register a new user**
- File: `lib/features/auth/services/auth_service.dart`
- Trigger: User fills RegisterScreen and taps "Create Account"
- What happens:
```dart
// Creates Firebase Auth account
await _auth.createUserWithEmailAndPassword(email, password);

// Creates Firestore document
await _db.collection('users').doc(uid).set(user.toMap());
```

**2. Submit a blood request**
- File: `lib/features/requests/services/request_service.dart`
- Trigger: Receiver fills BloodRequestScreen and taps "Submit Request"
- What happens:
```dart
await _db.collection('blood_requests').add(request.toMap());
// .add() auto-generates a document ID
```

---

### READ

**1. Load donor list (real-time)**
- File: `lib/features/donors/services/donor_service.dart`
- Trigger: HomeScreen opens, or blood group filter changes
- What happens:
```dart
return _db.collection('users')
    .where('role', isEqualTo: 'Donor')
    .where('isAvailable', isEqualTo: true)
    .snapshots(); // real-time stream
```

**2. Load current user profile**
- File: `lib/features/auth/services/auth_service.dart`
- Trigger: Any screen that calls `ref.watch(currentUserProfileProvider)`
- What happens:
```dart
final doc = await _db.collection('users').doc(uid).get();
return UserModel.fromDoc(doc);
```

**3. Load my blood requests (real-time)**
- File: `lib/features/requests/services/request_service.dart`
- Trigger: MyRequestsScreen opens
- What happens:
```dart
return _db.collection('blood_requests')
    .where('requesterId', isEqualTo: uid)
    .orderBy('createdAt', descending: true)
    .snapshots();
```

---

### UPDATE

**1. Edit user profile**
- File: `lib/features/auth/services/auth_service.dart`
- Trigger: User edits ProfileScreen and taps "Save Changes"
- What happens:
```dart
await _db.collection('users').doc(uid).update({
  'name': newName,
  'phone': newPhone,
  'location': newLocation,
  'bloodGroup': newBloodGroup,
  'photoUrl': newPhotoUrl,
});
```

**2. Toggle donor availability**
- File: `lib/features/donors/services/donor_service.dart`
- Trigger: Donor taps "Mark as Available/Unavailable" on DonateScreen
- What happens:
```dart
await _db.collection('users').doc(uid).update({'isAvailable': available});
```

**3. Update blood request status**
- File: `lib/features/requests/services/request_service.dart`
- Trigger: User taps "Mark Fulfilled" on MyRequestsScreen
- What happens:
```dart
await _db.collection('blood_requests').doc(requestId).update({'status': 'fulfilled'});
```

---

### DELETE

**1. Cancel/delete a blood request**
- File: `lib/features/requests/services/request_service.dart`
- Trigger: User taps "Cancel" on MyRequestsScreen
- What happens:
```dart
await _db.collection('blood_requests').doc(requestId).delete();
```

---

### CRUD Summary Table

| Operation | Where | Firestore Method |
|---|---|---|
| CREATE user | Register screen | `.set()` |
| CREATE blood request | Blood Request screen | `.add()` |
| READ donors (live) | Home screen | `.snapshots()` |
| READ user profile | All screens via provider | `.get()` |
| READ my requests (live) | My Requests screen | `.snapshots()` |
| UPDATE profile | Profile screen | `.update()` |
| UPDATE availability | Donate screen | `.update()` |
| UPDATE request status | My Requests screen | `.update()` |
| DELETE request | My Requests screen | `.delete()` |

---

## Section C: Step-by-Step Guide to Build a Similar Project from Scratch

Follow these steps in order if you want to build another Flutter + Firebase app.

---

### Step 1 — Create the Flutter project
```bash
flutter create your_app_name --org com.yourname --platforms android,ios,web
```

---

### Step 2 — Set up Firebase
1. Go to console.firebase.google.com → create a new project
2. Enable Authentication → Email/Password
3. Create Firestore Database → start in test mode
4. Enable Storage
5. Run:
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```
This generates `lib/firebase_options.dart` automatically.

---

### Step 3 — Add dependencies to pubspec.yaml
```yaml
dependencies:
  firebase_core: ^3.1.0
  firebase_auth: ^5.1.0
  cloud_firestore: ^5.1.0
  firebase_storage: ^12.1.0
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  go_router: ^14.1.4
  google_fonts: ^6.2.1
  image_picker: ^1.1.2
  cached_network_image: ^3.3.1
  intl: ^0.19.0
  url_launcher: ^6.3.0

dev_dependencies:
  build_runner: ^2.4.11
  riverpod_generator: ^2.4.3
```
Then run: `flutter pub get`

---

### Step 4 — Create folder structure
```
lib/
├── core/constants/
├── core/theme/
├── core/router/
├── features/auth/models/
├── features/auth/services/
├── features/auth/providers/
├── features/auth/screens/
├── features/[feature]/models/
├── features/[feature]/services/
├── features/[feature]/providers/
├── features/[feature]/screens/
└── widgets/
```

---

### Step 5 — Define constants
Create `core/constants/app_constants.dart` with:
- Collection names (so you never hardcode strings)
- Dropdown lists (blood groups, roles, categories)
- App name and other fixed values

---

### Step 6 — Define theme
Create `core/theme/app_theme.dart` with:
- Primary color
- `ThemeData` for light and dark
- Consistent button, input, and card styles

---

### Step 7 — Create data models
For each Firestore collection, create a model class with:
- All fields as `final` properties
- `fromDoc(DocumentSnapshot)` factory constructor
- `toMap()` method
- `copyWith()` method for updates

---

### Step 8 — Create services
For each feature, create a service class that:
- Has a `FirebaseFirestore` or `FirebaseAuth` instance
- Contains all database methods (no UI logic here)
- Returns `Future` for one-time operations
- Returns `Stream` for real-time operations
- Annotate with `@riverpod` for auto provider generation

---

### Step 9 — Create providers
For each service and state, create providers:
- `@riverpod` on a function → generates `FutureProvider` or `StreamProvider`
- `class X extends _$X` → generates `NotifierProvider` for mutable state
- Run `dart run build_runner build` to generate `.g.dart` files

---

### Step 10 — Set up routing
Create `core/router/app_router.dart`:
- Define all route paths as constants
- List all `GoRoute` entries
- Add redirect logic for auth guard

---

### Step 11 — Build screens one by one
Order to build:
1. SplashScreen (simplest — just UI and a timer)
2. SignInScreen (Firebase Auth login)
3. RegisterScreen (Firebase Auth + Firestore write)
4. HomeScreen (Firestore read + list)
5. Feature-specific screens (request, donate, profile)

---

### Step 12 — Build reusable widgets
Extract repeated UI into `lib/widgets/`:
- Any button used in 2+ screens → make a widget
- Any card layout used in 2+ screens → make a widget
- Navigation drawer → always a separate widget

---

### Step 13 — Connect main.dart
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: YourApp()));
}
```

---

### Step 14 — Test each feature
Test in this order:
1. Register a new user → check Firebase Console Auth tab
2. Check Firestore → users collection → verify document created
3. Sign out and sign back in
4. Test role-based UI differences
5. Submit a blood request → check blood_requests collection
6. Test update and delete operations

---

### Step 15 — Tighten Firestore security rules
Before sharing or deploying, replace test mode rules with proper rules that only allow users to read/write their own data.

---

*End of Documentation*
