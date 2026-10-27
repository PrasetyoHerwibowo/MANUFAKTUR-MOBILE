import 'dart:async';
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
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;

  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'Semua',
      'label': 'Semua',
      'icon': Icons.grid_view_rounded,
    },
    {
      'id': 'Commercial Espresso',
      'label': 'Espresso',
      'icon': Icons.coffee_maker_rounded,
    },
    {
      'id': 'Coffee Roaster',
      'label': 'Roaster',
      'icon': Icons.local_fire_department_rounded,
    },
    {
      'id': 'Grinder',
      'label': 'Grinder',
      'icon': Icons.tune_rounded,
    },
    {
      'id': 'Water Treatment',
      'label': 'Water',
      'icon': Icons.water_drop_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startBannerTimer();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_bannerController.hasClients) {
        final nextIndex = (_currentBannerIndex + 1) % 3;
        _bannerController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Commercial Espresso':
        return Icons.coffee_maker_rounded;
      case 'Coffee Roaster':
        return Icons.local_fire_department_rounded;
      case 'Grinder':
        return Icons.tune_rounded;
      case 'Water Treatment':
        return Icons.water_drop_rounded;
      default:
        return Icons.precision_manufacturing_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final filteredProducts = appState.filteredProducts;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),

          // 1. Interactive Category Card Row (Unified compact tiles evenly distributed across full width)
          _buildCategorySelector(appState, isDark),

          const SizedBox(height: 10),

          // 2. Promotional Banner Carousel (PageView with Animated Indicator)
          _buildBannerCarousel(context, isDark),

          const SizedBox(height: 10),

          // 3. Trust Badges / Value Propositions (Like Reference 3-Pill Strip)
          _buildTrustBadges(isDark),

          const SizedBox(height: 16),

          // 4. Section Header: Title & "Lihat Semua"
          _buildSectionHeader(context, appState, isDark, filteredProducts.length),

          const SizedBox(height: 10),

          // 5. 2-Column Product Grid (Clean, Eye-Friendly, Non-Straining)
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

  // ================= 1. CATEGORY SELECTOR =================
  Widget _buildCategorySelector(AppState appState, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _categories.map((cat) {
          final isSelected = appState.selectedCategory == cat['id'];
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.5),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    appState.setCategoryFilter(cat['id'] as String);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark
                              ? const Color(0xFF2E1215)
                              : const Color(0xFFFEF2F2))
                          : (isDark
                              ? const Color(0xFF141C28)
                              : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.secondary
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : const Color(0xFFE2E8F0)),
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.secondary.withValues(alpha: 0.22),
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          cat['icon'] as IconData,
                          size: 20,
                          color: isSelected
                              ? AppColors.secondary
                              : (isDark ? Colors.white70 : AppColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            cat['label'] as String,
                            maxLines: 1,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: isSelected
                                  ? AppColors.secondary
                                  : (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(duration: 250.ms);
  }

  // ================= 2. BANNER CAROUSEL =================
  Widget _buildBannerCarousel(BuildContext context, bool isDark) {
    return Column(
      children: [
        SizedBox(
          height: 154,
          child: PageView(
            controller: _bannerController,
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            children: [
              // Slide 1: Main Machinery Showcase
              _buildBannerSlide(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0B111A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                badgeText: "EASY | ECONOMIC | EXCELLENT",
                badgeColor: AppColors.secondary,
                title: "Mesin Pengolahan Kopi & Kakao",
                subtitle: "Standar Industri & UMKM. Garansi resmi 2 tahun.",
                buttonText: "Jelajahi Mesin",
                icon: Icons.coffee_maker_rounded,
                iconColor: AppColors.brandCoffeeLight,
                onTap: () {
                  widget.onNavigateToCatalog?.call();
                },
              ),

              // Slide 2: Custom RFQ Orders
              _buildBannerSlide(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF7F1D1D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                badgeText: "REQUEST FOR QUOTATION",
                badgeColor: AppColors.secondaryLight,
                title: "Butuh Mesin Custom Specs?",
                subtitle: "Sesuaikan daya watt, dual boiler & grafir logo brand Anda.",
                buttonText: "Form Custom Order",
                icon: Icons.settings_suggest_rounded,
                iconColor: Colors.white,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RfqCustomOrderScreen(),
                    ),
                  );
                },
              ),

              // Slide 3: DP 50% & After Sales Support
              _buildBannerSlide(
                gradient: const LinearGradient(
                  colors: [Color(0xFF18181B), Color(0xFF451A03)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                badgeText: "SISTEM FLEKSIBEL PO",
                badgeColor: AppColors.warning,
                title: "Sistem DP 50% & Purna Jual",
                subtitle: "Pelunasan saat lolos uji QC. Teknisi after-sales standby.",
                buttonText: "Konsultasi WA",
                icon: Icons.verified_user_rounded,
                iconColor: AppColors.brandCoffeeLight,
                onTap: () {
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

        const SizedBox(height: 8),

        // Animated Dot Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final isActive = _currentBannerIndex == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 20 : 6,
              height: 5,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.secondary
                    : (isDark ? Colors.white24 : AppColors.border),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBannerSlide({
    required Gradient gradient,
    required String badgeText,
    required Color badgeColor,
    required String title,
    required String subtitle,
    required String buttonText,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeText,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 10.5,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            buttonText,
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.primary,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 13,
                            color: AppColors.secondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= 3. TRUST / VALUE PROPOSITIONS =================
  Widget _buildTrustBadges(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCardBg : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? Colors.white10 : AppColors.border,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildTrustItem(
                icon: Icons.shield_outlined,
                iconColor: AppColors.secondary,
                title: "Garansi 2 Thn",
                desc: "Pabrik Resmi",
                isDark: isDark,
              ),
            ),
            Container(
              height: 24,
              width: 1,
              color: isDark ? Colors.white12 : AppColors.border,
            ),
            Expanded(
              child: _buildTrustItem(
                icon: Icons.payments_outlined,
                iconColor: AppColors.brandCoffee,
                title: "Sistem DP 50%",
                desc: "Pelunasan QC",
                isDark: isDark,
              ),
            ),
            Container(
              height: 24,
              width: 1,
              color: isDark ? Colors.white12 : AppColors.border,
            ),
            Expanded(
              child: _buildTrustItem(
                icon: Icons.engineering_outlined,
                iconColor: AppColors.info,
                title: "After-Sales",
                desc: "Teknisi Siap",
                isDark: isDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    maxLines: 1,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  desc,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 8.5,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= 4. SECTION HEADER =================
  Widget _buildSectionHeader(
      BuildContext context, AppState appState, bool isDark, int count) {
    String headerTitle = "Mesin Unggulan Industri";
    if (appState.selectedCategory != 'Semua') {
      headerTitle = appState.selectedCategory;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 3.5,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    headerTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              widget.onNavigateToCatalog?.call();
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Lihat Semua ($count)",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 11,
                    color: AppColors.secondary,
                  ),
                ],
              ),
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
          childAspectRatio: 0.58,
        ),
        itemBuilder: (context, index) {
          final product = products[index];
          return _buildProductCard(context, product, isDark);
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel product, bool isDark) {
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
            // Clean Machinery Image (Without obstructive overlay badges)
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
                        _getCategoryIcon(product.category),
                        color: AppColors.secondary,
                        size: 34,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Card Body Content
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
                        // Category Micro Tag
                        Text(
                          product.category.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 3),

                        // Machine Name
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            height: 1.25,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Spec Badge Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: isDark ? Colors.white10 : AppColors.border,
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.flash_on_rounded,
                                size: 10,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  product.specifications.dayaListrik,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
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
                                "Harga PO",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 8.5,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                                ),
                              ),
                              Text(
                                _formatPrice(product.price),
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
                            color: AppColors.secondary,
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
              "Coba ganti kata kunci pencarian atau pilih kategori lain.",
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () {
                appState.setSearchQuery('');
                appState.setCategoryFilter('Semua');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              ),
              child: const Text("Tampilkan Semua Mesin", style: TextStyle(fontSize: 12)),
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
