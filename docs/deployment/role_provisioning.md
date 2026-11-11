# Firebase role provisioning

ECB Transport has exactly two application roles: `admin` and `user`. Firebase Authentication custom claims are the trusted source of authorization. A client must never assign or change its own custom role.

- `admin`: may manage fleet data and use the Admin Web dashboard.
- `user`: may sign in to the mobile app and explicitly share GPS when that feature is enabled.
- Guest: has no Firebase account and can access only public read operations.

## One-time setup

1. Create or select the Firebase project used by this repository.
2. In Firebase Console, open Project settings → Service accounts.
3. Generate a private key for a dedicated, trusted administrator workstation.
4. Store the JSON file outside the repository. Never upload it to GitHub, commit it, or share it in chat.
5. Install Python 3.10 or newer, then run:

```powershell
py -m venv .venv
.\.venv\Scripts\Activate.ps1
py -m pip install -r tools/requirements.txt
$env:GOOGLE_APPLICATION_CREDENTIALS = "C:\secure\firebase-admin-service-account.json"
py tools/provision_user_role.py --email "admin@example.com" --role admin
```

For Linux/macOS, activate the virtual environment with `source .venv/bin/activate` and set the environment variable to the protected local key path.

Create the Firebase Authentication account before running the utility. The script updates an existing account only. Use `--role user` for a standard account or `--role admin` for a trusted administrator. The utility preserves unrelated custom claims while replacing the application role.

New registrations create a Firestore profile with `role: user`. That profile field is not an authorization grant: only the trusted Firebase Admin SDK can grant the `admin` custom claim. Accounts without a role claim are treated as standard users for backward compatibility; legacy privileged claims such as `transport_admin` and `super_admin` do not grant administrator access.

After changing a role, the user must sign out and sign in again so Firebase issues a fresh ID token. Admin Web accepts only `role: admin`; the mobile app accepts standard users and denies admin or unknown legacy roles.

## Operational safeguards

- Keep the service-account key on a trusted administrator workstation or secret manager.
- Limit access to the service account and rotate its key if it is exposed.
- Never add a service-account key to GitHub Actions or the Flutter app.
- Never allow a client to write the `admin` custom claim.
- Review Firebase Authentication audit events and remove privileged roles when staff access ends.

The utility is a local provisioning tool, not an application backend or a public API.
