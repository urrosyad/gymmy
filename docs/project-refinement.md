# PHASE 2 FINAL POLISH - NAVIGATION AND LANGUAGE CORRECTION

## Objective

Finalize Phase 2 application shell so the app can proceed safely to the next development phase.

Current working features:
- Auth flow works
- Member biodata onboarding works
- Owner wizard works
- Member shell navigation works
- Role-based routing works

Current issues:
- Owner role does not have proper bottom navigation
- Member Explore tab has wrong meaning
- App title placement is not aligned with desired layout
- QR Scan / Provide QR action is missing as center navigation action
- Active navigation style is incorrect
- App language must be fully Indonesian

---

# 1. OWNER NAVIGATION SHELL

Owner must have bottom navigation menu.

Owner tabs:
1. Beranda
2. Kelola Data
3. Scan
4. Membership
5. Profil

## Owner Tab Details

### Beranda
Contains:
- Ringkasan harga daily
- Ringkasan harga membership
- Total member
- Total kelas
- Total equipment
- Ringkasan check-in

### Kelola Data
Contains CRUD entry points for:
- Data harga daily dan membership
- Data benefit rank
- Data kelas
- Data equipment gym

### Scan
This is a special center circular action.

When tapped, show options:
- Scan QR User
- Tampilkan QR Membership Gym

### Membership
Contains:
- List user membership
- Detail aktivitas member
- Rank member
- Kelas yang diambil
- Riwayat check-in membership

### Profil
Contains:
- Profil owner
- Profil gym
- Edit data gym
- Logout

---

# 2. MEMBER NAVIGATION SHELL

Member tabs:
1. Beranda
2. Gym Saya
3. Scan
4. Riwayat
5. Profil

## Important Correction

The previous "Explore" tab is incorrect.

For active membership users:
- Gym Saya must contain class and equipment available in the gym they subscribe to.

For non-membership users:
- Beranda shows gym discovery.
- Gym Saya should show locked/empty state:
  "Ayo gabung sebagai member gym terlebih dahulu."

## Member Tab Details

### Beranda
If no active membership:
- Gym discovery
- Search gym
- Recommended gym cards

If active membership:
- Active gym home
- Membership progress
- Points
- Rank
- Latest activity

### Gym Saya
If active membership:
- Daftar alat gym
- Daftar kelas gym
- Detail class
- Equipment education

If no active membership:
- Locked state

### Scan
Center circular action.

For member:
- Show QR Daily Access if user is in daily access flow
- Show QR Class Subscription if user is registering to class
- Show QR Class Attendance if user has active class
- Open QR scanner when scanning owner membership QR

### Riwayat
Contains:
- Daily check-in history
- Membership check-in history
- Class attendance history

### Profil
Contains:
- User profile
- Biodata
- Theme setting
- Logout

---

# 3. CENTER QR NAVIGATION ACTION

Both owner and member navigation must have a center circular QR action.

Visual style:
- Circular button
- Positioned in center of bottom navigation
- Primary color: #C0FE39
- Icon only
- No text label required inside the circle
- Use clean Material 3 style
- Do not use emoji
- Do not use oversized shadows
- Do not use excessive gradients

Behavior:
- Owner center action opens bottom sheet with:
  1. Scan QR User
  2. Tampilkan QR Membership Gym

- Member center action opens bottom sheet with:
  1. Scan QR Membership Gym
  2. Tampilkan QR Daily Check-in
  3. Tampilkan QR Kelas

If feature is not ready yet, use clean placeholder page or modal.
Do not implement full QR engine yet.

---

# 4. ACTIVE NAVIGATION STYLE

Active navigation item must NOT use pill background.

Expected active state:
- only icon color changes to primary #C0FE39
- label may stay neutral or primary, but no filled active container
- no big highlighted bubble except center QR button
- inactive icons use neutral gray

Avoid:
- active indicator background
- capsule/pill behind selected item
- colorful navigation bar
- emoji icons

---

# 5. APP TITLE PLACEMENT

Do not center the app title.

App title "GYMMY" must be placed:
- top left
- aligned with screen horizontal padding
- clean and professional

Avoid:
- centered app title
- oversized title
- decorative title

---

# 6. LANGUAGE LOCALIZATION

Convert all visible text in the application to Indonesian.

Examples:
- Home → Beranda
- Explore → Gym Saya
- Activity → Riwayat
- Profile → Profil
- Settings → Pengaturan
- Logout → Keluar
- Search gym → Cari gym
- Complete biodata → Lengkapi biodata
- Submit → Simpan
- Next → Lanjut
- Back → Kembali
- Owner Dashboard → Beranda Owner
- Manage Data → Kelola Data
- Membership → Membership
- Scan QR → Scan QR
- Gym Setup → Pendaftaran Gym
- Daily Price → Harga Harian
- Membership Price → Harga Membership

All buttons, labels, empty states, validation messages, dashboard titles, and navigation labels must use Indonesian.

---

# 7. ARCHITECTURE RULES

Do NOT:
- rewrite authentication
- rewrite biodata onboarding
- rewrite owner wizard logic
- replace existing router entirely
- regenerate project structure

Only:
- add owner navigation shell
- refine member navigation shell
- add center QR action placeholder
- update active navigation style
- adjust title alignment
- convert text to Indonesian

Preserve:
- Clean Architecture
- Riverpod
- GoRouter
- StatefulShellRoute if already used
- dependency injection
- current working flow

---

# 8. FINAL EXPECTED FLOW

## Member without biodata
Login → Form Biodata

## Member with biodata but no membership
Login → Beranda with Gym Discovery

## Member with active membership
Login → Beranda Membership Aktif

## Owner without gym setup
Login → Wizard Pendaftaran Gym

## Owner with gym setup
Login → Owner Shell Navigation

---

# Definition of Done

The app must:
- pass flutter analyze
- run without runtime assertion
- keep existing auth working
- keep biodata flow working
- keep owner wizard working
- show bottom navigation for owner and member
- have center circular QR action
- use Indonesian language across visible UI
- use primary color only for active icons and center QR action