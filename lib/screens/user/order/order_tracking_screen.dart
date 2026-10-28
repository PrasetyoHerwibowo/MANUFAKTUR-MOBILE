import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state.dart';
import '../../../core/models/order_model.dart';
import '../../../core/models/custom_order_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/status_badge.dart';
import 'order_detail_screen.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<Map<String, dynamic>> _productionStages = [
    {
      'title': 'Verifikasi DP',
      'short': 'Verifikasi DP',
      'icon': Icons.receipt_long_rounded,
      'desc': 'Pemeriksaan & validasi pembayaran DP 50% oleh finance pabrik.',
    },
    {
      'title': 'Persiapan Bahan Baku',
      'short': 'Bahan Baku',
      'icon': Icons.inventory_2_outlined,
      'desc': 'Pemotongan laser stainless steel 304 & penyiapan boiler tembaga murni.',
    },
    {
      'title': 'Proses Produksi/Assembly',
      'short': 'Produksi/Assembly',
      'icon': Icons.precision_manufacturing_rounded,
      'desc': 'Perakitan komponen mekanik, pemipaan hidrolik, dan wiring kelistrikan.',
    },
    {
      'title': 'Quality Control (QC)',
      'short': 'Quality Control (QC)',
      'icon': Icons.verified_rounded,
      'desc': 'Uji tekanan hidrostatik 12 bar, kalibrasi suhu PID, dan uji kelistrikan.',
    },
    {
      'title': 'Menunggu Pelunasan',
      'short': 'Menunggu Pelunasan',
      'icon': Icons.payments_rounded,
      'desc': 'Mesin lulus uji QC 100%. Pelunasan sisa 50% sebelum pengiriman.',
    },
    {
      'title': 'Pengiriman & Instalasi',
      'short': 'Kirim & Instalasi',
      'icon': Icons.local_shipping_rounded,
      'desc': 'Pengiriman kargo khusus & instalasi on-site oleh teknisi resmi pabrik.',
    },
  ];

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

  int _getTimelineIndex(OrderStatus status) {
    switch (status) {
      case OrderStatus.verifikasiDp:
        return 0;
      case OrderStatus.persiapanBahan:
        return 1;
      case OrderStatus.prosesProduksi:
        return 2;
      case OrderStatus.qualityControl:
        return 3;
      case OrderStatus.menungguPelunasan:
        return 4;
      case OrderStatus.pengirimanInstalasi:
      case OrderStatus.afterSalesService:
        return 5;
    }
  }

  String _formatCurrency(double amount) {
    return "Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  String? _findProductImage(AppState appState, String productName) {
    final matches = appState.products.where(
      (p) => p.name.toLowerCase().contains(productName.toLowerCase()) ||
          productName.toLowerCase().contains(p.name.toLowerCase()),
    );
    if (matches.isNotEmpty) return matches.first.imageUrl;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final orders = appState.orders;
    final rfqOrders = appState.customOrders;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Container(
          color: isDark ? AppColors.darkSurface : Colors.white,
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.secondary,
            indicatorWeight: 3,
            labelColor: AppColors.secondary,
            unselectedLabelColor: isDark ? Colors.white60 : AppColors.textMuted,
            labelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              Tab(text: "Pesanan Mesin PO (${orders.length})"),
              Tab(text: "Custom RFQ Request (${rfqOrders.length})"),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Standard PO Tracking
          orders.isEmpty
              ? _buildEmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: "Belum Ada Pesanan Mesin",
                  message: "Anda belum memiliki transaksi Purchase Order (PO) mesin saat ini.",
                  isDark: isDark,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return _buildPoCard(context, appState, order, isDark);
                  },
                ),

          // Tab 2: Custom RFQ Tracking
          rfqOrders.isEmpty
              ? _buildEmptyState(
                  icon: Icons.settings_suggest_outlined,
                  title: "Belum Ada Pengajuan Custom RFQ",
                  message: "Pengajuan spesifikasi custom mesin Anda akan tampil di sini.",
                  isDark: isDark,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
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

  // ================= 1. PO ORDER CARD =================
  Widget _buildPoCard(
      BuildContext context, AppState appState, OrderModel order, bool isDark) {
    final currentStage = _getTimelineIndex(order.status);
    final totalFormatted = _formatCurrency(order.totalAmount);
    final dpFormatted = _formatCurrency(order.dpAmount);
    final sisaFormatted = _formatCurrency(order.pelunasanAmount);
    final imageUrl = _findProductImage(appState, order.productName);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white10 : AppColors.border,
          width: 1,
        ),
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
          // 1. Header Card (PO Number, Date, Status Badge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.white10 : AppColors.border,
                ),
              ),
            ),
            child: Row(
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
                        size: 16,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.poNumber,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                            color: isDark ? Colors.white : AppColors.primary,
                          ),
                        ),
                        Text(
                          "Tgl Order: ${order.orderDate}",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                OrderStatusBadge(status: order.status),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Info Mesin yang Dipesan
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Machine Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: imageUrl != null
                          ? Image.network(
                              imageUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildPlaceholderImage(isDark),
                            )
                          : _buildPlaceholderImage(isDark),
                    ),
                    const SizedBox(width: 14),

                    // Machine details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              order.category,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order.productName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.5,
                              color: isDark ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Kuantitas: ${order.quantity} Unit  •  ${order.serialNumber}",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                          ),
                          if (order.customNotes.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              "Catatan: ${order.customNotes}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontStyle: FontStyle.italic,
                                color: isDark ? Colors.amber.shade200 : const Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // 3. Estimasi Pengiriman & Lokasi Tujuan
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.white10 : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_shipping_rounded,
                          size: 16,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Estimasi Pengiriman Pabrik:",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  order.estimatedCompletionDate,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2563EB),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Tujuan: ${order.deliveryAddress}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 4. Timeline Produksi 6 Tahap
                _buildProductionTimeline(currentStage, isDark),

                const SizedBox(height: 16),
                Divider(color: isDark ? Colors.white10 : AppColors.border),
                const SizedBox(height: 8),

                // 5. Total Tagihan & Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total Tagihan PO",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                          ),
                        ),
                        Text(
                          totalFormatted,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                        Text(
                          "DP 50%: $dpFormatted  •  Sisa: $sisaFormatted",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9.5,
                            color: isDark ? Colors.white54 : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),

                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetailScreen(order: order),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: order.status == OrderStatus.menungguPelunasan
                            ? AppColors.warning
                            : AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            order.status == OrderStatus.menungguPelunasan
                                ? "Pelunasan 50%"
                                : "Detail Live",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_rounded, size: 14),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= 2. 6-STAGE PRODUCTION TIMELINE =================
  Widget _buildProductionTimeline(int currentStageIndex, bool isDark) {
    final clampedStage = currentStageIndex.clamp(0, 5);
    final activeStageData = _productionStages[clampedStage];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.linear_scale_rounded,
                  size: 15,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 6),
                Text(
                  "TIMELINE PRODUKSI (6 TAHAP)",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            Text(
              "Tahap ${clampedStage + 1} dari 6",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Visual Connected 6-Step Indicator
        Row(
          children: List.generate(6, (index) {
            final isCompleted = index < clampedStage;
            final isCurrent = index == clampedStage;

            Color nodeColor;
            Widget nodeChild;

            if (isCompleted) {
              nodeColor = const Color(0xFF10B981); // Green
              nodeChild = const Icon(Icons.check_rounded, color: Colors.white, size: 11);
            } else if (isCurrent) {
              nodeColor = AppColors.secondary; // Red accent
              nodeChild = Text(
                "${index + 1}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              );
            } else {
              nodeColor = isDark ? Colors.white24 : const Color(0xFFCBD5E1);
              nodeChild = Text(
                "${index + 1}",
                style: TextStyle(
                  color: isDark ? Colors.white60 : const Color(0xFF64748B),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                ),
              );
            }

            return Expanded(
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: nodeColor,
                      shape: BoxShape.circle,
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: AppColors.secondary.withValues(alpha: 0.4),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(child: nodeChild),
                  ),
                  if (index < 5)
                    Expanded(
                      child: Container(
                        height: 3,
                        color: index < clampedStage
                            ? const Color(0xFF10B981)
                            : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),

        const SizedBox(height: 10),

        // Active Stage Card Callout
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.secondary.withValues(alpha: 0.1)
                : const Color(0xFFFFF1F2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                activeStageData['icon'] as IconData,
                size: 16,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tahap ${clampedStage + 1}: ${activeStageData['title']}",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      activeStageData['desc'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        height: 1.3,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage(bool isDark) {
    return Container(
      width: 80,
      height: 80,
      color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
      child: const Center(
        child: Icon(
          Icons.coffee_maker_rounded,
          size: 32,
          color: AppColors.secondary,
        ),
      ),
    );
  }

  // ================= 3. CUSTOM RFQ CARD =================
  Widget _buildRfqCard(BuildContext context, CustomOrderModel rfq, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                rfq.rfqNumber,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDark ? Colors.white : AppColors.primary,
                ),
              ),
              CustomOrderStatusBadge(status: rfq.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            rfq.machineType,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "Target Kapasitas: ${rfq.targetCapacity}  •  Estimasi Budget: ${rfq.budgetRange}",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
          if (rfq.customFeatures.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              "Fitur Custom: ${rfq.customFeatures}",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.amber.shade200 : const Color(0xFFB45309),
              ),
            ),
          ],
          if (rfq.quotationPrice != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.request_quote_rounded, color: Colors.purple, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Surat Penawaran / Quotation Pabrik:",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        Text(
                          rfq.quotationPrice!,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.purple,
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
    );
  }

  // ================= 4. EMPTY STATE =================
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
            Icon(
              icon,
              size: 56,
              color: isDark ? Colors.white24 : AppColors.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 14),
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
