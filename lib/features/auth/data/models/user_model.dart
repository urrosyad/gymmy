import 'package:gymmy/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.fullName,
    required super.email,
    required super.role,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      fullName: map['user_full_name'] as String? ?? '',
      email: map['user_email_address'] as String? ?? '',
      role: map['user_global_role'] as String? ?? 'member',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_uid_auth': uid,
      'user_full_name': fullName,
      'user_email_address': email,
      'user_global_role': role,
    };
  }
}
