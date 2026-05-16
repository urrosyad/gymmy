import 'package:gymmy/features/biodata/domain/entities/biodata_entity.dart';
import 'package:gymmy/features/biodata/domain/repositories/biodata_repository.dart';

class SaveBiodataUsecase {
  final BiodataRepository _repository;

  SaveBiodataUsecase(this._repository);

  Future<void> call(BiodataEntity biodata) async {
    await _repository.saveBiodata(biodata);
    await _repository.markBiodataComplete(biodata.bioUserUid);
  }
}
