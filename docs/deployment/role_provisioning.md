# Firebase role provisioning

Firebase Authentication custom claims are the source of truth for application roles. Never let a client app write its own role or accept a role from a registration form.

Supported roles:

- `passenger`: standard passenger access
- `driver`: driver trip and assigned GPS access
- `transport_admin`: fleet, route, schedule, trip, and assignment administration
- `super_admin`: all administrator permissions, including app settings and user deletion

## One-time setup

1. Create or select the Firebase project used by this repository.
2. In Firebase Console, open Project settings → Service accounts.
3. Generate a private key for a dedicated, trusted administrator workstation.
4. Store the JSON file outside the repository. Do not upload it to GitHub, commit it, or share it in chat.
5. Install Python 3.10 or newer, then run:

```powershell
py -m venv .venv
.\.venv\Scripts\Activate.ps1
py -m pip install -r tools/requirements.txt
$env:GOOGLE_APPLICATION_CREDENTIALS = "C:\secure\firebase-admin-service-account.json"
py tools/provision_user_role.py --email "admin@example.com" --role super_admin
```

For Linux/macOS, activate the virtual environment with `source .venv/bin/activate` and set the environment variable to the protected local key path.

Run the same command with `--role driver` for an existing driver account, or `--role transport_admin` for an operations administrator. Create the user's Firebase Authentication account first; the script updates claims on an existing account only.

After a role change, the user must sign out and sign in again so Firebase issues a fresh ID token. The admin web app accepts only `transport_admin` and `super_admin`; the mobile driver portal accepts only `driver`; the passenger portal accepts `passenger` or accounts without a role claim.

## Operational safeguards

- Keep the service-account key on a trusted administrator workstation or secret manager.
- Limit access to the service account and rotate its key if it is exposed.
- Do not add a service-account key to GitHub Actions or the Flutter app.
- Do not place custom claims in Firestore profile documents as a substitute for ID-token claims.
- Review Firebase Authentication audit events and remove privileged roles when staff access ends.

The utility is a local provisioning tool, not an application backend or a public API.
