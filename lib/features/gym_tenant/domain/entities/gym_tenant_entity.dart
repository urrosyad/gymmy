class GymTenantEntity {
  final String gtIdKey;
  final String gtNameTitle;
  final String gtImage;
  final String gtLocation;
  final String gtCityName;
  final double gtRate;
  final String gtOwnerUid;
  final String gtDescriptionText;
  final double gtDailyPriceAmount;
  final double gtMembershipPriceAmount;
  final List<String> gtAvailableFacilities;
  final bool gtIsActive;
  final Map<String, dynamic> gtOperationalHours;
  final DateTime? gtCreatedAt;

  const GymTenantEntity({
    required this.gtIdKey,
    required this.gtNameTitle,
    required this.gtImage,
    required this.gtLocation,
    required this.gtCityName,
    required this.gtRate,
    required this.gtOwnerUid,
    required this.gtDescriptionText,
    required this.gtDailyPriceAmount,
    required this.gtMembershipPriceAmount,
    required this.gtAvailableFacilities,
    required this.gtIsActive,
    required this.gtOperationalHours,
    this.gtCreatedAt,
  });
}
