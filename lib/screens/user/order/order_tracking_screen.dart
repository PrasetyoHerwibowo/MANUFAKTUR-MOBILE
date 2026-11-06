import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state.dart';
import '../../../core/models/order_model.dart';
import '../../../core/models/custom_order_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/status_badge.dart';
import 'order_detail_screen.dart';
import 'rfq_detail_screen.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && _tabController.index != _currentTab) {
        setState(() {
          _currentTab = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    return "Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  String _resolveProductImage(AppState appState, OrderModel order) {
    if (order.imageUrl != null && order.imageUrl!.isNotEmpty) {
      return order.imageUrl!;
    }
    final nameLower = order.productName.toLowerCase();
    final catLower = order.category.toLowerCase();
    final matches = appState.products.where(
      (p) =>
          p.name.toLowerCase().contains(nameLower) ||
          nameLower.contains(p.name.toLowerCase()),
    );
    if (matches.isNotEmpty && matches.first.imageUrl.isNotEmpty) {
      return matches.first.imageUrl;
    }

    if (nameLower.contains('espresso') || catLower.contains('espresso')) {
      return 'https://images.unsplash.com/photo-1517256064527-09c73fc73e38?w=800&auto=format&fit=crop&q=80';
    } else if (nameLower.contains('roast') || catLower.contains('roast')) {
      return 'https://images.unsplash.com/photo-1518832553480-cd0e625ed3e6?w=800&auto=format&fit=crop&q=80';
    } else if (nameLower.contains('grind') || catLower.contains('grind')) {
      return 'https://images.unsplash.com/photo-1589396575653-c09c794ff6a6?w=800&auto=format&fit=crop&q=80';
    } else if (nameLower.contains('pulper') || catLower.contains('pulper') || nameLower.contains('pengolahan')) {
      return 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=800&auto=format&fit=crop&q=80';
    }
    return 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=800&auto=format&fit=crop&q=80';
  }

  String _resolveRfqImage(CustomOrderModel rfq) {
    if (rfq.imageUrl != null && rfq.imageUrl!.isNotEmpty) {
      return rfq.imageUrl!;
    }
    final typeLower = rfq.machineType.toLowerCase();
    if (typeLower.contains('espresso')) {
      return 'https://images.unsplash.com/photo-1517256064527-09c73fc73e38?w=800&auto=format&fit=crop&q=80';
    } else if (typeLower.contains('roast')) {
      return 'https://images.unsplash.com/photo-1518832553480-cd0e625ed3e6?w=800&auto=format&fit=crop&q=80';
    } else if (typeLower.contains('grind')) {
      return 'https://images.unsplash.com/photo-1589396575653-c09c794ff6a6?w=800&auto=format&fit=crop&q=80';
    }
    return 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=800&auto=format&fit=crop&q=80';
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final allOrders = appState.orders;
    final rfqOrders = appState.customOrders;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Modern Segmented Capsule Switcher matching Home and Servis design system
            _buildTopSegmentedTabs(appState, isDark),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // TAB 1: Standar PO Orders
                  allOrders.isEmpty
                      ? _buildEmptyState(
                          icon: Icons.inventory_2_outlined,
                          title: "Belum Ada Pesanan Mesin",
                          message: "Anda belum memiliki transaksi Purchase Order (PO) mesin saat ini.",
                          isDark: isDark,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                          physics: const BouncingScrollPhysics(),
                          itemCount: allOrders.length,
                          itemBuilder: (context, index) {
                            final order = allOrders[index];
                            return _buildPoCard(context, appState, order, isDark);
                          },
                        ),

                  // TAB 2: Custom RFQ Orders
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
            ),
          ],
        ),
      ),
    );
  }

  /// Modern Segmented Capsule Switcher (Smooth, Gentle on Eyes, matching BookingServiceScreen)
  Widget _buildTopSegmentedTabs(AppState appState, bool isDark) {
    final allOrders = appState.orders;
    final rfqOrders = appState.customOrders;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: Container(
        height: 42,
        padding: const EdgeInsets.all(3.5),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildTopTabButton(
                index: 0,
                icon: Icons.precision_manufacturing_outlined,
                activeIcon: Icons.precision_manufacturing_rounded,
                label: "Pesanan Mesin (${allOrders.length})",
                isDark: isDark,
              ),
            ),
            Expanded(
              child: _buildTopTabButton(
                index: 1,
                icon: Icons.design_services_outlined,
                activeIcon: Icons.design_services_rounded,
                label: "Custom RFQ (${rfqOrders.length})",
                isDark: isDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopTabButton({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isDark,
  }) {
    final isSelected = _currentTab == index;
    final activeBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final activeFg = isDark ? Colors.white : const Color(0xFF0F172A);
    final inactiveFg = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentTab = index;
          _tabController.animateTo(index);
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1.5),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 15,
              color: isSelected ? activeFg : inactiveFg,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? activeFg : inactiveFg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= 1. PO ORDER CARD =================
  Widget _buildPoCard(
      BuildContext context, AppState appState, OrderModel order, bool isDark) {
    final totalFormatted = _formatCurrency(order.totalAmount);
    final dpFormatted = _formatCurrency(order.dpAmount);
    final sisaFormatted = _formatCurrency(order.pelunasanAmount);
    final imageUrl = _resolveProductImage(appState, order);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white12 : AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card (HANYA PO Number & Date - Status Badge Dihapus dari Semua Pesanan)
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
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.description_rounded,
                    size: 16,
                    color: isDark ? Colors.white70 : const Color(0xFF475569),
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
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Mesin yang Dipesan
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailScreen(order: order),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Machine Thumbnail (Menampilkan Foto Mesin Nyata seperti sebelumnya)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl,
                          width: 84,
                          height: 84,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholderImage(isDark),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Machine details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                                  width: 0.6,
                                ),
                              ),
                              child: Text(
                                order.category.toUpperCase(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
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
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white10 : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    "${order.quantity} Unit",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white70 : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    order.serialNumber,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10.5,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            if (order.customNotes.isNotEmpty) ...[
                              const SizedBox(height: 5),
                              Text(
                                "Catatan: ${order.customNotes}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
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
                ),

                const SizedBox(height: 14),

                // Estimasi Pengiriman & Lokasi Tujuan
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.white10 : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_shipping_rounded,
                          size: 15,
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
                                  "Target Pengiriman:",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  order.estimatedCompletionDate,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
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
                                fontSize: 10,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),
                Divider(color: isDark ? Colors.white10 : AppColors.border),
                const SizedBox(height: 8),

                // Total Tagihan & Action Button (Mengikuti Tema Home & Servis)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Total Tagihan PO",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            totalFormatted,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Wrap(
                            spacing: 6,
                            runSpacing: 2,
                            children: [
                              Text(
                                "DP 50%: $dpFormatted",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9.5,
                                  color: isDark ? Colors.white54 : AppColors.textMuted,
                                ),
                              ),
                              Text(
                                "Sisa: $sisaFormatted",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9.5,
                                  color: isDark ? Colors.white54 : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Tombol Detail Pesanan (Kontras tinggi di dark mode agar tidak menyatu)
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
                            : (isDark ? Colors.white : const Color(0xFF0F172A)),
                        foregroundColor: order.status == OrderStatus.menungguPelunasan
                            ? Colors.white
                            : (isDark ? const Color(0xFF0F172A) : Colors.white),
                        elevation: isDark ? 2 : 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            order.status == OrderStatus.menungguPelunasan
                                ? "Pelunasan"
                                : "Detail Pesanan",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
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

  Widget _buildPlaceholderImage(bool isDark) {
    return Container(
      width: 76,
      height: 76,
      color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
      child: Center(
        child: Icon(
          Icons.precision_manufacturing_rounded,
          size: 30,
          color: isDark ? Colors.white70 : const Color(0xFF475569),
        ),
      ),
    );
  }

  // ================= 2. CUSTOM RFQ CARD =================
  Widget _buildRfqCard(BuildContext context, CustomOrderModel rfq, bool isDark) {
    final displayPrice = rfq.quotationPrice ?? rfq.budgetRange;
    final priceLabel =
        rfq.quotationPrice != null ? "Penawaran Resmi Pabrik" : "Estimasi Budget";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white12 : AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card (Icon, RFQ Number, Tgl Pengajuan & Status Badge - Bebas Overflow)
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
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.description_rounded,
                          size: 16,
                          color: isDark ? Colors.white70 : const Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rfq.rfqNumber,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.5,
                                color: isDark ? Colors.white : AppColors.primary,
                              ),
                            ),
                            Text(
                              rfq.requestDate,
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
                const SizedBox(width: 8),
                CustomOrderStatusBadge(status: rfq.status),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Mesin yang Dipesan
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RfqDetailScreen(rfq: rfq),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Machine Thumbnail (Menampilkan Foto Mesin Nyata seperti sebelumnya)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _resolveRfqImage(rfq),
                          width: 84,
                          height: 84,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholderImage(isDark),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Machine details (Clean & Sesuai Desain Home/Servis)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rfq.machineType,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.5,
                                color: isDark ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Kapasitas: ${rfq.targetCapacity}",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (rfq.customFeatures.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                "Catatan: ${rfq.customFeatures}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontStyle: FontStyle.italic,
                                  color: isDark
                                      ? Colors.amber.shade200
                                      : const Color(0xFFB45309),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Estimasi Pengiriman & Pemesan
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.white10 : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_shipping_rounded,
                          size: 15,
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
                                  "Target Pengiriman:",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  rfq.targetDeliveryDate,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2563EB),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Pemesan: ${rfq.companyName}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),
                Divider(color: isDark ? Colors.white10 : AppColors.border),
                const SizedBox(height: 8),

                // Total Tagihan / Budget & Action Button (Sesuai Tema Home & Servis)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            priceLabel,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            displayPrice,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            rfq.quotationPrice != null
                                ? "Penawaran pabrik tersedia"
                                : "Listrik: ${rfq.electricalSpecs}",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              color: isDark ? Colors.white54 : AppColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Tombol Detail Custom (Kontras tinggi di dark mode agar tidak menyatu)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RfqDetailScreen(rfq: rfq),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
                        foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                        elevation: isDark ? 2 : 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Detail Custom",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
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
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: isDark ? Colors.white30 : AppColors.textMuted.withValues(alpha: 0.5),
              ),
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
