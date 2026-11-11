# Development Guide

## Prerequisites

Install Flutter stable, Dart, Firebase CLI, and (for iOS builds) Xcode. Verify Flutter with `flutter doctor`.

## Mobile app

From the repository root:

```bash
cd apps/mobile
bash tool/bootstrap_platforms.sh
flutter pub get
flutter run --dart-define-from-file=../../firebase/firebase_config.json
```

The bootstrap script creates Android, iOS, and Web platform scaffolding and applies the location usage configuration templates. Review native permissions and test on real devices.

## Admin web

```bash
cd apps/admin_web
flutter create --platforms=web .
flutter pub get
flutter run -d chrome --dart-define-from-file=../../firebase/firebase_config.json
```

## Firebase

Copy `firebase/firebase_config.example.json` to `firebase/firebase_config.json` and enter values for your own Firebase project. Deploy reviewed rules from the repository root with `firebase deploy --config firebase/firebase.json` and the required target selectors.

Provision driver/admin custom claims and `driver_assignments` through a trusted Firebase administrative process. Do not grant roles from the client.

## Quality checks

Run `dart format lib test`, `flutter analyze`, and `flutter test` from each app directory. From `firebase/`, run `npm install` and `npx firebase-tools emulators:exec --only firestore --project ecb-transport-rules-test "npm test"` for Firestore rules tests.

## Known gaps

The current UI does not yet provide route-stop editing, historical GPS playback, ETA computation, report export, or trusted server-originated notification sending. See the security model and testing strategy before production deployment.
