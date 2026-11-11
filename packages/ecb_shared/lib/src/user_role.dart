enum UserRole {
  admin('admin'),
  user('user');

  const UserRole(this.claim);

  final String claim;

  static UserRole? fromClaim(String? value) {
    for (final role in UserRole.values) {
      if (role.claim == value) return role;
    }
    return null;
  }

  bool get canManageTransport => this == UserRole.admin;
}
