import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/app_state.dart';

class PdfPreviewModal extends StatelessWidget {
  final String title;
  final String subtitle;
  final String pdfType; // 'INVOICE', 'MANUAL_BOOK', 'QUOTATION', 'FAKTUR_PAJAK'
  final Map<String, dynamic>? data;

  const PdfPreviewModal({
    super.key,
    required this.title,
    required this.subtitle,
    required this.pdfType,
    this.data,
  });

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final isDark = appState.isDarkMode;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 680),
        child: Column(
          children: [
            // Modal Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white70,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Document Canvas (A4 Paper Simulation)
            Expanded(
              child: Container(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                padding: const EdgeInsets.all(14),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCardBg : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // PDF Header Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "PT MANUFACTUR DYNAMIC INDONESIA",
                                    style: GoogleFonts.outfit(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : AppColors.primary,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Fabrikasi Mesin Industri Pengolahan Kopi & Kakao",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 9.5,
                                      color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                                    ),
                                  ),
                                  Text(
                                    "Hotline Teknis: +62 812-3456-7890 • www.manufacturdynamic.com",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 8.5,
                                      color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: pdfType == 'MANUAL_BOOK'
                                    ? const Color(0xFFDC2626).withValues(alpha: isDark ? 0.25 : 0.1)
                                    : AppColors.secondary.withValues(alpha: isDark ? 0.25 : 0.15),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: pdfType == 'MANUAL_BOOK'
                                      ? const Color(0xFFDC2626).withValues(alpha: 0.4)
                                      : AppColors.secondary.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                pdfType == 'MANUAL_BOOK' ? "MANUAL SOP" : pdfType,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: pdfType == 'MANUAL_BOOK'
                                      ? const Color(0xFFEF4444)
                                      : AppColors.secondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          height: 22,
                          thickness: 1,
                          color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                        ),

                        if (pdfType == 'INVOICE' || pdfType == 'FAKTUR_PAJAK') ...[
                          _buildInvoiceContent(isDark),
                        ] else if (pdfType == 'MANUAL_BOOK') ...[
                          _buildManualBookContent(isDark),
                        ] else ...[
                          _buildQuotationContent(isDark),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Footer Action Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Mengirim $title ke antrean cetak..."),
                            backgroundColor: AppColors.primary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.print_rounded, size: 16),
                      label: const Text("Cetak"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? Colors.white : AppColors.primary,
                        side: BorderSide(
                          color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Berhasil mengunduh dokumen: $subtitle"),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.download_rounded, size: 16),
                      label: const Text("Unduh PDF"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= INVOICE CONTENT =================
  Widget _buildInvoiceContent(bool isDark) {
    final poNumber = data?['poNumber'] ?? 'PO-2026-089';
    final company = data?['company'] ?? 'PT Kopi Nusantara Jaya';
    final total = data?['total'] ?? 'Rp 290.000.000';
    final dp = data?['dp'] ?? 'Rp 145.000.000';
    final pelunasan = data?['pelunasan'] ?? 'Rp 145.000.000';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "DITERBITKAN UNTUK:",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextSecondary : Colors.grey,
                  ),
                ),
                Text(
                  company,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                Text(
                  "NPWP: 01.234.567.8-012.000",
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextSecondary : Colors.grey,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "NO: INV/$poNumber",
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                Text(
                  "Tanggal: 06 Okt 2026",
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextSecondary : Colors.grey,
                  ),
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 16),
        Table(
          border: TableBorder.all(
            color: isDark ? Colors.white12 : Colors.grey.shade300,
          ),
          columnWidths: const {
            0: FlexColumnWidth(3),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(2),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF131A26) : Colors.grey.shade100,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Item Mesin",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Qty",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Total Harga",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    data?['productName'] ?? "Mesin Fabrikasi PT MDI",
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "1",
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    total,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerRight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Pembayaran DP 50%: $dp (LUNAS)",
                style: const TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              Text(
                "Sisa Pelunasan 50%: $pelunasan",
                style: const TextStyle(
                  color: AppColors.warning,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              Divider(color: isDark ? Colors.white12 : Colors.grey.shade300),
              Text(
                "TOTAL TAGIHAN: $total",
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFF60A5FA) : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131A26) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.verified_user_rounded, color: Colors.green, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Dokumen Pre-Order Sah. Termin pelunasan diselesaikan setelah uji fungsi pabrik.",
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? AppColors.darkTextSecondary : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  // ================= CLEAN, STRAIGHTFORWARD MANUAL BOOK (TANPA BER-BAB-BAB, THEMED) =================
  Widget _buildManualBookContent(bool isDark) {
    final machineName = data?['productName'] ?? subtitle;
    final capacity = data?['capacity'] ?? '-';
    final power = data?['power'] ?? '-';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Machine Spec Header
        Text(
          "PANDUAN OPERASIONAL & PERAWATAN MESIN",
          style: GoogleFonts.outfit(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          machineName,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: isDark ? const Color(0xFF93C5FD) : AppColors.primary,
          ),
        ),

        const SizedBox(height: 12),

        // Parameter Ringkas
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141C28) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Kapasitas Kerja",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5,
                        color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      capacity,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 26,
                color: isDark ? Colors.white12 : const Color(0xFFCBD5E1),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Kebutuhan Daya",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5,
                        color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      power,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Poin Panduan Ringkas (Sederhana, Bersih, Tanpa Bab-bab)
        Text(
          "PANDUAN STANDAR PENGOPERASIAN (SOP):",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.4,
            color: isDark ? Colors.white70 : const Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 8),

        _buildGuidePoint(
          "1. Pemasangan & Listrik",
          "Pastikan grounding terpasang baik dan tegangan listrik stabil sesuai spesifikasi daya sebelum menghidupkan mesin.",
          isDark,
        ),
        _buildGuidePoint(
          "2. Uji Operasional Mesin",
          "Jalankan mesin tanpa beban (dry run) selama 3 menit untuk memeriksa putaran motor dan sensor suhu.",
          isDark,
        ),
        _buildGuidePoint(
          "3. SOP Pengoperasian Harian",
          "Masukkan bahan baku secara bertahap sesuai kapasitas batch agar motor tidak kelebihan beban (overload).",
          isDark,
        ),
        _buildGuidePoint(
          "4. Perawatan & Pelumasan",
          "Bersihkan sisa residu pasca-produksi dan lakukan pelumasan bearing berkala menggunakan grease food-grade.",
          isDark,
        ),
        _buildGuidePoint(
          "5. Tombol Emergency Stop",
          "Gunakan tombol darurat bila terjadi lonjakan arus atau hambatan mekanis mendadak.",
          isDark,
        ),

        const SizedBox(height: 14),

        // Note Garansi & Sertifikasi
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF064E3B).withValues(alpha: 0.35)
                : const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isDark ? const Color(0xFF059669) : const Color(0xFFA7F3D0),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.verified_rounded, color: Color(0xFF059669), size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Dokumen panduan resmi PT MDI. Dilampirkan bersama unit Pre-Order (PO) & Kartu Garansi 2 Tahun.",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF34D399) : const Color(0xFF065F46),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGuidePoint(String title, String desc, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.secondary),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                  height: 1.35,
                ),
                children: [
                  TextSpan(
                    text: "$title: ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  TextSpan(text: desc),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= QUOTATION CONTENT =================
  Widget _buildQuotationContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "SURAT PENAWARAN HARGA (QUOTATION)",
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Spesifikasi Custom Machine:",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        Text(
          "- Custom Dual Boiler Brass Accent\n- Logo Engraving Laser\n- Garansi Pabrik 2 Tahun\n- Sistem Produksi Pre-Order (PO)",
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.darkTextSecondary : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Harga Penawaran: ${data?['price'] ?? 'Rp 115.000.000'}",
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }
}
