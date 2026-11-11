# Realtime Database Schema

`live_buses/{busId}` stores only the latest location, not a location history:

- `latitude`, `longitude`: validated geographic coordinates
- `speed`, `heading`, `accuracy`: optional GPS measurements
- `updatedAt`: server timestamp in milliseconds
- `tripId`, `driverId`: current authorized trip and driver
- `status`: `active` or `paused`

`driver_assignments/{driverUid}` is a trusted administrative mirror containing `busId`, `activeTripId`, and `updatedAt`. Only administrators may create or change assignment values. A driver may only clear their own `activeTripId` after completing a trip; they cannot assign themselves a bus or trip.

Realtime Database rules validate the driver claim, assigned bus, trip ID, driver UID, coordinate ranges, and status. Passengers can read live bus nodes only after authentication. The app marks locations older than two minutes stale. Historical tracking is deliberately not stored in this live node.
