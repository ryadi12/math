# Ecole App (Flutter + Firebase)

## 1. Firebase (mra whda)
1. console.firebase.google.com > Create project.
2. Build > Authentication > Sign-in method > **Email/Password** (enable).
3. Build > Firestore Database > Create (production mode) > Rules > copy `firestore.rules`.
4. Build > Storage > Get started > Rules:
   ```
   rules_version = '2';
   service firebase.storage {
     match /b/{b}/o {
       match /series/{allPaths=**} {
         allow read: if request.auth != null;
         allow write: if request.auth != null &&
           firestore.get(/databases/(default)/documents/users/$(request.auth.uid)).data.role == 'admin';
       }
     }
   }
   ```
5. Project settings > Add app > **Android** (package: `com.ecole.ecole_app`). Copy apiKey, appId, senderId, projectId to `lib/firebase_options.dart`.

## 2. Compte admin (nta)
- Authentication > Users > Add user (email + password dyalek).
- Copy l'UID, then Firestore > collection `users` > doc id = UID > field `role` = `admin` (string).

## 3. GitHub
Push l'project, then Actions > "Build APK" > telecharge `ecole-app-apk`.

## 4. Tlamd
Mn l'app: Tlamd > khtar classe > (+) > smiya, code, mot de passe. L'tilmid kay-dkhl b code + mot de passe.
