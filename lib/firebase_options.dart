// Opciones de Firebase del proyecto rtoc-3a846.
// Equivalen a android/app/google-services.json y a
// ios/Runner/GoogleService-Info.plist; si esos archivos cambian, actualiza
// también estos valores.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('La app no está configurada para web.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'Firebase no está configurado para $defaultTargetPlatform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCIJgtu4mui9OC02nEYvcL-NXY8frGxjdI',
    appId: '1:377708066925:android:8e1d4bae072a21de4ee764',
    messagingSenderId: '377708066925',
    projectId: 'rtoc-3a846',
    databaseURL: 'https://rtoc-3a846.firebaseio.com',
    storageBucket: 'rtoc-3a846.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC0F0JTnNWvNTmZqKpOFx1sm-x8pB4yO4A',
    appId: '1:377708066925:ios:1b0ca706a00dabc04ee764',
    messagingSenderId: '377708066925',
    projectId: 'rtoc-3a846',
    databaseURL: 'https://rtoc-3a846.firebaseio.com',
    storageBucket: 'rtoc-3a846.firebasestorage.app',
    iosBundleId: 'com.bepensa.sostenibilidadapp',
  );
}
