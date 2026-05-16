import 'package:gymmy/features/biodata/data/datasources/biodata_remote_datasource.dart';
import 'package:gymmy/features/biodata/data/models/biodata_model.dart';
import 'package:gymmy/features/biodata/domain/entities/biodata_entity.dart';
import 'package:gymmy/features/biodata/domain/repositories/biodata_repository.dart';

class BiodataRepositoryImpl implements BiodataRepository {
  final BiodataRemoteDatasource _datasource;

  BiodataRepositoryImpl(this._datasource);

  @override
  Future<void> saveBiodata(BiodataEntity biodata) {
    final model = BiodataModel(
      bioUserUid: biodata.bioUserUid,
      bioFullName: biodata.bioFullName,
      bioBirthDate: biodata.bioBirthDate,
      bioWeight: biodata.bioWeight,
      bioHeight: biodata.bioHeight,
      bioDailyActivityFrequency: biodata.bioDailyActivityFrequency,
      bioGender: biodata.bioGender,
      bioGoalType: biodata.bioGoalType,
      bioMedicalNotes: biodata.bioMedicalNotes,
    );
    return _datasource.saveBiodata(model);
  }

  @override
  Future<BiodataEntity?> fetchBiodata(String userUid) =>
      _datasource.fetchBiodata(userUid);

  @override
  Future<void> markBiodataComplete(String userUid) =>
      _datasource.markBiodataComplete(userUid);
}
