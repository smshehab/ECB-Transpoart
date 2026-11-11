# ECB Transport

ECB Transport is a Flutter and Firebase public bus tracking and schedule management system. The application has exactly two roles: **ADMIN** and **NORMAL USER**. Guests can browse public transport data and view bus tracking without registering.

## Product rules

- Guest access: browse buses, routes, stops and schedules; view public bus tracking, bus status, speed and ETA where available.
- Normal user: register or sign in, select a bus and departure, then explicitly start or stop GPS sharing for that trip.
- Admin: manage buses, routes, stops, schedules and tracking settings.
- No driver role and no driver application.
- Location sharing is never started automatically.
- Multiple authenticated users may contribute location to the same trip.
- Default location update interval: 20 seconds.
- Offline position estimation is limited to five minutes from the last valid aggregated update. After that, show only the last known position and mark the current position unknown.

## Technology

- Flutter, Dart, Material Design 3, Riverpod, GoRouter
- Firebase Authentication, Cloud Firestore, Realtime Database, Cloud Messaging, Storage and App Check
- OpenStreetMap, flutter_map, latlong2 and Geolocator
- Feature-based Clean Architecture

## Repository layout

- `apps/mobile`: guest and normal-user Android/iOS application
- `apps/admin_web`: administrator Flutter Web dashboard
- `packages/ecb_shared`: shared role and location aggregation domain logic
- `firebase`: Firestore/Realtime Database/Storage rules, indexes and emulator tests
- `docs`: architecture, database, security, deployment and testing documentation

## Local setup

1. Install Flutter stable and verify with `flutter doctor`.
2. Copy `firebase/firebase_config.example.json` to `firebase/firebase_config.json` and add the client configuration from Firebase project settings.
3. Enable Email/Password Authentication. Create Firestore, Realtime Database and Storage. Configure FCM and App Check.
4. From `apps/mobile`, run `bash tool/bootstrap_platforms.sh`, then `flutter pub get`.
5. Run the mobile app with `flutter run --dart-define-from-file=../../firebase/firebase_config.json`.
6. From `apps/admin_web`, create the Web platform if needed, run `flutter pub get`, then `flutter run -d chrome --dart-define-from-file=../../firebase/firebase_config.json`.
7. Review and deploy Firebase rules and indexes with `firebase deploy --config firebase/firebase.json --only firestore:rules,firestore:indexes,database,storage`.

The local `firebase_config.json` is ignored by Git. Never commit service-account JSON or private credentials.

## Roles

Normal-user accounts self-register through Firebase Authentication. Admin access must be provisioned through a trusted Firebase Admin SDK process that sets the custom claim `role: admin`. Never let a client set its own admin claim. The Python provisioning utility in `tools/provision_user_role.py` must be aligned with this two-role model before production use.

## Location contribution and aggregation

Each signed-in user publishes an independent, pseudonymous contribution record under `trip_contributors/{tripId}/{contributorId}`. The ownership mapping is stored separately under `contributor_owners/{contributorId}`; public clients can read location observations but cannot read the mapping to a Firebase UID. A user can write only the contribution whose ownership mapping points to their authenticated UID.

The shared Dart aggregation engine rejects stale or inaccurate samples, removes coordinate outliers using a median-centred distance filter, and computes an accuracy- and age-weighted representative position. Each client can derive the same public position from the same contributor observations.

**Trusted-processing limitation:** with no trusted server process or Cloud Function, client-side aggregation is not an authoritative server-owned aggregate. A modified client can submit misleading GPS observations within the database rules. Production-grade anti-spoofing, server-authoritative aggregation, automatic contributor expiry and server-originated notifications require a trusted backend or equivalent managed service. This repository does not silently add Node.js or Cloud Functions.

## Offline estimation

Use the timestamp of the last valid aggregated update as the start of the five-minute window. Estimate along the configured route geometry using the last valid speed. Never reset the window on an invalid GPS sample. When five minutes have elapsed, stop moving the marker and show only the last known location with current position unknown. All estimates must be labelled as estimates, never as live GPS.

## Firebase configuration and cost

Firebase client configuration is not included. Firebase quotas and pricing depend on the selected plan, region, reads, writes, listeners and concurrent users. Do not enable paid billing without explicit approval. Public OpenStreetMap tiles are not unlimited production hosting; select a compliant tile provider for production.

## Verification

Run `flutter test` in each Flutter package, `flutter analyze`, and Firebase Emulator Suite security tests before deployment. GitHub changes are not considered tested until CI reports successful runs. Android foreground-service and iOS background-location behavior must be verified on physical devices and configured for current platform policies.
