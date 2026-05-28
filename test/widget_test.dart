import 'package:flutter_test/flutter_test.dart';
import 'package:gymmy/features/auth/domain/entities/user_entity.dart';

void main() {
  group('UserEntity Unit Tests', () {
    test('Should correctly identify owner role', () {
      const user = UserEntity(
        uid: '123',
        fullName: 'Owner Test',
        email: 'owner@test.com',
        role: 'owner',
      );
      expect(user.isOwner, isTrue);
      expect(user.isMember, isFalse);
    });

    test('Should correctly identify member role', () {
      const user = UserEntity(
        uid: '456',
        fullName: 'Member Test',
        email: 'member@test.com',
        role: 'member',
      );
      expect(user.isOwner, isFalse);
      expect(user.isMember, isTrue);
    });
  });
}
