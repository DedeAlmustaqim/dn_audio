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

**Status: Belum dimulai**

## 7. Stage 6 — Album Art & Metadata

- Cover album
- Artwork lagu
- Penyempurnaan metadata
- Tampilan album
- Tampilan artis

**Status: Belum dimulai**

## 8. Stage 7 — Equalizer & Audio Effects

- Equalizer
- Preset audio
- Bass enhancement
- Audio effects sesuai dukungan perangkat

**Status: Belum dimulai**

## 9. Stage 8 — Sleep Timer

- Pengaturan durasi
- Countdown
- Otomatis menghentikan musik

**Status: Belum dimulai**

## 10. Stage 9 — Final Polish & Release

- Penyempurnaan UI/UX
- Optimasi performa dan baterai
- Pengujian pada berbagai perangkat
- Bug fixing
- Persiapan rilis Google Play Store

**Status: Belum dimulai**

---

## Posisi Pengembangan Saat Ini

# Stage 4.4.1 — Audio Session & Audio Focus

Implementasi konfigurasi audio session dan penanganan headset yang dilepas sudah tersedia di branch `main`. Pengujian perangkat ditunda karena headset belum tersedia. Stage 4.3 masih memiliki checklist stabilisasi kontrol notifikasi dan metadata yang perlu diverifikasi.

### Urutan pekerjaan berikutnya

1. Lanjutkan implementasi Stage 4.4.2 — Headset & Bluetooth Controls; pengujian fisik dilakukan kemudian.
2. Implementasikan Stage 4.4.3 — Lock Screen Experience.
3. Implementasikan Stage 4.4.4 — Audio Interruption & Stabilization.
4. Saat perangkat headset tersedia, uji audio session, headset, Bluetooth, panggilan, dan interupsi audio.
5. Selesaikan checklist Stage 4.3 yang masih tertunda.
6. Tandai Stage 4 selesai hanya setelah seluruh implementasi dan pengujian terverifikasi.
7. Setelah Stage 4 selesai, masuk ke Stage 5 — Playlist Management.

---

## Aturan Penyelesaian Tahap

- Status tahap hanya diubah menjadi **Selesai** setelah implementasi dan pengujian lokal dinyatakan berhasil.
- Implementasi di GitHub tidak otomatis berarti tahap sudah terverifikasi di perangkat.
- Setiap tahap dikerjakan bertahap agar perubahan mudah diuji dan masalah mudah ditelusuri.
- Pengembangan utama dilakukan pada branch `main`.
