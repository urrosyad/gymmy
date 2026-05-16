class UserEntity {
  final String uid;
  final String fullName;
  final String email;
  final String role; // 'owner' or 'member'
  final bool hasCompletedBiodata;

  const UserEntity({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    this.hasCompletedBiodata = false,
  });

  bool get isOwner => role == 'owner';
  bool get isMember => role == 'member';
}
