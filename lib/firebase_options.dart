import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with Firebase.initializeApp.
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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBiVl6o-Msb3KUNK9vIhC-kVQCeQnS1wWk',
    appId: '1:150681432353:android:90dcb5ce491f28f2010e60',
    messagingSenderId: '150681432353',
    projectId: 'trinco-staff-registry',
    storageBucket: 'trinco-staff-registry.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBiVl6o-Msb3KUNK9vIhC-kVQCeQnS1wWk',
    appId: '1:150681432353:android:90dcb5ce491f28f2010e60',
    messagingSenderId: '150681432353',
    projectId: 'trinco-staff-registry',
    storageBucket: 'trinco-staff-registry.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBiVl6o-Msb3KUNK9vIhC-kVQCeQnS1wWk',
    appId: '1:150681432353:android:90dcb5ce491f28f2010e60',
    messagingSenderId: '150681432353',
    projectId: 'trinco-staff-registry',
    storageBucket: 'trinco-staff-registry.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBiVl6o-Msb3KUNK9vIhC-kVQCeQnS1wWk',
    appId: '1:150681432353:android:90dcb5ce491f28f2010e60',
    messagingSenderId: '150681432353',
    projectId: 'trinco-staff-registry',
    storageBucket: 'trinco-staff-registry.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBiVl6o-Msb3KUNK9vIhC-kVQCeQnS1wWk',
    appId: '1:150681432353:android:90dcb5ce491f28f2010e60',
    messagingSenderId: '150681432353',
    projectId: 'trinco-staff-registry',
    storageBucket: 'trinco-staff-registry.firebasestorage.app',
  );
}
