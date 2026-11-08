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
| **Tahap 4** | Penyelarasan Halaman Detail Produk | ⏳ Siap Dikerjakan | - | Function Preview Box, Brosur PDF, & Inverted Pill Action |
| **Tahap 5** | Halaman Custom Order RFQ | ⏳ Mendatang | - | Engineering Helpdesk WA, Dynamic Specs, & Auto-Ticket |

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

### Tahap 2: Standardisasi Kode Model & Fungsi Mesin
- **File Dimodifikasi**:
  1. `lib/core/models/product_model.dart`
  2. `lib/core/constants/mock_data.dart`
- **Poin Perubahan**:
  - Menambahkan field `modelCode` dan `function` di `ProductModel` beserta getter helper `modelCodeDisplay` dan `functionPreview`.
  - Menyelaraskan seluruh 10 produk mesin mock data dengan kode pabrik resmi website:
    - Roaster: `MDI-RS01`, `MDI-RS04`, `MDI-RS50`, `MDI-RS80`
    - Pasca-Panen Kopi: `MDI-PL200`, `MDI-HL150`, `MDI-ESP03`
    - Pengolahan Kakao: `MDI-FM500`, `MDI-DR1000`, `MDI-GR30`
- **Commit**: `[fitur/ui-monokrom ab02853] feat: standardisasi model dan fungsi mesin web`

---

## 4. Rencana Kerja Tahap Berikutnya

### Tahap 3: Redesain Halaman Home (`lib/screens/user/home/home_screen.dart`)
1. **Industrial Hero Showcase Banner**:
   - Background gradien Zinc pekat (`#09090B` ke `#000000`).
   - Slogan resmi: *"WE BUILD THE FUTURE OF MACHINERY"*.
   - 2 tombol aksi kapsul: *"Jelajahi Produk"* & *"Konsultasi RFQ"*.
2. **Series Navigation Tabs**:
   - Filter seri kapsul monokrom (*Semua Lini*, *MD-Coffee Series*, *MD-Cocoa Series*).
3. **Industrial Machine Card**:
   - Kartu produk rasio proporsional dengan badge kode model (`MDI-RS50`, dll) dan teks ringkasan fungsi mesin.
