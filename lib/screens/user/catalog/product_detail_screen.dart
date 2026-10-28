import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/models/product_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/app_state.dart';
import '../../../widgets/pdf_preview_dialog.dart';
import '../../../widgets/video_player_mock.dart';
import '../order/po_form_screen.dart';
import '../order/rfq_custom_order_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedModelIndex = 0;
  bool _isSaved = false;

  String _formatCurrency(double amount) {
    return "Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final p = widget.product;
    final hasModels = p.capacityModels.isNotEmpty;
    final selectedModel = hasModels ? p.capacityModels[_selectedModelIndex] : null;
    final activePrice = selectedModel != null ? selectedModel.price : p.price;
    final formattedPrice = _formatCurrency(activePrice);

    final activeSpec = selectedModel != null
        ? TechnicalSpec(
            tipe: p.specifications.tipe,
            kapasitas: selectedModel.capacity,
            sumberListrik: p.specifications.sumberListrik,
            dayaListrik: selectedModel.power,
            dimensi: p.specifications.dimensi,
            berat: p.specifications.berat,
            materialBoiler: p.specifications.materialBoiler,
            kapasitasBoiler: p.specifications.kapasitasBoiler,
          )
        : p.specifications;

    final brandColor = p.commodity == 'Kakao'
        ? AppColors.brandCocoa
        : (p.commodity == 'Roaster Kopi' ? const Color(0xFFDC2626) : AppColors.brandCoffee);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Clean SliverAppBar for Hero Image
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: isDark ? Colors.black54 : Colors.white.withValues(alpha: 0.9),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CircleAvatar(
                  backgroundColor: isDark ? Colors.black54 : Colors.white.withValues(alpha: 0.9),
                  child: IconButton(
                    icon: Icon(
                      _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      color: _isSaved ? AppColors.secondary : (isDark ? Colors.white : AppColors.textPrimary),
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _isSaved = !_isSaved;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _isSaved
                                ? "Mesin disimpan ke daftar simpanan."
                                : "Mesin dihapus dari daftar simpanan.",
                          ),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: CircleAvatar(
                  backgroundColor: isDark ? Colors.black54 : Colors.white.withValues(alpha: 0.9),
                  child: IconButton(
                    icon: Icon(
                      Icons.share_outlined,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      size: 19,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Tautan spesifikasi ${p.name} disalin."),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                child: Image.network(
                  p.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Icon(
                      Icons.precision_manufacturing_rounded,
                      color: isDark ? Colors.white24 : Colors.black26,
                      size: 72,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. Clean, Linear Content Flow (Zero Redundancy)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // A. Category & Pre-Order Status Row
                  Row(
                    children: [
                      Text(
                        p.category.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: brandColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? Colors.white30 : const Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        p.stockStatus,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // B. Machine Name (Clean, Bold, Crisp)
                  Text(
                    p.name,
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // C. Price & Essential Terms (Responsive Wrap, Zero Overflow)
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        formattedPrice,
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: brandColor,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "Termin DP 50% • Sistem PO",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextSecondary : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        size: 14,
                        color: Color(0xFF059669),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          "Garansi Resmi 2 Tahun PT MDI",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF059669),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 16),
                          const SizedBox(width: 3),
                          Text(
                            "${p.rating.toStringAsFixed(1)} (${p.reviewsCount})",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white70 : const Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // D. Capacity Model Selector (Only if product has variant models)
                  if (hasModels) ...[
                    const SizedBox(height: 18),
                    Text(
                      "Pilihan Model Kapasitas",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white70 : const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(p.capacityModels.length, (idx) {
                        final model = p.capacityModels[idx];
                        final isSelected = _selectedModelIndex == idx;
                        return ChoiceChip(
                          label: Text(
                            "${model.shortLabel} (${_formatCurrency(model.price)})",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.white70 : const Color(0xFF334155)),
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: brandColor,
                          backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          side: BorderSide(
                            color: isSelected
                                ? brandColor
                                : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onSelected: (_) {
                            setState(() {
                              _selectedModelIndex = idx;
                            });
                          },
                        );
                      }),
                    ),
                  ],

                  const SizedBox(height: 18),
                  Divider(
                    height: 1,
                    color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                  ),
                  const SizedBox(height: 18),

                  // E. Description Section
                  Text(
                    "Deskripsi Mesin",
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    p.description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 18),
                  Divider(
                    height: 1,
                    color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                  ),
                  const SizedBox(height: 18),

                  // F. Single Authoritative Technical Specifications Table (Zero Redundancy!)
                  Text(
                    "Spesifikasi Teknis",
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildCleanSpecsTable(activeSpec, isDark),

                  const SizedBox(height: 18),
                  Divider(
                    height: 1,
                    color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                  ),
                  const SizedBox(height: 18),

                  // G. Documents & Video Review (Clean, Linear Links - As Requested!)
                  Text(
                    "Dokumen & Media",
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Manual Book Tile
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => PdfPreviewModal(
                          title: "Manual Book Teknis",
                          subtitle: p.name,
                          pdfType: "MANUAL_BOOK",
                          data: {
                            'productName': p.name,
                            'productId': p.id,
                            'capacity': activeSpec.kapasitas,
                            'power': activeSpec.dayaListrik,
                          },
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF131A26) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.picture_as_pdf_rounded,
                            size: 20,
                            color: Color(0xFFDC2626),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.manualBookPdfName,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Buku Manual & Panduan Perawatan (PDF)",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: Color(0xFF94A3B8),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Video Demo Tile
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => VideoPlayerModal(
                          videoTitle: p.videoReviewTitle,
                          duration: p.videoReviewDuration,
                          imageUrl: p.imageUrl,
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF131A26) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.play_circle_fill_rounded,
                            size: 20,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.videoReviewTitle,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Video Uji Operasional (${p.videoReviewDuration})",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: Color(0xFF94A3B8),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),

      // 3. Fixed Bottom Action Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                // Custom Order / RFQ
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      final activeProduct = hasModels
                          ? ProductModel(
                              id: p.id,
                              name: "${p.name} (${selectedModel!.shortLabel})",
                              category: p.category,
                              commodity: p.commodity,
                              processStage: p.processStage,
                              machineType: p.machineType,
                              modelName: selectedModel.modelName,
                              capacityScale: selectedModel.scale,
                              capacityModels: p.capacityModels,
                              price: selectedModel.price,
                              rating: p.rating,
                              reviewsCount: p.reviewsCount,
                              imageUrl: p.imageUrl,
                              description: p.description,
                              specifications: activeSpec,
                              manualBookPdfName: p.manualBookPdfName,
                              videoReviewTitle: p.videoReviewTitle,
                              videoReviewDuration: p.videoReviewDuration,
                              stockStatus: p.stockStatus,
                            )
                          : p;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RfqCustomOrderScreen(baseProduct: activeProduct),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      side: BorderSide(
                        color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Custom",
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: isDark ? Colors.white : AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Form PO Standar Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final activeProduct = hasModels
                          ? ProductModel(
                              id: p.id,
                              name: "${p.name} (${selectedModel!.shortLabel})",
                              category: p.category,
                              commodity: p.commodity,
                              processStage: p.processStage,
                              machineType: p.machineType,
                              modelName: selectedModel.modelName,
                              capacityScale: selectedModel.scale,
                              capacityModels: p.capacityModels,
                              price: selectedModel.price,
                              rating: p.rating,
                              reviewsCount: p.reviewsCount,
                              imageUrl: p.imageUrl,
                              description: p.description,
                              specifications: activeSpec,
                              manualBookPdfName: p.manualBookPdfName,
                              videoReviewTitle: p.videoReviewTitle,
                              videoReviewDuration: p.videoReviewDuration,
                              stockStatus: p.stockStatus,
                            )
                          : p;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PoFormScreen(product: activeProduct),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "Pesan",
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                        color: Colors.white,
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

  // ================= CLEAN SPECIFICATIONS TABLE (ZERO DUPLICATION) =================
  Widget _buildCleanSpecsTable(TechnicalSpec spec, bool isDark) {
    final rawItems = [
      {'label': 'Tipe Mesin', 'val': spec.tipe},
      {'label': 'Kapasitas Produksi', 'val': spec.kapasitas},
      {'label': 'Konsumsi Daya', 'val': spec.dayaListrik},
      {'label': 'Sumber Listrik / Penggerak', 'val': spec.sumberListrik},
      {'label': 'Dimensi (P x L x T)', 'val': spec.dimensi},
      {'label': 'Bobot Mesin', 'val': spec.berat},
      {'label': 'Material Kontak Produk', 'val': spec.materialBoiler},
      {'label': 'Kapasitas Hopper / Wadah', 'val': spec.kapasitasBoiler},
    ];

    // Omit '-' or empty values so irrelevant attributes never clutter the table
    final items = rawItems.where((i) {
      final v = (i['val'] ?? '').trim();
      return v.isNotEmpty && v != '-';
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131A26) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: List.generate(items.length, (idx) {
          final it = items[idx];
          final isLast = idx == items.length - 1;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(
                      bottom: BorderSide(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : const Color(0xFFEDF2F7),
                      ),
                    ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    it['label']!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 5,
                  child: Text(
                    it['val']!,
                    textAlign: TextAlign.end,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
