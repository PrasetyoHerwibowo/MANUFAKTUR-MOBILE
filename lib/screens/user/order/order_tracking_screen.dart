import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state.dart';
import '../../../core/models/order_model.dart';
import '../../../core/models/custom_order_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/pdf_preview_dialog.dart';
import 'order_detail_screen.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    return "Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  String? _findProductImage(AppState appState, String productName) {
    final matches = appState.products.where(
      (p) =>
          p.name.toLowerCase().contains(productName.toLowerCase()) ||
          productName.toLowerCase().contains(p.name.toLowerCase()),
    );
    if (matches.isNotEmpty) return matches.first.imageUrl;
    return null;
  }

  // Model helper for comprehensive, intuitive order status context
  _OrderStatusInfo _getOrderStatusInfo(OrderStatus status) {
    switch (status) {
      case OrderStatus.verifikasiDp:
        return const _OrderStatusInfo(
          badgeText: "Menunggu Verifikasi DP",
          description: "Bukti transfer DP 50% sedang divalidasi finance pabrik",
          icon: Icons.hourglass_top_rounded,
          color: Color(0xFFD97706), // Amber 600
          dpStatusText: "Proses Verifikasi",
          isDpVerified: false,
          pelunasanStatusText: "Pasca Uji QC",
          isPelunasanDue: false,
          isCompleted: false,
        );
      case OrderStatus.persiapanBahan:
        return const _OrderStatusInfo(
          badgeText: "Persiapan Bahan Baku",
          description: "DP terverifikasi • Komponen stainless 304 & boiler disiapkan",
          icon: Icons.inventory_2_outlined,
          color: Color(0xFF0284C7), // Sky 600
          dpStatusText: "Terbayar (50%)",
          isDpVerified: true,
          pelunasanStatusText: "Pasca Uji QC",
          isPelunasanDue: false,
          isCompleted: false,
        );
      case OrderStatus.prosesProduksi:
        return const _OrderStatusInfo(
          badgeText: "Dalam Proses Produksi",
          description: "Perakitan mekanik, wiring kelistrikan & instalasi komponen",
          icon: Icons.precision_manufacturing_rounded,
          color: Color(0xFF6366F1), // Indigo 500
          dpStatusText: "Terbayar (50%)",
          isDpVerified: true,
          pelunasanStatusText: "Pasca Uji QC",
          isPelunasanDue: false,
          isCompleted: false,
        );
      case OrderStatus.qualityControl:
        return const _OrderStatusInfo(
          badgeText: "Uji Quality Control (QC)",
          description: "Uji hidrostatik 12 bar & kalibrasi suhu sebelum rilis",
          icon: Icons.verified_outlined,
          color: Color(0xFF8B5CF6), // Purple 500
          dpStatusText: "Terbayar (50%)",
          isDpVerified: true,
          pelunasanStatusText: "Menunggu Rilis QC",
          isPelunasanDue: false,
          isCompleted: false,
        );
      case OrderStatus.menungguPelunasan:
        return const _OrderStatusInfo(
          badgeText: "Menunggu Pelunasan Sisa 50%",
          description: "Mesin lulus QC 100% • Pelunasan diperlukan sebelum kirim",
          icon: Icons.payment_rounded,
          color: Color(0xFFEA580C), // Orange 600
          dpStatusText: "Terbayar (50%)",
          isDpVerified: true,
          pelunasanStatusText: "Perlu Dilunasi",
          isPelunasanDue: true,
          isCompleted: false,
        );
      case OrderStatus.pengirimanInstalasi:
        return const _OrderStatusInfo(
          badgeText: "Pengiriman & Instalasi",
          description: "Pelunasan diterima • Unit dalam perjalanan kargo pabrik",
          icon: Icons.local_shipping_outlined,
          color: Color(0xFF2563EB), // Blue 600
          dpStatusText: "Terbayar (50%)",
          isDpVerified: true,
          pelunasanStatusText: "Lunas (50%)",
          isPelunasanDue: false,
          isCompleted: false,
        );
      case OrderStatus.afterSalesService:
        return const _OrderStatusInfo(
          badgeText: "Selesai • Garansi Resmi Aktif",
          description: "Unit mesin terpasang & garansi purna jual 2 tahun aktif",
          icon: Icons.check_circle_outline_rounded,
          color: Color(0xFF16A34A), // Emerald 600
          dpStatusText: "Lunas (50%)",
          isDpVerified: true,
          pelunasanStatusText: "Lunas (50%)",
          isPelunasanDue: false,
          isCompleted: true,
        );
    }
  }

  // Model helper for RFQ status context
  _RfqStatusInfo _getRfqStatusInfo(CustomOrderStatus status) {
    switch (status) {
      case CustomOrderStatus.diajukan:
        return const _RfqStatusInfo(
          badgeText: "Pengajuan Baru",
          description: "Menunggu review spesifikasi teknis oleh tim engineering",
          icon: Icons.assignment_outlined,
          color: Color(0xFF0284C7),
        );
      case CustomOrderStatus.dalamReview:
        return const _RfqStatusInfo(
          badgeText: "Dalam Review Engineering",
          description: "Tim sedang menelaah kelayakan desain & kalkulasi biaya",
          icon: Icons.engineering_outlined,
          color: Color(0xFF6366F1),
        );
      case CustomOrderStatus.quotationTerkirim:
        return const _RfqStatusInfo(
          badgeText: "Penawaran (Quotation) Tersedia",
          description: "Pabrik telah menerbitkan estimasi biaya & spesifikasi resmi",
          icon: Icons.request_quote_outlined,
          color: Color(0xFF16A34A),
        );
      case CustomOrderStatus.disetujui:
        return const _RfqStatusInfo(
          badgeText: "Spesifikasi Disetujui",
          description: "Penawaran diterima • Siap dilanjutkan ke Purchase Order (PO)",
          icon: Icons.check_circle_outlined,
          color: Color(0xFF0D9488),
        );
      case CustomOrderStatus.ditolak:
        return const _RfqStatusInfo(
          badgeText: "Pengajuan Ditolak",
          description: "Spesifikasi kustom melampaui kapasitas mesin pabrik",
          icon: Icons.cancel_outlined,
          color: Color(0xFFDC2626),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final orders = appState.orders;
    final rfqOrders = appState.customOrders;

    final bgColor = isDark ? const Color(0xFF0B111A) : const Color(0xFFF4F6F9);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          color: bgColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141D2B) : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(3.5),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: isDark ? const Color(0xFF1E2B3E) : Colors.white,
                borderRadius: BorderRadius.circular(9),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1.5),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: isDark ? Colors.white : AppColors.primary,
              unselectedLabelColor:
                  isDark ? Colors.white60 : const Color(0xFF64748B),
              labelStyle: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.precision_manufacturing_outlined,
                          size: 15),
                      const SizedBox(width: 6),
                      Text("Pesanan Mesin PO (${orders.length})"),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.tune_rounded, size: 15),
                      const SizedBox(width: 6),
                      Text("Custom RFQ (${rfqOrders.length})"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Standard PO Orders
          orders.isEmpty
              ? _buildEmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: "Belum Ada Pesanan Mesin PO",
                  message:
                      "Anda belum memiliki transaksi Purchase Order (PO) mesin saat ini.",
                  isDark: isDark,
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  physics: const BouncingScrollPhysics(),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return _buildPoCard(context, appState, order, isDark);
                  },
                ),

          // Tab 2: Custom RFQ Orders
          rfqOrders.isEmpty
              ? _buildEmptyState(
                  icon: Icons.settings_suggest_outlined,
                  title: "Belum Ada Pengajuan Custom RFQ",
                  message:
                      "Pengajuan spesifikasi custom mesin Anda akan tampil di sini.",
                  isDark: isDark,
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  physics: const BouncingScrollPhysics(),
                  itemCount: rfqOrders.length,
                  itemBuilder: (context, index) {
                    final rfq = rfqOrders[index];
                    return _buildRfqCard(context, rfq, isDark);
                  },
                ),
        ],
      ),
    );
  }

  // ================= 1. REFINED PO ORDER CARD =================
  Widget _buildPoCard(
      BuildContext context, AppState appState, OrderModel order, bool isDark) {
    final totalFormatted = _formatCurrency(order.totalAmount);
    final dpFormatted = _formatCurrency(order.dpAmount);
    final sisaFormatted = _formatCurrency(order.pelunasanAmount);
    final imageUrl = _findProductImage(appState, order.productName);
    final statusInfo = _getOrderStatusInfo(order.status);

    // Color definitions for dark / light modes
    final cardBg = isDark ? const Color(0xFF131D2A) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF223145) : const Color(0xFFE2E8F0);
    final innerBg = isDark ? const Color(0xFF0E1622) : const Color(0xFFF8FAFC);
    final innerBorder =
        isDark ? const Color(0xFF1D2A3D) : const Color(0xFFE2E8F0);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtextColor =
        isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569);
    final mutedTextColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailScreen(order: order),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Row (No. PO, Tanggal Order & Chevron)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : AppColors.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.receipt_long_rounded,
                            size: 14,
                            color: isDark
                                ? Colors.white70
                                : AppColors.primary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            order.poNumber,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                              color: titleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "•  ${order.orderDate}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: mutedTextColor,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                    ),
                  ],
                ),
              ),

              // 2. Integrated Status Banner (Menghilangkan kebingungan user!)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: statusInfo.color
                      .withValues(alpha: isDark ? 0.16 : 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: statusInfo.color
                        .withValues(alpha: isDark ? 0.35 : 0.22),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: statusInfo.color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        statusInfo.icon,
                        size: 14,
                        color: statusInfo.color,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            statusInfo.badgeText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: statusInfo.color,
                            ),
                          ),
                          Text(
                            statusInfo.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              color: subtextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 3. Info Mesin & Spesifikasi
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Machine Image Thumbnail with subtle border
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: innerBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: innerBorder),
                        ),
                        child: imageUrl != null
                            ? Image.network(
                                imageUrl,
                                width: 76,
                                height: 76,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildPlaceholderImage(isDark),
                              )
                            : _buildPlaceholderImage(isDark),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Detail Mesin
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6.5, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E2B3E)
                                  : const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              order.category,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? const Color(0xFF93C5FD)
                                    : const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order.productName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              height: 1.25,
                              color: titleColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Kuantitas: ${order.quantity} Unit  •  SN: ${order.serialNumber}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: subtextColor,
                            ),
                          ),
                          if (order.customNotes.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.edit_note_rounded,
                                  size: 13,
                                  color: Color(0xFFD97706),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    order.customNotes,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10.5,
                                      fontStyle: FontStyle.italic,
                                      color: isDark
                                          ? Colors.amber.shade200
                                          : const Color(0xFFB45309),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 4. Info Pengiriman (Jelas & Rapih)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 7.5),
                  decoration: BoxDecoration(
                    color: innerBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: innerBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_shipping_outlined,
                        size: 15,
                        color: Color(0xFF2563EB),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Estimasi Kirim: ${order.estimatedCompletionDate}  •  Tujuan: ${order.deliveryAddress}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            color: subtextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 5. Rincian Finansial & Termin Pembayaran PO (Transparan & Jelas)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: innerBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: innerBorder),
                  ),
                  child: Column(
                    children: [
                      // Total Tagihan Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Tagihan PO",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: mutedTextColor,
                            ),
                          ),
                          Text(
                            totalFormatted,
                            style: GoogleFonts.outfit(
                              fontSize: 16.5,
                              fontWeight: FontWeight.bold,
                              color: titleColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Divider(
                        height: 1,
                        color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                      ),
                      const SizedBox(height: 8),

                      // Termin 1: DP 50%
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: statusInfo.isDpVerified
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFFD97706),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "DP 50% (Saat Pesan):",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  color: subtextColor,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                dpFormatted,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: statusInfo.isDpVerified
                                      ? (isDark
                                          ? const Color(0xFF4ADE80)
                                          : const Color(0xFF16A34A))
                                      : (isDark
                                          ? const Color(0xFFFBBF24)
                                          : const Color(0xFFD97706)),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: statusInfo.isDpVerified
                                      ? const Color(0xFF16A34A)
                                          .withValues(alpha: 0.12)
                                      : const Color(0xFFD97706)
                                          .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  statusInfo.dpStatusText,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: statusInfo.isDpVerified
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFFD97706),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      // Termin 2: Sisa 50%
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: statusInfo.isCompleted
                                      ? const Color(0xFF16A34A)
                                      : (statusInfo.isPelunasanDue
                                          ? const Color(0xFFEA580C)
                                          : const Color(0xFF94A3B8)),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Sisa 50% (Pasca QC):",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  color: subtextColor,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                sisaFormatted,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: statusInfo.isPelunasanDue
                                      ? (isDark
                                          ? const Color(0xFFFB923C)
                                          : const Color(0xFFEA580C))
                                      : subtextColor,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: statusInfo.isPelunasanDue
                                      ? const Color(0xFFEA580C)
                                          .withValues(alpha: 0.12)
                                      : (isDark
                                          ? Colors.white10
                                          : const Color(0xFFE2E8F0)),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  statusInfo.pelunasanStatusText,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: statusInfo.isPelunasanDue
                                        ? const Color(0xFFEA580C)
                                        : mutedTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Divider(
                height: 1,
                color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
              ),

              // 6. Action Bar (Invoice PDF & Detail CTA - Sangat Intuitif)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                child: Row(
                  children: [
                    // Tombol Unduh / Lihat Invoice PDF
                    Expanded(
                      flex: 4,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => PdfPreviewModal(
                              title: "PDF Invoice & Faktur Pajak",
                              subtitle: order.poNumber,
                              pdfType: "INVOICE",
                              data: {
                                'poNumber': order.poNumber,
                                'company': order.companyName,
                                'productName': order.productName,
                                'total': totalFormatted,
                                'dp': dpFormatted,
                                'pelunasan': sisaFormatted,
                              },
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              isDark ? Colors.white70 : const Color(0xFF334155),
                          side: BorderSide(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFCBD5E1),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                        icon: const Icon(Icons.picture_as_pdf_outlined,
                            size: 15),
                        label: Text(
                          "Invoice PDF",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Tombol Detail / Aksi Pelunasan
                    Expanded(
                      flex: 6,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OrderDetailScreen(order: order),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: statusInfo.isPelunasanDue
                              ? const Color(0xFFEA580C)
                              : (isDark
                                  ? const Color(0xFF1E293B)
                                  : AppColors.primary),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                            side: isDark && !statusInfo.isPelunasanDue
                                ? const BorderSide(
                                    color: Color(0xFF3B82F6), width: 0.8)
                                : BorderSide.none,
                          ),
                        ),
                        icon: Icon(
                          statusInfo.isPelunasanDue
                              ? Icons.upload_file_rounded
                              : Icons.arrow_forward_rounded,
                          size: 15,
                        ),
                        label: Text(
                          statusInfo.isPelunasanDue
                              ? "Upload Pelunasan"
                              : "Detail Pesanan",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(bool isDark) {
    return Container(
      width: 76,
      height: 76,
      color: isDark ? const Color(0xFF101725) : const Color(0xFFF1F5F9),
      child: Center(
        child: Icon(
          Icons.coffee_maker_rounded,
          size: 32,
          color: isDark
              ? Colors.white24
              : AppColors.secondary.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  // ================= 2. REFINED CUSTOM RFQ CARD =================
  Widget _buildRfqCard(
      BuildContext context, CustomOrderModel rfq, bool isDark) {
    final statusInfo = _getRfqStatusInfo(rfq.status);

    final cardBg = isDark ? const Color(0xFF131D2A) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF223145) : const Color(0xFFE2E8F0);
    final innerBg = isDark ? const Color(0xFF0E1622) : const Color(0xFFF8FAFC);
    final innerBorder =
        isDark ? const Color(0xFF1D2A3D) : const Color(0xFFE2E8F0);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtextColor =
        isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569);
    final mutedTextColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header (RFQ Number & Date)
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.settings_suggest_rounded,
                        size: 14,
                        color: isDark ? Colors.white70 : AppColors.primary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        rfq.rfqNumber,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                          color: titleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "•  ${rfq.requestDate}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: mutedTextColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 2. Integrated RFQ Status Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: statusInfo.color.withValues(alpha: isDark ? 0.16 : 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: statusInfo.color.withValues(alpha: isDark ? 0.35 : 0.22),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: statusInfo.color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      statusInfo.icon,
                      size: 14,
                      color: statusInfo.color,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statusInfo.badgeText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: statusInfo.color,
                          ),
                        ),
                        Text(
                          statusInfo.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            color: subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 3. Machine Type & Specifications
            Text(
              rfq.machineType,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 14.5,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Target Kapasitas: ${rfq.targetCapacity}  •  Estimasi Budget: ${rfq.budgetRange}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: subtextColor,
              ),
            ),
            if (rfq.customFeatures.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: innerBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: innerBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.extension_outlined,
                      size: 14,
                      color: Color(0xFF0284C7),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Kustomisasi: ${rfq.customFeatures}",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: subtextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 4. Quotation Price Banner (jika pabrik sudah memberikan penawaran)
            if (rfq.quotationPrice != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withValues(alpha: isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF16A34A).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.request_quote_rounded,
                        color: Color(0xFF16A34A), size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Surat Penawaran Resmi Pabrik:",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF16A34A),
                            ),
                          ),
                          Text(
                            rfq.quotationPrice!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.5,
                              color: const Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ================= 3. EMPTY STATE =================
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    required bool isDark,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : const Color(0xFFE2E8F0).withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: isDark ? Colors.white38 : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper models for type-safe status rendering
class _OrderStatusInfo {
  final String badgeText;
  final String description;
  final IconData icon;
  final Color color;
  final String dpStatusText;
  final bool isDpVerified;
  final String pelunasanStatusText;
  final bool isPelunasanDue;
  final bool isCompleted;

  const _OrderStatusInfo({
    required this.badgeText,
    required this.description,
    required this.icon,
    required this.color,
    required this.dpStatusText,
    required this.isDpVerified,
    required this.pelunasanStatusText,
    required this.isPelunasanDue,
    required this.isCompleted,
  });
}

class _RfqStatusInfo {
  final String badgeText;
  final String description;
  final IconData icon;
  final Color color;

  const _RfqStatusInfo({
    required this.badgeText,
    required this.description,
    required this.icon,
    required this.color,
  });
}
