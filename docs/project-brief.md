# PROJECT BRIEF  
## GYMMY - Aplikasi Mobile Manajemen Membership Gym Berbasis SaaS

**Status dokumen:** Versi matang untuk acuan pengembangan  
**Tujuan dokumen:** Menjadi blueprint utama untuk development, vibe coding dengan Antigravity, dan validasi scope UAS  
**Platform target:** Android mobile app, dapat dipublish sebagai APK  
**Nama produk:** GYMMY  
**Model bisnis:** SaaS multi-tenant untuk beberapa gym/cabang dalam satu platform

---

## 1. Ringkasan Produk

GYMMY adalah aplikasi mobile berbasis **Software as a Service (SaaS)** yang digunakan untuk mengelola operasional membership gym sekaligus meningkatkan retensi member melalui edukasi fasilitas, sistem check-in digital, visualisasi aktivitas, dan gamifikasi loyalitas.

Aplikasi ini memiliki dua sisi utama:

1. **Sisi Owner/Admin Gym**
   - Mengelola data gym
   - Mengelola member
   - Mengelola inventaris alat
   - Mengelola harga layanan dan kelas
   - Memverifikasi check-in member
   - Memantau aktivitas dan loyalitas member

2. **Sisi Member**
   - Mendaftar dan bergabung ke gym
   - Melihat fasilitas dan alat gym
   - Mengakses panduan penggunaan alat
   - Melakukan check-in via QR
   - Melihat poin, streak, rank, dan riwayat aktivitas

Produk ini tidak hanya menjadi aplikasi administrasi, tetapi juga alat untuk meningkatkan pengalaman member agar lebih loyal, aktif, dan terbantu saat latihan.

---

## 2. Latar Belakang Masalah

Banyak gym masih menghadapi masalah berikut:

- Pencatatan membership masih manual atau tersebar di banyak file
- Proses check-in tidak rapi dan rawan salah input
- Member sering tidak memahami cara penggunaan alat
- Owner sulit memantau aktifitas member secara real-time
- Tidak ada sistem loyalitas yang mendorong member untuk datang rutin
- Pengelolaan kelas, PT, dan harga masih kurang terstruktur

GYMMY dirancang untuk menjawab masalah tersebut melalui satu platform mobile yang ringan, modern, dan berbasis data.

---

## 3. Tujuan Produk

### 3.1 Tujuan Utama
Membangun aplikasi mobile yang dapat:
- Mendigitalisasi manajemen gym  
- Memudahkan operasional owner/admin
- Membantu member memahami fasilitas gym
- Meningkatkan engagement dan retensi member
- Menyediakan check-in yang aman dan terukur

### 3.2 Tujuan Akademik
Aplikasi ini ditargetkan untuk memenuhi kriteria UAS Pemrograman Mobile dengan level implementasi tinggi, mencakup:
- CRUD dasar
- Authentication
- State management
- Form handling
- Animasi
- Chart visualisasi data
- QR scanner
- Security rules
- Clean architecture
- Multi-tenant data separation
- Gamification

---

## 4. Target Pengguna

### 4.1 User Owner / Admin Gym
Pengguna yang mengelola bisnis gym. Mereka membutuhkan:
- Dashboard operasional
- Kontrol member
- Kontrol inventaris
- Kontrol harga layanan
- Kontrol akses check-in
- Data aktivitas gym yang mudah dipantau

### 4.2 User Member
Pelanggan gym yang terdaftar pada salah satu gym mitra. Mereka membutuhkan:
- Login dan identitas digital
- Akses fasilitas gym
- Panduan alat
- Check-in cepat
- Poin dan rank
- Riwayat kunjungan
- Motivasi untuk rutin datang ke gym

---

## 5. Value Proposition

### Untuk Owner
- Mengurangi proses manual
- Data lebih rapi dan terpusat
- Memantau member lebih cepat
- Mengelola alat, kelas, dan harga dalam satu sistem
- Memiliki platform yang terlihat profesional

### Untuk Member
- Mudah memahami alat gym
- Check-in lebih cepat dan modern
- Mendapat feedback visual saat berhasil check-in
- Ada rasa pencapaian melalui poin, streak, dan rank
- Pengalaman gym jadi lebih interaktif dan nyaman

---

## 6. Ruang Lingkup Produk

### 6.1 In Scope
Fitur yang wajib dibangun dalam versi ini:
- Autentikasi multi-role
- Registrasi member dan owner
- Setup gym secara otomatis saat owner daftar
- Dashboard admin
- Manajemen member
- CRUD inventaris alat gym
- Manajemen harga layanan dan kelas
- Master rank loyalty system
- QR generator untuk member
- QR scanner untuk admin
- Check-in validation
- Riwayat check-in
- Grafik 7 hari terakhir
- Theme system light/dark
- Reusable component library
- Firebase backend

### 6.2 Out of Scope
Fitur yang tidak wajib pada versi ini:
- Pembayaran real payment gateway
- Chat antar member dan admin
- Integrasi wearable device
- Integrasi AI workout recommendation
- Push notification kompleks
- Offline sync lanjutan
- Multi-language
- Web dashboard terpisah

---

## 7. Definisi Produk dan Prinsip Desain

### 7.1 Karakter Produk
GYMMY harus terasa:
- Modern
- Minimalis
- Sporty
- Premium
- Bersih
- Cepat dipahami

### 7.2 Prinsip UX
- Navigasi harus singkat
- Informasi penting harus tampil di atas
- Form harus sederhana dan jelas
- Feedback sistem harus instan
- Data visual harus mudah dibaca
- Hierarki layar harus berbeda antara owner dan member

### 7.3 Prinsip UI
- Gunakan ruang putih atau dark surface secara seimbang
- Hindari tampilan ramai
- Gunakan aksen warna neon secara terkontrol
- Gunakan kartu, badge, dan progress bar untuk memperjelas status
- Animasi dipakai sebagai feedback, bukan dekorasi berlebihan

---

## 8. Persona Pengguna

### 8.1 Persona Owner
- Memiliki gym kecil sampai menengah
- Tidak ingin ribet dengan pencatatan manual
- Ingin data member cepat dicari
- Ingin kontrol alat, kelas, dan harga dari satu aplikasi
- Ingin tampilan yang modern agar bisnis terlihat profesional

### 8.2 Persona Member
- Usia remaja sampai dewasa muda
- Sering menggunakan mobile untuk aktivitas harian
- Suka visual yang menarik
- Ingin progres kebugaran terasa nyata
- Tertarik pada gamifikasi dan streak

---

## 9. User Journey Utama

### 9.1 Journey Owner
1. Owner membuat akun
2. Owner mengisi profil gym
3. Sistem otomatis membuat gym tenant dan rank awal
4. Owner masuk dashboard admin
5. Owner menambahkan alat gym
6. Owner mengatur layanan dan kelas
7. Owner memantau member
8. Owner melakukan validasi check-in member

### 9.2 Journey Member
1. Member membuat akun
2. Member mencari gym atau bergabung
3. Member melihat fasilitas dan kelas
4. Member membuka QR digital ID
5. Admin memindai QR saat check-in
6. Sistem menyimpan riwayat dan poin
7. Member melihat streak, rank, dan progres

---

## 10. Fitur Inti Produk

## 10.1 Autentikasi Multi-Role
Sistem login tunggal untuk semua user.

### Role:
- Owner
- Member

### Alur:
- Login dengan email dan password
- Sistem membaca `user_global_role`
- Jika role Owner, arahkan ke dashboard admin
- Jika role Member, arahkan ke dashboard member

### Registrasi:
- Mode Member
- Mode Owner

### Validasi:
- Email valid
- Password minimal 8 karakter
- Validasi form real-time
- Email tidak boleh duplikat

---

## 10.2 Registrasi Owner
Registrasi owner lebih lengkap karena menginisialisasi sebuah tenant gym baru.

### Data wajib:
- Nama lengkap
- Email bisnis
- Nama gym
- Alamat gym
- Persetujuan syarat dan ketentuan

### Sistem otomatis saat owner berhasil daftar:
- Membuat akun auth
- Membuat profil global user
- Membuat dokumen gym tenant
- Menghubungkan owner ke gym
- Membuat rank default Bronze, Silver, Gold

---

## 10.3 Registrasi Member
Registrasi member dibuat sederhana agar onboarding cepat.

### Data wajib:
- Nama lengkap
- Email
- Password
- Persetujuan kebijakan

### Setelah registrasi:
- Membuat akun auth
- Membuat profil global user
- Mengarahkan user ke discovery atau join gym flow

---

## 10.4 Discovery Gym
Fitur marketplace gym untuk member yang belum bergabung atau ingin pindah gym.

### Komponen:
- Search bar gym
- Kartu gym rekomendasi
- Detail gym
- Alamat gym
- Tombol join atau subscribe

### Tujuan:
- Mempermudah member menemukan gym mitra
- Menjadi pintu masuk onboarding member baru

---

## 10.5 Dashboard Admin
Pusat kendali operasional owner.

### Modul:
- Ringkasan member
- Statistik check-in
- Daftar alat gym
- Katalog kelas
- Master rank
- Search member
- Status member
- Shortcut scanner

---

## 10.6 Manajemen Member
Admin dapat:
- Melihat daftar member gym sendiri
- Mencari member berdasarkan nama atau email
- Melihat detail member
- Melihat poin dan streak
- Menandai member aktif atau non-aktif
- Memberikan bonus poin manual bila diperlukan

### Data penting di detail member:
- Nama
- Email
- Status aktif
- Poin saat ini
- Streak harian
- Rank saat ini
- Riwayat check-in terbaru

---

## 10.7 Manajemen Inventaris Alat
Admin mengelola alat gym sebagai referensi edukasi member.

### Operasi:
- Create alat
- Read daftar alat
- Update data alat
- Delete alat

### Data alat:
- Nama alat
- Foto alat
- Instruksi penggunaan
- Link video tutorial
- Status aktif atau rusak

### Tujuan:
- Member lebih paham penggunaan alat
- Mengurangi kebingungan di ruang gym
- Menambah nilai edukasi pada aplikasi

---

## 10.8 Manajemen Harga dan Kelas
Admin bisa membuat layanan yang dijual ke member.

### Jenis layanan:
- Gym Access
- Specialist Class
- Personal Trainer

### Data layanan:
- Nama layanan
- Harga
- Deskripsi
- Status aktif
- Poin reward

### Tujuan:
- Menjadi basis monetisasi gym
- Memudahkan owner mengatur daftar layanan

---

## 10.9 Master Rank Loyalty System
Sistem loyalitas untuk meningkatkan retensi member.

### Contoh rank:
- Bronze
- Silver
- Gold

### Setiap rank memiliki:
- Nama rank
- Threshold poin
- Daftar benefit

### Contoh benefit:
- Diskon kelas
- Minuman gratis
- Prioritas akses
- Bonus check-in

### Fungsi:
- Memotivasi member datang rutin
- Membangun kebiasaan latihan
- Menambah elemen gamifikasi

---

## 10.10 QR Member Generator
Member memiliki identitas digital dalam bentuk QR.

### Isi QR:
- `mem_user_uid`
- `mem_gym_id`

### Aturan:
- QR dibuat dinamis
- Refresh otomatis setiap 60 detik
- QR tidak menyimpan data sensitif tambahan
- QR digunakan untuk identifikasi member saat check-in

### UX tambahan:
- Brightness layar naik saat QR dibuka
- Tampilan QR harus besar dan jelas
- Tampil status membership aktif

---

## 10.11 QR Scanner Admin
Admin memindai QR member untuk check-in.

### Alur:
1. Admin membuka scanner
2. QR terbaca
3. Sistem mengambil data member
4. Bottom sheet konfirmasi muncul
5. Admin memilih jenis check-in
6. Sistem menyimpan log dan memperbarui data

### Tipe check-in:
- Daily Check-in
- Class Check-in

### Validasi:
- Gym harus cocok
- Member harus terdaftar di gym tersebut
- Status membership harus aktif
- Kelas harus valid jika check-in kelas

---

## 10.12 Check-in Engine
Mesin logika untuk mencatat kehadiran member.

### Saat berhasil check-in:
- Menambah log aktivitas
- Memperbarui streak harian
- Menambahkan poin bila relevan
- Menampilkan animasi sukses
- Menampilkan notifikasi sukses

### Aturan streak:
- Jika check-in harian dilakukan berurutan, streak bertambah
- Jika melewatkan hari tertentu, streak dapat direset atau dihitung ulang sesuai aturan yang ditentukan

---

## 10.13 Riwayat Aktivitas
Member dapat melihat catatan kehadiran mereka.

### Tampilan:
- Daftar kronologis
- Dikelompokkan per bulan
- Tipe daily dan class dibedakan dengan ikon
- Ada timestamp jelas

### Tujuan:
- Member tahu konsistensi latihan mereka
- Menjadi bahan evaluasi kebiasaan olahraga

---

## 10.14 Visualisasi Data
Untuk memperkuat poin level expert, aplikasi menampilkan data sederhana dalam bentuk grafik.

### Grafik utama:
- Frekuensi check-in 7 hari terakhir
- Streak member
- Tren keaktifan singkat

### Tujuan:
- Membantu member melihat progres
- Membantu owner membaca aktivitas member

---

## 11. Struktur Modul Aplikasi

### 11.1 Modul Auth
- Login
- Register Member
- Register Owner
- Role routing
- Session handling

### 11.2 Modul Owner Dashboard
- Dashboard overview
- Member management
- Equipment management
- Class and pricing management
- Rank configuration
- QR scanner

### 11.3 Modul Member Dashboard
- Gym discovery
- Active gym home
- QR generator
- Equipment education
- Class list
- Rank and points
- Activity log

### 11.4 Modul Core
- Theme
- Constants
- Utilities
- Widgets
- Helper functions
- Validators
- Formatters

---

## 12. Data Model Konseptual

### 12.1 `gym_tenants`
Menyimpan identitas gym.

Field utama:
- `gt_id_key`
- `gt_name_title`
- `gt_address_location`
- `gt_owner_uid`
- `gt_created_at`

### 12.2 `gym_master_ranks`
Konfigurasi rank per gym.

Field utama:
- `rank_id_key`
- `rank_parent_gym_id`
- `rank_title_name`
- `rank_min_points_threshold`
- `rank_benefit_description_list`

### 12.3 `gym_equipments`
Inventaris alat gym.

Field utama:
- `equip_id_key`
- `equip_parent_gym_id`
- `equip_name_label`
- `equip_image_storage_url`
- `equip_usage_instruction_text`
- `equip_tutorial_video_link`
- `equip_is_active_status`

### 12.4 `user_accounts_global`
Profil global user.

Field utama:
- `user_uid_auth`
- `user_full_name`
- `user_email_address`
- `user_global_role`

### 12.5 `gym_members_registry`
Data member per gym.

Field utama:
- `mem_id_key`
- `mem_user_uid`
- `mem_gym_id`
- `mem_current_points_balance`
- `mem_streak_consecutive_days`
- `mem_join_timestamp`

### 12.6 `gym_classes_catalog`
Daftar kelas dan layanan.

Field utama:
- `class_id_key`
- `class_parent_gym_id`
- `class_title_name`
- `class_pricing_amount`
- `class_is_personal_trainer`

### 12.7 `gym_attendance_logs`
Log check-in.

Field utama:
- `log_id_key`
- `log_member_id`
- `log_gym_id`
- `log_category_type`
- `log_reference_class_id`
- `log_recorded_at`

---

## 13. Arsitektur Sistem

### 13.1 Arsitektur yang Dipilih
**Feature-first Clean Architecture**

Struktur utama:
- Data layer
- Domain layer
- Presentation layer

### 13.2 Alasan Pemilihan
- Mudah dikembangkan bertahap
- Cocok untuk aplikasi dengan banyak fitur
- Mudah dipelihara
- Cocok untuk standard penilaian expert
- Memisahkan logika bisnis dari UI

### 13.3 Tools dan Teknologi
- Flutter
- Firebase Auth
- Firestore
- Firebase Storage
- Riverpod
- GetIt
- Freezed
- QR scanner package
- Lottie
- Chart package

---

## 14. Standar Package

### Core
- `firebase_core`
- `cloud_firestore`
- `firebase_auth`
- `firebase_storage`

### State Management
- `flutter_riverpod`
- `riverpod_annotation`

### UI dan Visual
- `lottie`
- `qr_flutter`
- `mobile_scanner`
- `google_fonts`
- `lucide_icons`
- `fl_chart`

### Architecture
- `get_it`
- `freezed_annotation`

### Utility
- `image_picker`

---

## 15. Sistem Desain

### 15.1 Identitas Visual
- Minimalist
- Clean
- Modern
- Sporty
- Premium

### 15.2 Warna Brand
- Primary: `#C0FE39`
- Secondary: `#57B2DC`
- Accent: `#BBF6E2`

### 15.3 Warna Dark Mode
- Background: `#121417`
- Surface: `#1E2126`
- Primary text: `#F1F3F4`
- Secondary text: `#ADB5BD`

### 15.4 Tipografi
- Heading: Montserrat
- Body: Inter

### 15.5 Komponen Reusable
- `GymmyButton`
- `GymmyCard`
- `GymmyInput`

### 15.6 Prinsip Komponen
- Konsisten
- Ringan
- Reusable
- Mudah dipakai lintas fitur

---

## 16. Aset dan Animasi

### 16.1 Lottie
- `success_checkin.json`
- `rank_up.json`
- `loading_bar.json`

### 16.2 Gambar
- Placeholder alat gym
- Empty state gym
- Logo aplikasi

### 16.3 Hero Animation
Hero animation wajib dipakai untuk:
- Gambar alat gym
- Logo gym
- Transisi kartu gym ke detail

### 16.4 UX Feedback
- Animasi sukses saat check-in
- Animasi saat naik rank
- Loading state yang halus
- Transisi antar halaman yang lembut

---

## 17. Business Rules

### 17.1 Aturan Umum
- Satu member hanya terdaftar aktif pada gym yang sesuai
- Data antar gym harus terisolasi
- Owner hanya mengelola gym miliknya
- Member hanya membaca data gym tempat ia terdaftar
- QR check-in harus cocok dengan gym tenant

### 17.2 Aturan Point
- Poin bertambah dari pembelian layanan tertentu
- Poin dapat bertambah manual oleh admin jika diperlukan
- Rank dihitung berdasarkan threshold poin

### 17.3 Aturan Streak
- Check-in harian yang berurutan meningkatkan streak
- Data streak harus disimpan di registry member
- Riwayat check-in harus dicatat pada log

### 17.4 Aturan QR
- QR bersifat dinamis
- QR memiliki masa berlaku singkat
- QR tidak boleh digunakan lintas gym

---

## 18. Keamanan Data

### 18.1 Firebase Security Rules
- Member hanya bisa membaca data gym sendiri
- Owner hanya bisa CRUD pada data gym miliknya
- Data global hanya sebagian yang boleh dibaca publik
- Storage hanya bisa diakses sesuai otorisasi

### 18.2 Prinsip Keamanan
- Batasi akses berdasarkan `gym_id`
- Validasi role sebelum operasi penting
- Gunakan data timestamp untuk audit
- Hindari penyimpanan data sensitif di QR

---

## 19. Non-Functional Requirements

### 19.1 Performansi
- Aplikasi harus ringan
- Fetch data harus efisien
- UI harus responsif
- List panjang harus dioptimalkan

### 19.2 Maintainability
- Struktur folder harus jelas
- Widget harus reusable
- Business logic tidak bercampur dengan UI

### 19.3 Usability
- Mudah dipahami pengguna awam
- Navigasi sederhana
- Pesan error jelas
- Tampilan konsisten

### 19.4 Reliability
- Error handling harus baik
- Data check-in tidak boleh double submit
- Proses login harus stabil

---

## 20. Risk Register

### Risiko 1: Scope terlalu besar
**Dampak:** Pengerjaan melebihi waktu UAS  
**Mitigasi:** Prioritaskan fitur inti dan MVP

### Risiko 2: Konflik role dan security
**Dampak:** Data lintas gym bocor  
**Mitigasi:** Terapkan rules berbasis gym_id dari awal

### Risiko 3: QR scanner gagal membaca
**Dampak:** Check-in terganggu  
**Mitigasi:** Gunakan layout QR yang jelas dan brightness boost

### Risiko 4: Terlalu banyak animasi
**Dampak:** UI berat  
**Mitigasi:** Batasi animasi hanya sebagai feedback penting

### Risiko 5: Data model terlalu rumit
**Dampak:** Implementasi lambat  
**Mitigasi:** Gunakan field name eksplisit dan konsisten

---

## 21. Prioritas Pengembangan

### Prioritas 1: Fondasi
- Setup project
- Firebase
- Auth
- Role routing
- Struktur folder
- Theme system

### Prioritas 2: Fitur Inti
- Gym tenant
- Member registry
- Equipment CRUD
- Class pricing
- Rank config

### Prioritas 3: Check-in
- QR generator
- QR scanner
- Log attendance
- Streak update

### Prioritas 4: Experience
- Discovery
- Dashboard member
- Riwayat aktivitas
- Chart
- Animasi

---

## 22. Definition of Done

Fitur dianggap selesai jika:
- Bisa dijalankan tanpa error utama
- UI sesuai tema
- Data tersimpan ke Firestore
- Role routing berjalan benar
- Security rule tidak bocor lintas gym
- QR check-in berfungsi
- Poin, streak, dan rank ter-update
- Halaman utama cukup stabil untuk demo dan publish APK

---

## 23. Output yang Diharapkan dari Development

Saat proyek selesai, hasil akhir minimal harus memiliki:
- APK yang bisa diinstal
- Login dan registrasi dua role
- Dashboard owner dan member
- CRUD alat gym
- QR generator dan scanner
- Check-in log
- Rank system
- Grafik aktivitas
- Dark mode dan light mode
- Komponen reusable yang konsisten

---

## 24. Catatan Implementasi untuk Antigravity

Antigravity harus diarahkan untuk:
- Menghasilkan kode sesuai clean architecture
- Memisahkan data, domain, dan presentation
- Membuat service dan repository yang jelas
- Menggunakan provider secara modular
- Menghindari hardcode berlebihan
- Menjaga naming field konsisten
- Menyusun file secara feature-first
- Menghasilkan UI yang rapi, modern, dan siap demo

### Aturan penting untuk implementasi:
- Semua data gym wajib memakai `gym_id`
- Semua akses user wajib melalui role check
- Semua check-in wajib menghasilkan log
- Semua perubahan poin dan streak wajib tercatat
- Semua widget utama wajib reusable

---

## 25. Kesimpulan

GYMMY adalah aplikasi mobile manajemen membership gym berbasis SaaS yang menggabungkan administrasi operasional, edukasi alat gym, check-in QR, loyalitas member, dan visualisasi aktivitas dalam satu platform modern.

Dengan arsitektur yang rapi, desain minimalis, sistem multi-tenant, dan gamifikasi yang jelas, aplikasi ini layak dijadikan proyek UAS dengan kualitas tinggi serta berpotensi dikembangkan lebih lanjut menjadi produk nyata.

---

## 26. Lampiran Ringkas Implementasi

### Modul wajib untuk MVP
- Auth
- Role routing
- Tenant setup
- Equipment CRUD
- Member registry
- QR generator
- QR scanner
- Attendance log
- Rank calculation
- Chart 7 hari
- Theme dan reusable components

### Modul tambahan jika waktu cukup
- Discovery gym
- Class management detail
- Animasi hero lanjutan
- Empty state ilustratif
- Notifikasi in-app
