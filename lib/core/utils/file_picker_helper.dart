import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum UploadSourceType { camera, gallery, document }

class UploadResult {
  final String fileName;
  final String fileSize;
  final UploadSourceType sourceType;

  const UploadResult({
    required this.fileName,
    required this.fileSize,
    required this.sourceType,
  });
}

class FilePickerHelper {
  // Legacy simulation fallback
  static Future<String?> pickFileName({List<String>? allowedExtensions}) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final ext = (allowedExtensions != null && allowedExtensions.isNotEmpty)
        ? allowedExtensions.first
        : 'jpg';
    return "Bukti_Transfer_BCA_MDI.$ext";
  }

  // Interactive Bottom Sheet to choose upload source: Kamera, Galeri, or Dokumen PDF
  static Future<UploadResult?> showUploadSourceSheet({
    required BuildContext context,
    String title = 'Pilih Sumber Dokumen',
    String subtitle = 'Pilih metode unggah bukti transfer atau dokumen teknis',
    bool isRfq = false,
    bool isDark = false,
    Color brandColor = const Color(0xFFC07F42),
  }) async {
    final bgColor = isDark ? const Color(0xFF111827) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDark ? Colors.white10 : const Color(0xFFE2E8F0);
    final itemBg = isDark ? const Color(0xFF1F2937) : const Color(0xFFF8FAFC);

    return await showModalBottomSheet<UploadResult>(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle Bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title & Subtitle
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  color: subtextColor,
                ),
              ),
              const SizedBox(height: 16),

              // Option 1: Kamera
              _buildOptionTile(
                icon: Icons.camera_alt_rounded,
                iconColor: const Color(0xFF0284C7),
                title: isRfq ? "Kamera (Foto Sketsa / Ruang)" : "Kamera (Foto Struk Fisik)",
                subtitle: isRfq
                    ? "Ambil foto langsung denah atau lokasi instalasi pabrik"
                    : "Foto langsung struk cetak ATM atau bukti setor tunai",
                itemBg: itemBg,
                borderColor: borderColor,
                textColor: textColor,
                subtextColor: subtextColor,
                onTap: () {
                  Navigator.pop(
                    ctx,
                    UploadResult(
                      fileName: isRfq
                          ? "Foto_Sketsa_Workshop_2026.jpg"
                          : "Foto_Struk_ATM_BCA_2026.jpg",
                      fileSize: "2.3 MB",
                      sourceType: UploadSourceType.camera,
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),

              // Option 2: Galeri Foto
              _buildOptionTile(
                icon: Icons.photo_library_rounded,
                iconColor: const Color(0xFF16A34A),
                title: isRfq ? "Galeri Foto (Foto Desain / Mesin)" : "Galeri Foto (Screenshot m-Banking)",
                subtitle: isRfq
                    ? "Pilih gambar referensi model mesin dari galeri"
                    : "Pilih tangkapan layar transaksi BCA Mobile / Mandiri Livin",
                itemBg: itemBg,
                borderColor: borderColor,
                textColor: textColor,
                subtextColor: subtextColor,
                onTap: () {
                  Navigator.pop(
                    ctx,
                    UploadResult(
                      fileName: isRfq
                          ? "Referensi_Custom_Mesin_Varian.png"
                          : "Screenshot_mBanking_BCA_DP50.png",
                      fileSize: "1.4 MB",
                      sourceType: UploadSourceType.gallery,
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),

              // Option 3: Dokumen PDF
              _buildOptionTile(
                icon: Icons.picture_as_pdf_rounded,
                iconColor: const Color(0xFFDC2626),
                title: isRfq ? "Dokumen CAD / Blueprint (PDF)" : "Dokumen / E-Receipt (PDF)",
                subtitle: isRfq
                    ? "Lampirkan file proposal teknis atau spesifikasi CAD pabrik"
                    : "Pilih file mutasi rekening koran atau e-receipt resmi bank",
                itemBg: itemBg,
                borderColor: borderColor,
                textColor: textColor,
                subtextColor: subtextColor,
                onTap: () {
                  Navigator.pop(
                    ctx,
                    UploadResult(
                      fileName: isRfq
                          ? "Blueprint_Layout_Pabrik_PTMDI.pdf"
                          : "Resi_Transfer_B2B_Corporate.pdf",
                      fileSize: "820 KB",
                      sourceType: UploadSourceType.document,
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildOptionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color itemBg,
    required Color borderColor,
    required Color textColor,
    required Color subtextColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: itemBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: subtextColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: subtextColor),
          ],
        ),
      ),
    );
  }

  // Realistic Receipt Preview Dialog (Zero Overflow Guarantee)
  static void showProofPreviewDialog({
    required BuildContext context,
    required String fileName,
    required double amount,
    required String bankAccount,
    bool isDark = false,
    Color brandColor = const Color(0xFFC07F42),
  }) {
    final bgColor = isDark ? const Color(0xFF111827) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDark ? Colors.white10 : const Color(0xFFE2E8F0);
    final cardInnerBg = isDark ? const Color(0xFF1F2937) : const Color(0xFFF8FAFC);

    final isBca = bankAccount.contains('BCA');
    final bankName = isBca ? 'BANK BCA CORPORATE' : 'BANK MANDIRI B2B';
    final targetAccount = isBca ? '088-2930-112' : '137-0099-221';

    String formattedAmount = 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: bgColor,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top Action Row with Close Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 14),
                          const SizedBox(width: 5),
                          Text(
                            "BUKTI TRANSFER TERVERIFIKASI",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF10B981),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, size: 20, color: subtextColor),
                      onPressed: () => Navigator.pop(ctx),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  "Bukti Transfer Pembayaran",
                  style: GoogleFonts.outfit(
                    fontSize: 16.5,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  fileName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: subtextColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),

                // Simulated Receipt Slip
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardInnerBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      // Bank Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              bankName,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: brandColor,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "BERHASIL",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Divider(color: borderColor, height: 1),
                      const SizedBox(height: 10),

                      // Big Amount Display
                      Text(
                        "Nominal Transfer DP 50%",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          color: subtextColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formattedAmount,
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: brandColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Divider(color: borderColor, height: 1),
                      const SizedBox(height: 10),

                      // Safe 2-Column Details (Flex-protected against overflow)
                      _buildReceiptRow("No. Referensi", "TRX-20261028-091823", textColor, subtextColor),
                      _buildReceiptRow("Waktu Transaksi", "28 Okt 2026, 14:35 WIB", textColor, subtextColor),
                      _buildReceiptRow("Penerima", "PT Manufactur Dynamic Indonesia", textColor, subtextColor),
                      _buildReceiptRow("Rekening", targetAccount, textColor, subtextColor),
                      _buildReceiptRow("Keterangan", "Termin DP 50% Pre-Order", textColor, subtextColor),
                      _buildReceiptRow("Berkas", fileName, textColor, subtextColor),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Note
                Text(
                  "Bukti transfer digital ini sah dan diterbitkan untuk sistem antrean produksi PT MDI.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    color: subtextColor,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 14),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "Tutup",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildReceiptRow(String label, String value, Color textColor, Color subtextColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: subtextColor),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
