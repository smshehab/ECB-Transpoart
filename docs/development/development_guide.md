# Development Guide

## Workspace status

The repository currently contains the initial Flutter app shells and Firebase rule baselines. Passenger, driver, and admin screens are scaffolds, not completed production workflows.

## Mobile

```bash
cd apps/mobile
flutter pub get
flutterfire configure
flutter run
```

## Admin web

```bash
cd apps/admin_web
flutter pub get
flutterfire configure
flutter run -d chrome
```

## Quality checks

Run `dart format .`, `flutter analyze`, and `flutter test` from each app directory after installing Flutter. Run Firebase Emulator Suite rule tests before deploying rules to a live project.

## Security prerequisites

Provision custom claims and driver assignment mirrors only through a trusted operator-controlled process. Never test privileged workflows with client-editable role fields. Do not use production user data in local development.
