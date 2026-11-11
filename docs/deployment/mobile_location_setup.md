# Mobile Location Setup

The initial driver GPS service requests runtime location permission, verifies location services, filters readings with accuracy worse than 80 metres, and publishes while the app process is active. It is not yet a background tracking service.

Before production use, configure Android manifest permissions for fine/coarse location and the required foreground service location permissions/service declaration for the target Android SDK. Add the required iOS usage descriptions and background location capability only if the product needs it. Explain location use to drivers, request only necessary permissions, and test permission denial, revocation, battery saver, process termination, and network loss on physical devices.

The app must visibly show when sharing is active. Do not enable hidden tracking. Stop publishing on trip completion and ensure the trusted assignment mirror is cleared by an authorized process.

OpenStreetMap's public tile endpoint is suitable for development with attribution and a compliant user agent; production deployments should select a tile provider with terms and capacity appropriate for expected traffic.
