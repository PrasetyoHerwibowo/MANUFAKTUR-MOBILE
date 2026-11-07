import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/file_picker_helper.dart';
import '../../../providers/app_state.dart';
import '../../../core/models/order_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/pdf_preview_dialog.dart';

import '../service/booking_service_screen.dart';
import '../service/warranty_claim_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  String? _pelunasanProofName;
  UploadResult? _pelunasanUploadResult;
  String? _dpProofName;
  UploadResult? _dpUploadResult;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    // Ambil order secara reaktif dari AppState agar update status langsung tampil realtime di layar
    final o = appState.orders.firstWhere(
      (item) => item.id == widget.order.id || item.poNumber == widget.order.poNumber,
      orElse: () => widget.order,
    );

    final totalFormatted =
        "Rp ${o.totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
    final dpFormatted =
        "Rp ${o.dpAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
    final sisaFormatted =
        "Rp ${o.pelunasanAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";

    return Scaffold(
      backgroundColor: appState.isDarkMode ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text("Detail Pesanan ${o.poNumber}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: "Download Invoice PDF",
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => PdfPreviewModal(
                  title: "PDF Invoice & Faktur Pajak",
                  subtitle: o.poNumber,
                  pdfType: "INVOICE",
                  data: {
                    'poNumber': o.poNumber,
                    'company': o.companyName,
                    'productName': o.productName,
                    'total': totalFormatted,
                    'dp': dpFormatted,
                    'pelunasan': sisaFormatted,
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: appState.isDarkMode ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: appState.isDarkMode ? Colors.white10 : AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        o.poNumber,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: appState.isDarkMode ? Colors.white : AppColors.primary,
                        ),
                      ),
                      Text(
                        o.orderDate,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: appState.isDarkMode ? AppColors.darkTextSecondary : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    children: [
                      Expanded(child: _buildInfoColumn("Perusahaan", o.companyName)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildInfoColumn("Tgl PO", o.orderDate)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildInfoColumn("Nomor Seri Mesin", o.serialNumber)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildInfoColumn("Estimasi Selesai", o.estimatedCompletionDate)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // DYNAMIC ALERT FOR "VERIFIKASI DP 50%" (STAGE 1)
            if (o.status == OrderStatus.verifikasiDp) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.shade700, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.hourglass_top_rounded,
                            color: Colors.amber.shade800, size: 28),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "STATUS: VERIFIKASI PEMBAYARAN DP (50%)",
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.amber.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Bukti transfer Down Payment (50%) sebesar $dpFormatted telah terkirim dan sedang dalam proses validasi oleh Tim Finance Pabrik.\n\nSetelah admin mengkonfirmasi bukti valid pada dashboard website, status produksi akan otomatis diperbarui.",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: appState.isDarkMode ? Colors.white70 : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // DYNAMIC ALERT FOR "BUKTI DP DITOLAK" (STAGE 1 REJECTED)
            if (o.status == OrderStatus.dpDitolak) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.shade600, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.cancel_outlined,
                            color: Colors.red.shade700, size: 28),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "STATUS: BUKTI DP DITOLAK (TIDAK VALID)",
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Bukti pembayaran DP 50% dinyatakan tidak valid oleh Admin Finance Pabrik.${o.rejectionReason != null && o.rejectionReason!.isNotEmpty ? '\n\nCatatan Admin: "${o.rejectionReason}"' : '\n\nMohon pastikan nominal transfer sesuai ($dpFormatted) dan foto/struk terlihat jelas.'}\n\nSilakan unggah ulang bukti transfer yang valid agar pesanan dapat segera diproses.",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: appState.isDarkMode ? Colors.white70 : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showReuploadDpModal(context, appState, o),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text("UNGGAH ULANG BUKTI DP (50%)"),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // DYNAMIC ALERT FOR "MENUNGGU PELUNASAN" (STAGE 5)
            if (o.status == OrderStatus.menungguPelunasan) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.warning, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: AppColors.warning, size: 28),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "STATUS: MENUNGGU PELUNASAN SISA 50%",
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Mesin telah lulus Quality Control (QC) & siap dikirim. Silakan unggah bukti transfer pelunasan sisa 50% ($sisaFormatted).",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: appState.isDarkMode ? Colors.white70 : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showPelunasanModal(context, appState, o),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.warning,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.upload_file),
                        label: const Text("FORMULIR UPLOAD PELUNASAN (50%)"),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // DYNAMIC ALERT FOR "VERIFIKASI PELUNASAN" (STAGE 5b - MENUNGGU ACC ADMIN)
            if (o.status == OrderStatus.verifikasiPelunasan) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF0284C7), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.hourglass_top_rounded,
                            color: Color(0xFF0284C7), size: 28),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "STATUS: MENUNGGU VERIFIKASI PELUNASAN",
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: const Color(0xFF0284C7),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Bukti transfer pelunasan sisa 50% ($sisaFormatted) telah berhasil diunggah. Saat ini admin finance sedang memverifikasi keabsahan pembayaran Anda.\n\nStatus akan diperbarui ke 'Pengiriman & Instalasi' setelah admin mengonfirmasi bukti tersebut VALID di dashboard website.",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: appState.isDarkMode ? Colors.white70 : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, size: 16, color: Color(0xFF0284C7)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _pelunasanProofName ?? "Bukti transfer tersimpan & terkirim ke server",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0284C7),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => _showPelunasanModal(context, appState, o),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text("Ganti Bukti", style: TextStyle(fontSize: 11)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // DYNAMIC ALERT FOR "PELUNASAN DITOLAK" (STAGE 5 REJECTED)
            if (o.status == OrderStatus.pelunasanDitolak) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.shade600, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.error_outline_rounded,
                            color: Colors.red.shade700, size: 28),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "STATUS: BUKTI PELUNASAN DITOLAK (TIDAK VALID)",
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Bukti pembayaran pelunasan 50% dinyatakan tidak valid oleh Admin Finance Pabrik.${o.rejectionReason != null && o.rejectionReason!.isNotEmpty ? '\n\nCatatan Admin: "${o.rejectionReason}"' : '\n\nNominal transfer tidak sesuai atau gambar bukti buram/tidak terbaca.'}\n\nSilakan unggah kembali bukti pelunasan yang valid agar jadwal pengiriman unit dapat segera diterbitkan.",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: appState.isDarkMode ? Colors.white70 : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showPelunasanModal(context, appState, o),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.upload_file),
                        label: const Text("UNGGAH ULANG BUKTI PELUNASAN (50%)"),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // DYNAMIC ALERT FOR "PENGIRIMAN & INSTALASI" (STAGE 6)
            if (o.status == OrderStatus.pengirimanInstalasi) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade700, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_shipping, color: Colors.blue.shade700, size: 28),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "STATUS: PENGIRIMAN & INSTALASI TEKNISI",
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Pelunasan 50% telah diterima. Unit mesin sedang dalam perjalanan kargo & teknisi pabrik siap melakukan instalasi di lokasi Anda.",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: appState.isDarkMode ? Colors.white70 : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          appState.completeDeliveryAndOpenAfterSales(o.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Instalasi Selesai! Layanan After-Sales Service & Garansi Aktif."),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                        ),
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text("KONFIRMASI UNIT TERPASANG & AKTIFKAN AFTER-SALES"),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // DYNAMIC CARD FOR "AFTER-SALES SERVICE" (STAGE 7)
            if (o.status == OrderStatus.afterSalesService) ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF064E3B),
                      Color(0xFF047857),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified, color: Colors.amber, size: 28),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "7. AFTER-SALES SERVICE & GARANSI RESMI",
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Unit mesin telah terpasang dan beroperasi penuh. Garansi resmi 2 tahun aktif untuk suku cadang & servis teknisi on-site.",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "No. Seri Mesin: ${o.serialNumber}",
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade400,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "GARANSI AKTIF",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const BookingServiceScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF064E3B),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                            ),
                            icon: const Icon(Icons.handyman, size: 16),
                            label: const Text(
                              "Booking Servis",
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const WarrantyClaimScreen(asStandalonePage: true),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white, width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                            ),
                            icon: const Icon(Icons.shield, size: 16, color: Colors.white),
                            label: const Text(
                              "Klaim Garansi",
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Informasi Pengiriman & Catatan Pabrik
            _buildSectionTitle("Informasi Pengiriman & Spesifikasi"),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: appState.isDarkMode ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: appState.isDarkMode ? Colors.white10 : AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.local_shipping_outlined,
                          color: Color(0xFF2563EB),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Alamat Pengiriman:",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: appState.isDarkMode ? Colors.white70 : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              o.deliveryAddress,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                color: appState.isDarkMode ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Divider(
                    height: 1,
                    color: appState.isDarkMode ? Colors.white10 : AppColors.border,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoColumn(
                          "Estimasi Pengiriman Pabrik",
                          o.estimatedCompletionDate,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoColumn(
                          "Metode Logistik",
                          "Kargo Khusus Pabrik",
                        ),
                      ),
                    ],
                  ),
                  if (o.customNotes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: appState.isDarkMode ? 0.12 : 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.note_alt_outlined, size: 16, color: Color(0xFFB45309)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Catatan Khusus: ${o.customNotes}",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontStyle: FontStyle.italic,
                                color: appState.isDarkMode ? Colors.amber.shade200 : const Color(0xFFB45309),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Item Details Card
            _buildSectionTitle("Rincian Mesin Dipesan"),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: appState.isDarkMode ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: appState.isDarkMode ? Colors.white10 : AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          o.productName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            color: appState.isDarkMode ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "x${o.quantity} Unit",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          color: appState.isDarkMode ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("DP 50% (Terbayar):",
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(dpFormatted,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.success,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Pelunasan 50%:",
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(sisaFormatted,
                          style: TextStyle(
                              fontSize: 12,
                              color: o.pelunasanProofPath != null
                                  ? AppColors.success
                                  : AppColors.warning,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("TOTAL BILLING PO",
                          style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      Text(totalFormatted,
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            color: AppColors.textMuted,
          ),
        ),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showPelunasanModal(
      BuildContext context, AppState appState, OrderModel order) {
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Formulir Pelunasan Sisa 50%",
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Text(
                "Jumlah Pelunasan (50%): Rp ${order.pelunasanAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              const Text("Pilih Rekening Tujuan Transfer Pelunasan:"),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.account_balance, color: AppColors.primary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "BCA Corporate: 088-2930-112 (a.n. PT Kopi Industri)",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: isSubmitting
                    ? null
                    : () async {
                        final result = await FilePickerHelper.showUploadSourceSheet(
                          context: context,
                          title: "Unggah Bukti Pelunasan 50%",
                          subtitle: "Pilih foto struk ATM, screenshot m-Banking, atau dokumen PDF",
                          isDark: appState.isDarkMode,
                          brandColor: AppColors.primary,
                        );
                        if (result != null) {
                          setModalState(() {
                            _pelunasanProofName = result.fileName;
                            _pelunasanUploadResult = result;
                          });
                        }
                      },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _pelunasanProofName != null
                        ? Colors.green.shade50
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _pelunasanProofName != null
                          ? Colors.green
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _pelunasanProofName != null
                            ? Icons.check_circle
                            : Icons.cloud_upload_outlined,
                        color: _pelunasanProofName != null
                            ? Colors.green
                            : AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _pelunasanProofName ?? "Unggah Bukti Transfer Pelunasan",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (_pelunasanProofName == null && _pelunasanUploadResult == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Silakan pilih file bukti transfer terlebih dahulu!"),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          setModalState(() => isSubmitting = true);

                          Uint8List? bytes = _pelunasanUploadResult?.fileBytes;
                          if (bytes == null && _pelunasanUploadResult?.filePath != null) {
                            try {
                              bytes = await File(_pelunasanUploadResult!.filePath!).readAsBytes();
                            } catch (_) {}
                          }

                          String proof = _pelunasanProofName ?? 'bukti_pelunasan_50_percent.jpg';
                          if (bytes != null) {
                            final name = (_pelunasanUploadResult?.fileName ?? '').toLowerCase();
                            String mime = 'jpeg';
                            if (name.endsWith('.png')) {
                              mime = 'png';
                            } else if (name.endsWith('.webp')) {
                              mime = 'webp';
                            } else if (name.endsWith('.pdf')) {
                              mime = 'pdf';
                            }

                            final prefix = mime == 'pdf' ? 'data:application/pdf;base64,' : 'data:image/$mime;base64,';
                            proof = '$prefix${base64Encode(bytes)}';
                          }

                          await appState.uploadPelunasanProof(order.id, proof);

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Bukti pelunasan terkirim! Status: Menunggu verifikasi & ACC admin."),
                                backgroundColor: AppColors.success,
                                duration: Duration(seconds: 4),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text("KONFIRMASI UPLOAD PELUNASAN"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReuploadDpModal(
      BuildContext context, AppState appState, OrderModel order) {
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Unggah Ulang Bukti DP 50%",
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Text(
                "Jumlah DP (50%): Rp ${order.dpAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              const Text("Pilih Rekening Tujuan Transfer:"),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.account_balance, color: AppColors.primary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "BCA Corporate: 088-2930-112 (a.n. PT Kopi Industri)",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: isSubmitting
                    ? null
                    : () async {
                        final result = await FilePickerHelper.showUploadSourceSheet(
                          context: context,
                          title: "Unggah Ulang Bukti DP 50%",
                          subtitle: "Pilih foto struk ATM, screenshot m-Banking, atau dokumen PDF",
                          isDark: appState.isDarkMode,
                          brandColor: AppColors.primary,
                        );
                        if (result != null) {
                          setModalState(() {
                            _dpProofName = result.fileName;
                            _dpUploadResult = result;
                          });
                        }
                      },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _dpProofName != null
                        ? Colors.green.shade50
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _dpProofName != null
                          ? Colors.green
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _dpProofName != null
                            ? Icons.check_circle
                            : Icons.cloud_upload_outlined,
                        color: _dpProofName != null
                            ? Colors.green
                            : AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _dpProofName ?? "Unggah Bukti Transfer DP Baru",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (_dpProofName == null && _dpUploadResult == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Silakan pilih file bukti transfer DP terlebih dahulu!"),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          setModalState(() => isSubmitting = true);

                          Uint8List? bytes = _dpUploadResult?.fileBytes;
                          if (bytes == null && _dpUploadResult?.filePath != null) {
                            try {
                              bytes = await File(_dpUploadResult!.filePath!).readAsBytes();
                            } catch (_) {}
                          }

                          String proof = _dpProofName ?? 'bukti_dp_50_percent.jpg';
                          if (bytes != null) {
                            final name = (_dpUploadResult?.fileName ?? '').toLowerCase();
                            String mime = 'jpeg';
                            if (name.endsWith('.png')) {
                              mime = 'png';
                            } else if (name.endsWith('.webp')) {
                              mime = 'webp';
                            } else if (name.endsWith('.pdf')) {
                              mime = 'pdf';
                            }

                            final prefix = mime == 'pdf' ? 'data:application/pdf;base64,' : 'data:image/$mime;base64,';
                            proof = '$prefix${base64Encode(bytes)}';
                          }

                          await appState.reuploadDpProof(order.id, proof);

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Bukti DP baru terkirim! Status: Menunggu verifikasi admin."),
                                backgroundColor: AppColors.success,
                                duration: Duration(seconds: 4),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text("KONFIRMASI UNGGAH ULANG DP"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
