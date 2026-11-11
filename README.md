# ECB Transport

A Flutter and Firebase public transport management platform with passenger, driver, and administrator experiences and consent-based live bus tracking.

## Architecture

- Flutter and Dart with Material Design 3
- Riverpod state management and GoRouter navigation
- Feature-based Clean Architecture
- Firebase Authentication, Cloud Firestore, Realtime Database, Cloud Messaging, Storage, Security Rules, and App Check
- OpenStreetMap, flutter_map, latlong2, and Geolocator

## Applications

- `apps/mobile`: passenger and driver Android/iOS application
- `apps/admin_web`: responsive Flutter Web administrator application
- `packages/`: shared core, design system, domain, and Firebase data packages
- `firebase/`: database rules and indexes
- `docs/`: architecture, database, security, deployment, testing, and development guides

## Prerequisites

- Flutter stable SDK and compatible Dart SDK
- Firebase project with Authentication, Firestore, Realtime Database, Storage, FCM, and App Check configured
- FlutterFire CLI for platform configuration

## Setup

1. Install Flutter and verify with `flutter doctor`.
2. Configure Firebase for each target using FlutterFire CLI.
3. Enable Email/Password authentication and create the required Firebase databases.
4. Review and deploy the rules in `firebase/` before using real user data.
5. Run `flutter pub get` in the application workspace, then run the desired target.

Firebase credentials and generated platform configuration are environment-specific and must not be committed. See `docs/deployment/firebase_setup.md`.

## Security

Client-editable role fields are not authoritative. Administrative access must be provisioned through a trusted operator-controlled process. Database rules must enforce role claims, driver-to-bus assignments, and active-trip checks. Live tracking must be explicitly enabled by the driver and stop when the authorized trip ends.

## Operational limitations

Trusted server-originated push notifications, scheduled jobs, and privileged role provisioning require a trusted backend or operator-managed Firebase administrative workflow. Firebase Cloud Functions may have separate billing requirements. Clients must not impersonate trusted notifications or self-assign privileged roles. ETA values are estimates, not guaranteed arrival times. Public OpenStreetMap tile servers are not unlimited production infrastructure.
