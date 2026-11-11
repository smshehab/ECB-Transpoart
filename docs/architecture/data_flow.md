# Data Flow

## Passenger authentication

The passenger signs up or signs in with Firebase Authentication. The client creates or reads only the authenticated user's profile. Firestore rules prevent clients from setting roles or changing privileged account fields.

## Driver trip and location flow

1. A trusted administrator creates the trip with `driverId`, `busId`, `routeId`, and `status: scheduled`.
2. The driver signs in. The mobile app refreshes the ID token and requires the `driver` custom claim.
3. The driver starts the assigned trip. The trip repository checks the signed-in UID and expected state in a Firestore transaction.
4. An administrator activates the RTDB assignment mirror only after verifying the Firestore trip is active.
5. The driver explicitly enables location sharing. Geolocator readings with poor accuracy are discarded; accepted readings are written to `live_buses/{busId}`.
6. Passengers subscribe to permitted live bus data and see location age/status. Positions older than two minutes are labelled stale.
7. Pausing the trip stops the stream and marks the live bus paused. Completing the trip removes the live bus node and lets the driver clear only their own active assignment mirror.

## Admin data management

An administrator signs in with Firebase Authentication and a verified `transport_admin` or `super_admin` custom claim. The dashboard reads counts and provides create/read/update/delete controls for supported management collections. User and trip views are read-only in this client; privileged account provisioning remains a trusted administrative task.

## Notifications

The client requests notification permission and stores its FCM token under the signed-in user's private token subcollection. Foreground notification payloads are shown through the app messenger. Background notification payloads are displayed by the operating system. The client does not send privileged notifications.
