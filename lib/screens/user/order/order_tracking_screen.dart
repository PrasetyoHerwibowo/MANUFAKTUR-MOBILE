import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state.dart';
import '../../../core/models/order_model.dart';
import '../../../core/models/custom_order_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/status_badge.dart';
import '../../../widgets/pdf_preview_dialog.dart';
import '../info/contact_whatsapp_screen.dart';
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

  String? _resolveProductImage(AppState appState, OrderModel order) {
    if (order.imageUrl != null && order.imageUrl!.isNotEmpty) {
      return order.imageUrl;
    }
    final matches = appState.products.where(
      (p) =>
          p.name.toLowerCase().contains(order.productName.toLowerCase()) ||
          order.productName.toLowerCase().contains(p.name.toLowerCase()),
    );
    if (matches.isNotEmpty) return matches.first.imageUrl;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final allOrders = appState.orders;
    final rfqOrders = appState.customOrders;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
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
              Tab(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.precision_manufacturing_outlined, size: 16),
                      const SizedBox(width: 6),
                      Text("Pesanan Mesin (${allOrders.length})"),
                    ],
                  ),
                ),
              ),
              Tab(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.design_services_outlined, size: 16),
                      const SizedBox(width: 6),
                      Text("Custom RFQ (${rfqOrders.length})"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
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
                      // Machine Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: imageUrl != null
                            ? Image.network(
                                imageUrl,
                                width: 84,
                                height: 84,
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
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                order.category.toUpperCase(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9,
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

                // Total Tagihan & Action Button
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
                              color: AppColors.secondary,
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

                    // Hanya tombol Detail Pesanan
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
      child: const Center(
        child: Icon(
          Icons.precision_manufacturing_rounded,
          size: 30,
          color: AppColors.secondary,
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
                  onTap: () => _showRfqDetailSheet(context, rfq, isDark),
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Machine Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildPlaceholderImage(isDark),
                      ),
                      const SizedBox(width: 14),

                      // Machine details (Clean & Tidak Ramai)
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

                // Total Tagihan / Budget & Action Button (Bersih & Lega)
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
                              color: AppColors.secondary,
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

                    // Tombol Detail Custom
                    ElevatedButton(
                      onPressed: () {
                        _showRfqDetailSheet(context, rfq, isDark);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
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

  void _showRfqDetailSheet(
      BuildContext context, CustomOrderModel rfq, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            top: 16,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          rfq.rfqNumber,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        CustomOrderStatusBadge(status: rfq.status),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                Text(
                  "Tanggal Pengajuan: ${rfq.requestDate}",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 14),
                Divider(color: isDark ? Colors.white10 : AppColors.border),
                const SizedBox(height: 12),
                Text(
                  "Mesin Custom yang Diajukan:",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rfq.machineType,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.white10 : AppColors.border,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildDetailItem(
                        icon: Icons.speed_rounded,
                        label: "Target Kapasitas",
                        value: rfq.targetCapacity,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 8),
                      _buildDetailItem(
                        icon: Icons.bolt_rounded,
                        label: "Spesifikasi Listrik",
                        value: rfq.electricalSpecs,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 8),
                      _buildDetailItem(
                        icon: Icons.payments_outlined,
                        label: "Estimasi Budget",
                        value: rfq.budgetRange,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 8),
                      _buildDetailItem(
                        icon: Icons.calendar_today_outlined,
                        label: "Target Pengiriman",
                        value: rfq.targetDeliveryDate,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                if (rfq.customFeatures.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    "Fitur Khusus / Custom:",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.03)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Text(
                      rfq.customFeatures,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        height: 1.4,
                        color: isDark ? Colors.white70 : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
                if (rfq.attachmentFileName != null &&
                    rfq.attachmentFileName!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.02)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.attach_file_rounded,
                            size: 16, color: Color(0xFF64748B)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Blueprint: ${rfq.attachmentFileName!}",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.02)
                        : const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: isDark ? Colors.white10 : AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.business_rounded,
                              size: 15, color: Color(0xFF64748B)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              rfq.companyName,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.person_outline_rounded,
                              size: 15, color: Color(0xFF64748B)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "${rfq.contactPerson}  •  ${rfq.phone}",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (rfq.quotationPrice != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.white12 : const Color(0xFFCBD5E1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Surat Penawaran Resmi Pabrik:",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    rfq.quotationPrice!,
                                    style: GoogleFonts.outfit(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.secondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => PdfPreviewModal(
                                    title: "Surat Penawaran Resmi (Quotation)",
                                    subtitle: rfq.rfqNumber,
                                    pdfType: "QUOTATION",
                                    data: {
                                      'rfqNumber': rfq.rfqNumber,
                                      'company': rfq.companyName,
                                      'productName': rfq.machineType,
                                      'total': rfq.quotationPrice,
                                    },
                                  ),
                                );
                              },
                              icon: const Icon(Icons.picture_as_pdf_outlined,
                                  size: 14),
                              label: const Text("Lihat PDF"),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (rfq.quotationNotes != null &&
                            rfq.quotationNotes!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            "Catatan: ${rfq.quotationNotes!}",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ContactWhatsappScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.support_agent_rounded, size: 18),
                    label: const Text("KONSULTASI TIM TEKNIK"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ],
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
