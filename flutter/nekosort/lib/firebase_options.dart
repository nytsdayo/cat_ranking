// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    /*
          apiKey: "AIzaSyDAQRm-GaPz4BBCnHrti-A8uu9ZRReNgKE",
      authDomain: "flask-project-1f3cb.firebaseapp.com",
      projectId: "flask-project-1f3cb",
      storageBucket: "flask-project-1f3cb.appspot.com",
      messagingSenderId: "55381721876",
      appId: "1:55381721876:web:59e595414a6d8ee20bb801",
      measurementId: "G-HY3JB5WT20"
    */
    if (kIsWeb) {
      return FirebaseOptions(
          apiKey: "AIzaSyDAQRm-GaPz4BBCnHrti-A8uu9ZRReNgKE",
      authDomain: "flask-project-1f3cb.firebaseapp.com",
      projectId: "flask-project-1f3cb",
      storageBucket: "flask-project-1f3cb.appspot.com",
      messagingSenderId: "55381721876",
      appId: "1:55381721876:web:59e595414a6d8ee20bb801",
      measurementId: "G-HY3JB5WT20"
      );
    } else {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          return FirebaseOptions(
          apiKey: "AIzaSyDAQRm-GaPz4BBCnHrti-A8uu9ZRReNgKE",
      authDomain: "flask-project-1f3cb.firebaseapp.com",
      projectId: "flask-project-1f3cb",
      storageBucket: "flask-project-1f3cb.appspot.com",
      messagingSenderId: "55381721876",
      appId: "1:55381721876:web:59e595414a6d8ee20bb801",
          );
        case TargetPlatform.iOS:
          return FirebaseOptions(
          apiKey: "AIzaSyDAQRm-GaPz4BBCnHrti-A8uu9ZRReNgKE",
      authDomain: "flask-project-1f3cb.firebaseapp.com",
      projectId: "flask-project-1f3cb",
      storageBucket: "flask-project-1f3cb.appspot.com",
      messagingSenderId: "55381721876",
      appId: "1:55381721876:web:59e595414a6d8ee20bb801",
      measurementId: "G-HY3JB5WT20"
          );
        default:
          throw UnsupportedError(
            'Unsupported platform $defaultTargetPlatform');
      }
    }
  }
}
