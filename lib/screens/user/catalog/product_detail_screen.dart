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
                  // A. Category Pill & Stock Status Row (Web Aligned)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.surfaceVariant, // Zinc 100
                          borderRadius: BorderRadius.circular(999), // Web Pill Shape
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.border,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          p.category.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.border,
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF10B981), // Emerald active dot
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              p.stockStatus,
                              style: GoogleFonts.inter(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // B. Machine Name (Plus Jakarta Sans Extra Bold)
                  Text(
                    p.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      letterSpacing: -0.4,
                      height: 1.25,
                    ),
                  ),

                  // C. Official Model Code (Web .card-model)
                  if (p.modelCodeDisplay.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      "KODE MODEL: ${p.modelCodeDisplay}",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // D. Price & PO Terms (Zinc Monochrome Aligned)
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    runSpacing: 6,
                    children: [
                      Text(
                        formattedPrice,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.border,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          "Termin DP 50% • Sistem PO",
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // E. Official Warranty Row
                  Row(
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        size: 14,
                        color: Color(0xFF10B981),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "Garansi Resmi 2 Tahun PT MDI",
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),

                  // F. Official Function Box (Web Aligned: "FUNGSI MESIN")
                  if (p.functionPreview.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.surfaceVariant, // Zinc 100
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.border,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.settings_suggest_rounded,
                                size: 15,
                                color: isDark ? Colors.white70 : AppColors.textMuted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "FUNGSI MESIN",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          Text(
                            p.functionPreview,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              height: 1.55,
                              color: isDark ? const Color(0xFFD4D4D8) : const Color(0xFF3F3F46),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // G. Capacity Model Selector (Zinc Monochrome Pills)
                  if (hasModels) ...[
                    const SizedBox(height: 18),
                    Text(
                      "Pilihan Model Kapasitas",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: isDark ? Colors.white : AppColors.textPrimary,
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
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected
                                  ? (isDark ? AppColors.primary : Colors.white)
                                  : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: isDark ? Colors.white : AppColors.primary,
                          backgroundColor: isDark ? AppColors.darkSurface : AppColors.surfaceVariant,
                          side: BorderSide(
                            color: isSelected
                                ? (isDark ? Colors.white : AppColors.primary)
                                : (isDark ? AppColors.darkBorder : AppColors.border),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999), // Pill shape
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

                  // H. Technical Specifications Section (Web Aligned)
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Icon(
                        Icons.fact_check_outlined,
                        size: 16,
                        color: isDark ? Colors.white70 : AppColors.textPrimary,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        "Spesifikasi Teknis",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildCleanSpecsTable(activeSpec, isDark),

                  // I. Description & Advantages Section (Web Aligned)
                  if (p.description.isNotEmpty) ...[
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 16,
                          color: isDark ? Colors.white70 : AppColors.textPrimary,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          "Deskripsi & Keunggulan",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.border,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        p.description,
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          height: 1.6,
                          color: isDark ? const Color(0xFFD4D4D8) : const Color(0xFF3F3F46),
                        ),
                      ),
                    ),
                  ],

                  // J. Documentation & Review (Brosur PDF & Video Demo)
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      // PDF Brochure Button
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => PdfPreviewModal(
                                  title: "Brosur & Manual Book",
                                  subtitle: p.name,
                                  pdfType: "MANUAL_BOOK",
                                  data: {
                                    'productName': p.name,
                                    'modelCode': p.modelCodeDisplay,
                                    'capacity': activeSpec.kapasitas,
                                  },
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSurface : AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: isDark ? AppColors.darkBorder : AppColors.border,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.picture_as_pdf_outlined, size: 16, color: Color(0xFFEF4444)),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      "Brosur PDF",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? Colors.white : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Video Demo Button
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
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
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSurface : AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: isDark ? AppColors.darkBorder : AppColors.border,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.play_circle_outline_rounded,
                                    size: 16,
                                    color: isDark ? Colors.white : AppColors.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      "Video Demo",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? Colors.white : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),

      // 3. Fixed Bottom Action Bar (Zinc Monochrome Inverted Pill CTA)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                // Custom Order / RFQ (Outlined Pill)
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
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999), // Pill Shape
                      ),
                    ),
                    child: Text(
                      "Konsultasi RFQ",
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Form PO Standar Button (Solid Zinc 950 Inverted Pill)
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
                      backgroundColor: isDark ? Colors.white : AppColors.primary, // Zinc 950
                      foregroundColor: isDark ? AppColors.primary : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999), // Pill Shape
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "Pesan Mesin (PO)",
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                        letterSpacing: -0.2,
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
      {'label': 'Kapasitas Wadah / Hopper', 'val': spec.kapasitasBoiler},
    ];

    // Omit '-' or empty values so irrelevant attributes never clutter the table
    final items = rawItems.where((i) {
      final v = (i['val'] ?? '').trim();
      return v.isNotEmpty && v != '-';
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surfaceVariant, // Zinc 100
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        children: List.generate(items.length, (idx) {
          final it = items[idx];
          final isLast = idx == items.length - 1;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(
                      bottom: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.border.withValues(alpha: 0.6),
                        width: 0.8,
                      ),
                    ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    it['label']!,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
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
                      color: isDark ? Colors.white : AppColors.textPrimary,
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

