class User {
  final String id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String? avatarUrl;  // 🆕 OAuth profile picture
  final String? role;  // 🆕 User role (ADMIN, RESEARCHER, FARMER)

  User({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.avatarUrl,  // 🆕
    this.role,  // 🆕
  });

  String get fullName => '$firstName $lastName';
  
  // Check if user is super admin or admin
  bool get canManageFeedback => role == 'SUPER_ADMIN' || role == 'ADMIN';
}
