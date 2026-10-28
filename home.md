# Dokumentasi Perubahan, Penyederhanaan & Perapihan (MANUFAKTUR-MOBILE)

Dokumen ini mencatat seluruh riwayat perbaikan, refactoring, penyederhanaan antarmuka (*UI/UX*), kurasi dataset mesin pabrik, eliminasi redundansi data, kepatuhan model bisnis (*100% Pre-Order*), perbaikan overflow layar, dan dukungan penuh Dark Mode pada aplikasi **PT Manufactur Dynamic Indonesia** (B2B Coffee & Cocoa Machinery Mobile Application).

---

## 1. Latar Belakang & Masalah Awal

Sebelum dilakukan perbaikan, terdapat beberapa kendala utama:
1. **Kendala Sistemik (Fatal Dependency Error)**:
   - Pada file `pubspec.yaml`, versi SDK terkunci pada `sdk: ^3.13.3`, sedangkan komputer pengembang terpasang Dart SDK `3.13.1` (Flutter 3.47.1).
   - Solusi: Menyesuaikan SDK constraint menjadi `sdk: '>=3.13.0 <4.0.0'` dan memperbarui deprecation `withOpacity` ke `withValues(alpha: ...)`, serta `RadioListTile` ke `RadioGroup`.
2. **Kendala Desain & UX Halaman Home (*Overly Complex & Cluttered*)**:
   - File `home_screen.dart` membengkak hingga **1.556 baris kode**.
   - Terdapat filter yang bertumpuk dan berulang di 6 lokasi berbeda.
   - Kartu produk (*Product Card*) di dalam grid memuat terlalu banyak detail teknis yang menyumbat layar.
3. **Kendala Redundansi Data & Visual Terlalu Ramai pada Halaman Detail**:
   - Spesifikasi teknis (Daya, Kapasitas, Tegangan, Bobot) sempat dicetak berulang kali dalam bentuk kartu quick-stats dan tabel di bawahnya.
   - Pilihan model varian dan dokumen memakan tab-bar kompleks yang menyembunyikan informasi penting.
   - Foto produk tertutup gradien dan badge bertumpuk.
4. **Penyimpangan Model Bisnis Pabrik (Ready Stock vs Pre-Order)**:
   - Sempat ada produk bertuliskan *Ready Stock*. Padahal aturan pabrik PT MDI adalah **seluruh mesin murni Pre-Order (PO / Made-to-Order)** dengan termin DP 50%.
5. **Kendala UI Bug (Mode Gelap & Overflow Layar)**:
   - Dialog Pratinjau PDF tidak mengikuti tema sistem saat mode gelap aktif (latar dialog dan kertas tetap putih terang sehingga menyilaukan mata pengguna).
   - Baris harga produk pada layar detail mengalami *Right Overflowed by 36 Pixels* pada perangkat berlayar standar karena penempatan teks panjang di dalam `Row` yang tidak fleksibel.

---

## 2. Rincian Perubahan yang Diterapkan

### Tahap 1: Menghapus 5 Dropdown Spesifikasi Teknis Horizontal
- **File**: `lib/screens/user/home/home_screen.dart`
- **Aksi**: Menghapus barisan dropdown horizontal: *Daya Listrik, Kapasitas, Komoditas, Nama Mesin,* dan *Urutan*.
- **Tujuan**: Mengurangi kepadatan di area tengah layar sehingga produk mesin langsung terlihat.

---

### Tahap 2: Merampingkan Kategori Atas Menjadi 1 Baris Tunggal
- **File**: `lib/screens/user/home/home_screen.dart`
- **Aksi**: Menghapus baris kedua (Alur Proses: Hulu & Hilir) yang sebelumnya menumpuk di bawah tab komoditas. Memperbarui label menjadi 1 baris bersih.
- **Tujuan**: Mengeliminasi efek filter bertingkat yang membingungkan.

---

### Tahap 3: Membersihkan Area Header Katalog Mesin
- **File**: `lib/screens/user/home/home_screen.dart`
- **Aksi**: Menghapus tombol modal **`Filter`**, shortcut **`Urutan: Populer`**, dan seluruh *active filter tags*.
- **Tujuan**: Menghilangkan tombol filter redundan karena filter kategori di atas sudah cukup.

---

### Tahap 4: Menghapus Ikon Filter di Samping Kolom Pencarian (Top AppBar)
- **File**: `lib/screens/user/user_main_layout.dart`
- **Aksi**: Menghapus tombol aksi `Icons.tune_rounded` di samping kolom pencarian.
- **Tujuan**: Memberikan ruang lebih lega pada *Search Bar* untuk mengetik kata kunci mesin.

---

### Tahap 5: Merapikan & Menyederhanakan Kartu Produk (*Product Card*)
- **File**: `lib/screens/user/home/home_screen.dart`
- **Aksi**: Menghapus badge mikro di atas foto, menghapus tag jenis mesin, dan mengalihkan baris watt ke detail produk. Fokus pada: Foto Bersih, Nama Mesin, Badge Kapasitas, dan Estimasi Harga PO.
- **Tujuan**: Mengurangi beban visual dan membuat katalog produk terlihat elegan dan proporsional (rasio 0.65).

---

### Tahap 6: Perampingan Dataset Menjadi 10 Mesin Representatif
- **File**: `lib/core/constants/mock_data.dart`, `lib/screens/user/home/home_screen.dart`
- **Aksi**: Merampingkan dataset dari 39 mesin menjadi **10 mesin pabrik representatif** dengan rentang harga yang presisi:
  1. **Roaster Kopi (4 Mesin | Rp 4 Juta - Rp 525 Juta)**:
     - `PROD-ROAST-01`: MicroRoast 100g Lab Sample Roaster (Rp 4.000.000)
     - `PROD-ROAST-04`: ProRoast 1 kg / Batch Shop Roaster (Rp 28.000.000)
     - `PROD-ROAST-08`: Artisan Series 5 kg Double Wall Roaster (Rp 98.000.000, varian 3kg, 5kg, 8kg)
     - `PROD-ROAST-16`: GigantRoast 80 kg Full Industrial Plant Roaster (Rp 525.000.000)
  2. **Mesin Hulu-Hilir Kopi (3 Mesin | Rp 9.5 Juta - Rp 68 Juta)**:
     - `PROD-HKP-01`: Mesin Pulper Kopi Basah Single Roll (Rp 9.500.000)
     - `PROD-HKP-05`: Mesin Huller Kopi Kering Standar UMKM (Rp 18.500.000)
     - `PROD-HKP-16`: Mesin Espresso Komersial 3-Group Multi Boiler Barista Pro (Rp 68.000.000)
  3. **Mesin Kakao (3 Mesin | Rp 28 Juta - Rp 78 Juta)**:
     - `PROD-KKO-01`: Mesin Pemecah Buah Kakao & Pemisah Biji / Pod Breaker (Rp 28.000.000)
     - `PROD-KKO-04`: Mesin Sangrai Biji Kakao Rotary Roaster 25kg (Rp 45.000.000)
     - `PROD-KKO-07`: Mesin Penghalus Bubuk Kakao & Pulverizer Disk Mill 200 Mesh (Rp 78.000.000)
  - **Penghitungan Badge Kategori Otomatis**: Menghitung kuantitas langsung dari `appState.products`: `Semua Mesin (10)`, `Roaster Kopi (4)`, `Hulu-Hilir Kopi (3)`, `Mesin Kakao (3)`.

---

### Tahap 7: Halaman Detail Produk Bersih & Minimalis (*Ultra-Clean Design*)
- **File**: `lib/screens/user/catalog/product_detail_screen.dart` & `lib/screens/user/home/home_screen.dart`
- **Aksi pada Halaman Detail**:
  1. Mempertahankan alur **linear alami yang disukai pengguna**:
     - Foto Bersih & Utuh (tanpa gradien/badge menumpuk).
     - Kategori & Status Pre-Order (PO).
     - Nama Mesin (Font Outfit Bold 22px).
     - Harga PO (DP 50%), Garansi 2 Tahun, dan Rating.
     - Varian Kapasitas (ChoiceChips ringkas, hanya jika ada varian).
     - Deskripsi Mesin.
     - Tabel Spesifikasi Teknis Tunggal (tanpa duplikasi quick-stats).
     - Tile Dokumen Manual Book & Video Demo (linear dan rapi).
     - Fixed Bottom Bar (Konsultasi RFQ & Pesan PO).

---

### Tahap 8: Kepatuhan Model Bisnis Murni Pre-Order (PO) & Penyederhanaan Pratinjau Manual Book
- **File**: `lib/core/constants/mock_data.dart`, `lib/screens/user/catalog/product_detail_screen.dart`, `lib/widgets/pdf_preview_dialog.dart`
- **Aksi 1: Kepatuhan 100% Pre-Order (PO)**:
  - Mengeliminasi seluruh kata dan status *Ready Stock* di seluruh proyek.
  - Setiap mesin berstatus `Pre-Order` (14 Hari, 21 Hari, 28 Hari, 45 Hari).
- **Aksi 2: Penyederhanaan Pratinjau Manual Book (`PdfPreviewModal`)**:
  - Menghilangkan struktur ber-bab-bab (*tanpa BAB 1 s.d. BAB 5*).
  - Menampilkan ringkasan spesifikasi mesin aktual (Kapasitas & Daya) dan 5 poin panduan SOP langsung yang padat, ringkas, dan jelas.
  - Disertai stempel validasi garansi resmi 2 tahun Pre-Order PT MDI.

---

### Tahap 9: Perbaikan Bug Mode Gelap Dialog PDF & Resolusi Overflow 36px
- **File**: `lib/widgets/pdf_preview_dialog.dart` & `lib/screens/user/catalog/product_detail_screen.dart`
- **Aksi 1: Dukungan Penuh Dark Mode pada Dialog PDF**:
  - Mengintegrasikan `AppState.isDarkMode` ke dalam `PdfPreviewModal`.
  - Pada Mode Gelap: Background dialog beralih ke `AppColors.darkSurface`, kanvas kertas menjadi gelap elegan (`0xFF0F172A` & `0xFF1E293B`), teks beralih ke warna putih & kontras tinggi, dan divider serta border beradaptasi halus tanpa menyilaukan mata pengguna.
- **Aksi 2: Memperbaiki Right Overflowed by 36 Pixels**:
  - Mengubah baris harga dan termin dari `Row` kaku menjadi **`Wrap` responsif** dengan chip padding rapi `Termin DP 50% • Sistem PO`.
  - Membungkus teks `"Garansi Resmi 2 Tahun PT MDI"` dengan widget **`Flexible`** sehingga aman dan tidak akan pernah mendorong rating bintang melebihi batas layar ponsel pada resolusi apa pun.

---

### Tahap 10: Penyederhanaan Tombol Aksi ("Custom" & "Pesan") dan Perapihan Total Halaman Pemesanan PO (`PoFormScreen`)
- **File**: `lib/screens/user/catalog/product_detail_screen.dart` & `lib/screens/user/order/po_form_screen.dart`
- **Aksi 1: Penyederhanaan Tombol Aksi Bawah `ProductDetailScreen`**:
  - Tombol 1: Dari teks panjang kapital `KONSULTASI RFQ` disederhanakan menjadi ringkas **`Custom`** (OutlinedButton).
  - Tombol 2: Dari `PESAN PO (DP 50%)` disederhanakan menjadi ringkas **`Pesan`** (ElevatedButton dengan Brand Color).
  - Menggunakan rasio 1:1 yang simetris, seimbang, dan modern di seluruh perangkat.
- **Aksi 2: Redesain & Perapihan Bersih Halaman Pemesanan PO (`PoFormScreen`)**:
  - **Dukungan Dark Mode Dinamis**: Menggantikan latar putih kaku dan warna statis dengan tema responsif (`isDark ? AppColors.darkBackground : Color(0xFFF8FAFC)`).
  - **Kartu Ringkasan Mesin Terintegrasi**: Menggabungkan thumbnail gambar mesin, kategori, nama, status lead time PO, harga satuan, dan *Quantity Stepper* (`- / +`) dalam satu kartu yang bersih tanpa visual noise.
  - **Form Pengiriman & Kustomisasi**: Input alamat instalasi pabrik dan catatan kustom laser engraving dengan input field yang nyaman dan berbayang halus.
  - **Pilihan Rekening Transfer DP Interaktif**: Pilihan Bank BCA Corporate (`088-2930-112`) dan Mandiri B2B (`137-0099-221`) a.n. PT Manufactur Dynamic Indonesia, dilengkapi tombol **"Salin"** satu ketukan ke clipboard dengan notifikasi *SnackBar*.
  - **Area Bukti Transfer Fleksibel**: Dropzone interaktif dengan indikator visual terunggah (berwarna hijau ramah saat dokumen dipilih).
  - **Eliminasi Kartu Rincian Pembayaran Redundan**: Menghapus tabel rincian pembayaran bertumpuk yang mengulang nominal subtotal dan DP berulang kali. Edukasi pelunasan termin dipindahkan langsung ke dalam *Sticky Bottom Bar* secara ringkas dan informatif (`Sisa 50% dilunasi pasca uji QC pabrik`).
  - **Sticky Bottom Action Bar & Modal Sukses**: Menampilkan nominal DP 50% yang harus dibayar sekarang, edukasi pelunasan sisa 50%, dan tombol **"Kirim Pesanan (PO)"** di bagian bawah layar yang selalu dapat diakses, diikuti dengan dialog konfirmasi PO sukses.

---

### Tahap 11: Mekanisme Unggah Bukti Transfer Interaktif (Kamera / Galeri / PDF), Dialog Pratinjau Struk, & Redesain Total Halaman Custom Order (RFQ)
- **File**: `lib/core/utils/file_picker_helper.dart`, `lib/screens/user/order/po_form_screen.dart`, `lib/screens/user/order/rfq_custom_order_screen.dart`, & `lib/screens/user/catalog/product_detail_screen.dart`
- **Aksi 1: Mekanisme Unggah Dokumen Interaktif & Modal Pratinjau Struk (`FilePickerHelper`)**:
  - **Modal Bottom Sheet Pemilihan Sumber**:
    - 📸 **Kamera**: Ambil foto langsung struk cetak ATM / bukti setor fisik.
    - 🖼️ **Galeri Foto**: Ambil screenshot m-Banking (BCA Mobile, Livin Mandiri, dsb.).
    - 📄 **Dokumen PDF**: E-receipt resmi atau rekening koran digital.
  - **Status File Terunggah Lengkap**: Menampilkan nama file dokumen, ukuran berkas nyata (cth: `1.4 MB`), ikon representatif, dan status terverifikasi.
  - **Dialog Pratinjau Struk Digital (`showProofPreviewDialog`)**: Pengguna dapat mengetuk **"Lihat Pratinjau Struk"** untuk melihat simulasi resi transfer m-Banking berstempel resmi dengan detail: No. Referensi, waktu transaksi, rekening PT MDI tujuan, dan nominal DP 50%.
  - **Kontrol Fleksibel**: Dilengkapi tombol **"Ganti"** dan **"Hapus"** satu ketukan.
- **Aksi 2: Redesain & Perapihan Bersih Halaman Custom Order (RFQ)**:
  - **Koneksi Cerdas Konteks Mesin**: Menekan tombol **`Custom`** pada halaman detail mesin otomatis meneruskan objek mesin aktif (`baseProduct`) ke `RfqCustomOrderScreen`, menampilkan kartu acuan mesin, prefill nama mesin, dan kapasitas awal.
  - **Dukungan Dark Mode Penuh**: Seluruh tampilan formulir RFQ beradaptasi elegan dengan tema terang/gelap (`AppState.isDarkMode`).
  - **Chips Rekomendasi Fitur Cepat**: Menyediakan tombol chip satu-ketukan untuk menambahkan spesifikasi khusus (cth: *Stainless 316 Food Grade*, *Touchscreen PLC Otomatis*, *Laser Engraving Logo*, *Dual Burner Modulated*, *Data Logger Artisan Sync*).
  - **Lampiran Dokumen Blueprint / CAD Interaktif**: Terhubung dengan *upload source sheet* untuk melampirkan foto sketsa, denah ruang, atau dokumen PDF blueprint.
  - **Sticky Bottom Action Bar & Modal Sukses**: Memuat informasi estimasi respon engineer (1x24 jam kerja) dan tombol **"Kirim Pengajuan Custom"** dengan dialog konfirmasi RFQ resmi.

---

### Tahap 12: Resolusi Total Overflow Dialog Pratinjau Bukti Transfer & Penataan Interaksi Langsung
- **File**: `lib/core/utils/file_picker_helper.dart` & `lib/screens/user/order/po_form_screen.dart`
- **Aksi 1: Resolusi Overflow pada Dialog Pratinjau (`showProofPreviewDialog`)**:
  - **Bottom Overflow Fix**: Membungkus kanvas dialog dengan `SingleChildScrollView` dan membatasi `insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24)`. Dialog kini bebas dari overflow vertikal pada perangkat berlayar kecil.
  - **Right Overflow Fix**: Mengganti baris teks kaku menjadi `Row` berbasis `Expanded(flex: 4)` (label) dan `Expanded(flex: 6)` (nilai teks dengan `maxLines: 2, overflow: TextOverflow.ellipsis`), sehingga teks panjang seperti rekening dan nama file tidak akan pernah terdorong melewati batas kanan layar.
  - **Tampilan Struk Digital Nyata**: Pratinjau kini menampilkan resi transfer m-Banking resmi (Header Bank, Badge Hijau "BERHASIL", Nominal DP 50% tegas, No. Referensi, dan Rekening Tujuan PT MDI).
  - **Tombol Tutup Cepat**: Menambahkan ikon silang (`Icons.close_rounded`) di pojok atas serta tombol tutup di bawah untuk kenyamanan navigasi.
- **Aksi 2: Interaksi Langsung pada Kartu Bukti Transfer (`PoFormScreen`)**:
  - Mengubah baris tombol aksi menjadi **`Wrap`** responsif dengan label ringkas **"Lihat Bukti"** dan **"Hapus"** (menghilangkan potensi overflow tombol di layar sempit).
  - Mengetuk kartu berkas yang sudah terunggah kini **langsung membuka pratinjau bukti transfer**, sedangkan tombol **"Ganti"** digunakan untuk mengubah dokumen.

---

### Tahap 13: Formulir Custom Adaptif Cerdas (Smart Adaptive RFQ) & Integrasi Jalur Cepat WhatsApp Engineer
- **File**: `lib/screens/user/order/rfq_custom_order_screen.dart`
- **Aksi 1: Formulir Custom Adaptif (Memangkas 50% Beban Pengisian)**:
  - **Kondisi 1: Dibuka dari Detail Mesin (`baseProduct != null`)**:
    - Kolom input berulang *Jenis Mesin*, *Target Kapasitas*, dan *Sumber Listrik* **otomatis dihilangkan**.
    - Menampilkan kartu ringkasan mesin acuan yang elegan (Foto, Nama Mesin, Estimasi Harga Dasar, Kapasitas & Daya acuan).
    - Formulir langsung berfokus pada inti: **Permintaan Kustomisasi & Modifikasi** (Textarea + Quick Suggestion Chips: *Stainless 316, Touchscreen PLC, Logo Laser, Custom Warna Cat, Dual Burner Gas, Data Logger Artisan Sync*).
    - Pilihan budget menyesuaikan mesin basis (*Sesuai Estimasi Standar Mesin*, *+ Upgrade 10-25%*, dll.).
  - **Kondisi 2: Dibuka dari Banner Home (`baseProduct == null`)**:
    - Menyediakan form kustom lini pabrik baru secara ringkas dari nol.
- **Aksi 2: Integrasi Akses Cepat WhatsApp Engineer Pabrik**:
  - Menyediakan banner pintas konsultasi WhatsApp resmi di dalam form dan ikon aksi cepat WhatsApp pada AppBar.
  - Membuka halaman kontak resmi [`ContactWhatsappScreen`](file:///C:/laragon/www/MANUFAKTUR-MOBILE/lib/screens/user/info/contact_whatsapp_screen.dart) untuk diskusi desain CAD 3D secara instan.

---

### Tahap 14: Eliminasi Chips Pilihan Fitur Cepat pada Halaman Custom Order (RFQ)
- **File**: `lib/screens/user/order/rfq_custom_order_screen.dart`
- **Aksi**: Menghapus deretan tombol chip *Pilihan Fitur Cepat* di bawah kolom textarea modifikasi.
- **Tujuan**:
  - Menghilangkan beban visual dan membuat kartu permintaan modifikasi lebih lapang, bersih, dan leluasa bagi pengguna untuk mengetikkan kebutuhan kustomisasinya secara alami.
  - Mengurangi tinggi kartu form sehingga pengguna tidak perlu menggulir (*scroll*) terlalu panjang.

---

### Tahap 15: Perampingan Kategori Home Menjadi 3 Tab Bersih Tanpa Angka
- **File**: `lib/screens/user/home/home_screen.dart`, `lib/core/constants/mock_data.dart`
- **Aksi 1: Eliminasi Angka Jumlah pada Tab Kategori**:
  - Menghilangkan label angka dalam kurung (seperti `(10)`, `(4)`, `(3)`) pada deretan tab kategori atas.
  - Label kini tampil sangat bersih dan rapi: **`Semua Mesin`**, **`Mesin Kopi`**, dan **`Mesin Kakao`**.
- **Aksi 2: Merampingkan Menjadi 3 Tab Utama**:
  - Menggabungkan kembali lini kopi ke dalam satu tab terpadu: **`Mesin Kopi`** (mencakup 4 unit Roaster Kopi dan 3 unit Mesin Hulu-Hilir Kopi, total 7 mesin kopi).
  - Menyediakan tab terpisah untuk **`Mesin Kakao`** (3 mesin kakao) dan tab default **`Semua Mesin`** (10 mesin).
- **Aksi 3: Penyelarasan Judul Katalog**:
  - Header dinamis di bawahnya beradaptasi otomatis: *"Katalog Seluruh Mesin"*, *"Katalog Mesin Kopi"*, dan *"Katalog Mesin Kakao"*.

---

### Tahap 16: Dukungan Penuh Dark Mode & Interaktivitas Bottom Sheet Notifikasi Pesanan
- **File**: `lib/widgets/app_notification_sheet.dart`, `lib/providers/app_state.dart`
- **Latar Belakang & Kendala**:
  - Saat mode gelap (Dark Mode) diaktifkan, modal bottom sheet notifikasi tetap berlatar belakang putih terang (`color: Colors.white`) yang menyilaukan mata pengguna dan tidak konsisten dengan tema industrial gelap aplikasi.
  - Teks judul menggunakan warna statis `AppColors.primary` (navy pekat) dan teks rincian pesan tidak adaptif terhadap kontras gelap.
- **Aksi & Solusi yang Diterapkan**:
  1. **Adaptasi Latar Belakang & Border**:
     - Mengaitkan lembar modal secara reaktif dengan `AppState.isDarkMode`.
     - Warna latar dinamis: `isDark ? AppColors.darkSurface (0xFF111827) : Colors.white`.
     - Ditambahkan border pembatas halus atas `Border(top: BorderSide(color: Colors.white12, width: 1))` saat mode gelap aktif.
  2. **Indikator Drag Handle Modern**:
     - Menambahkan *drag handle bar* di bagian atas sheet berukuran 38x4 dp dengan warna adaptif (`Colors.white24` saat gelap, `0xFFCBD5E1` saat terang).
  3. **Tipografi & Kontras Bersih**:
     - Judul lembar mengadopsi `darkTextPrimary` (putih jernih) saat mode gelap.
     - Teks pesan notifikasi menggunakan `darkTextSecondary` (abu-abu terang dengan kontras tinggi).
     - Divider dan waktu notifikasi menggunakan `Colors.white10` & `Colors.white38`.
  4. **Badge Status & Aksi Interaktif**:
     - Ditambahkan badge unread counter cerdas (`$unreadCount Baru`) di sebelah judul lembar notifikasi.
     - Implementasi fungsi `markNotificationAsRead(String id)` pada `AppState` sehingga pengguna dapat menandai pesan sebagai dibaca saat mengklik item notifikasi secara individual, selain tombol massal *"Tandai Dibaca"*.
  5. **Ikon Kontekstual Pesan**:
     - Ikon otomatis menyesuaikan jenis notifikasi: `verified` untuk uji QC, `receipt_long` untuk pelunasan DP/invoice, `shield` untuk login SSO, dan `inventory_2` untuk rilis produk baru.

---

## 3. Ringkasan Antarmuka Pengguna Terkini (Clean Minimalist Architecture)

```text
======================= HOME SCREEN =======================
[ Top AppBar: Logo Brand | Kolom Cari | Theme Toggle | Notif ]

[ 1. Banner Carousel Mesin Unggulan (Auto-scroll 5s) ]
  - Pameran Garansi & Kualitas Mesin Kopi & Kakao
  - Tombol CTA Custom RFQ

[ 2. Tab Kategori Horisontal 3 Utama (Bersih Tanpa Angka) ]
  [ Semua Mesin ] | [ Mesin Kopi ] | [ Mesin Kakao ]

[ 3. Header Katalog Minimalis ]
  - Judul Kategori & Label Jumlah Produk Bersih (cth: "Katalog Mesin Kopi" • "7 Produk")

[ 4. Grid Katalog Produk (2 Kolom, Rasio 0.65) ]
  - Foto Mesin Bersih & Jernih
  - Nama Mesin Tegas (Outfit Bold)
  - Badge Kapasitas Resmi (kg/batch atau kg/jam)
  - Estimasi Harga PO & Tombol Panah Detail

[ 5. Banner Konsultasi Tim Engineer Pabrik ]
  - WhatsApp Langsung ke Teknisi Pabrik

=================== PRODUCT DETAIL SCREEN ===================
[ SliverAppBar: Foto Mesin Jernih + Tombol Kembali + Simpan + Bagikan ]

[ Badan Konten - Alur Linear Alami (Disukai & Bersih) ]
  1. Kategori & Status PO (Teks minimalis: ROASTER KOPI • Pre-Order 14 Hari)
  2. Judul Nama Mesin (Outfit 22px Bold)
  3. Baris Harga & Termin Responsif (Wrap: Rp XX.XXX.XXX + Termin DP 50% • Sistem PO) -> Bebas Overflow!
  4. Garansi Resmi 2 Tahun PT MDI (Flexible) & Rating Pelanggan
  5. Pilihan Model Kapasitas (ChoiceChips minimalis jika ada varian)
  6. Garis Pembatas Halus (Divider)
  7. Deskripsi Mesin (Tipografi nyaman dibaca)
  8. Garis Pembatas Halus (Divider)
  9. Tabel Spesifikasi Teknis Tunggal (Filter atribut kosong/strip)
  10. Garis Pembatas Halus (Divider)
  11. Tile Dokumen Manual Book PDF (Pratinjau & SOP Ringkas)
  12. Tile Video Demo Uji Operasional Mesin

[ Fixed Bottom Bar: Custom (Outlined) -> Ke RFQ | Pesan (Filled) -> Ke PO ]

====================== PO FORM SCREEN ======================
[ AppBar: Formulir Pemesanan (PO) | Tombol Kembali ]

[ 1. Kartu Ringkasan Mesin & Kuantitas Terintegrasi ]
  - Thumbnail Foto Mesin Jernih
  - Kategori Produk & Status Lead Time PO (cth: "ROASTER KOPI • Pre-Order 14 Hari")
  - Nama Mesin & Harga PO Per Unit
  - Divider Halus
  - Stepper Unit Mesin [- 1 +] & Subtotal Dinamis

[ 2. Pengiriman & Kustomisasi ]
  - Alamat Pengiriman & Lokasi Instalasi Pabrik
  - Catatan Custom Laser Engraving Logo (Opsional)

[ 3. Rekening Pembayaran DP 50% ]
  - Pilihan Interaktif: Bank BCA Corporate (088-2930-112)
  - Pilihan Interaktif: Bank Mandiri B2B (137-0099-221)
  - Tombol Aksi Cepat "Salin" (Copy to Clipboard) dengan Feedback SnackBar

[ 4. Bukti Transfer DP 50% Interaktif ]
  - Modal Bottom Sheet: [Kamera] | [Galeri Screenshot m-Banking] | [Dokumen PDF]
  - File Terlampir, Ukuran Berkas, Tombol "Lihat Pratinjau Struk", "Ganti", & "Hapus"

[ Sticky Bottom Bar: Total DP 50% (Saat Pesan) + Catatan Pelunasan QC | Tombol "Kirim Pesanan (PO)" ]
  - Modal Konfirmasi Sukses Penerbitan PO

================== RFQ CUSTOM ORDER SCREEN ==================
[ AppBar: Kustomisasi Mesin (RFQ) | Tombol Kembali | Ikon Chat WA ]

[ 1. Banner Info RFQ Industrial ]
  - Estimasi Kajian Teknis & Surat Penawaran Resmi

[ 2. Kartu Acuan Mesin Dasar (Jika datang dari Detail Produk) ]
  - Foto Mesin, Seri Mesin, Harga Basis, & Spesifikasi Acuan
  - Otomatis menghilangkan input redundan (Jenis Mesin, Kapasitas, & Daya)

[ 3. Rincian Permintaan Modifikasi (Inti Form) ]
  - Textarea Kustomisasi Spesifikasi Khusus yang Leluasa & Bersih (Tanpa Chips Redundan)

[ 4. Estimasi Budget & Target Waktu ]
  - Dropdown Budget Menyesuaikan Mesin Basis
  - Target Tanggal Mesin Siap Pasang

[ 5. Lampiran Dokumen Pendukung / Blueprint (Opsional) ]
  - Modal Bottom Sheet Unggah (Kamera Denah, Galeri Sketsa, atau PDF CAD)

[ 6. Banner Akses Cepat WhatsApp Lead Engineer ]
  - Jalur Cepat Diskusi Desain CAD 3D via WhatsApp Official

[ Sticky Bottom Bar: Info Respon Engineer 1x24 Jam | Tombol "Kirim Form RFQ" ]
  - Modal Konfirmasi Sukses Pengajuan RFQ
```

---

## 4. Hasil Verifikasi Kode & Pengujian

- **Validasi Kepatuhan Model Bisnis**:
  - `Ready Stock`: **0 entri** (100% dieliminasi).
  - `Pre-Order (PO)`: **100% dari 10 mesin industri**.
  - `Rentang Harga`:
    - Roaster Kopi: Rp 4 Juta – Rp 525 Juta (4 mesin)
    - Hulu-Hilir Kopi: Rp 9,5 Juta – Rp 68 Juta (3 mesin)
    - Mesin Kakao: Rp 28 Juta – Rp 78 Juta (3 mesin)
- **Hasil Analisis Statis**:
  ```bash
  flutter analyze
  # Output: Analyzing MANUFAKTUR-MOBILE... No issues found! (ran in 1.7s)
  ```
- **Hasil Pengujian Unit/Widget**:
  ```bash
  flutter test
  # Output: 00:01 +1: All tests passed!
  ```

---
*Dokumentasi ini dibuat untuk referensi laporan Tugas Akhir dan serah terima teknis kepada Klien.*
