import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymmy/features/biodata/domain/entities/biodata_entity.dart';

class BiodataModel extends BiodataEntity {
  const BiodataModel({
    required super.bioUserUid,
    required super.bioFullName,
    required super.bioBirthDate,
    required super.bioWeight,
    required super.bioHeight,
    required super.bioDailyActivityFrequency,
    required super.bioGender,
    required super.bioGoalType,
    super.bioMedicalNotes,
    super.bioUpdatedAt,
  });

  factory BiodataModel.fromMap(Map<String, dynamic> map) {
    final birthTs = map['bio_birth_date'];
    final updatedTs = map['bio_updated_at'];
    return BiodataModel(
      bioUserUid: map['bio_user_uid'] as String? ?? '',
      bioFullName: map['bio_full_name'] as String? ?? '',
      bioBirthDate: birthTs is Timestamp
          ? birthTs.toDate()
          : DateTime(2000),
      bioWeight: (map['bio_weight'] as num?)?.toDouble() ?? 0.0,
      bioHeight: (map['bio_height'] as num?)?.toDouble() ?? 0.0,
      bioDailyActivityFrequency:
          map['bio_daily_activity_frequency'] as String? ?? 'medium',
      bioGender: map['bio_gender'] as String? ?? 'male',
      bioGoalType: map['bio_goal_type'] as String? ?? 'fitness',
      bioMedicalNotes: map['bio_medical_notes'] as String? ?? '',
      bioUpdatedAt:
          updatedTs is Timestamp ? updatedTs.toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bio_user_uid': bioUserUid,
      'bio_full_name': bioFullName,
      'bio_birth_date': Timestamp.fromDate(bioBirthDate),
      'bio_weight': bioWeight,
      'bio_height': bioHeight,
      'bio_daily_activity_frequency': bioDailyActivityFrequency,
      'bio_gender': bioGender,
      'bio_goal_type': bioGoalType,
      'bio_medical_notes': bioMedicalNotes,
      'bio_updated_at': FieldValue.serverTimestamp(),
    };
  }
}
