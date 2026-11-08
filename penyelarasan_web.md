# Dokumentasi Penyelarasan UI Mobile ke Web (MANUFAKTUR-MOBILE)

Dokumen ini mencatat seluruh riwayat penyelarasan antarmuka (*UI/UX*), sistem warna monokrom industrial (*Zinc Monochrome System*), tipografi, kode model mesin pabrik, serta tata letak aplikasi mobile **PT Manufactur Dynamic Indonesia** agar selaras 100% dengan website resmi (`C:\laragon\www\MANUFACTUR-DYNAMIC-INDONESIA`).

---

## 1. Latar Belakang & Spesifikasi Acuan Desain Web

- **Repositori Acuan Website**: `C:\laragon\www\MANUFACTUR-DYNAMIC-INDONESIA`
- **Dokumen Acuan**: `Desaind.md` (Spesifikasi Desain Web Hitam & Putih Monokrom) & `resources/css/public.css`
- **Konsep Desain**: *Monochrome Industrial High Contrast* yang menonjolkan presisi teknis, kesan kokoh, bersih, profesional, dan premium.

### Palet Warna Pokok Acuan (Zinc Monochrome):
- **Pitch Black (`#000000`)**: Kontras tertinggi untuk Hero banner dan elemen visual utama.
- **Zinc 950 (`#09090B`)**: Warna primer untuk heading, tombol aksi utama, dan kartu beraksen pekat.
- **Zinc 800 (`#27272A`)**: Teks sekunder dan garis batas gelap.
- **Zinc 500 (`#71717A`)**: Teks muted / placeholder.
- **Zinc 200 (`#E4E4E7`)**: Garis batas kartu (*hairline border*) presisi.
- **Zinc 100 (`#F4F4F5`) & Zinc 50 (`#FAFAFA`)**: Permukaan chip badge, pill, dan latar belakang bersih.
- **Bentuk Tombol (CTA)**: Kapsul melingkar penuh (*Pill Shape*, border radius `999px`) dengan kontras terbalik (*Inverted CTA*).
- **Tipografi**:
  - Headings: `Plus Jakarta Sans` (Bold 700 & Extra Bold 800) dengan letter spacing rapat (-0.3 s/d -0.8).
  - Body & Spesifikasi: `Inter` untuk keterbacaan tajam dan bersih.

---

## 2. Roadmap Pengerjaan & Riwayat Commit Git

Branch aktif pengerjaan: **`fitur/ui-monokrom`**

| Tahap | Modul / Layar | Status | Commit Hash | Keterangan |
| :---: | :--- | :---: | :---: | :--- |
| **Tahap 1** | Desain Sistem & Palet Warna | ✅ Selesai | `83ff3f2` | `app_colors.dart` & `app_theme.dart` beralih ke Zinc Monokrom & Pill CTA |
| **Tahap 2** | Standardisasi Kode Model & Fungsi Mesin | ✅ Selesai | `ab02853` | `product_model.dart` & `mock_data.dart` diselaraskan dengan database web |
| **Tahap 3.1**| Home: Industrial Hero Showcase Banner | ✅ Selesai | `f80c74f` | Hero banner solid, background `GambarBG.jpg` monokrom web, tombol kapsul |
| **Tahap 3.2**| Home: Series Navigation Tabs & Search Bar | ✅ Selesai | `49074d8` | Tab monokrom pill (Semua Lini, MD-Coffee, MD-Cocoa) & Search bar pill 999px |
| **Tahap 3.3**| Home: Industrial Machine Card & Clean Layout | ✅ Selesai | `49074d8` | Kode model MDI-xxx, badge lini, rasio 0.58, tombol bulat monokrom, hapus banner ganda |
| **Tahap 4** | Penyelarasan Halaman Detail Produk | ✅ Selesai | `44cd378` | Kode model, Kotak Fungsi Mesin, Tabel Spek, Brosur SOP PDF, Video Demo, Pill CTA |
| **Tahap 5** | Halaman Custom Order RFQ & WhatsApp Gateway | ✅ Selesai | `ff11fe0` | Form ringkas 30 detik, Kontak PIC, Auto-Ticket RFQ, Dialog WhatsApp Helpdesk |
| **Tahap 6** | Halaman Kontak WhatsApp Resmi Lead Engineer | ✅ Selesai | `77e23e2` | Satukan kontak jadi 1 kanal resmi Lead Engineer, monokrom industrial, Inverted Zinc Pill |
| **Tahap 7** | Formulir PO Standar & Pratinjau Bukti Transfer | ✅ Selesai | `6b4d31b` | Hapus catatan PO standar, standardisasi identitas PIC, slip pratinjau bukti DP 50% monokrom |

---

## 3. Rincian Perubahan yang Telah Diterapkan

### Tahap 1: Penyelarasan Desain Sistem & Palet Warna Monokrom
- **File Dimodifikasi**:
  1. `lib/core/theme/app_colors.dart`
  2. `lib/core/theme/app_theme.dart`
- **Poin Perubahan**:
  - Mengganti warna dasar dari navy pekat dan merah crimson menjadi sistem Zinc Monokrom resmi web:
    - `primary`: Zinc 950 (`#09090B`)
    - `pitchBlack`: `#000000`
    - `background`: Zinc 50 (`#FAFAFA`)
    - `surfaceVariant` / `zinc100`: Zinc 100 (`#F4F4F5`)
    - `border`: Zinc 200 (`#E4E4E7`)
  - Mengatur `elevatedButtonTheme` dan `outlinedButtonTheme` menjadi bentuk kapsul (*pill shape* `BorderRadius.circular(999)`).
  - Mengatur tipografi judul ke `GoogleFonts.plusJakartaSans` dan bodi ke `GoogleFonts.inter`.
- **Commit**: `[fitur/ui-monokrom 83ff3f2] feat: sesuaikan sistem tema dan warna monokrom web`

---

### Tahap 4: Penyelarasan Halaman Detail Produk & Modal Media
- **File Dimodifikasi**: `lib/screens/user/product/product_detail_screen.dart`
- **Poin Perubahan**:
  - Menampilkan Kode Model resmi (`MDI-RS50`, dll) dan menghapus star rating/review count (sesuai karakteristik mesin B2B).
  - Menghapus badge "SS304 Food Grade" yang berulang pada row garansi.
  - Memperbarui status ketersediaan menjadi "Pre-Order 30 Hari".
  - Menambahkan kartu "FUNGSI MESIN" dengan gaya industrial web.
  - Mengonversi tabel spesifikasi teknis menjadi format monokrom berselang-seling yang rapi.
  - Menyelaraskan modal "Brosur PDF (Manual Book)" dan "Video Demo" menjadi modal profesional tanpa box merah.

---

### Tahap 5: Penyelarasan Formulir Custom Order RFQ & WhatsApp Gateway
- **File Dimodifikasi**:
  1. `lib/screens/user/home/home_screen.dart`
  2. `lib/screens/user/order/rfq_custom_order_screen.dart`
- **Poin Perubahan**:
  - **Home Screen Hero CTA**: Tombol kedua di banner dialihkan menjadi *"Konsultasi Sales"* yang langsung membuka kanal WhatsApp resmi PT MDI (`ContactWhatsappScreen`) untuk tanya-jawab umum pengunjung.
  - **Alur Kustomisasi Terpadu**: Pemesanan kustomisasi teknis (RFQ) difokuskan murni dari Halaman Detail Mesin sehingga selalu memiliki mesin acuan dasar (`baseProduct` required).
  - **Header Banner Monokrom Industrial**: Menggunakan Zinc 950 (`#09090B`) dengan tipografi `Plus Jakarta Sans`.
  - **Kartu Mesin Acuan**: Menampilkan thumbnail, pill category (`MD-COFFEE` / `MD-COCOA`), status `Pre-Order 30 Hari`, Kode Model Resmi (`KODE MODEL: MDI-xxx`), dan harga basis. Bebas issue overflow menggunakan `Wrap`.
  - **Penyederhanaan Form Masukan**: Menghapus opsi file upload sketsa, dropdown budget/waktu, dan input mesin manual agar formulir cepat diisi pembeli (< 30 detik).
  - **Textarea Modifikasi Lapang**: Input spesifikasi khusus berlatar Zinc 100 dengan border Zinc 200 presisi.
  - **Kontak PIC Pengadaan**: Kolom Nama PIC dan Nomor WhatsApp aktif (otomatis terisi dari profil user jika login).
  - **Generator Nomor Tiket RFQ Otomatis**: Menghasilkan tiket antrean resmi (contoh `RFQ-2026-050`) dan mencatatkannya ke `AppState`.
  - **Bottom Action Bar Inverted Zinc Pill**: Tombol kapsul `999px` bertuliskan *"Kirim & Diskusi WA"*.
  - **Modal Tiket Sukses & WhatsApp Gateway**: Dialog sukses berdesain monokrom yang menampilkan badge nomor tiket resmi, ringkasan penugasan tim engineer, dan tombol kapsul Inverted Zinc *"Buka WhatsApp Engineer Sekarang"* yang mengarahkan pembeli langsung ke chat WhatsApp helpdesk PT MDI dengan membawa konteks tiket.

---

### Tahap 6: Penyelarasan Halaman Kontak WhatsApp & Kanal Resmi Lead Engineer
- **File Dimodifikasi**:
  1. `lib/screens/user/info/contact_whatsapp_screen.dart`
  2. `lib/screens/user/order/rfq_custom_order_screen.dart`
- **Poin Perubahan**:
  - **Hapus Warna Hijau Norak & Lingkaran Besar**: Menggantikan lingkaran hijau 50px dan tombol hijau kaku dengan tata letak Industrial Monokrom bersih (*Zinc 950, Zinc 200 hairline border, Zinc 100 surface*).
  - **Header Banner Resmi**: Menggunakan tipografi kokoh *Plus Jakarta Sans* dengan pill badge `"OFFICIAL SUPPORT PT MDI"`.
  - **Dukungan Tiket Kustomisasi Aktif**: Jika dibuka dari dialog RFQ kustomisasi, halaman otomatis menampilkan banner hitam Zinc 950 berisi nomor tiket resmi dan nama unit mesin untuk memudahkan customer menyebutkan nomor tiket saat chat.
  - **Penyatuan Menjadi 1 Kanal Resmi**: Menggabungkan kontak menjadi 1 kartu resmi tunggal: *Lead Engineer & Konsultasi Teknis PT MDI* dengan tombol kapsul Inverted Zinc `999px`.
  - **Kartu Workshop & Pabrik Cikarang**: Info lokasi dan jam operasional pabrik yang rapi dengan tipografi monokrom bersih tanpa teks oranye.
  - **Dialog Tiket Monokrom**: Ikon centang dan tombol *"Buka WhatsApp Engineer Sekarang"* di dialog RFQ diselaraskan menjadi Inverted Zinc Pill monokrom tanpa warna hijau yang bertabrakan.
- **Commit**: `[fitur/ui-monokrom 77e23e2] refactor(contact): satukan kontak whatsapp menjadi satu kanal resmi lead engineer`

---

### Tahap 7: Formulir Pemesanan Standar PO & Pratinjau Bukti Transfer Monokrom
- **File Dimodifikasi**:
  1. `lib/screens/user/order/po_form_screen.dart`
  2. `lib/screens/user/order/rfq_custom_order_screen.dart`
  3. `lib/core/utils/file_picker_helper.dart`
- **Poin Perubahan**:
  - **Standardisasi Identitas Pemesan**: Menyelaraskan form pemesanan dengan field terpadu: Nama Lengkap PIC (auto-prefill profil), Nomor WhatsApp PIC (koordinasi ekspedisi), dan Alamat Lengkap Pengiriman Pabrik / Workshop.
  - **Hapus Catatan PO Standar (Anti-Multitafsir)**: Menghapus kolom catatan tambahan untuk admin dari PO Standar agar pengujian uji kelayakan tegas membedakan transaksi unit standar (katalog) murni dengan formulir RFQ custom order.
  - **Pilihan Rekening Bank Monokrom**: Menghapus warna amber/oranye pada pilihan bank BCA & Mandiri, menggunakan tipografi *Plus Jakarta Sans* bold hitam tegas, dan tombol salin kapsul minimalis.
  - **Upload Bukti Transfer DP 50%**: Kotak unggah berlatar Zinc 100 dengan *hairline border* Zinc 200 dan tombol ganti/lihat bukti monokrom.
  - **Penyelarasan Dialog Pratinjau Bukti Transfer (`file_picker_helper.dart`)**:
    - Mengganti badge hijau *"BUKTI TRANSFER TERVERIFIKASI"* menjadi badge monokrom industrial *"LAMPIRAN BUKTI TRANSFER"*.
    - Mengganti badge hijau *"BERHASIL"* menjadi badge Zinc monokrom *"DRAF DP 50%"* (menghindari kebingungan status sebelum verifikasi admin).
    - Tipografi nominal monokrom pekat (`Plus Jakarta Sans`).
    - Tombol *"Tutup"* diubah menjadi Inverted Zinc Pill `999px`.
  - **Bottom Action Bar Inverted Zinc Pill**: Tombol utama *"Kirim Pesanan (PO)"* kapsul `999px` berlatar Zinc 950 `#09090B`.
  - **Dialog Sukses PO Monokrom**: Ikon centang terverifikasi industrial Zinc 950 dan tombol kapsul Inverted Zinc yang langsung mengarahkan user ke Tab Pesanan.
  - **Tambahan Lokasi Workshop di RFQ Custom**: Menambahkan kolom *"Kota / Lokasi Workshop (Instalasi Mesin)"* pada form kustomisasi RFQ untuk kelengkapan identitas di dashboard admin.
- **Commit**: 
  - `[fitur/ui-monokrom 3963a77] feat(order): selaraskan form po standar dan standardisasi data pic serta lokasi workshop`
  - `[fitur/ui-monokrom 6b4d31b] feat(order): hapus catatan po standar dan selaraskan dialog bukti transfer ke monokrom industrial`

---

## 4. Kesimpulan Status Ruang Lingkup Home (Tab 0)

Seluruh komponen dalam ruang lingkup **Home (Tab 0)** beserta seluruh cabang alur belanja dan konsultasi yang berpangkal dari Home telah **100% tuntas diselaraskan dengan website resmi**:
1. Top Bar, Search Bar Pill, dan Switch Tema Monokrom.
2. Industrial Hero Showcase Banner Grayscale + 2 Action Pills ("Jelajahi Produk" & "Konsultasi Sales").
3. Category Navigation Tabs Monokrom Pill (Semua Lini, MD-Coffee, MD-Cocoa).
4. Section Header & Counter Badge.
5. Grid 2-Kolom Katalog Mesin (Badge Lini, Kode Model Resmi MDI-xxx, Spesifikasi Ringkas, Harga PO).
6. Empty State Monokrom saat filter tidak ditemukan.
7. Detail Mesin (Foto, Kode Model, Fungsi Mesin, Model Kapasitas, Spek Teknis, Deskripsi, Brosur PDF, Video Demo, Bottom Bar Ganda).
8. Formulir RFQ Kustomisasi Mesin & Generator Tiket WhatsApp Resmi.
9. Formulir Pemesanan PO Standar 30 Hari & Dialog Pratinjau Slip DP 50% Monokrom.
10. Kanal Resmi WhatsApp Lead Engineer PT MDI.
