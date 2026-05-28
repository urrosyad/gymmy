FINAL PATCH PROMPT - GYMMY FEATURE COMPLETION AND STABILIZATION
Use existing:

* Clean Architecture
* Riverpod
* GoRouter
* Firebase Auth
* Firestore
* existing reusable widgets
* existing theme system
* existing owner/member shell

Read and follow:

* docs/project-brief.md
* docs/database-schema.md
* docs/design.md
* existing codebase

==================================================
OWNER FEATURE FIXES
===================

1. FIX EQUIPMENT CRUD FORM

Current issues:

* Equipment form does not have proper image and video fields.
* Equipment form has no validation.
* Empty form can still create data.

Required:

* Add image field for equipment.
* Add tutorial video field for equipment.
* If Firebase Storage is already available, allow image upload.
* If Firebase Storage is not stable, allow image URL input as fallback.
* Video can be stored as URL input.
* Validate all required fields before submit.
* Do not allow empty equipment data to be saved.

Required equipment fields:

* equip_name_label
* equip_image_storage_url
* equip_usage_instruction_text
* equip_tutorial_video_link
* equip_category_type
* equip_is_active_status

Validation:

* equipment name required
* usage instruction required
* category required
* image URL or uploaded image required
* tutorial video URL optional but must be valid URL if filled

Show inline validation errors in Indonesian.

2. FIX CLASS CRUD FORM

Current issues:

* Personal trainer checkbox was removed.
* Class form has no validation.
* Empty form can still create data.

Required:

* Restore personal trainer checkbox.
* Validate all required class fields.
* Do not save empty class data.

Required class fields:

* class_title_name
* class_pricing_amount
* class_schedule_text
* class_session_count
* class_is_personal_trainer
* class_description_text
* class_max_capacity
* class_is_active

Validation:

* class title required
* price required and must be number greater than 0
* schedule required
* session count required and must be greater than 0
* description required
* capacity required and must be greater than 0

Show inline validation errors in Indonesian.

3. FIX RANK BENEFIT CRUD FORM

Current issues:

* Rank benefit form has no validation.
* Empty form can still create data.
* Priority order input was removed.

Required:

* Restore priority order input.
* Validate all required rank fields.
* Do not save empty rank data.

Required rank fields:

* rank_title_name
* rank_min_points_threshold
* rank_benefit_description_list
* rank_priority_order
* rank_is_active

Validation:

* rank title required
* minimum points required and must be number >= 0
* benefit list required
* priority order required and must be number >= 1

Show inline validation errors in Indonesian.

4. FIX OWNER PROFILE AND GYM IMAGE

Current issue:

* Owner profile cannot set gym image.
* Member discovery needs gym image from gym_tenants.

Required:

* Add edit gym profile feature in owner profile.
* Allow owner to input or upload gym image.
* Store image in:
  gt_image
* Also allow editing:
  gt_name_title
  gt_location
  gt_description_text
  gt_city_name
  gt_daily_price_amount
  gt_membership_price_amount
  gt_available_facilities
  gt_operational_hours
  gt_is_active

If Storage is unstable, use image URL input as fallback.

5. FIX OWNER DASHBOARD DATA CONNECTION

Current issue:

* Daily price and membership price show 0 even when data exists in gym_tenants.
* Check-in data is not connected.

Required:

* Owner dashboard must read real Firestore data from owner's gym_tenants document.
* Show real:
  gt_daily_price_amount
  gt_membership_price_amount
  total active members from gym_members_registry
  total daily visits from gym_daily_visits
  total check-ins today from gym_attendance_logs
  total classes from gym_classes_catalog
  total equipment from gym_equipments

Handle missing fields safely.
Do not crash if old Firestore documents do not contain new fields.
Use fallback 0 or empty state.

==================================================
QR FIXES
========

6. FIX QR VISIBILITY IN DARK MODE

Current issue:

* QR is not visible in dark mode.

Required:

* QR must always be readable.
* In light mode:
  QR foreground should be dark.
  QR background should be white.
* In dark mode:
  QR foreground must be white or very light.
  QR background must use dark contrast or a white QR container.
* Best approach:
  Wrap QR in a high-contrast container.
  Ensure scanner can read it.
* Do not let QR blend into background.

Apply this to:

* daily QR
* membership QR
* class QR if already exists

==================================================
MEMBERSHIP AND HISTORY FIXES
============================

7. FIX MEMBERSHIP PAGE ERROR

Current issue:

* Membership page errors after a user becomes a member.

Required:

* Fix membership page runtime error.
* Read membership data from gym_members_registry safely.
* Join with user_accounts_global only if needed and safely.
* If user data is missing, show fallback text.
* Do not crash on null fields.

Membership page must show:

* all members
* active members
* inactive members
* user name or email
* membership status
* start date
* end date
* points
* streak
* total check-in

Tabs:

* Semua
* Aktif
* Tidak Aktif

8. ADD CHECK-IN AND HISTORY TRACKING PAGE

Current issue:

* There is no proper tracking page for daily/member/non-member check-ins.

Required:
Create or complete history/tracking pages for owner and member.

Owner history page:

* Show all check-in records for owner gym.
* Data sources:
  gym_attendance_logs
  gym_daily_visits
* Filter tabs:
  Semua
  Harian
  Membership
  Kelas
* Show:
  user name/email if available
  category
  time
  gym
  validator
  status

Member history page:

* Show current user's activity history.
* Data sources:
  gym_attendance_logs
  gym_daily_visits
  gym_class_subscriptions
* Filter tabs:
  Semua
  Harian
  Membership
  Kelas

If no data:
show Indonesian empty state.

9. CONNECT CHECK-IN DATA TO DASHBOARD

Current issue:

* Check-in data on dashboard is not connected.

Required:

* Owner dashboard must show check-in summary from Firestore.
* Member active dashboard must show latest check-in and total check-in.
* Update data after successful QR scan.
* Refresh providers after scan success.

For daily QR scan:

* create gym_daily_visits
* create gym_attendance_logs
* update dashboard counters

For membership check-in if implemented:

* create gym_attendance_logs
* update mem_total_checkin_count
* update mem_last_checkin_at
* update mem_streak_consecutive_days if applicable

==================================================
FORM VALIDATION STANDARD
========================

Apply this validation standard to all create/update forms:

* Do not submit empty required fields.
* Show inline error message below field.
* Disable submit button or stop submit when invalid.
* Use Indonesian validation text.
* Keep user input after validation fails.
* Do not navigate away on validation failure.
* Do not show fullscreen error page.

Indonesian validation examples:

* "Nama wajib diisi"
* "Harga wajib diisi"
* "Harga harus lebih dari 0"
* "Jadwal wajib diisi"
* "Deskripsi wajib diisi"
* "URL tidak valid"
* "Data berhasil disimpan"
* "Gagal menyimpan data"

==================================================
UI LANGUAGE REQUIREMENT
=======================

Convert all remaining visible UI text to Indonesian.

Examples:

* Add Equipment -> Tambah Peralatan
* Save -> Simpan
* Cancel -> Batal
* Edit -> Ubah
* Delete -> Hapus
* Equipment -> Peralatan
* Class -> Kelas
* Rank Benefit -> Benefit Rank
* Daily Price -> Harga Harian
* Membership Price -> Harga Membership
* Check-in History -> Riwayat Check-in
* No data available -> Belum ada data
* Coming soon -> remove this, replace with working screen

Do not use emoji.

==================================================
DATA NORMALIZATION AND SAFETY
=============================

Firestore is schemaless. Existing documents may be missing new fields.

Implement safe reading:

* never assume fields exist
* use null-safe parsing
* provide fallback values
* avoid runtime cast errors

When owner updates profile/pricing, write missing gym_tenants fields:

* gt_image
* gt_description_text
* gt_city_name
* gt_operational_hours
* gt_gallery_images
* gt_daily_price_amount
* gt_membership_price_amount
* gt_available_facilities
* gt_is_active

When creating new documents, include all required schema fields.

==================================================
TECHNICAL REQUIREMENTS
======================

Maintain:

* existing Clean Architecture
* existing Riverpod providers where possible
* existing GoRouter routes
* existing Firebase initialization
* existing reusable widgets
* current working auth and role flow

Fix:

* invalid forms
* broken membership page
* disconnected dashboard data
* inaccessible CRUD screens
* QR dark mode visibility
* history tracking
* old missing-field crashes

Avoid:

* full project rewrite
* duplicate models
* duplicate repositories
* dead code
* unused imports
* hardcoded demo-only data
* English UI text

==================================================
IMPLEMENTATION PRIORITY
=======================

Priority 1:

* Fix validation for equipment, class, rank
* Fix owner dashboard Firestore data
* Fix membership page error
* Fix profile gym image
* Fix QR dark mode visibility
* Remove "Segera datang" from listed menus

Priority 2:

* Complete check-in/history tracking
* Connect check-in data to dashboard
* Stabilize QR scan success flow

Priority 3:

* Polish UI consistency
* Clean all remaining English text
* Remove unused imports and lints

==================================================
FINAL ACCEPTANCE CRITERIA
=========================

The final app must:

* pass flutter analyze
* run without red screen
* keep auth working
* keep logout working
* keep member biodata flow working
* keep owner wizard working
* equipment form has validation
* class form has validation
* rank form has validation
* owner profile can set gym image
* member discovery shows gym image
* QR is visible in dark mode
* membership page does not crash
* history/check-in page works
* owner dashboard reads real Firestore prices and check-in data
* all visible UI text is Indonesian
* no menu from the listed issues shows only "Segera datang"

After implementation:

1. Run flutter analyze.
2. Fix all errors and warnings.
3. Ensure the app runs successfully.
4. Do not stop until the app is stable.
