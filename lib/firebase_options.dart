import 'package:firebase_core/firebase_core.dart';

// عمّر هاد القيم من Firebase Console > Project settings > Your apps > Android
class DefaultFirebaseOptions {
  static const FirebaseOptions current = FirebaseOptions(
    apiKey: 'PUT_API_KEY',
    appId: 'PUT_APP_ID',
    messagingSenderId: 'PUT_SENDER_ID',
    projectId: 'PUT_PROJECT_ID',
    storageBucket: 'PUT_PROJECT_ID.appspot.com',
  );
}
