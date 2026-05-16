class BiodataEntity {
  final String bioUserUid;
  final String bioFullName;
  final DateTime bioBirthDate;
  final double bioWeight;
  final double bioHeight;
  final String bioDailyActivityFrequency; // low / medium / high
  final String bioGender; // male / female
  final String bioGoalType; // cutting / bulking / fitness
  final String bioMedicalNotes;
  final DateTime? bioUpdatedAt;

  const BiodataEntity({
    required this.bioUserUid,
    required this.bioFullName,
    required this.bioBirthDate,
    required this.bioWeight,
    required this.bioHeight,
    required this.bioDailyActivityFrequency,
    required this.bioGender,
    required this.bioGoalType,
    this.bioMedicalNotes = '',
    this.bioUpdatedAt,
  });
}
