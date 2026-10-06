// File generated for Firebase Options
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAOL4dZEZqNtj3M1Je3C44DGAaU6ZxbCO8',
    appId: '1:886975897845:web:60158e1e64b8b3b888a5bc',
    messagingSenderId: '886975897845',
    projectId: 'cyclego-fd4d2',
    authDomain: 'cyclego-fd4d2.firebaseapp.com',
    storageBucket: 'cyclego-fd4d2.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAOL4dZEZqNtj3M1Je3C44DGAaU6ZxbCO8',
    appId: '1:886975897845:android:60158e1e64b8b3b888a5bc',
    messagingSenderId: '886975897845',
    projectId: 'cyclego-fd4d2',
    storageBucket: 'cyclego-fd4d2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAOL4dZEZqNtj3M1Je3C44DGAaU6ZxbCO8',
    appId: '1:886975897845:ios:60158e1e64b8b3b888a5bc',
    messagingSenderId: '886975897845',
    projectId: 'cyclego-fd4d2',
    storageBucket: 'cyclego-fd4d2.firebasestorage.app',
  );
}
