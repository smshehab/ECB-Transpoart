# Firebase Setup

## Client configuration

1. Create a Firebase project and register Android, iOS, and Web applications.
2. Enable Email/Password in Authentication.
3. Create Cloud Firestore, Realtime Database, and Storage in the intended region.
4. Copy `firebase/firebase_config.example.json` to `firebase/firebase_config.json` and replace the placeholders with the correct client configuration values from Firebase project settings. Use the Android, iOS, and Web app IDs separately; the API key, project ID, sender ID, database URL, and storage bucket belong to the Firebase project.
5. Build from the relevant app directory with `--dart-define-from-file=../../firebase/firebase_config.json`.
6. Enable App Check. Add a reCAPTCHA v3 site key to `FIREBASE_APP_CHECK_SITE_KEY` for Web. For Android release builds configure Play Integrity; for iOS configure DeviceCheck/App Attest as appropriate. Debug builds use the Firebase App Check debug provider; register its debug token in the Firebase console.
7. Deploy reviewed rules and indexes from the repository root with `firebase deploy --project YOUR_FIREBASE_PROJECT_ID --config firebase/firebase.json --only firestore:rules,firestore:indexes,database,storage`.

## Authentication and roles

Enable Email/Password authentication. Passenger self-registration creates a passenger profile. Driver and administrator accounts must be provisioned by a trusted Firebase administrative process and assigned custom claims (`driver`, `transport_admin`, or `super_admin`). The client never writes custom claims. The driver app verifies the `driver` claim before showing its workspace; the web admin verifies an administrator claim before showing management tools.

The Realtime Database `driver_assignments/{uid}` mirror must be written by an administrator with the assigned `busId` and active `activeTripId`. The admin web tool checks the Firestore trip is active and that its driver and bus IDs match before activating the RTDB assignment. The driver cannot set these values; after completing a trip, the driver can only clear their own active trip field.

## Push notifications

The client requests notification permission and registers its FCM token under the authenticated user's private notification-token subcollection. Foreground notification messages are surfaced in-app; background notification payloads are handled by the operating system. Sending trusted messages to other users requires an authorized server or operator process. Do not send privileged announcements from a passenger or driver client.

## Secrets and billing

No service-account key is included. Firebase client configuration values are not service-account credentials, but restrict API keys to the required APIs and application identifiers. Trusted scheduled notifications and privileged account provisioning require a trusted backend or Firebase administrative workflow and may incur separate billing. Cloud Functions are not assumed available on the free plan.
