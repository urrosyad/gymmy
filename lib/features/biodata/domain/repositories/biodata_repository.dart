import 'package:gymmy/features/biodata/domain/entities/biodata_entity.dart';

abstract class BiodataRepository {
  /// Save or update biodata for a user.
  Future<void> saveBiodata(BiodataEntity biodata);

  /// Fetch the biodata for [userUid]. Returns null if not found.
  Future<BiodataEntity?> fetchBiodata(String userUid);

  /// Mark user's biodata as complete in user_accounts_global.
  Future<void> markBiodataComplete(String userUid);
}
