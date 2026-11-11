# Security Model

## Identity and roles

Firebase Authentication establishes identity. Custom claims `role=driver`, `role=transport_admin`, and `role=super_admin` are trusted authorization attributes. Passenger profile documents are not an authorization source. The client cannot write custom claims.

## Firestore

- Users can create and update only permitted fields in their own profile.
- Administrators can manage fleet, route, schedule, driver, and announcement collections.
- Drivers can update only their own assigned trip and only through allowed state transitions.
- Notification tokens are scoped to the owning user.
- Unmatched paths are denied by default.

## Realtime Database

- Live bus reads require authentication.
- A driver can publish only for the bus and trip in their trusted assignment mirror.
- Coordinates and telemetry values are validated.
- Drivers cannot create or change assignment values; they may clear their own active trip after completion.
- Admin assignment writes require an administrator custom claim.

## Storage

Profile image uploads are scoped to the owner, limited to image content types and 5 MB. Transport documents are administrator-managed. All other paths are denied.

## Operational trust boundary

The admin client is not a substitute for Firebase Admin SDK provisioning. Creating Auth users, setting custom claims, disabling accounts, and sending trusted FCM messages require an authorized operator or trusted backend. Cloud Functions are not assumed available on the free plan. App Check must be configured and enforced in the Firebase console after registering app attestation providers and reCAPTCHA.

## Tests

`firebase/tests/security.test.mjs` contains Firestore Emulator tests for profile ownership, role escalation prevention, unauthenticated reads, and admin-only fleet writes. Realtime Database and Storage emulator tests should be added before production deployment.
