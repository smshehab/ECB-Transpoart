import argparse
import os
import sys

import firebase_admin
from firebase_admin import auth, credentials


ALLOWED_ROLES = ("passenger", "driver", "transport_admin", "super_admin")


def main():
    parser = argparse.ArgumentParser(
        description="Assign a Firebase Authentication custom role to an existing user."
    )
    parser.add_argument("--email", required=True, help="Existing Firebase user email")
    parser.add_argument("--role", required=True, choices=ALLOWED_ROLES)
    args = parser.parse_args()

    service_account_path = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS")
    if not service_account_path or not os.path.isfile(service_account_path):
        print("Set GOOGLE_APPLICATION_CREDENTIALS to a local service-account JSON path.", file=sys.stderr)
        return 2

    credential = credentials.Certificate(service_account_path)
    if not firebase_admin._apps:
        firebase_admin.initialize_app(credential)

    user = auth.get_user_by_email(args.email)
    claims = dict(user.custom_claims or {})
    claims["role"] = args.role
    auth.set_custom_user_claims(user.uid, claims)

    print(f"Updated role for {user.email}: {args.role}")
    print("The user must sign out and sign in again to refresh the ID token.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
