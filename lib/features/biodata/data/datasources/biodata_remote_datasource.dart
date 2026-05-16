import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymmy/features/biodata/data/models/biodata_model.dart';

class BiodataRemoteDatasource {
  final FirebaseFirestore _firestore;

  BiodataRemoteDatasource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  static const _bioCollection = 'user_biodata_profiles';
  static const _userCollection = 'user_accounts_global';

  Future<void> saveBiodata(BiodataModel biodata) async {
    await _firestore
        .collection(_bioCollection)
        .doc(biodata.bioUserUid)
        .set(biodata.toMap());
  }

  Future<BiodataModel?> fetchBiodata(String userUid) async {
    final doc = await _firestore
        .collection(_bioCollection)
        .doc(userUid)
        .get();
    if (!doc.exists || doc.data() == null) return null;
    return BiodataModel.fromMap(doc.data()!);
  }

  Future<void> markBiodataComplete(String userUid) async {
    await _firestore
        .collection(_userCollection)
        .doc(userUid)
        .update({'user_has_completed_biodata': true});
  }
}
