import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            // Modal Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf, color: Colors.white, size: 22),

                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Document Canvas (Simulated A4 Paper View)
            Expanded(
              child: Container(
                color: const Color(0xFFEBEBEB),
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // PDF Header Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "PT MANUFACTUR DYNAMIC INDONESIA",
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  "Kawasan Industri Manufaktur Mesin Pengolahan, Indonesia",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  "Telp: +62 812-3456-7890 • www.manufacturdynamic.com",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                pdfType,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 32, thickness: 1.5),

                        if (pdfType == 'INVOICE' || pdfType == 'FAKTUR_PAJAK') ...[
                          _buildInvoiceContent(),
                        ] else if (pdfType == 'MANUAL_BOOK') ...[
                          _buildManualBookContent(),
                        ] else ...[
                          _buildQuotationContent(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Footer Action Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Mencetak dokumen PDF..."),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                      icon: const Icon(Icons.print, size: 18),
                      label: const Text("Cetak"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Berhasil mengunduh $title (PDF)"),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text("Unduh PDF"),
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

  Widget _buildInvoiceContent() {
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
                const Text("DITERBITKAN UNTUK:",
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)),
                Text(company,
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                const Text("NPWP: 01.234.567.8-012.000",
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("NO: INV/$poNumber",
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold, fontSize: 12)),
                const Text("Tanggal: 06 Okt 2026",
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            )
          ],
        ),
        const SizedBox(height: 20),
        Table(
          border: TableBorder.all(color: Colors.grey.shade300),
          columnWidths: const {
            0: FlexColumnWidth(3),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(2),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey.shade100),
              children: const [
                Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Item Mesin",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 11))),
                Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Qty",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 11))),
                Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Total Harga",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 11))),
              ],
            ),
            TableRow(
              children: [
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(data?['productName'] ?? "Artisan Espresso Craft Pro 2G",
                        style: const TextStyle(fontSize: 11))),
                const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("2", style: TextStyle(fontSize: 11))),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(total, style: const TextStyle(fontSize: 11))),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("Pembayaran DP 50%: $dp (LUNAS)",
                  style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 11)),
              Text("Sisa Pelunasan 50%: $pelunasan",
                  style: const TextStyle(
                      color: AppColors.warning,
                      fontWeight: FontWeight.bold,
                      fontSize: 11)),
              const Divider(),
              Text("TOTAL TAGIHAN: $total",
                  style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: const Row(
            children: [
              Icon(Icons.verified_user, color: Colors.green, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Faktur Pajak Elektronik Sah (Terintegrasi e-Faktur DJP). QR Code Verifikasi telah terlampir secara digital.",
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildManualBookContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "MANUAL BUKU PANDUAN TEKNIS & PENGOPERASIAN",
          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          "Model: Artisan Espresso Craft Pro 2G / 3G Series",
          style: GoogleFonts.plusJakartaSans(
              fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        Container(
          height: 140,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
              const SizedBox(height: 8),
              Text(
                "Daftar Isi Manual PDF (48 Halaman)",
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const Text("1. Skema Instalasi Listrik 220V/380V\n2. Setting Suhu PID Boiler\n3. Descaling & Maintenance Rutin",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuotationContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "SURAT PENAWARAN HARGA (QUOTATION)",
          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text("Spesifikasi Custom Machine:",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const Text("- Custom Dual Boiler Brass Accent\n- Logo Engraving Laser\n- Garansi Pabrik 2 Tahun",
            style: TextStyle(fontSize: 11)),
        const SizedBox(height: 16),
        Text(
          "Harga Penawaran: ${data?['price'] ?? 'Rp 115.000.000'}",
          style: GoogleFonts.outfit(
              fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.secondary),
        ),
      ],
    );
  }
}
