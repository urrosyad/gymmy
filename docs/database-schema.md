# GYMME DATABASE SCHEMA

## Database Overview

GYMME menggunakan Firebase Firestore sebagai database utama dengan pendekatan multi-tenant architecture.

Setiap gym memiliki data yang terisolasi berdasarkan:
- gt_id_key
- mem_gym_id
- equip_parent_gym_id

---

# COLLECTION: gym_tenants

Data utama gym mitra.

## Fields

| Field | Type | Description |
|---|---|---|
| gt_id_key | String | Primary ID gym |
| gt_name_title | String | Nama gym |
| gt_address_location | String | Alamat gym |
| gt_owner_uid | String | UID owner Firebase Auth |
| gt_business_license_number | String | Nomor izin usaha |
| gt_created_at | Timestamp | Tanggal pembuatan |

---

# COLLECTION: user_accounts_global

Identitas user global seluruh platform.

## Fields

| Field | Type | Description |
|---|---|---|
| user_uid_auth | String | UID Firebase Auth |
| user_full_name | String | Nama lengkap |
| user_email_address | String | Email user |
| user_global_role | String | Owner / Admin / Member |

---

# COLLECTION: gym_members_registry

Relasi member dengan gym tertentu.

## Fields

| Field | Type | Description |
|---|---|---|
| mem_id_key | String | ID membership |
| mem_user_uid | String | Relasi ke user_uid_auth |
| mem_gym_id | String | Relasi ke gt_id_key |
| mem_current_points_balance | Number | Total poin |
| mem_streak_consecutive_days | Number | Total streak check-in |
| mem_join_timestamp | Timestamp | Tanggal join |
| mem_membership_type | String | membership / daily |
| mem_membership_status | String | active / inactive |
| mem_membership_start_date | Timestamp | Tanggal mulai |
| mem_membership_end_date | Timestamp | Tanggal expired |

---

# COLLECTION: gym_equipments

Inventaris alat gym.

## Fields

| Field | Type | Description |
|---|---|---|
| equip_id_key | String | ID alat |
| equip_parent_gym_id | String | Relasi gym |
| equip_name_label | String | Nama alat |
| equip_image_storage_url | String | URL gambar |
| equip_usage_instruction_text | String | Cara penggunaan |
| equip_tutorial_video_link | String | Link tutorial |
| equip_is_active_status | Boolean | Status alat |

---

# COLLECTION: gym_classes_catalog

Katalog kelas dan personal trainer.

## Fields

| Field | Type | Description |
|---|---|---|
| class_id_key | String | ID kelas |
| class_parent_gym_id | String | Relasi gym |
| class_title_name | String | Nama kelas |
| class_pricing_amount | Number | Harga |
| class_is_personal_trainer | Boolean | PT atau bukan |

---

# COLLECTION: gym_attendance_logs

Riwayat check-in dan aktivitas member.

## Fields

| Field | Type | Description |
|---|---|---|
| log_id_key | String | ID log |
| log_member_id | String | Relasi member |
| log_gym_id | String | Relasi gym |
| log_category_type | String | Daily / Class |
| log_reference_class_id | String | Relasi kelas |
| log_recorded_at | Timestamp | Waktu log |

---

# COLLECTION: gym_master_ranks

Sistem ranking dan gamifikasi.

## Fields

| Field | Type | Description |
|---|---|---|
| rank_id_key | String | ID rank |
| rank_parent_gym_id | String | Relasi gym |
| rank_title_name | String | Bronze / Silver / Gold |
| rank_min_points_threshold | Number | Minimal poin |

---

# COLLECTION: gym_daily_visits

Riwayat user non-membership.

## Fields

| Field | Type | Description |
|---|---|---|
| daily_visit_id_key | String | ID visit |
| daily_visit_user_uid | String | UID user |
| daily_visit_gym_id | String | Gym tujuan |
| daily_visit_checkin_at | Timestamp | Waktu check-in |
| daily_visit_payment_status | String | paid / pending |

# RELATIONSHIP MAP

user_accounts_global
→ hasMany gym_members_registry

gym_tenants
→ hasMany gym_equipments
→ hasMany gym_classes_catalog
→ hasMany gym_master_ranks
→ hasMany gym_attendance_logs

gym_members_registry
→ belongsTo user_accounts_global
→ belongsTo gym_tenants

gym_attendance_logs
→ belongsTo gym_members_registry

---

# DATABASE DEVELOPMENT STRATEGY

## Phase 1
- gym_tenants
- user_accounts_global

## Phase 2
- gym_members_registry

## Phase 3
- gym_equipments

## Phase 4
- gym_attendance_logs

## Phase 5
- gym_master_ranks
- gym_classes_catalog