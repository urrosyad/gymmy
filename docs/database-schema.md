# GYMME DATABASE SCHEMA

# 1. Database Overview

GYMME menggunakan Firebase Firestore dengan pendekatan multi-tenant architecture.

Sistem mendukung:
- gym discovery
- onboarding user
- onboarding owner gym
- membership gym
- daily access
- class subscription
- attendance tracking
- QR operational system
- gamification
- loyalty system

Setiap gym memiliki data operasional masing-masing dan dipisahkan menggunakan ID gym.

Primary tenant references:
- gt_id_key
- mem_gym_id
- class_parent_gym_id
- equip_parent_gym_id
- rank_parent_gym_id

---

# 2. COLLECTION: gym_tenants

## Deskripsi
Menyimpan data utama gym yang dibuat oleh owner setelah onboarding wizard selesai.

## Fields

| Field | Type | Description |
|---|---|---|
| gt_id_key | String | Primary ID gym |
| gt_name_title | String | Nama gym |
| gt_image | String | Thumbnail gym |
| gt_location | String | Lokasi gym |
| gt_rate | Number | Rating gym |
| gt_owner_uid | String | UID owner |
| gt_created_at | Timestamp | Tanggal dibuat |

---

## Additional Operational Fields

| Field | Type | Description |
|---|---|---|
| gt_description_text | String | Deskripsi gym |
| gt_city_name | String | Kota |
| gt_operational_hours | Map | Jam operasional |
| gt_gallery_images | Array<String> | Gallery gym |
| gt_daily_price_amount | Number | Harga daily pass |
| gt_membership_price_amount | Number | Harga membership |
| gt_available_facilities | Array<String> | Fasilitas gym |
| gt_is_active | Boolean | Status gym |

---

# 3. COLLECTION: user_accounts_global

## Deskripsi
Menyimpan akun global user hasil registrasi Firebase Authentication.

User belum otomatis menjadi member gym setelah register.

## Fields

| Field | Type | Description |
|---|---|---|
| user_uid_auth | String | Firebase Auth UID |
| user_full_name | String | Nama lengkap |
| user_email_address | String | Email user |
| user_global_role | String | member / owner |
| user_created_at | Timestamp | Waktu registrasi |

---

## Additional Fields

| Field | Type | Description |
|---|---|---|
| user_profile_photo_url | String | Foto profile |
| user_has_completed_biodata | Boolean | Status biodata |
| user_last_login_at | Timestamp | Login terakhir |
| user_is_active | Boolean | Status akun |

---

# 4. COLLECTION: user_biodata_profiles

## Deskripsi
Data fisik user yang wajib diisi sebelum:
- membership
- daily access
- class subscription

## Fields

| Field | Type | Description |
|---|---|---|
| bio_user_uid | String | UID user |
| bio_full_name | String | Nama lengkap |
| bio_birth_date | Timestamp | Tanggal lahir |
| bio_weight | Number | Berat badan |
| bio_height | Number | Tinggi badan |
| bio_daily_activity_frequency | String | low / medium / high |

---

## Additional Fields

| Field | Type | Description |
|---|---|---|
| bio_gender | String | male / female |
| bio_goal_type | String | cutting / bulking / fitness |
| bio_medical_notes | String | Catatan kesehatan |
| bio_updated_at | Timestamp | Update terakhir |

---

# 5. COLLECTION: gym_members_registry

## Deskripsi
Menyimpan relasi membership antara user dan gym.

Membership hanya aktif setelah:
- user scan QR membership dari gym
ATAU
- owner memvalidasi membership.

## Fields

| Field | Type | Description |
|---|---|---|
| mem_id_key | String | Primary membership ID |
| mem_user_uid | String | UID user |
| mem_gym_id | String | ID gym |
| mem_membership_type | String | monthly / yearly |
| mem_membership_status | String | active / inactive / expired |
| mem_current_points_balance | Number | Loyalty points |
| mem_streak_consecutive_days | Number | Streak aktif |
| mem_join_timestamp | Timestamp | Tanggal join |
| mem_membership_start_date | Timestamp | Mulai membership |
| mem_membership_end_date | Timestamp | Expired membership |

---

## Additional Fields

| Field | Type | Description |
|---|---|---|
| mem_current_rank_id | String | Rank aktif |
| mem_total_checkin_count | Number | Total attendance |
| mem_last_checkin_at | Timestamp | Check-in terakhir |
| mem_is_frozen | Boolean | Membership freeze |
| mem_created_by_owner_uid | String | Owner validator |

---

# 6. COLLECTION: gym_daily_visits

## Deskripsi
Menyimpan log kunjungan user non-membership.

## Fields

| Field | Type | Description |
|---|---|---|
| daily_visit_id_key | String | Primary ID |
| daily_visit_user_uid | String | UID user |
| daily_visit_gym_id | String | ID gym |
| daily_visit_checkin_at | Timestamp | Waktu check-in |
| daily_visit_payment_status | String | paid / pending |

---

## Additional Fields

| Field | Type | Description |
|---|---|---|
| daily_visit_qr_session_id | String | QR validation session |
| daily_visit_checkout_at | Timestamp | Checkout |
| daily_visit_validated_by_owner | String | UID owner |
| daily_visit_status | String | success / cancelled |

---

# 7. COLLECTION: gym_classes_catalog

## Deskripsi
Daftar kelas, layanan, dan personal trainer dalam gym.

## Fields

| Field | Type | Description |
|---|---|---|
| class_id_key | String | Primary class ID |
| class_parent_gym_id | String | Parent gym |
| class_title_name | String | Nama kelas |
| class_pricing_amount | Number | Harga kelas |
| class_schedule_text | String | Jadwal kelas |
| class_session_count | Number | Jumlah sesi |
| class_is_personal_trainer | Boolean | PT class |

---

## Additional Fields

| Field | Type | Description |
|---|---|---|
| class_description_text | String | Deskripsi kelas |
| class_thumbnail_image_url | String | Thumbnail |
| class_max_capacity | Number | Kapasitas |
| class_current_subscribers | Number | Subscriber |
| class_is_active | Boolean | Status aktif |

---

# 8. COLLECTION: gym_class_subscriptions

## Deskripsi
Relasi user dengan kelas gym tertentu.

## Fields

| Field | Type | Description |
|---|---|---|
| sub_id_key | String | Subscription ID |
| sub_user_uid | String | UID user |
| sub_class_id | String | Class ID |
| sub_gym_id | String | Gym ID |
| sub_started_at | Timestamp | Mulai langganan |
| sub_expired_at | Timestamp | Expired |
| sub_status | String | active / inactive |

---

# 9. COLLECTION: gym_equipments

## Deskripsi
Inventaris alat gym.

## Fields

| Field | Type | Description |
|---|---|---|
| equip_id_key | String | Equipment ID |
| equip_parent_gym_id | String | Parent gym |
| equip_name_label | String | Nama alat |
| equip_image_storage_url | String | Foto alat |
| equip_usage_instruction_text | String | Instruksi penggunaan |
| equip_tutorial_video_link | String | Video tutorial |
| equip_is_active_status | Boolean | Status alat |

---

## Additional Fields

| Field | Type | Description |
|---|---|---|
| equip_created_at | Timestamp | Created |
| equip_last_updated_at | Timestamp | Updated |
| equip_category_type | String | chest / leg / cardio |
| equip_total_usage_count | Number | Statistik penggunaan |

---

# 10. COLLECTION: gym_attendance_logs

## Deskripsi
Log attendance seluruh aktivitas gym.

Mencakup:
- membership check-in
- daily visit
- class attendance

## Fields

| Field | Type | Description |
|---|---|---|
| log_id_key | String | Primary log ID |
| log_member_id | String | Membership ID |
| log_gym_id | String | Gym ID |
| log_category_type | String | membership / daily / class |
| log_reference_class_id | String | Class reference |
| log_recorded_at | Timestamp | Timestamp log |

---

## Additional Fields

| Field | Type | Description |
|---|---|---|
| log_user_uid | String | UID user |
| log_qr_session_id | String | QR session |
| log_validated_by_owner_uid | String | Validator |
| log_device_platform | String | android / ios |

---

# 11. COLLECTION: gym_master_ranks

## Deskripsi
Konfigurasi rank loyalty per gym.

## Fields

| Field | Type | Description |
|---|---|---|
| rank_id_key | String | Rank ID |
| rank_parent_gym_id | String | Parent gym |
| rank_title_name | String | Nama rank |
| rank_min_points_threshold | Number | Minimal points |
| rank_benefit_description_list | Array<String> | Benefit rank |

---

## Additional Fields

| Field | Type | Description |
|---|---|---|
| rank_badge_image_url | String | Badge |
| rank_priority_order | Number | Urutan rank |
| rank_is_active | Boolean | Status aktif |

---

# 12. COLLECTION: qr_sessions

## Deskripsi
Layer validasi QR untuk:
- anti screenshot abuse
- expired QR
- operational verification

## Fields

| Field | Type | Description |
|---|---|---|
| qr_session_id | String | Session ID |
| qr_type | String | daily / membership / class |
| qr_related_user_uid | String | UID user |
| qr_related_gym_id | String | Gym ID |
| qr_related_class_id | String | Class ID |
| qr_generated_at | Timestamp | Generate time |
| qr_expired_at | Timestamp | Expired time |
| qr_is_used | Boolean | Sudah digunakan |

---

# 13. COLLECTION: gym_reviews

## Deskripsi
Review dan rating gym.

## Fields

| Field | Type | Description |
|---|---|---|
| review_id_key | String | Review ID |
| review_gym_id | String | Gym ID |
| review_user_uid | String | UID user |
| review_rating_value | Number | Rating |
| review_review_text | String | Isi review |
| review_created_at | Timestamp | Created |

---

# 14. RELATIONSHIP MAP

user_accounts_global
→ hasOne user_biodata_profiles
→ hasMany gym_members_registry
→ hasMany gym_daily_visits
→ hasMany gym_class_subscriptions
→ hasMany gym_attendance_logs

gym_tenants
→ hasMany gym_members_registry
→ hasMany gym_classes_catalog
→ hasMany gym_equipments
→ hasMany gym_master_ranks
→ hasMany gym_reviews

gym_classes_catalog
→ hasMany gym_class_subscriptions

gym_members_registry
→ belongsTo user_accounts_global
→ belongsTo gym_tenants

gym_attendance_logs
→ belongsTo gym_tenants

qr_sessions
→ operational QR validation layer

---

# 15. DATABASE DEVELOPMENT ORDER

## Phase 1
- user_accounts_global
- user_biodata_profiles
- gym_tenants

## Phase 2
- gym_members_registry
- gym_daily_visits

## Phase 3
- gym_classes_catalog
- gym_class_subscriptions

## Phase 4
- gym_equipments
- gym_master_ranks

## Phase 5
- gym_attendance_logs
- qr_sessions
- gym_reviews