import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Placeholder — web not configured
  static const FirebaseOptions web = FirebaseOptions(
      apiKey: "AIzaSyAFHRrs5XpEHk0oAFveBOCK9C3y9Rs991A",
      authDomain: "blood-link-app-d820f.firebaseapp.com",
      projectId: "blood-link-app-d820f",
      storageBucket: "blood-link-app-d820f.firebasestorage.app",
      messagingSenderId: "296909417789",
      appId: "1:296909417789:web:c5dc7f8a0e81e58ff0e954"
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAMR4mybNQsh7wKo552kXaYsr4eAMolYFc',
    appId: '1:296909417789:android:c82311535595968df0e954',
    messagingSenderId: '296909417789',
    projectId: 'blood-link-app-d820f',
    storageBucket: 'blood-link-app-d820f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBdEhD1-kewotiTBGi9PgopAHHdaZ0u-PA',
    appId: '1:296909417789:ios:0d2a2cd5e71c5831f0e954',
    messagingSenderId: '296909417789',
    projectId: 'blood-link-app-d820f',
    storageBucket: 'blood-link-app-d820f.firebasestorage.app',
    iosBundleId: 'com.example.bloodDonationApp',
  );

}