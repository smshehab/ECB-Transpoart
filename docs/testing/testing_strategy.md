# Testing Strategy

## Automated checks

The Flutter CI workflow generates platform scaffolding, runs `dart format`, `flutter analyze`, and `flutter test` for the mobile app, then builds an Android debug APK. It separately formats, analyzes, and builds the Admin Web app.

Mobile tests currently cover role claim parsing, trip status parsing, and the missing-Firebase configuration smoke state.

The Firebase rules workflow starts the Firestore Emulator and runs tests for user profile ownership, attempted role escalation, unauthenticated reads, and administrator-only fleet writes.

## Required additional tests

Before production, add integration tests for sign-up/login/password reset, driver custom-claim rejection, trip state transitions against Firestore Emulator, RTDB assignment enforcement, GPS permission denial/revocation, stale bus handling, FCM token rotation, and admin CRUD authorization. Add RTDB and Storage emulator rules tests and test on physical Android/iOS devices.

## Evidence policy

A workflow file is not evidence of a passing test. Use GitHub Actions run results to report actual status. This environment can push source changes but cannot run Flutter, Dart, or Firebase emulators locally.
