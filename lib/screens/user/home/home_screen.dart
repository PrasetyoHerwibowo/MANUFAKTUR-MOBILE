import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../providers/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/product_model.dart';
import '../catalog/product_detail_screen.dart';
import '../order/rfq_custom_order_screen.dart';
import '../info/contact_whatsapp_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToCatalog;

  const HomeScreen({super.key, this.onNavigateToCatalog});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _catalogSectionKey = GlobalKey();

  final List<Map<String, dynamic>> _commodities = [
    {
      'id': 'Semua',
      'title': 'Semua Mesin',
      'icon': Icons.apps_rounded,
    },
    {
      'id': 'Kopi',
      'title': 'Mesin Kopi',
      'icon': Icons.coffee_rounded,
    },
    {
      'id': 'Kakao',
      'title': 'Mesin Kakao',
      'icon': Icons.spa_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  void _scrollToCatalog() {
    if (_catalogSectionKey.currentContext != null) {
      Scrollable.ensureVisible(
        _catalogSectionKey.currentContext!,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }



  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final filteredProducts = appState.filteredProducts;

    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          // 1. Industrial Hero Showcase Banner (Align with Web)
          _buildHeroShowcase(context, isDark),

          const SizedBox(height: 14),

          // 2. Category Selector (Horizontal Pills)
          _buildCategorySelector(appState, isDark),

          const SizedBox(height: 16),

          // 4. Section Header: Title & Count
          _buildSectionHeader(context, appState, isDark, filteredProducts.length),

          const SizedBox(height: 10),

          // 5. Product Display (Clean 2-Column Grid View)
          if (filteredProducts.isEmpty)
            _buildEmptyState(appState, isDark)
          else
            _buildProductGrid(context, appState, isDark, filteredProducts),

          const SizedBox(height: 20),

          // 6. WhatsApp Engineering Consultation Banner (Soft Mint Tone)
          _buildConsultationBanner(context, isDark),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ================= 1. COMMODITY SELECTOR (3 KATEGORI UTAMA) =================
  Widget _buildCategorySelector(AppState appState, bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _commodities.map((item) {
          final id = item['id']?.toString() ?? 'Semua';
          final label = item['title'].toString();
          final isSelected = appState.selectedCommodity == item['id'];
          final isCoffee = id == 'Kopi';
          final isCocoa = id == 'Kakao';

          Color activeBg;
          Color activeBorder;
          Color activeColor;

          if (isCoffee) {
            activeBg = isDark ? const Color(0xFF382314) : const Color(0xFFFEF3C7);
            activeBorder = AppColors.brandCoffee;
            activeColor = AppColors.brandCoffee;
          } else if (isCocoa) {
            activeBg = isDark ? const Color(0xFF2C1608) : const Color(0xFFFFEDD5);
            activeBorder = AppColors.brandCocoa;
            activeColor = AppColors.brandCocoa;
          } else {
            activeBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
            activeBorder = AppColors.secondary;
            activeColor = AppColors.secondary;
          }

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  appState.setCommodityFilter(id);
                  appState.setProcessStageFilter('Semua');
                },
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? activeBg
                        : (isDark ? const Color(0xFF141C28) : Colors.white),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? activeBorder
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : const Color(0xFFE2E8F0)),
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: activeBorder.withValues(alpha: 0.22),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.03),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        (item['icon'] as IconData?) ?? Icons.category_rounded,
                        size: 18,
                        color: isSelected
                            ? activeColor
                            : (isDark ? Colors.white70 : AppColors.textSecondary),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        label,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected
                              ? activeColor
                              : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(duration: 250.ms);
  }

  // ================= 1. INDUSTRIAL HERO SHOWCASE (WEB ALIGNED) =================
  Widget _buildHeroShowcase(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.14),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // 1. Factory Machinery Background (Exact Web Image with 100% Monochrome Grayscale)
              Positioned.fill(
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.grey,
                    BlendMode.saturation, // 100% Grayscale (Identik filter: grayscale(100%) web)
                  ),
                  child: Image.asset(
                    'assets/images/GambarBG.jpg',
                    fit: BoxFit.cover,
                    opacity: const AlwaysStoppedAnimation(0.55), // Identik opacity 0.65 web
                    errorBuilder: (context, error, stackTrace) => Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF18181B), Color(0xFF09090B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 2. High-Contrast Monokrom Vignette Gradient (Identik .hero-bg::after web)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.55),
                        const Color(0xFF09090B).withValues(alpha: 0.65),
                        Colors.black.withValues(alpha: 0.90),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // 3. Subtle Mechanical Watermark Icon (Precision Machinery)
              Positioned(
                right: -14,
                bottom: -18,
                child: Icon(
                  Icons.precision_manufacturing_rounded,
                  size: 130,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),

              // 4. Hero Content (Headline, Subtitle, & Actions)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Web Headline: WE BUILD THE FUTURE OF MACHINERY
                    Text(
                      "WE BUILD\nTHE FUTURE OF MACHINERY",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.8,
                        height: 1.15,
                      ),
                    ),

                    const SizedBox(height: 7),

                    // Web Mobile Subtitle
                    Text(
                      "Manufaktur mesin pengolahan kakao dan kopi presisi dengan standar mutu food grade dan efisiensi energi tinggi.",
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.82),
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Action Pill Buttons Row (Zero Duplication with Categories!)
                    Row(
                      children: [
                        // Button 1: Inverted White Pill "Jelajahi Produk"
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _scrollToCatalog,
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 8.5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.settings_suggest_rounded,
                                    size: 14,
                                    color: Color(0xFF09090B),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    "Jelajahi Produk",
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFF09090B), // Zinc 950
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Button 2: Glassmorphism Outline Pill "Konsultasi RFQ"
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const RfqCustomOrderScreen(),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8.5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.28),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Konsultasi RFQ",
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 13,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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

  // ================= 4. SECTION HEADER =================
  Widget _buildSectionHeader(
      BuildContext context, AppState appState, bool isDark, int count) {
    String headerTitle = "Katalog Seluruh Mesin";
    if (appState.searchQuery.isNotEmpty) {
      headerTitle = 'Pencarian: "${appState.searchQuery}"';
    } else if (appState.selectedCommodity == 'Kopi') {
      headerTitle = "Katalog Mesin Kopi";
    } else if (appState.selectedCommodity == 'Kakao') {
      headerTitle = "Katalog Mesin Kakao";
    }

    return Padding(
      key: _catalogSectionKey,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            headerTitle,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          Text(
            "$count Produk",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  // ================= 5. 2-COLUMN PRODUCT GRID =================
  Widget _buildProductGrid(
      BuildContext context, AppState appState, bool isDark, List<ProductModel> products) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 14,
          childAspectRatio: 0.65,
        ),
        itemBuilder: (context, index) {
          final product = products[index];
          return _buildProductCard(context, product, isDark);
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel product, bool isDark) {
    final isCoffee = product.commodity == 'Kopi';
    final hasMultipleModels = isCoffee && product.capacityModels.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Clean Machine Image (No cluttering micro-badge!)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: AspectRatio(
                aspectRatio: 1.25,
                child: Image.network(
                  product.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                    child: Center(
                      child: Icon(
                        isCoffee ? Icons.coffee_rounded : Icons.spa_rounded,
                        color: isCoffee ? AppColors.brandCoffee : AppColors.brandCocoa,
                        size: 34,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Card Body Content (Clean & Focused)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Machine Name
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            height: 1.25,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Capacity / Multi-Model Indicator
                        if (hasMultipleModels)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.brandCoffeeDark.withValues(alpha: 0.4)
                                  : const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.brandCoffee.withValues(alpha: 0.3)
                                    : const Color(0xFFFDE68A),
                                width: 0.6,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.layers_rounded,
                                  size: 10,
                                  color: AppColors.brandCoffee,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    "${product.capacityModels.length} Model Kapasitas",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkSurface
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: isDark ? Colors.white10 : AppColors.border,
                                width: 0.6,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.speed_rounded,
                                  size: 10,
                                  color: isDark ? Colors.white60 : AppColors.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    product.specifications.kapasitas,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    // Price & Action Button Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                hasMultipleModels ? "Mulai dari" : "Harga PO",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                                ),
                              ),
                              Text(
                                _formatPrice(hasMultipleModels
                                    ? product.capacityModels.first.price
                                    : product.price),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: isCoffee
                                ? AppColors.brandCoffee
                                : AppColors.secondary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= 5B. EMPTY STATE =================
  Widget _buildEmptyState(AppState appState, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : AppColors.border,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 44,
              color: AppColors.textMuted.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 10),
            Text(
              "Tidak Ada Mesin yang Cocok",
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Coba ubah kata kunci pencarian atau sesuaikan filter kategori.",
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: () {
                appState.resetFilters();
              },
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text("Reset Filter & Tampilkan Semua", style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= 6. CONSULTATION BANNER =================
  Widget _buildConsultationBanner(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF064E3B).withValues(alpha: 0.25)
              : const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF059669) : const Color(0xFF86EFAC),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: Color(0xFF059669),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Konsultasi Engineer Pabrik",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
                    ),
                  ),
                  Text(
                    "Tanya spesifikasi, skema listrik & layout bar gratis.",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      color: isDark ? const Color(0xFFA7F3D0) : const Color(0xFF047857),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFF059669),
                size: 14,
              ),
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
      ),
    );
  }
}
