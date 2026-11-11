# System Architecture

## Applications

The platform has three role-oriented experiences in a shared Flutter codebase: passenger mobile, driver mobile, and administrator web. Each feature follows Presentation, Domain, and Data boundaries. Shared packages contain cross-cutting UI, domain contracts, and Firebase adapters.

## Client architecture

- Presentation: screens, reusable widgets, Riverpod providers, and controllers.
- Domain: entities, repository contracts, use cases, and validation rules.
- Data: Firebase data sources, DTOs, serialization, and repository implementations.
- Core: routing, theme, error mapping, configuration, and shared utilities.

## Data services

Cloud Firestore stores profiles, fleet inventory, routes, stops, schedules, trip records, announcements, and notification inbox entries. Realtime Database stores the latest active bus position and a server-managed driver assignment mirror used by RTDB rules. Firebase Authentication identifies users. Custom claims provide trusted role authorization; clients cannot set claims.

## Live tracking flow

1. A driver signs in and loads the server-provisioned assignment.
2. The driver explicitly starts an assigned trip after validation.
3. The app requests foreground/background location permissions and displays tracking state.
4. Geolocator updates are validated and published to the assigned bus node in Realtime Database.
5. Passenger and admin clients subscribe to permitted live bus nodes.
6. The UI marks locations stale when updates exceed a configured age.
7. Completing or pausing a trip stops or suspends publishing. Trusted assignment state must be updated by an authorized administrative process.

## Trust boundaries

Firestore and RTDB rules are mandatory enforcement points. Role claims and driver assignment mirrors must be provisioned by a trusted administrative environment. Client-only checks are UX controls, not security controls. FCM trusted notifications and privileged provisioning require a trusted server process; no Node.js application backend is introduced by this client architecture.
