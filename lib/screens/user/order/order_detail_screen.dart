import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../../../core/utils/file_picker_helper.dart';
import '../../../providers/app_state.dart';
import '../../../core/models/order_model.dart';
import '../../../core/models/product_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/pdf_preview_dialog.dart';
import '../service/booking_service_screen.dart';
import '../service/warranty_claim_screen.dart';
import '../info/contact_whatsapp_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  String? _pelunasanProofName;

  String _formatCurrency(double amount) {
    return "Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  ProductModel? _findMatchingProduct(AppState appState, String productName) {
    final matches = appState.products.where(
      (p) =>
          p.name.toLowerCase().contains(productName.toLowerCase()) ||
          productName.toLowerCase().contains(p.name.toLowerCase()),
    );
    if (matches.isNotEmpty) return matches.first;
    return null;
  }

  String _resolveImageUrl(ProductModel? matchedProduct, OrderModel order) {
    if (order.imageUrl != null && order.imageUrl!.isNotEmpty) {
      return order.imageUrl!;
    }
    if (matchedProduct != null && matchedProduct.imageUrl.isNotEmpty) {
      return matchedProduct.imageUrl;
    }
    return 'https://images.unsplash.com/photo-1517256064527-09c73fc73e38?w=800&auto=format&fit=crop&q=80';
  }

  String _resolveDescription(ProductModel? matchedProduct, OrderModel order) {
    if (order.description != null && order.description!.isNotEmpty) {
      return order.description!;
    }
    if (matchedProduct != null && matchedProduct.description.isNotEmpty) {
      return matchedProduct.description;
    }
    return "Unit mesin manufaktur berstandar industri dengan sertifikasi kualitas presisi tinggi, material food-grade stainless steel 304, dan garansi resmi pabrik.";
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final o = widget.order;

    final totalFormatted = _formatCurrency(o.totalAmount);
    final dpFormatted = _formatCurrency(o.dpAmount);
    final sisaFormatted = _formatCurrency(o.pelunasanAmount);

    final matchedProduct = _findMatchingProduct(appState, o.productName);
    final imageUrl = _resolveImageUrl(matchedProduct, o);
    final description = _resolveDescription(matchedProduct, o);
    final specs = matchedProduct?.specifications;

    final grayIconColor = isDark ? Colors.white60 : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text(
          "Detail Pesanan ${o.poNumber}",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
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
          IconButton(
            icon: const Icon(Icons.support_agent_rounded),
            tooltip: "Konsultasi Teknisi Pabrik",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ContactWhatsappScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= 1. BAGIAN PALING ATAS: GAMBAR & DESKRIPSI PRODUK =================
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: isDark ? Colors.white10 : AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Foto Produk Bersih (Tanpa Teks Menempel di Gambar)
                  Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: double.infinity,
                      height: 180,
                      color: isDark ? AppColors.darkBackground : const Color(0xFFF1F5F9),
                      child: const Center(
                        child: Icon(
                          Icons.precision_manufacturing_rounded,
                          size: 48,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ),

                  // Detail & Deskripsi Mesin
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Teks Kategori & Jumlah Unit Dipindahkan ke SINI (Di Atas Nama Produk)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                o.category.toUpperCase(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isDark ? Colors.white12 : AppColors.border,
                                ),
                              ),
                              child: Text(
                                "${o.quantity} Unit Dipesan",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white70 : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Nama Produk Mesin (Misal: Artisan Espresso Craft Pro 2G)
                        Text(
                          o.productName,
                          style: GoogleFonts.outfit(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Deskripsi Mesin
                        Text(
                          description,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            height: 1.5,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                        ),

                        // Technical Specs Highlights
                        if (specs != null) ...[
                          const SizedBox(height: 14),
                          Divider(color: isDark ? Colors.white10 : AppColors.border),
                          const SizedBox(height: 10),
                          Text(
                            "SPESIFIKASI TEKNIS MESIN",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildSpecBadge(Icons.straighten_rounded, "Tipe", specs.tipe, isDark),
                              _buildSpecBadge(Icons.speed_rounded, "Kapasitas", specs.kapasitas, isDark),
                              _buildSpecBadge(Icons.bolt_rounded, "Daya", specs.dayaListrik, isDark),
                              _buildSpecBadge(Icons.square_foot_rounded, "Dimensi", specs.dimensi, isDark),
                              if (specs.materialBoiler.isNotEmpty)
                                _buildSpecBadge(Icons.shield_outlined, "Material", specs.materialBoiler, isDark),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ================= 2. DIBAWAHNYA: CARD DETAIL PESANAN & PENGIRIMAN =================
            _buildSectionTitle("Detail Pesanan & Pengiriman", isDark),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: isDark ? Colors.white10 : AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2A. Header PO
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.description_rounded,
                                    size: 18,
                                    color: AppColors.secondary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  o.poNumber,
                                  style: GoogleFonts.outfit(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: isDark ? Colors.white12 : AppColors.border),
                              ),
                              child: Text(
                                "${o.quantity} Unit Mesin",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white70 : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoColumn("Tanggal PO Terbit", o.orderDate, isDark),
                            _buildInfoColumn("Nomor Seri Mesin", o.serialNumber, isDark, crossAlignEnd: true),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Divider(
                    height: 1,
                    color: isDark ? Colors.white10 : AppColors.border,
                  ),

                  // 2B. Detail Pemesan & Alamat Pengiriman Menjadi SATU Bagian (Icon Abu-Abu, Tanpa Email)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white10 : Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person_pin_circle_rounded,
                                color: grayIconColor,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Informasi Pemesan & Alamat Pengiriman",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white70 : Colors.grey.shade800,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Perusahaan Pemesan
                        _buildDetailRow(
                          icon: Icons.business_rounded,
                          label: "Perusahaan Pemesan",
                          value: o.companyName,
                          isDark: isDark,
                          isBold: true,
                          iconColor: grayIconColor,
                        ),
                        const SizedBox(height: 10),

                        // Nama Kontak / PIC Pemesan
                        _buildDetailRow(
                          icon: Icons.person_outline_rounded,
                          label: "Nama Kontak Pemesan (PIC)",
                          value: o.contactPerson,
                          isDark: isDark,
                          iconColor: grayIconColor,
                        ),
                        const SizedBox(height: 10),

                        // Nomor Telepon / WhatsApp Pemesan
                        _buildDetailRow(
                          icon: Icons.phone_outlined,
                          label: "Nomor Telepon / WhatsApp",
                          value: o.buyerPhone,
                          isDark: isDark,
                          iconColor: grayIconColor,
                        ),
                        const SizedBox(height: 10),

                        // Alamat Tujuan Pengiriman (Icon abu-abu)
                        _buildDetailRow(
                          icon: Icons.location_on_outlined,
                          label: "Alamat Tujuan Pengiriman",
                          value: o.deliveryAddress,
                          isDark: isDark,
                          iconColor: grayIconColor,
                        ),
                        const SizedBox(height: 10),

                        // Target Estimasi Pengiriman Pabrik (Icon abu-abu)
                        _buildDetailRow(
                          icon: Icons.local_shipping_outlined,
                          label: "Estimasi Pengiriman Pabrik",
                          value: o.estimatedCompletionDate,
                          isDark: isDark,
                          iconColor: grayIconColor,
                        ),
                      ],
                    ),
                  ),

                  // Catatan Kustomisasi (jika ada)
                  if (o.customNotes.isNotEmpty) ...[
                    Divider(
                      height: 1,
                      color: isDark ? Colors.white10 : AppColors.border,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.amber.withValues(alpha: 0.12)
                              : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark
                                ? Colors.amber.withValues(alpha: 0.3)
                                : const Color(0xFFFDE68A),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.edit_note_rounded,
                              color: Color(0xFFD97706),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Catatan Kustomisasi Produksi:",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.amber.shade200 : const Color(0xFF92400E),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    o.customNotes,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      height: 1.35,
                                      color: isDark ? Colors.white70 : const Color(0xFF78350F),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ================= 3. CARD TIMELINE PELACAKAN PRODUKSI (7 TAHAP) =================
            _buildSectionTitle("Timeline Pelacakan Produksi (7 Tahap)", isDark),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white10 : AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildTimelineTile(
                    title: "1. Verifikasi DP 50%",
                    subtitle: "DP Rp $dpFormatted telah terverifikasi oleh Finance.",
                    isFirst: true,
                    isDone: o.currentStageIndex >= 0,
                    isActive: o.currentStageIndex == 0,
                    isDark: isDark,
                  ),
                  _buildTimelineTile(
                    title: "2. Persiapan Bahan Baku & Sourcing",
                    subtitle: "Pemotongan frame stainless 304, penyiapan drum & komponen kelistrikan.",
                    isDone: o.currentStageIndex >= 1,
                    isActive: o.currentStageIndex == 1,
                    isDark: isDark,
                  ),
                  _buildTimelineTile(
                    title: "3. Proses Produksi / Assembly",
                    subtitle: "Pengelasan boiler, perakitan wiring PID & pompa rotari presisi.",
                    isDone: o.currentStageIndex >= 2,
                    isActive: o.currentStageIndex == 2,
                    isDark: isDark,
                  ),
                  _buildTimelineTile(
                    title: "4. Quality Control (QC) & Pressure Test",
                    subtitle: "Pengujian tekanan hidrostatik 100 Bar & kestabilan suhu extraction.",
                    isDone: o.currentStageIndex >= 3,
                    isActive: o.currentStageIndex == 3,
                    isDark: isDark,
                  ),
                  _buildTimelineTile(
                    title: "5. Menunggu Pelunasan Sisa 50%",
                    subtitle: "Tagihan pelunasan $sisaFormatted terbit sebelum pengiriman kargo.",
                    isDone: o.currentStageIndex >= 4,
                    isActive: o.currentStageIndex == 4,
                    isDark: isDark,
                  ),
                  _buildTimelineTile(
                    title: "6. Pengiriman & Instalasi Teknisi",
                    subtitle: "Pengiriman kargo industri, pengantaran on-site & instalasi teknisi pabrik.",
                    isDone: o.currentStageIndex >= 5,
                    isActive: o.currentStageIndex == 5,
                    isDark: isDark,
                  ),
                  _buildTimelineTile(
                    title: "7. After-Sales Service & Garansi Aktif",
                    subtitle: "Unit mesin aktif beroperasi, garansi 2 tahun & servis berkala.",
                    isLast: true,
                    isDone: o.currentStageIndex >= 6,
                    isActive: o.currentStageIndex == 6,
                    isDark: isDark,
                  ),

                  // Tombol Pelunasan jika tahap 5
                  if (o.status == OrderStatus.menungguPelunasan) ...[
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showPelunasanModal(context, appState, o),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.warning,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                        icon: const Icon(Icons.upload_file, size: 18),
                        label: const Text(
                          "UPLOAD BUKTI PELUNASAN (50%)",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                  ],

                  // Tombol Konfirmasi Pengiriman jika tahap 6
                  if (o.status == OrderStatus.pengirimanInstalasi) ...[
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
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: const Text(
                          "KONFIRMASI UNIT TERPASANG",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
                        ),
                      ),
                    ),
                  ],

                  // Tombol Servis & Garansi jika tahap 7
                  if (o.status == OrderStatus.afterSalesService) ...[
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
                              backgroundColor: const Color(0xFF047857),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            icon: const Icon(Icons.handyman, size: 16),
                            label: const Text(
                              "Booking Servis",
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
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
                              foregroundColor: const Color(0xFF047857),
                              side: const BorderSide(color: Color(0xFF047857), width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            icon: const Icon(Icons.shield, size: 16),
                            label: const Text(
                              "Klaim Garansi",
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ================= 4. CARD TERAKHIR: RINCIAN PEMBAYARAN & INVOICE =================
            _buildSectionTitle("Rincian Pembayaran & Invoice", isDark),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white10 : AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Nilai PO (${o.quantity} Unit)",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        totalFormatted,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 15, color: AppColors.success),
                          const SizedBox(width: 4),
                          Text(
                            "DP 50% (Lunas Terverifikasi):",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: isDark ? Colors.white70 : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        dpFormatted,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            o.pelunasanProofPath != null
                                ? Icons.check_circle_rounded
                                : Icons.hourglass_top_rounded,
                            size: 15,
                            color: o.pelunasanProofPath != null
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Pelunasan Sisa 50%:",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: isDark ? Colors.white70 : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        sisaFormatted,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: o.pelunasanProofPath != null
                              ? AppColors.success
                              : AppColors.warning,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    height: 24,
                    color: isDark ? Colors.white10 : AppColors.border,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "TOTAL TAGIHAN PO",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        totalFormatted,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
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
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.secondary,
                        side: const BorderSide(color: AppColors.secondary),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                      label: const Text(
                        "DOWNLOAD DOKUMEN INVOICE & FAKTUR",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 14.5,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, bool isDark, {bool crossAlignEnd = false}) {
    return Column(
      crossAxisAlignment: crossAlignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    bool isBold = false,
    Color? iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: iconColor ?? (isDark ? Colors.white60 : const Color(0xFF64748B)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 1.5),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpecBadge(IconData icon, String label, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? Colors.white10 : AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.secondary),
          const SizedBox(width: 5),
          Text(
            "$label: ",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineTile({
    required String title,
    required String subtitle,
    bool isFirst = false,
    bool isLast = false,
    bool isDone = false,
    bool isActive = false,
    required bool isDark,
  }) {
    return TimelineTile(
      isFirst: isFirst,
      isLast: isLast,
      beforeLineStyle: LineStyle(
        color: isDone ? const Color(0xFF10B981) : (isDark ? Colors.white12 : Colors.grey.shade300),
        thickness: 2.5,
      ),
      indicatorStyle: IndicatorStyle(
        width: 22,
        height: 22,
        indicator: Container(
          decoration: BoxDecoration(
            color: isDone
                ? const Color(0xFF10B981)
                : (isActive ? AppColors.secondary : (isDark ? Colors.white24 : Colors.grey.shade300)),
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.4),
                      blurRadius: 6,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
          child: Icon(
            isDone ? Icons.check_rounded : (isActive ? Icons.autorenew_rounded : Icons.circle),
            color: Colors.white,
            size: 13,
          ),
        ),
      ),
      endChild: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 0, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: isActive || isDone ? FontWeight.bold : FontWeight.w500,
                fontSize: 12.5,
                color: isActive
                    ? AppColors.secondary
                    : (isDone
                        ? (isDark ? Colors.white : AppColors.textPrimary)
                        : (isDark ? Colors.white38 : AppColors.textMuted)),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
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
                      fontSize: 17,
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
