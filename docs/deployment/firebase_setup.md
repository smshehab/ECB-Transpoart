# Firebase Setup

1. Create a Firebase project and register Android, iOS, and Web applications.
2. Enable Email/Password in Authentication.
3. Create Cloud Firestore, Realtime Database, and Storage in the intended region.
4. Enable App Check and configure supported platform attestation providers before enforcing it.
5. Install FlutterFire CLI and run `flutterfire configure` from each app directory.
6. Keep generated `firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist`, service-account files, and private credentials out of source control.
7. Deploy rules and indexes from the `firebase/` directory using the Firebase CLI after reviewing the project IDs and database instance.
8. Provision custom claims (`role`) and `driver_assignments/{uid}` through a trusted operator-controlled environment. Never allow a client to write these values.

The client repository intentionally does not include service-account credentials. FCM messages that must be trusted, scheduled, or sent to other users need a trusted backend or administrative process. Firebase Cloud Functions can incur separate billing and are not assumed to be available on the free plan.
