import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymmy/features/gym_tenant/domain/entities/gym_tenant_entity.dart';

class GymTenantModel extends GymTenantEntity {
  const GymTenantModel({
    required super.gtIdKey,
    required super.gtNameTitle,
    required super.gtImage,
    required super.gtLocation,
    required super.gtCityName,
    required super.gtRate,
    required super.gtOwnerUid,
    required super.gtDescriptionText,
    required super.gtDailyPriceAmount,
    required super.gtMembershipPriceAmount,
    required super.gtAvailableFacilities,
    required super.gtIsActive,
    required super.gtOperationalHours,
    super.gtCreatedAt,
  });

  factory GymTenantModel.fromMap(String id, Map<String, dynamic> map) {
    final ts = map['gt_created_at'];
    return GymTenantModel(
      gtIdKey: map['gt_id_key'] as String? ?? id,
      gtNameTitle: map['gt_name_title'] as String? ?? '',
      gtImage: map['gt_image'] as String? ?? '',
      gtLocation: map['gt_location'] as String? ?? '',
      gtCityName: map['gt_city_name'] as String? ?? '',
      gtRate: (map['gt_rate'] as num?)?.toDouble() ?? 0.0,
      gtOwnerUid: map['gt_owner_uid'] as String? ?? '',
      gtDescriptionText: map['gt_description_text'] as String? ?? '',
      gtDailyPriceAmount:
          (map['gt_daily_price_amount'] as num?)?.toDouble() ?? 0.0,
      gtMembershipPriceAmount:
          (map['gt_membership_price_amount'] as num?)?.toDouble() ?? 0.0,
      gtAvailableFacilities:
          List<String>.from(map['gt_available_facilities'] as List? ?? []),
      gtIsActive: map['gt_is_active'] as bool? ?? true,
      gtOperationalHours:
          Map<String, dynamic>.from(map['gt_operational_hours'] as Map? ?? {}),
      gtCreatedAt:
          ts is Timestamp ? ts.toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gt_id_key': gtIdKey,
      'gt_name_title': gtNameTitle,
      'gt_image': gtImage,
      'gt_location': gtLocation,
      'gt_city_name': gtCityName,
      'gt_rate': gtRate,
      'gt_owner_uid': gtOwnerUid,
      'gt_description_text': gtDescriptionText,
      'gt_daily_price_amount': gtDailyPriceAmount,
      'gt_membership_price_amount': gtMembershipPriceAmount,
      'gt_available_facilities': gtAvailableFacilities,
      'gt_is_active': gtIsActive,
      'gt_operational_hours': gtOperationalHours,
      'gt_created_at': FieldValue.serverTimestamp(),
    };
  }
}
