# GYMME FIREBASE RULES

## Firestore Rules

rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    match /{document=**} {
      allow read, write: if request.auth != null;
    }

  }
}

---

# Planned Advanced Security Rules

## Member Access
- Member hanya bisa membaca data gym tempat mereka terdaftar.
- Member tidak boleh CRUD data gym.

## Owner/Admin Access
- Owner hanya bisa CRUD data gym miliknya sendiri.
- Owner hanya bisa CRUD equipment gym miliknya.

## Global Public Access
- Semua user authenticated dapat membaca daftar gym.

---

# Attendance Automation Logic

## Daily Check-in
Saat QR berhasil discan:
1. Tambahkan dokumen baru ke gym_attendance_logs
2. Tambahkan streak member
3. Tambahkan points member

---

# QR Validation Rules

## Member QR
QR harus berisi:
- mem_user_uid
- mem_gym_id

## Scanner Validation
Admin scanner harus:
- memvalidasi gym
- memvalidasi member aktif
- memvalidasi QR belum expired

---

# Firebase Storage Rules

NOTE:
Firebase Storage akan diimplementasikan pada fase lanjutan.

## Planned Rules

Write Access:
- Admin only

Read Access:
- Authenticated users

Folder Structure:
gym_assets/{gt_id_key}/equipments/