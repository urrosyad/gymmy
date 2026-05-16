import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AccessStatus { none, member, daily }

class MembershipNotifier extends Notifier<AccessStatus> {
  @override
  AccessStatus build() {
    // Default initial state is none (no active gym)
    return AccessStatus.none;
  }

  void joinMembership() {
    state = AccessStatus.member;
  }

  void buyDailyPass() {
    state = AccessStatus.daily;
  }

  void resetAccess() {
    state = AccessStatus.none;
  }
}

final membershipProvider = NotifierProvider<MembershipNotifier, AccessStatus>(() {
  return MembershipNotifier();
});
