class UserEntity {
  final String uid;
  final String fullName;
  final String email;
  final String role; // 'owner' or 'member'

  const UserEntity({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
  });

  bool get isOwner => role == 'owner';
  bool get isMember => role == 'member';
}
