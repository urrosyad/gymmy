# PROJECT BRIEF REVISI  
## GYMMY - Aplikasi Mobile Manajemen Akses Gym dan Membership Berbasis SaaS

**Status dokumen:** Revisi utama alur produk  
**Tujuan dokumen:** Menjadi blueprint utama yang sudah disesuaikan dengan alur baru user, owner, membership, dan daily access  
**Platform target:** Android mobile app, dapat dipublish sebagai APK  
**Nama produk:** GYMMY  
**Model bisnis:** SaaS multi-tenant untuk beberapa gym/cabang dalam satu platform

---

## 1. Ringkasan Produk

GYMMY adalah aplikasi mobile berbasis **Software as a Service (SaaS)** untuk mengelola ekosistem akses gym, mulai dari discovery gym, daily access, membership, class access, check-in QR, sampai pemantauan aktivitas member di gym yang dipilih. Aplikasi ini bukan hanya membership manager, tetapi juga marketplace gym, sistem akses harian, dan platform operasional owner.

Aplikasi ini memiliki dua sisi utama:

1. **Sisi Owner / Admin Gym**
   - Mengisi data gym melalui wizard saat onboarding
   - Mengelola data gym
   - Mengelola member dan user yang berkunjung
   - Mengelola harga daily, membership, class, PT, dan benefit rank
   - Memverifikasi check-in dan QR terkait akses gym
   - Memantau aktivitas member dan visitor

2. **Sisi User / Member / Daily Visitor**
   - Login lalu masuk ke dashboard discovery gym
   - Mencari gym terdekat dari daftar gym tenant yang sudah terdaftar sebagai owner gym
   - Melihat detail gym sebelum memutuskan daily access atau membership
   - Mengisi biodata wajib sebelum dapat melakukan daily access atau membership
   - Melakukan check-in harian melalui QR general
   - Mengajukan membership di lokasi gym melalui QR khusus
   - Melihat aktivitas, class, poin, rank, dan histori bila sudah membership aktif

Produk ini dirancang agar pengalaman user lebih realistis: user baru tidak langsung menjadi member gym, tetapi harus memilih gym terlebih dahulu lalu menentukan akses daily atau membership sesuai kebutuhan.

---

## 2. Latar Belakang Masalah

Banyak gym masih menghadapi masalah berikut:

- Pencatatan membership masih manual atau tersebar di banyak file
- User baru tidak punya alur discovery gym yang jelas
- Proses check-in tidak rapi dan rawan salah input
- Member sering tidak memahami cara penggunaan alat
- Owner sulit memantau aktivitas member dan visitor
- Tidak ada pemisahan jelas antara daily access dan membership access
- Pengelolaan kelas, PT, dan harga masih kurang terstruktur
- User sering perlu datang ke tempat gym untuk aktivasi membership, tetapi alurnya belum terdokumentasi dengan baik

GYMMY dirancang untuk menjawab masalah tersebut melalui satu platform mobile yang ringan, modern, berbasis data, dan memiliki alur onboarding gym yang lebih nyata.

---

## 3. Tujuan Produk

### 3.1 Tujuan Utama
Membangun aplikasi mobile yang dapat:
- Mendigitalisasi discovery dan akses gym
- Memudahkan operasional owner/admin
- Memisahkan alur daily access dan membership access
- Membantu user memilih gym yang sesuai
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
- Wizard onboarding untuk mendaftarkan gym
- Dashboard operasional
- Kontrol member dan visitor
- Kontrol inventaris
- Kontrol harga daily, membership, kelas, dan PT
- Kontrol akses check-in
- Data aktivitas gym yang mudah dipantau

### 4.2 User Member / Daily Visitor
Pengguna yang belum tentu langsung berlangganan membership. Mereka membutuhkan:
- Login dan identitas digital
- Discovery gym terdekat
- Detail gym sebelum memilih akses
- Daily access
- Membership access
- Panduan alat
- Check-in cepat
- Poin, rank, dan histori aktivitas bila membership aktif

---

## 5. Value Proposition

### Untuk Owner
- Mengurangi proses manual
- Data lebih rapi dan terpusat
- Memantau member dan visitor lebih cepat
- Mengelola gym, kelas, alat, dan harga dalam satu sistem
- Memiliki platform yang terlihat profesional

### Untuk User
- Bisa mencari gym terdekat dengan mudah
- Bisa memilih antara daily access atau membership
- Bisa melihat detail gym sebelum masuk
- Check-in lebih cepat dan modern
- Mendapat feedback visual saat berhasil check-in
- Ada pengalaman progres jika menjadi member aktif

---

## 6. Ruang Lingkup Produk

### 6.1 In Scope
Fitur yang wajib dibangun dalam versi ini:
- Autentikasi multi-role
- Registrasi owner dan user
- Wizard onboarding owner saat mendaftar gym
- Discovery gym setelah login
- Detail gym lengkap sebelum akses
- Biodata user wajib sebelum daily access atau membership
- Dashboard member dan visitor
- Manajemen member
- CRUD inventaris alat gym
- Manajemen harga daily, membership, kelas, dan PT
- Master rank loyalty system
- QR generator untuk daily access, membership, dan class flow
- QR scanner untuk owner
- Check-in validation
- Riwayat check-in
- Grafik 7 hari terakhir
- Theme system light dan dark
- Reusable component library
- Firebase backend

### 6.2 Out of Scope
Fitur yang tidak wajib pada versi ini:
- Pembayaran real payment gateway di dalam aplikasi
- Chat antar user dan admin
- Integrasi wearable device
- Integrasi AI workout recommendation
- Push notification kompleks
- Offline sync lanjutan
- Multi-language
- Web dashboard terpisah

Catatan:
Pembayaran daily access, membership, dan class dilakukan secara offline di tempat gym, bukan di dalam sistem aplikasi.

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
- Realistis sebagai produk gym access dan membership

### 7.2 Prinsip UX
- Navigasi harus singkat
- User baru harus diarahkan ke discovery terlebih dahulu
- Informasi penting harus tampil di atas
- Form harus sederhana dan jelas
- Feedback sistem harus instan
- Data visual harus mudah dibaca
- Hierarki layar harus berbeda antara owner, member aktif, dan visitor harian

### 7.3 Prinsip UI
- Gunakan ruang putih atau dark surface secara seimbang
- Hindari tampilan ramai
- Gunakan aksen warna secara terkontrol
- Gunakan kartu, badge, dan progress bar untuk memperjelas status
- Animasi dipakai sebagai feedback, bukan dekorasi berlebihan

---

## 8. Persona Pengguna

### 8.1 Persona Owner
- Memiliki gym kecil sampai menengah
- Tidak ingin ribet dengan pencatatan manual
- Ingin data member dan visitor cepat dicari
- Ingin kontrol alat, kelas, dan harga dari satu aplikasi
- Ingin tampilan yang modern agar bisnis terlihat profesional

### 8.2 Persona User Baru
- Belum punya gym tetap
- Ingin mencari gym terdekat
- Ingin melihat detail gym sebelum memutuskan
- Membutuhkan alur daily access yang sederhana
- Ingin melihat harga dan fasilitas secara jelas

### 8.3 Persona Member Aktif
- Sudah berlangganan gym tertentu
- Sering menggunakan mobile untuk aktivitas harian
- Suka visual yang jelas dan cepat dipahami
- Ingin progres kebugaran terasa nyata
- Tertarik pada poin, rank, streak, dan histori aktivitas

---

## 9. User Journey Utama

### 9.1 Journey Owner
1. Owner membuat akun
2. Owner mengisi data pemilik, data gym, harga daily, dan harga membership melalui wizard
3. Sistem otomatis membuat gym tenant dan struktur awal gym
4. Owner masuk dashboard admin
5. Owner menambahkan alat gym
6. Owner mengatur layanan, kelas, dan rank
7. Owner memantau user membership dan daily access
8. Owner melakukan validasi check-in member atau visitor

### 9.2 Journey User Baru
1. User membuat akun
2. User login
3. User masuk dashboard awal berisi card rekomendasi gym tenant terdekat
4. User mengisi biodata wajib sebelum dapat menggunakan daily access atau membership
5. User klik salah satu card gym
6. User melihat detail gym lengkap
7. User memilih daily access atau membership
8. Sistem mengarahkan user ke flow akses yang sesuai

### 9.3 Journey Daily Visitor
1. User memilih daily access di detail gym
2. User melihat QR general untuk check-in harian
3. Owner memindai QR tersebut
4. Sistem menyimpan log daily check-in
5. Payment dilakukan offline di tempat gym
6. User tetap berada pada akses terbatas tanpa fitur membership penuh

### 9.4 Journey Member Aktif
1. User memilih membership di detail gym
2. User mendapat informasi bahwa aktivasi membership dilakukan di lokasi gym
3. Di tempat gym, owner menyediakan QR membership khusus
4. User memindai QR membership melalui APK user
5. Sistem mengaktifkan membership user pada gym tersebut
6. Dashboard member menampilkan gym yang dilanggan, aktivitas, poin, rank, alat, dan class
7. User dapat memakai fitur membership penuh selama status aktif

---

## 10. Fitur Inti Produk

## 10.1 Autentikasi Multi-Role
Sistem login tunggal untuk semua user.

### Role:
- Owner
- User

### Alur:
- Login dengan email dan password
- Sistem membaca `user_global_role`
- Jika role Owner, arahkan ke wizard onboarding owner
- Jika role User, arahkan ke dashboard discovery gym

### Registrasi:
- Mode User
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
- Nama lengkap pemilik
- Email pemilik
- Nama gym
- Lokasi gym
- Harga daily
- Harga membership
- Persetujuan syarat dan ketentuan

### Sistem otomatis saat owner berhasil daftar:
- Membuat akun auth
- Membuat profil global user
- Membuat dokumen gym tenant
- Menghubungkan owner ke gym
- Menyiapkan data awal gym
- Membuka akses ke modul kelola data

---

## 10.3 Registrasi User
Registrasi user dibuat sederhana agar onboarding cepat.

### Data wajib:
- Nama lengkap
- Email
- Password
- Persetujuan kebijakan

### Setelah registrasi:
- Membuat akun auth
- Membuat profil global user
- Mengarahkan user ke dashboard discovery gym
- User belum otomatis punya membership gym

---

## 10.4 Discovery Gym
Fitur utama untuk user baru yang belum punya gym tetap.

### Komponen:
- Search bar gym
- Card gym rekomendasi
- Nama gym
- Gambar gym
- Lokasi gym
- Rate gym
- Tombol detail

### Tujuan:
- Mempermudah user menemukan gym mitra
- Menjadi pintu masuk onboarding user baru

---

## 10.5 Detail Gym
Ketika user klik card gym, tampil halaman detail lengkap.

### Isi halaman:
- Gambar utama gym
- Deskripsi gym
- Lokasi
- Harga daily access
- Harga membership
- Kelas tambahan
- PT
- Alat yang tersedia
- Button daily access
- Button membership

### Tujuan:
- Memberi informasi lengkap sebelum user memutuskan akses

---

## 10.6 Daily Access Flow
Daily access dipakai user yang hanya ingin datang harian.

### Alur:
- User memilih daily access dari detail gym
- User wajib mengisi biodata terlebih dahulu jika belum lengkap
- User melihat QR general
- Owner memindai QR
- Sistem mencatat daily check-in
- Pembayaran dilakukan offline di tempat gym

### Aturan:
- Daily visitor tidak mendapatkan fitur membership penuh
- Daily visitor hanya mendapat akses harian

---

## 10.7 Membership Flow
Membership harus dilakukan di tempat gym.

### Alur:
- User memilih membership dari detail gym
- Aplikasi menampilkan catatan bahwa aktivasi membership dilakukan di lokasi gym
- Owner memiliki QR membership khusus
- User memindai QR membership lewat APK user
- Sistem mengaktifkan membership pada gym tersebut

### Setelah membership aktif:
- User masuk dashboard home gym langganan
- User mendapat akses penuh sesuai status membership

---

## 10.8 Biodata Wajib User
Sebelum user dapat daily access atau membership, user wajib mengisi biodata.

### Data wajib:
- Nama lengkap
- Tanggal lahir
- Berat badan
- Tinggi badan
- Frekuensi aktivitas harian

### Tujuan:
- Menjadi data dasar user
- Menyesuaikan pengalaman akses gym
- Menjadi prasyarat sebelum check-in daily atau membership

---

## 10.9 Dashboard Member Aktif
Dashboard setelah user menjadi member aktif pada gym tertentu.

### Isi dashboard:
- Nama gym yang dilanggan
- Ringkasan aktivitas gym
- Card poin
- Rank
- Daftar alat gym
- Kelas yang diambil bila ada
- Progress bar masa langganan
- Tombol berhenti langganan dengan validasi

### Tujuan:
- Menjadi pusat pengalaman membership aktif

---

## 10.10 Dashboard Daily Visitor
Dashboard untuk user yang hanya daily access.

### Isi dashboard:
- Akses ke detail gym
- QR daily access
- Informasi gym yang dipilih
- Status biodata
- Informasi bahwa fitur membership belum aktif

### Batasan:
- Tidak ada fitur rank penuh
- Tidak ada streak penuh
- Tidak ada history membership penuh
- Tidak ada akses ke class dashboard membership

---

## 10.11 Modul Kelas
Kelas memiliki alur khusus.

### Isi halaman kelas:
- Daftar kelas pada gym tersebut
- Deskripsi kelas
- Harga per bulan
- Jumlah pertemuan
- Jadwal kelas

### Daftar kelas:
- Jika user ingin mendaftar kelas, tampil QR yang berisi `user_id + class_id`
- Owner memindai QR tersebut
- Sistem menandai user sudah mulai berlangganan kelas
- Pembayaran dilakukan offline

### Saat check-in kelas:
- User membuka menu kelas
- Tampil QR class check-in
- Owner memindai QR tersebut saat jadwal kelas

---

## 10.12 Dashboard Owner
Pusat kendali operasional owner.

### Modul:
- Ringkasan harga daily dan membership
- Total member aktif
- Total kelas gym
- Total equipment
- Kelola data
- Membership members
- Activity logs
- Scan menu
- Profil gym

---

## 10.13 Kelola Data Owner
Owner mengelola semua data operasional gym.

### CRUD:
- Harga daily dan membership
- Benefit rank
- Data kelas
- Data equipment gym

### Tujuan:
- Menjadi pusat administrasi gym
- Memudahkan owner mengubah data penting

---

## 10.14 Membership Data Owner
Owner dapat melihat data seluruh user yang melakukan membership.

### Isi:
- Nama user
- Tanggal mulai membership
- Kelas yang diambil
- Rank user
- Aktivitas latihan
- Riwayat check-in

### Tujuan:
- Membantu owner memantau member aktif
- Memudahkan validasi loyalitas dan aktivitas

---

## 10.15 Sistem QR dan Access Control

GYMMY menggunakan beberapa jenis QR untuk mendukung alur operasional gym yang berbeda. QR bukan hanya dipakai untuk absensi, tetapi juga untuk aktivasi membership, pendaftaran kelas, dan check-in kelas.

### 10.15.1 Prinsip Umum QR
- QR harus memiliki jenis yang jelas melalui field `type`
- QR bersifat dinamis dan memiliki waktu berlaku
- QR hanya valid untuk gym dan konteks yang sesuai
- QR tidak boleh dipakai lintas gym
- QR tidak boleh menyimpan data sensitif berlebihan
- QR harus bisa divalidasi oleh sistem sebelum proses database dijalankan

### 10.15.2 Jenis QR yang Digunakan
1. **QR Daily Check-in**
   - Digunakan oleh user yang ingin melakukan check-in harian ke gym
   - Ditampilkan oleh user
   - Discanning oleh owner/admin
   - Setelah valid, sistem mencatat daily visit pada database

2. **QR Membership Activation**
   - Digunakan saat user ingin mengaktifkan membership gym
   - Ditampilkan oleh owner/gym
   - Discanning oleh user melalui aplikasi
   - Setelah valid, sistem membuat membership aktif pada gym tujuan

3. **QR Class Subscription**
   - Digunakan saat user mendaftar kelas tertentu
   - Ditampilkan oleh user
   - Discanning oleh owner/admin
   - Setelah valid, sistem mencatat user terdaftar pada kelas tersebut

4. **QR Class Attendance**
   - Digunakan saat user melakukan check-in kelas sesuai jadwal
   - Ditampilkan oleh user
   - Discanning oleh owner/admin
   - Setelah valid, sistem mencatat attendance kelas dan riwayat aktivitas

### 10.15.3 Alur QR Daily Check-in
- User memilih gym yang dituju
- User membuka menu daily check-in
- Aplikasi menampilkan QR daily
- Owner/admin memindai QR
- Sistem memvalidasi gym, user, dan masa berlaku QR
- Jika valid, sistem menyimpan daily visit ke database

### 10.15.4 Alur QR Membership Activation
- User berada di lokasi gym
- Owner/gym menampilkan QR membership activation
- User memindai QR dari aplikasi
- Sistem memvalidasi gym dan paket membership
- Jika valid, sistem mengaktifkan membership user untuk gym tersebut

### 10.15.5 Alur QR Class Subscription
- User membuka detail kelas
- User memilih daftar kelas
- Aplikasi menampilkan QR pendaftaran kelas
- Owner/admin memindai QR
- Sistem mencatat user sebagai peserta kelas tersebut

### 10.15.6 Alur QR Class Attendance
- User membuka kelas aktif yang dimiliki
- User menampilkan QR check-in kelas
- Owner/admin memindai QR
- Sistem memvalidasi jadwal dan kepemilikan kelas
- Jika valid, sistem mencatat attendance kelas

### 10.15.7 Ketentuan Teknis QR
- Payload QR harus dibuat dalam format data terstruktur
- QR harus menyertakan `type`, `userId`, `gymId`, dan timestamp
- QR dynamic refresh disarankan untuk mencegah screenshot reuse
- QR check-in harus menghasilkan log database
- QR membership harus mengubah status membership bila berhasil
- QR kelas harus terhubung dengan data kelas yang sesuai

### 10.15.8 Dampak ke Dashboard
- User yang belum punya gym akan melihat onboarding dan discovery gym
- User membership akan melihat dashboard penuh dengan fitur loyalty
- User non-membership hanya melihat fitur terbatas sesuai status akses
- Menu QR yang tampil harus menyesuaikan status akses user

### 10.15.9 Tujuan Fitur QR
- Mempercepat operasional gym
- Menjaga alur check-in tetap rapi
- Membuat aktivasi membership lebih terkontrol
- Membedakan akses daily visitor dan member aktif
- Menjadi bagian utama dari pengalaman pengguna GYMMY
---

## 10.16 Profil Owner
Halaman profil untuk owner.

### Isi:
- Profil gym
- Ubah biodata gym
- Informasi dasar gym
- Pengaturan akun

---

## 10.17 Riwayat Aktivitas
User aktif dapat melihat catatan kehadiran mereka.

### Tampilan:
- Daftar kronologis
- Dikelompokkan per bulan
- Tipe daily, class, dan membership dibedakan dengan ikon
- Ada timestamp jelas

### Tujuan:
- User tahu konsistensi latihan dan status akses mereka

---

## 10.18 Visualisasi Data
Untuk memperkuat poin level expert, aplikasi menampilkan data sederhana dalam bentuk grafik.

### Grafik utama:
- Frekuensi check-in 7 hari terakhir
- Streak member aktif
- Tren keaktifan singkat

### Tujuan:
- Membantu member melihat progres
- Membantu owner membaca aktivitas user

---

## 11. Struktur Modul Aplikasi

### 11.1 Modul Auth
- Login
- Register User
- Register Owner
- Role routing
- Session handling

### 11.2 Modul Discovery
- Search gym
- Card gym terdekat
- Detail gym
- Daily access
- Membership flow

### 11.3 Modul Owner Dashboard
- Dashboard overview
- Kelola data
- Membership members
- Activity logs
- QR scanner
- Profil gym

### 11.4 Modul Member Aktif
- Home gym langganan
- QR generator
- Equipment education
- Class list
- Rank dan points
- Activity log

### 11.5 Modul Core
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
- `gt_image`
- `gt_location`
- `gt_rate`
- `gt_owner_uid`
- `gt_created_at`
- `gt_description_text`
- `gt_city_name`
- `gt_operational_hours`
- `gt_gallery_images`
- `gt_daily_price_amount`
- `gt_membership_price_amount`
- `gt_available_facilities`
- `gt_is_active`

### 12.2 `user_accounts_global`
Profil global user.

Field utama:
- `user_uid_auth`
- `user_full_name`
- `user_email_address`
- `user_global_role`
- `user_created_at`
- `user_profile_photo_url`
- `user_has_completed_biodata`
- `user_last_login_at`
- `user_is_active`

### 12.3 `user_biodata_profiles`
Data fisik user wajib sebelum akses gym.

Field utama:
- `bio_user_uid`
- `bio_full_name`
- `bio_birth_date`
- `bio_weight`
- `bio_height`
- `bio_daily_activity_frequency`
- `bio_gender`
- `bio_goal_type`
- `bio_medical_notes`
- `bio_updated_at`

### 12.4 `gym_members_registry`
Data member per gym.

Field utama:
- `mem_id_key`
- `mem_user_uid`
- `mem_gym_id`
- `mem_membership_type`
- `mem_membership_status`
- `mem_current_points_balance`
- `mem_streak_consecutive_days`
- `mem_join_timestamp`
- `mem_membership_start_date`
- `mem_membership_end_date`
- `mem_current_rank_id`
- `mem_total_checkin_count`
- `mem_last_checkin_at`
- `mem_is_frozen`
- `mem_created_by_owner_uid`

### 12.5 `gym_daily_visits`
Log access harian user non-membership.

Field utama:
- `daily_visit_id_key`
- `daily_visit_user_uid`
- `daily_visit_gym_id`
- `daily_visit_checkin_at`
- `daily_visit_payment_status`
- `daily_visit_qr_session_id`
- `daily_visit_checkout_at`
- `daily_visit_validated_by_owner`
- `daily_visit_status`

### 12.6 `gym_classes_catalog`
Daftar kelas dan layanan.

Field utama:
- `class_id_key`
- `class_parent_gym_id`
- `class_title_name`
- `class_pricing_amount`
- `class_schedule_text`
- `class_session_count`
- `class_is_personal_trainer`
- `class_description_text`
- `class_thumbnail_image_url`
- `class_max_capacity`
- `class_current_subscribers`
- `class_is_active`

### 12.7 `gym_equipments`
Inventaris alat gym.

Field utama:
- `equip_id_key`
- `equip_parent_gym_id`
- `equip_name_label`
- `equip_image_storage_url`
- `equip_usage_instruction_text`
- `equip_tutorial_video_link`
- `equip_is_active_status`
- `equip_created_at`
- `equip_last_updated_at`
- `equip_category_type`
- `equip_total_usage_count`

### 12.8 `gym_attendance_logs`
Log check-in.

Field utama:
- `log_id_key`
- `log_member_id`
- `log_gym_id`
- `log_category_type`
- `log_reference_class_id`
- `log_recorded_at`
- `log_user_uid`
- `log_qr_session_id`
- `log_validated_by_owner_uid`
- `log_device_platform`

### 12.9 `gym_master_ranks`
Konfigurasi rank per gym.

Field utama:
- `rank_id_key`
- `rank_parent_gym_id`
- `rank_title_name`
- `rank_min_points_threshold`
- `rank_benefit_description_list`
- `rank_badge_image_url`
- `rank_priority_order`
- `rank_is_active`

### 12.10 `gym_class_subscriptions`
Relasi langganan user terhadap kelas gym.

Field utama:
- `sub_id_key`
- `sub_user_uid`
- `sub_class_id`
- `sub_gym_id`
- `sub_started_at`
- `sub_expired_at`
- `sub_status`

### 12.11 `qr_sessions`
Layer validasi QR operasional aplikasi.

Digunakan untuk:
- anti screenshot abuse
- QR expiration
- operational verification
- attendance validation

Field utama:
- `qr_session_id`
- `qr_type`
- `qr_related_user_uid`
- `qr_related_gym_id`
- `qr_related_class_id`
- `qr_generated_at`
- `qr_expired_at`
- `qr_is_used`

### 12.12 `gym_reviews`
Review dan rating gym.

Field utama:
- `review_id_key`
- `review_gym_id`
- `review_user_uid`
- `review_rating_value`
- `review_review_text`
- `review_created_at`

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

### 15.3 Tema Default
- Default aplikasi: Light Mode
- Dark Mode tersedia sebagai opsi user
- System Theme juga didukung

### 15.4 Warna Light Mode
- Background: `#F7F8FA`
- Surface: `#FFFFFF`
- Primary text: `#121417`
- Secondary text: `#6B7280`

### 15.5 Warna Dark Mode
- Background: `#121417`
- Surface: `#1E2126`
- Primary text: `#F1F3F4`
- Secondary text: `#ADB5BD`

### 15.6 Tipografi
- Heading: Montserrat
- Body: Inter

### 15.7 Komponen Reusable
- `GymmyButton`
- `GymmyCard`
- `GymmyInput`

### 15.8 Prinsip Komponen
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
- Transisi card gym ke detail

### 16.4 UX Feedback
- Animasi sukses saat check-in
- Animasi saat naik rank
- Loading state yang halus
- Transisi antar halaman yang lembut

---

## 17. Business Rules

### 17.1 Aturan Umum
- User baru tidak otomatis menjadi member gym
- User harus memilih gym terlebih dahulu
- Data antar gym harus terisolasi
- Owner hanya mengelola gym miliknya
- User hanya membaca data gym yang dipilih
- QR check-in harus cocok dengan gym tenant
- Biodata user wajib sebelum daily access atau membership

### 17.2 Aturan Access Type
- Daily access memberi akses harian terbatas
- Membership memberi akses penuh pada gym tertentu
- Class access mengikuti kelas yang diambil
- Access type harus disimpan di database

### 17.3 Aturan Point
- Poin bertambah dari pembelian layanan tertentu
- Poin dapat bertambah manual oleh admin jika diperlukan
- Rank dihitung berdasarkan threshold poin

### 17.4 Aturan Streak
- Check-in harian yang berurutan meningkatkan streak
- Data streak harus disimpan di registry member
- Riwayat check-in harus dicatat pada log

### 17.5 Aturan QR
- QR bersifat dinamis
- QR memiliki masa berlaku singkat
- QR tidak boleh digunakan lintas gym
- QR berbeda untuk daily, membership, dan class flow

---

## 18. Keamanan Data

### 18.1 Firebase Security Rules
- User hanya bisa membaca data gym yang dipilih atau dimiliki
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
- Biodata user
- Discovery gym
- Detail gym
- Daily access
- Membership access
- Equipment CRUD
- Class pricing
- Rank config

### Prioritas 3: Check-in
- QR generator
- QR scanner
- Log attendance
- Streak update

### Prioritas 4: Experience
- Dashboard member aktif
- Dashboard daily visitor
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
- Dashboard owner
- Dashboard discovery user
- Dashboard member aktif
- Detail gym
- QR generator dan scanner
- Check-in log
- Rank system
- Grafik aktivitas
- Light mode dan dark mode
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
- Semua user baru wajib masuk discovery dashboard terlebih dahulu
- Semua check-in wajib menghasilkan log
- Semua perubahan poin dan streak wajib tercatat
- Semua widget utama wajib reusable

---

## 25. Kesimpulan

GYMMY adalah aplikasi mobile manajemen akses gym berbasis SaaS yang menggabungkan discovery gym, daily access, membership access, check-in QR, loyalitas member, dan visualisasi aktivitas dalam satu platform modern.

Dengan arsitektur yang rapi, desain minimalis, sistem multi-tenant, dan alur akses yang realistis, aplikasi ini layak dijadikan proyek UAS dengan kualitas tinggi serta berpotensi dikembangkan lebih lanjut menjadi produk nyata.

---

## 26. Lampiran Ringkas Implementasi

### Modul wajib untuk MVP
- Auth
- Role routing
- Tenant setup
- Biodata user
- Discovery gym
- Detail gym
- Daily access
- Membership access
- Equipment CRUD
- Member registry
- QR generator
- QR scanner
- Attendance log
- Rank calculation
- Chart 7 hari
- Theme dan reusable components

### Modul tambahan jika waktu cukup
- Class management detail
- Animasi hero lanjutan
- Empty state ilustratif
- Notifikasi in-app
