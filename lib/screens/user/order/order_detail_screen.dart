import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/file_picker_helper.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../../../providers/app_state.dart';
import '../../../core/models/order_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/status_badge.dart';
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

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final o = widget.order;

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
                      OrderStatusBadge(status: o.status),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoColumn("Perusahaan", o.companyName),
                      _buildInfoColumn("Tgl PO", o.orderDate),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoColumn("Nomor Seri Mesin", o.serialNumber),
                      _buildInfoColumn("Estimasi Selesai", o.estimatedCompletionDate),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

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

            // 7-STAGE FULL PRODUCTION TIMELINE
            _buildSectionTitle("Timeline Pelacakan Produksi & Manufaktur (7 Tahap)"),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: appState.isDarkMode ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: appState.isDarkMode ? Colors.white10 : AppColors.border),
              ),
              child: Column(
                children: [
                  _buildTimelineTile(
                    title: "1. Verifikasi DP 50%",
                    subtitle: "DP Rp $dpFormatted telah terverifikasi oleh Finance.",
                    isFirst: true,
                    isDone: o.currentStageIndex >= 0,
                    isActive: o.currentStageIndex == 0,
                  ),
                  _buildTimelineTile(
                    title: "2. Persiapan Bahan Baku & Sourcing",
                    subtitle: "Pemesanan frame stainless steel 304, boiler & motor listrik.",
                    isDone: o.currentStageIndex >= 1,
                    isActive: o.currentStageIndex == 1,
                  ),
                  _buildTimelineTile(
                    title: "3. Proses Produksi / Assembly",
                    subtitle: "Pengelasan boiler, perakitan wiring PID & pompa rotari presisi.",
                    isDone: o.currentStageIndex >= 2,
                    isActive: o.currentStageIndex == 2,
                  ),
                  _buildTimelineTile(
                    title: "4. Quality Control (QC) & Pressure Test",
                    subtitle: "Pengujian tekanan 100 Bar & kestabilan suhu extraction.",
                    isDone: o.currentStageIndex >= 3,
                    isActive: o.currentStageIndex == 3,
                  ),
                  _buildTimelineTile(
                    title: "5. Menunggu Pelunasan Sisa 50%",
                    subtitle: "Tagihan pelunasan $sisaFormatted terbit sebelum pengiriman.",
                    isDone: o.currentStageIndex >= 4,
                    isActive: o.currentStageIndex == 4,
                  ),
                  _buildTimelineTile(
                    title: "6. Pengiriman & Instalasi Teknisi",
                    subtitle: "Pengiriman kargo industri, pengantaran on-site & instalasi teknisi.",
                    isDone: o.currentStageIndex >= 5,
                    isActive: o.currentStageIndex == 5,
                  ),
                  _buildTimelineTile(
                    title: "7. After-Sales Service (Layanan Purna Jual)",
                    subtitle: "Unit beroperasi normal, garansi 2 tahun aktif & servis berkala.",
                    isLast: true,
                    isDone: o.currentStageIndex >= 6,
                    isActive: o.currentStageIndex == 6,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Item Details Card
            _buildSectionTitle("Rincian Mesin Dipesan"),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(o.productName,
                          style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold)),
                      Text("x${o.quantity} Unit",
                          style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold)),
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
        Text(label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 10, color: AppColors.textMuted)),
        Text(value,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTimelineTile({
    required String title,
    required String subtitle,
    bool isFirst = false,
    bool isLast = false,
    bool isDone = false,
    bool isActive = false,
  }) {
    return TimelineTile(
      isFirst: isFirst,
      isLast: isLast,
      beforeLineStyle: LineStyle(
        color: isDone ? AppColors.secondary : Colors.grey.shade300,
        thickness: 3,
      ),
      indicatorStyle: IndicatorStyle(
        width: 24,
        height: 24,
        indicator: Container(
          decoration: BoxDecoration(
            color: isDone
                ? AppColors.secondary
                : (isActive ? AppColors.warning : Colors.grey.shade300),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isDone ? Icons.check : (isActive ? Icons.autorenew : Icons.circle),
            color: Colors.white,
            size: 14,
          ),
        ),
      ),
      endChild: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: isActive || isDone ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
                color: isActive
                    ? AppColors.primary
                    : (isDone ? AppColors.textPrimary : AppColors.textMuted),
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPelunasanModal(
      BuildContext context, AppState appState, OrderModel order) {
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
                  Text(
                    "Formulir Pelunasan Sisa 50%",
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
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
                    Text("BCA Corporate: 088-2930-112 (a.n. PT Kopi Industri)"),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final name = await FilePickerHelper.pickFileName();
                  setModalState(() {
                    _pelunasanProofName =
                        name ?? 'bukti_pelunasan_50_percent.jpg';
                  });
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
                      Text(
                        _pelunasanProofName ?? "Unggah Bukti Transfer Pelunasan",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
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
                  onPressed: () {
                    final proof =
                        _pelunasanProofName ?? 'bukti_pelunasan_50_percent.jpg';
                    appState.uploadPelunasanProof(order.id, proof);
                    Navigator.pop(context);
                  },
                  child: const Text("KONFIRMASI UPLOAD PELUNASAN"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
