import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymmy/core/di/injection.dart';
import 'package:gymmy/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymmy/features/gym_tenant/domain/entities/gym_tenant_entity.dart';
import 'package:gymmy/features/gym_tenant/domain/usecases/create_gym_usecase.dart';
import 'package:gymmy/features/gym_tenant/domain/usecases/get_all_gyms_usecase.dart';
import 'package:gymmy/features/gym_tenant/domain/usecases/get_owner_gym_usecase.dart';

// ---------------------------------------------------------------------------
// Stream of all active gyms (for discovery)
// ---------------------------------------------------------------------------
final gymListProvider = StreamProvider<List<GymTenantEntity>>((ref) {
  final usecase = sl<GetAllGymsUsecase>();
  return usecase();
});

// ---------------------------------------------------------------------------
// Owner's gym (for owner flow routing)
// ---------------------------------------------------------------------------
final ownerGymProvider = FutureProvider<GymTenantEntity?>((ref) async {
  final auth = ref.watch(authProvider);
  final uid = auth.user?.uid;
  if (uid == null) return null;
  final usecase = sl<GetOwnerGymUsecase>();
  return usecase(uid);
});

// ---------------------------------------------------------------------------
// Gym Setup State
// ---------------------------------------------------------------------------
class GymSetupState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  const GymSetupState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
  });

  GymSetupState copyWith({bool? isLoading, bool? isSuccess, String? error}) {
    return GymSetupState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
    );
  }
}

// ---------------------------------------------------------------------------
// Gym Setup Notifier (Owner wizard)
// ---------------------------------------------------------------------------
class GymSetupNotifier extends Notifier<GymSetupState> {
  late final CreateGymUsecase _createGymUsecase;

  @override
  GymSetupState build() {
    _createGymUsecase = sl<CreateGymUsecase>();
    return const GymSetupState();
  }

  Future<void> submit({
    required String ownerUid,
    required String name,
    required String description,
    required String city,
    required String location,
    required double dailyPrice,
    required double membershipPrice,
    required List<String> facilities,
    required String operationalHours,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final gym = GymTenantEntity(
        gtIdKey: '',
        gtNameTitle: name,
        gtImage: '',
        gtLocation: location,
        gtCityName: city,
        gtRate: 0.0,
        gtOwnerUid: ownerUid,
        gtDescriptionText: description,
        gtDailyPriceAmount: dailyPrice,
        gtMembershipPriceAmount: membershipPrice,
        gtAvailableFacilities: facilities,
        gtIsActive: true,
        gtOperationalHours: {'info': operationalHours},
      );
      await _createGymUsecase(gym);
      // Refresh owner gym provider
      ref.invalidate(ownerGymProvider);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final gymSetupProvider = NotifierProvider<GymSetupNotifier, GymSetupState>(
  GymSetupNotifier.new,
);
