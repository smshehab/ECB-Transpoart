# Firebase Setup

## Client configuration

1. Create a Firebase project and register Android, iOS, and Web applications.
2. Enable Email/Password in Authentication.
3. Create Cloud Firestore, Realtime Database, and Storage in the intended region.
4. Copy `firebase/firebase_config.example.json` to `firebase/firebase_config.json` and replace the placeholders with the correct client configuration values from Firebase project settings. Use the Android, iOS, and Web app IDs separately; the API key, project ID, sender ID, database URL, and storage bucket belong to the Firebase project. This file is ignored by Git.
5. Build from the relevant app directory with `--dart-define-from-file=../../firebase/firebase_config.json`.
6. Enable App Check. Add a reCAPTCHA v3 site key to `FIREBASE_APP_CHECK_SITE_KEY` for Web. For Android release builds configure Play Integrity; for iOS configure DeviceCheck/App Attest as appropriate. Debug builds use the Firebase App Check debug provider; register its debug token in the Firebase console.
7. Deploy rules and indexes from the repository root using `firebase deploy --config firebase/firebase.json --only firestore:rules,firestore:indexes,database,storage` after reviewing the project and database instance.

## Authentication and roles

Enable Email/Password authentication. Passenger self-registration creates a passenger profile. Driver and administrator accounts must be provisioned by a trusted operator and assigned Firebase custom claims (`driver`, `transport_admin`, or `super_admin`). The client never writes custom claims. The driver app verifies the `driver` claim before showing its workspace; the web admin verifies an administrator claim before showing management tools.

The Realtime Database `driver_assignments/{uid}` mirror must also be written by a trusted administrative process with the assigned `busId` and current `activeTripId`. The client cannot create or edit this assignment mirror.

## Push notifications

The client requests notification permission and registers its FCM token under the authenticated user's private notification-token subcollection. Foreground notification messages are surfaced in-app; background notification payloads are handled by the operating system. Sending trusted messages to other users requires an authorized server or operator process. Do not send privileged announcements from a passenger or driver client.

## Secrets and billing

No service-account key is included. Firebase client configuration values are not service-account credentials, but restrict API keys to the required APIs and application identifiers. Trusted scheduled notifications and privileged account provisioning require a trusted backend or Firebase administrative workflow and may incur separate billing. Cloud Functions are not assumed available on the free plan.
