# Mobile Location Setup

The driver tracking service requests runtime location permission, verifies that location services are enabled, rejects readings with accuracy worse than 80 metres, and publishes only while an assigned trip is active in the app workflow.

On Android the service uses Geolocator's foreground notification configuration, wake lock, and a ten-second requested interval with a 15-metre distance filter. The platform bootstrap template declares fine/coarse/background location, foreground-service-location, notification, and wake-lock permissions. Android version and Play policy requirements vary; request background permission only when needed and explain the ongoing notification.

On iOS the service uses automotive navigation settings, keeps location updates active, and shows the system background-location indicator. The generated Info.plist template includes location usage descriptions and the location background mode. The user must grant the required Always permission in Settings for background updates; test the exact permission flow on a physical device.

Both platforms must visibly show when sharing is active. Stop publishing when the trip is paused or completed. Revoke permissions, kill/restart the app, enable battery saver, and test network loss/reconnection on physical devices before production. Background behavior is not considered production-verified until these tests pass.

OpenStreetMap's public tile endpoint is suitable for development with attribution and a compliant user agent; production deployments should select a tile provider with terms and capacity appropriate for expected traffic.
