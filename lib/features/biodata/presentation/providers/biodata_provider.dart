import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymmy/core/di/injection.dart';
import 'package:gymmy/features/auth/domain/entities/user_entity.dart';
import 'package:gymmy/features/biodata/domain/entities/biodata_entity.dart';
import 'package:gymmy/features/biodata/domain/usecases/save_biodata_usecase.dart';
import 'package:gymmy/features/auth/presentation/providers/auth_provider.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------
class BiodataState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  const BiodataState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
  });

  BiodataState copyWith({bool? isLoading, bool? isSuccess, String? error}) {
    return BiodataState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------
class BiodataNotifier extends Notifier<BiodataState> {
  late final SaveBiodataUsecase _saveBiodataUsecase;

  @override
  BiodataState build() {
    _saveBiodataUsecase = sl<SaveBiodataUsecase>();
    return const BiodataState();
  }

  Future<void> submit({
    required UserEntity user,
    required String fullName,
    required DateTime birthDate,
    required String gender,
    required double weight,
    required double height,
    required String activityFrequency,
    required String goalType,
    required String medicalNotes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final biodata = BiodataEntity(
        bioUserUid: user.uid,
        bioFullName: fullName,
        bioBirthDate: birthDate,
        bioWeight: weight,
        bioHeight: height,
        bioDailyActivityFrequency: activityFrequency,
        bioGender: gender,
        bioGoalType: goalType,
        bioMedicalNotes: medicalNotes,
      );
      await _saveBiodataUsecase(biodata);
      // Refresh auth user so hasCompletedBiodata updates
      await ref.read(authProvider.notifier).refreshUser();
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

final biodataProvider = NotifierProvider<BiodataNotifier, BiodataState>(
  BiodataNotifier.new,
);
