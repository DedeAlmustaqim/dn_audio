# Digital Native Dev

# Roadmap Utama — DN Audio

**Your Music. Your Experience.**

Premium Offline Music Player · Flutter + GetX

---

## 1. Stage 1 — Project Foundation

Fondasi aplikasi, struktur GetX MVC, tema dark premium, navigasi, dan mini-player.

**Status: Selesai**

## 2. Stage 2 — Local Music Library

- Scan musik dari perangkat
- Permission audio
- Integrasi Android MediaStore
- Daftar lagu
- Pencarian lagu
- Refresh library

**Status: Selesai**

## 3. Stage 3 — Audio Playback Engine

- Integrasi `just_audio`
- Play dan Pause
- Next dan Previous
- Seek dan progress
- Shuffle dan Repeat
- Mini-player dan Now Playing

**Status: Implementasi dasar selesai**

## 4. Stage 3.5 — Stabilization & Refinement

- Perbaikan proses library loading
- Penanganan error playback
- Validasi lagu dan metadata
- Unit testing

**Status: Selesai**

## 5. Stage 4 — Background Audio Experience

### 4.1 — Audio Service Architecture

- Integrasi `audio_service`
- Implementasi `DnAudioHandler`
- Satu instance `AudioPlayer` sebagai playback engine
- Integrasi dengan GetX
- Android foreground media service dan media button receiver

**Status: Selesai — sudah diuji lokal**

### 4.2 — Background Playback

- Musik tetap berjalan saat aplikasi diminimalkan
- Musik tetap berjalan saat layar dikunci
- Kontrol playback diarahkan melalui audio handler

**Status: Selesai — sudah diuji lokal**

### 4.3 — Media Notification

- Judul lagu dan artis
- Informasi album dan durasi
- Album artwork dari MediaStore jika tersedia
- Kontrol Play/Pause
- Kontrol Next/Previous
- Progress dan posisi pemutaran
- Kontrol dari notification shade

**Status: Implementasi tersedia — verifikasi dan penyempurnaan berlangsung**

Catatan pengujian perangkat:
- Media notification berhasil muncul.
- Judul lagu, progress, durasi, dan kontrol media sudah tampil.
- Metadata artis masih terbaca sebagai `<unknown>` pada lagu yang diuji.
- Artwork notification kini memiliki resolver native: embedded artwork terlebih dahulu, lalu fallback MediaStore album art; hasil disimpan di cache aplikasi.
- Now Playing kini mendengarkan `MediaItem.artUri` dari `DnAudioHandler`; pengguna telah mengonfirmasi artwork tampil di halaman Now Playing.
- Sinkronisasi status Play/Pause antara Now Playing dan notifikasi sudah berhasil diuji.

### 4.4 — Lock Screen & Audio Focus

- Informasi musik di lock screen
- Kontrol headset dan Bluetooth
- Audio focus
- Penanganan panggilan dan interupsi audio

#### 4.4.1 — Audio Session & Audio Focus

- Menambahkan dependency `audio_session`
- Mengonfigurasi `AudioSessionConfiguration.music()` saat startup
- Menangani event `becomingNoisyEventStream` untuk pause saat headset dilepas
- Interupsi audio lainnya tetap ditangani oleh mekanisme bawaan `just_audio`

**Status: Implementasi tersedia di GitHub — pengujian perangkat ditunda**

Catatan:
- Pengujian headset kabel dan Bluetooth belum dilakukan karena perangkat headset belum tersedia.
- Pengujian interupsi panggilan dan audio dari aplikasi lain juga masih tertunda.
- Jangan tandai substage ini selesai sebelum pengujian perangkat dilakukan.

#### 4.4.2 — Headset & Bluetooth Controls

- Memastikan tombol media headset dapat mengontrol playback
- Memastikan tombol media Bluetooth dapat mengontrol playback
- Memastikan event perubahan koneksi audio ditangani dengan aman

**Status: Belum dimulai**

#### 4.4.3 — Lock Screen Experience

- Memastikan judul, artis, album, dan artwork tampil di lock screen
- Memastikan Play/Pause, Next/Previous dapat digunakan dari lock screen
- Memastikan status playback tetap sinkron

**Status: Belum dimulai**

#### 4.4.4 — Audio Interruption & Stabilization

- Menangani interupsi panggilan dan audio dari aplikasi lain
- Memastikan perilaku playback setelah interupsi
- Pengujian akhir audio focus dan perubahan perangkat audio

**Status: Belum dimulai**

## 6. Stage 5 — Playlist Management

- Membuat playlist
- Rename playlist
- Menghapus playlist
- Menambah dan menghapus lagu dari playlist
- Menampilkan daftar lagu dalam playlist
- Pemutaran berdasarkan playlist
- Next/Previous mengikuti urutan playlist
- Penyimpanan permanen menggunakan SQLite

#### 5.1 — Playlist Architecture & Database

- Menambahkan SQLite melalui `sqflite`
- Menyiapkan database lokal khusus playlist
- Tabel `playlists` untuk identitas dan timestamp playlist
- Tabel `playlist_songs` untuk relasi playlist, snapshot metadata lagu, dan urutan pemutaran
- Foreign key cascade agar detail lagu ikut terhapus saat playlist dihapus
- Indeks untuk pencarian dan pengurutan lagu dalam playlist

**Status: Fondasi database diimplementasikan — menunggu `flutter pub get`, analisis, dan pengujian lokal**

#### 5.2 — Create, Rename & Delete Playlist

- Repository CRUD playlist dengan SQLite
- Membuat playlist dengan nama wajib dan batas 50 karakter
- Mencegah nama playlist duplikat tanpa membedakan huruf besar/kecil
- Rename playlist dan memperbarui `updated_at`
- Menghapus playlist; detail lagu akan mengikuti foreign key cascade
- Menampilkan daftar playlist beserta jumlah lagu
- UI tab Playlists dengan dialog create/rename dan konfirmasi delete
- Unit test controller menggunakan repository fake

**Status: Implementasi tersedia di GitHub — menunggu analisis dan pengujian lokal**

#### 5.3 — Add & Remove Songs

- Menambahkan operasi repository untuk mengambil lagu playlist berdasarkan urutan posisi
- Menambahkan lagu ke playlist dengan snapshot metadata lokal
- Mencegah lagu yang sama ditambahkan dua kali ke playlist yang sama berdasarkan content URI
- Menempatkan lagu baru pada posisi terakhir playlist
- Menghapus lagu dari playlist dan memperbarui timestamp playlist
- Menambahkan aksi controller untuk add/remove lagu serta penanganan error duplikat
- Menambahkan tombol Add to playlist pada setiap lagu di Music Library
- Menampilkan pemilih playlist melalui bottom sheet
- Menambahkan unit test controller untuk proses penambahan lagu dan validasi duplikat

**Status: Implementasi tersedia di GitHub — menunggu analisis dan pengujian lokal. UI penghapusan lagu akan diselesaikan bersama tampilan detail playlist pada Stage 5.4.**

#### 5.4 — Playlist Detail & Song List

- Menambahkan halaman detail playlist dengan navigasi dari daftar playlist
- Menampilkan nama playlist dan jumlah lagu
- Memuat daftar lagu dari SQLite sesuai urutan posisi
- Menampilkan empty state dan opsi refresh
- Menyediakan menu Remove from playlist pada setiap lagu
- Menambahkan konfirmasi sebelum lagu dihapus
- Memperbarui daftar lagu dan jumlah lagu setelah penghapusan
- Menambahkan unit test controller untuk load playlist songs dan remove song

**Status: Implementasi tersedia di GitHub — menunggu analisis dan pengujian lokal**

#### 5.5 — Playlist Playback & Queue

- Menambahkan validasi playlist kosong dan indeks lagu sebelum audio source dimuat
- Menyelaraskan queue audio_service dengan urutan lagu playlist setelah audio source berhasil dimuat
- Menambahkan `PlayerController.playPlaylist()` agar pemutaran playlist dan lagu terpilih memakai satu `DnAudioHandler`
- Mempertahankan `playSong()` sebagai jalur pemutaran lagu yang meneruskan daftar antrean terkait
- Menambahkan tombol Play all pada halaman detail playlist
- Menambahkan aksi tap pada setiap lagu untuk memulai pemutaran dari lagu yang dipilih
- Next/Previous mengikuti sequence playlist yang dimuat oleh just_audio

**Status: Implementasi tersedia di GitHub — menunggu analisis dan pengujian lokal**

#### 5.6 — Persistence, Validation & Testing

- Memperbaiki propagasi error saat memuat lagu playlist agar kegagalan database tidak dianggap sebagai playlist kosong
- Menambahkan unit test untuk memastikan error pemuatan lagu diteruskan ke halaman pemanggil dan pesan error controller tetap tersedia
- Melanjutkan pengujian persistensi SQLite, validasi CRUD, dan konsistensi queue pada perangkat

**Status: Implementasi penyempurnaan tersedia di GitHub — pengujian lokal dan verifikasi persistensi masih menunggu**

## 7. Stage 6 — Album Art & Metadata

### 6.1 — Shared Artwork Resolution & Presentation

- Memusatkan pemanggilan native artwork resolver dalam `ArtworkService`
- Menggunakan cache Future per lagu agar beberapa tampilan tidak meminta artwork yang sama berulang kali
- Menyediakan `SongArtwork` sebagai komponen visual bersama dengan fallback DN Audio
- Menggunakan artwork yang sama pada Library, Playlist, mini player, dan Now Playing
- Mempertahankan resolver Android MediaStore dan embedded artwork yang sudah ada

- Pengujian perangkat oleh pengguna: seluruh checklist A–F dinyatakan lolos
- Perbaikan tambahan: keyboard pencarian ditutup saat lagu dipilih dari hasil pencarian

**Status: Selesai — pengguna mengonfirmasi pengujian perangkat A–F dan perbaikan keyboard bersih**

### 6.2 — Metadata & Album/Artist Browsing

#### 6.2.1 — Metadata Identity & Collection Grouping

- Menambahkan `albumId` dan `artistId` dari Android MediaStore ke model `Song`
- Menjadikan ID MediaStore sebagai identitas utama album dan artis
- Menyediakan fallback grouping berdasarkan nama album + artis dan nama artis yang dinormalisasi
- Menurunkan koleksi album dan artis dari daftar lagu yang sudah dimuat
- Menambahkan unit test untuk parsing ID dan pengelompokan koleksi

**Status: Implementasi tersedia di GitHub — menunggu format, analisis, dan pengujian lokal**

#### 6.2.2 — Album & Artist Browsing UI

- Menambahkan navigasi Songs, Albums, dan Artists di dalam Library
- Menampilkan daftar album dalam grid dua kolom dengan artwork, nama album, artis, dan jumlah lagu
- Menampilkan daftar artis dalam list dengan artwork representatif, nama artis, jumlah album, dan jumlah lagu
- Menyediakan pencarian yang mengikuti tab aktif untuk lagu, album, maupun artis
- Menyediakan empty state untuk koleksi kosong dan hasil pencarian yang tidak ditemukan
- Memakai kembali SongArtwork dan koleksi turunan dari LibraryController tanpa scan MediaStore tambahan
- Navigasi ke halaman detail album/artis ditangani pada Stage 6.2.3

**Status: Implementasi tersedia di GitHub — menunggu format, analisis, dan pengujian lokal**

#### 6.2.3 — Album & Artist Detail

- Menambahkan halaman detail album dengan artwork besar, metadata, jumlah lagu, dan daftar lagu
- Menambahkan halaman detail artis dengan artwork representatif, jumlah album/lagu, daftar album, dan seluruh lagu artis
- Menambahkan navigasi dari kartu album dan baris artis ke halaman detail
- Menambahkan navigasi dari album di halaman artis ke detail album
- Menambahkan Play all pada detail album dan artis
- Pemilihan lagu memulai playback dari indeks terpilih dan mempertahankan urutan koleksi melalui `PlayerController.playPlaylist()`
- Menggunakan kembali SongArtwork, tema DN Audio, dan PlayerMiniBar
- Menyediakan empty state untuk koleksi yang tidak memiliki lagu

**Status: Selesai — pengguna mengonfirmasi seluruh checklist A–E bersih pada pengujian perangkat**


## 8. Stage 7 — Equalizer & Audio Effects

- Equalizer 5-band atau mengikuti kemampuan perangkat
- Preset audio
- Bass enhancement
- Virtualizer / spatial effect jika tersedia
- Persistensi pengaturan audio
- Penanganan perangkat yang tidak mendukung efek tertentu

### 7.1 — Audio Effects Architecture & Capability Discovery

- Menggunakan Android Audio Session ID dari instance `just_audio` yang sudah menjadi playback engine utama
- Mengikat efek native Android ke session ID aktif dan memperbaruinya jika session berubah
- Menyediakan MethodChannel khusus audio effects, terpisah dari channel audio library
- Mendeteksi ketersediaan Equalizer, BassBoost, dan Virtualizer serta membaca jumlah band dan rentang level dari perangkat
- Menyediakan kontrak service Flutter yang tidak bergantung pada UI
- Melepaskan instance efek lama dengan aman saat session berubah atau service ditutup
- Menangani perangkat/API yang tidak mendukung efek tanpa mengganggu playback

#### 7.1.1 — Native Audio Effects Manager

- Menambahkan `AudioEffectsManager` native Android untuk mengelola instance Equalizer, BassBoost, dan Virtualizer secara independen
- Menambahkan MethodChannel khusus `dn_audio/audio_effects`
- Menyediakan operasi `attachSession`, `getCapabilities`, dan `release`
- Mengembalikan kemampuan dasar Equalizer dari perangkat, termasuk jumlah band, rentang level, dan rentang frekuensi
- Menangani kegagalan inisialisasi tiap efek secara terpisah agar efek lain tetap dapat digunakan
- Melepaskan instance efek dengan aman jika gagal diinisialisasi atau saat manager dilepas

**Status: Implementasi tersedia di GitHub — menunggu build Android, analisis, dan pengujian lokal**

#### 7.1.2 — Session Binding & Lifecycle

- Menambahkan `AudioEffectsService` sebagai pemilik kontrak MethodChannel `dn_audio/audio_effects` di sisi Flutter
- Menghubungkan `AudioPlayer.androidAudioSessionIdStream` dari `DnAudioHandler` yang sudah ada tanpa membuat player atau audio pipeline baru
- Menserialisasi event session agar event duplikat atau perubahan cepat tidak menyebabkan attach native berjalan bersamaan
- Melakukan attach saat session ID valid, release saat session menjadi null, dan release saat handler ditutup
- Menangani kegagalan MethodChannel sebagai kegagalan fitur opsional tanpa mengubah status playback
- Menambahkan unit test untuk deduplikasi session, pergantian session, release pada session null, dan disposal

**Status: Implementasi tersedia di GitHub — menunggu format, analisis, pengujian, dan build Android lokal**

#### 7.1.3 — Capability Detection & Error Handling

- Menambahkan model bertipe `AudioEffectsCapabilities`, `AudioEffectCapability`, dan `AudioEffectBandCapability` untuk membaca respons native secara aman
- Mengambil jumlah band, frekuensi tengah, rentang frekuensi, rentang level, dan jumlah preset sesuai data perangkat
- Menyediakan snapshot kemampuan terbaru dan stream perubahan capability melalui `AudioEffectsService`
- Menambahkan pemanggilan `getCapabilities` serta fallback unavailable ketika channel tidak tersedia atau terjadi platform error
- Menambahkan alasan kegagalan per efek pada native manager agar Equalizer, BassBoost, dan Virtualizer tetap dapat dilaporkan secara independen
- Menambahkan unit test parsing metadata band, dukungan efek opsional, publikasi capability, dan kegagalan channel

**Status: Selesai — pengguna mengonfirmasi 7.1.1, 7.1.2, dan 7.1.3 clean**

### 7.2 — Equalizer Engine & Controls

- Membuat dan mengelola band equalizer berdasarkan kemampuan perangkat
- Mengatur level tiap band dan master enable/disable
- Menambahkan operasi native untuk mengaktifkan/menonaktifkan Equalizer
- Mengatur level band berdasarkan indeks dan rentang millibel yang dilaporkan perangkat
- Mengembalikan capability terbaru setelah perubahan agar state Flutter tetap sinkron
- Menolak indeks band dan level di luar rentang sebelum perubahan diterapkan
- Menambahkan API service Flutter dan unit test untuk command, sinkronisasi capability, dan validasi rentang
- Menambahkan akses Equalizer dari header Now Playing
- Menambahkan halaman bottom sheet Equalizer dengan sakelar ON/OFF
- Menampilkan slider sesuai band dan rentang level perangkat
- Menampilkan level dB aktual, refresh capability, reset flat, dan state unsupported
- Menggunakan AudioEffectsService yang dimiliki DnAudioHandler tanpa membuat audio pipeline baru

**Status: Implementasi UI dan engine tersedia di GitHub — menunggu format, analisis, pengujian, dan build Android lokal**

### 7.3 — Preset Audio

- Menambahkan preset Flat, Bass, Vocal, Treble, dan Rock sebagai kurva bawaan DN Audio
- Memetakan kurva lima titik frekuensi ke band aktual perangkat menggunakan interpolasi logaritmik
- Membatasi gain sesuai rentang millibel yang dilaporkan perangkat
- Menambahkan pemilih preset pada halaman Equalizer
- Menggunakan perintah band yang sama pada AudioEffectsService dan session native aktif
- Menambahkan unit test untuk pemetaan Flat, kurva preset, pembatasan rentang, dan ID preset tidak dikenal

**Status: Selesai — pengguna mengonfirmasi pengujian lokal clean**

### 7.4 — Bass Enhancement & Virtualizer

- Menambahkan operasi native untuk mengaktifkan/menonaktifkan BassBoost dan Virtualizer secara independen
- Menambahkan pengaturan intensitas menggunakan rentang standar Android 0–1000 dan membaca `strengthSupported` dari perangkat
- Melaporkan status aktif dan kekuatan aktual kedua efek melalui capability snapshot
- Menambahkan validasi sesi, dukungan efek, kemampuan strength, dan rentang sebelum perintah diterapkan
- Menambahkan API service Flutter dan unit test untuk command, sinkronisasi capability, serta validasi
- Menambahkan kontrol toggle dan slider intensitas pada halaman Equalizer; slider hanya aktif jika perangkat mendukung strength control
- Mempertahankan satu `AudioEffectsService`, satu audio session, dan satu `AudioPlayer` milik `DnAudioHandler`

**Status: Implementasi tersedia di GitHub — menunggu format, analisis, pengujian, dan build Android lokal**

### 7.5 — Persistence, UI & Device Stabilization

- Menyediakan repository SQLite lokal terpisah untuk preferensi efek audio
- Menyimpan status Equalizer, preset, level band, BassBoost, dan Virtualizer
- Menambahkan EqualizerController sebagai pengelola preferensi dan pemulihan efek saat session baru aktif
- Menghubungkan tab Equalizer Home ke halaman Equalizer lengkap
- Mempertahankan akses Equalizer dari Playing Now melalui bottom sheet
- Menjaga kedua entry point menggunakan DnAudioHandler dan AudioEffectsService yang sama
- Menguji efek saat lagu berganti, queue berubah, aplikasi background, dan session audio diperbarui
- Memastikan playback tetap berjalan ketika efek tidak tersedia atau gagal diinisialisasi

**Status: Selesai — pengguna mengonfirmasi pengujian lokal clean**

## 9. Stage 8 — Sleep Timer

- Pengaturan durasi
- Countdown
- Otomatis menghentikan musik
- Timer dikelola oleh audio handler agar tidak bergantung pada lifecycle halaman UI

### 8.1 — Sleep Timer Architecture

- Menambahkan `SleepTimerService` dengan countdown berbasis `Stopwatch` monotonic
- Menyediakan start, cancel, remaining time, dan stream pembaruan countdown
- Memastikan timer pengganti membatalkan timer sebelumnya dan expiry hanya dipicu satu kali
- Mengikat service ke `DnAudioHandler` yang sama dengan playback engine utama
- Menjeda playback saat timer berakhir tanpa menghapus queue atau membuat instance `AudioPlayer` baru
- Membatalkan timer saat audio handler dihentikan dan melepaskan resource saat dispose
- Menambahkan unit test untuk start, cancel, replacement, expiry, validasi durasi, dan disposal

**Status: Implementasi tersedia di GitHub — menunggu analisis, pengujian lokal, dan verifikasi perangkat**

### 8.2 — Timer UI & Controls

- Menambahkan `SleepTimerController` sebagai state presenter bersama untuk entry point Home dan Now Playing
- Mendaftarkan controller secara permanent pada binding Home agar countdown tetap terpantau lintas tab dan bottom sheet
- Menambahkan bottom sheet Sleep Timer dengan pilihan cepat 15, 30, 45, 60, 90, dan 120 menit
- Menambahkan custom duration melalui pilihan jam dan menit
- Menampilkan status timer aktif, countdown tersisa, dan informasi ketika timer selesai
- Menambahkan aksi Cancel Timer dan mengganti timer aktif ketika durasi baru dipilih
- Menambahkan akses Sleep Timer dari header Home dan Now Playing dengan indikator visual saat timer aktif
- Memakai `SleepTimerService` milik `DnAudioHandler` yang sama; tidak membuat timer atau audio engine kedua
- Menambahkan unit test untuk format countdown menit/detik, jam/menit/detik, dan nilai nol

**Status: Fitur utama berjalan — perbaikan SafeArea tersedia di GitHub dan menunggu verifikasi lokal**

### 8.3 — Playback Integration (Stop Playback)

- Menetapkan satu perilaku saat timer berakhir: langsung menghentikan playback dengan pause
- Tidak menyediakan Fade Out atau transisi volume bertahap
- Menghubungkan callback expiry `SleepTimerService` ke `DnAudioHandler` yang mengendalikan satu `AudioPlayer` utama
- Memastikan expiry tidak menghapus queue atau membuat audio player baru
- Menangani kegagalan pause dengan logging agar tidak memutus lifecycle audio service
- Memastikan perilaku timer saat aplikasi berada di background melalui audio service

**Status: Integrasi playback sudah tersedia — menunggu verifikasi background dan pengujian lokal Stage 8.3**

### 8.4 — Stabilization & Testing

- Menambahkan unit test untuk publikasi countdown dan event zero saat expiry
- Menambahkan unit test disposal ketika timer masih aktif agar callback expiry tidak terpanggil setelah service ditutup
- Menambahkan unit test pembatalan timer aktif dan publikasi nilai null
- Pengujian timer saat lagu berganti dan queue berubah pada perangkat
- Pengujian background, pembatalan, dan lifecycle audio service pada perangkat
- Validasi akurasi countdown dan expiry pada perangkat

**Status: Selesai — pengguna mengonfirmasi pengujian clean**

## 10. Stage 9 — Product Completion, Settings & Release

### 9.0 — Release Readiness & Functional Audit

Temuan audit repository:
- Home memiliki struktur tampilan, tetapi belum berfungsi sebagai dashboard interaktif.
- Search field Home masih berupa dekorasi dan belum membuka pencarian Library.
- Shortcut Songs, Albums, Artists, dan Folders belum memiliki aksi.
- Section Recently Played masih berupa placeholder; belum ada listening-history persistence yang dapat menjadi sumber data.
- Label "See all" belum memiliki aksi.
- Home belum menyediakan akses ke Settings.
- Library scan mengambil semua audio dari MediaStore; belum ada preferensi format/extension yang dapat dipilih pengguna.
- Android MediaStore query berada di `MainActivity.kt`, sedangkan pemanggilan scan Flutter berada di `AudioLibraryService` dan `LibraryController`.
- Belum ditemukan modul Settings atau penyimpanan preferensi aplikasi umum pada struktur `lib/modules` saat audit ini.

Keputusan implementasi:
- Pertahankan Flutter + GetX MVC dan struktur feature module.
- Format filter harus diterapkan pada query MediaStore/native scan, bukan hanya menyembunyikan item di UI.
- Preferensi format disimpan lokal dan diterapkan setiap kali scan/refresh dilakukan.
- Jangan menampilkan Recently Played seolah-olah berfungsi sebelum sumber riwayat pemutaran tersedia. Bangun listening history secara eksplisit atau gunakan konten Home berbasis data yang sudah tersedia.
- Folder browsing tidak boleh ditampilkan sebagai fitur aktif sebelum implementasinya tersedia.

**Status: Audit repository selesai — siap masuk implementasi Home**

### 9.1 — Home Functional Completion

- Menghubungkan search entry point Home ke pencarian Library.
- Menghubungkan shortcut Songs, Albums, dan Artists ke section Library yang sesuai.
- Menghapus atau menonaktifkan shortcut Folders sampai folder browsing benar-benar tersedia.
- Menghubungkan "See all" ke halaman/section terkait atau menghapus affordance yang belum memiliki aksi.
- Mengganti placeholder Recently Played dengan data riwayat pemutaran yang nyata, atau mengubah hierarki Home menjadi library-first sampai listening history selesai.
- Menyediakan akses Settings dari header Home.
- Menambahkan unit/widget tests untuk aksi Home dan navigasi.

- Menginisialisasi pemuatan Library ketika HomeController dibuat agar Home siap menggunakan data koleksi aktual.
- Menghubungkan pencarian Home ke hasil pencarian Songs di Library melalui submit keyboard atau tombol search.
- Menghubungkan shortcut Songs, Albums, dan Artists ke section Library yang sesuai.
- Mengganti placeholder Recently Played yang belum memiliki sumber history dengan Now Playing yang hanya muncul saat ada lagu aktif.
- Menghapus shortcut Folders karena folder browsing belum tersedia.
- Menghapus affordance See all yang belum memiliki aksi.

**Status: Implementasi tersedia di GitHub — menunggu format, analisis, dan pengujian lokal**

### 9.2 — Settings Foundation & Audio Library Preferences

- Membuat modul Settings mengikuti pola GetX MVC.
- Membuat halaman Settings dengan kelompok Audio Library, Playback, Audio Experience, Storage & Maintenance, dan About.
- Menambahkan pilihan format audio yang dapat diaktifkan/nonaktifkan pengguna.
- Menyediakan default format yang umum: MP3, FLAC, WAV, M4A, AAC, OGG, dan OPUS; daftar dapat diperluas berdasarkan dukungan MediaStore.
- Menyimpan preferensi secara persisten di perangkat.
- Menerapkan filter format pada query Android MediaStore.
- Menerapkan ulang preferensi ketika scan ulang atau aplikasi dibuka.
- Menambahkan unit test untuk model/repository preferensi dan pemetaan filter.

**Status: Direncanakan**

### 9.3 — Playback & Audio Experience Settings

- Menentukan dan mengimplementasikan opsi playback yang benar-benar didukung engine.
- Menyediakan pengaturan preferensi audio yang terhubung ke EqualizerController/AudioEffectsService.
- Tidak menampilkan toggle untuk perilaku yang belum memiliki implementasi nyata.
- Menambahkan pengujian persistensi dan penerapan preferensi.

**Status: Direncanakan**

### 9.4 — Storage & Maintenance

- Menampilkan ringkasan jumlah lagu Library.
- Menyediakan scan ulang Library.
- Menampilkan ukuran cache artwork jika dapat dihitung secara andal.
- Menyediakan clear artwork cache melalui ArtworkService/native cache path.
- Menambahkan konfirmasi untuk tindakan yang menghapus data cache.
- Menambahkan pengujian untuk operasi maintenance.

**Status: Direncanakan**

### 9.5 — About DN Audio

- Menampilkan nama dan identitas DN Audio.
- Menampilkan versi aplikasi dan build number dari package metadata.
- Menampilkan Digital Native Dev sebagai developer.
- Menyediakan deskripsi aplikasi dan lisensi open-source.
- Menyediakan Privacy Policy ketika URL resminya sudah ditetapkan.

**Status: Direncanakan**

### 9.6 — Final UI/UX Polish

- Menerapkan arah Premium Editorial dengan aksen Monochrome sesuai `docs/DESIGN_DIRECTION.md`.
- Memoles Home, Library, Settings, Playlist, Now Playing, Equalizer, dan Sleep Timer.
- Menjaga seluruh fungsi, playback, queue, background audio, dan playlist tetap utuh.
- Menyelesaikan accessibility, safe-area, text scaling, dan responsive checks.

**Status: Direncanakan**

### 9.7 — Performance, Regression & Release Preparation

- Audit performa scan, artwork cache, memory, dan battery usage.
- Regression test seluruh fitur utama.
- Verifikasi audio focus, headset/Bluetooth, lock screen, dan interupsi audio.
- Menyiapkan app icon, splash screen, versioning, signing, release build, privacy policy, dan Google Play Store checklist.

**Status: Direncanakan**

---

## Posisi Pengembangan Saat Ini

# Stage 9.1 — Home Functional Completion

Stage 9.0 audit selesai. Implementasi awal Stage 9.1 tersedia di GitHub: Home memuat Library saat dibuka, pencarian diarahkan ke Library, shortcut Songs/Albums/Artists berfungsi, dan placeholder Recently Played diganti dengan Now Playing yang hanya muncul ketika ada lagu aktif. Pengujian lokal masih menunggu.



---

## Aturan Penyelesaian Tahap

- Status tahap hanya diubah menjadi **Selesai** setelah implementasi dan pengujian lokal dinyatakan berhasil.
- Implementasi di GitHub tidak otomatis berarti tahap sudah terverifikasi di perangkat.
- Setiap tahap dikerjakan bertahap agar perubahan mudah diuji dan masalah mudah ditelusuri.
- Pengembangan utama dilakukan pada branch `main`.
