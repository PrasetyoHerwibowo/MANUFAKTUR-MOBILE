import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/product_model.dart';
import '../../../widgets/product_filter_bottom_sheet.dart';
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
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _catalogSectionKey = GlobalKey();
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;

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
    _bannerTimer?.cancel();
    _bannerController.dispose();
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
          const SizedBox(height: 8),

          // 1. Promotional Banner Carousel (PageView with Animated Indicator)
          _buildBannerCarousel(context, isDark),

          const SizedBox(height: 10),

          // 2. Trust Badges / Value Propositions (Like Reference 3-Pill Strip)
          _buildTrustBadges(isDark),

          const SizedBox(height: 16),

          // 3. Section Header: Title, Filters & Controls
          _buildSectionHeader(context, appState, isDark, filteredProducts.length),

          const SizedBox(height: 10),

          // 4. Product Display (Clean 2-Column Grid View)
          if (filteredProducts.isEmpty)
            _buildEmptyState(appState, isDark)
          else
            _buildProductGrid(context, appState, isDark, filteredProducts),

          const SizedBox(height: 20),

          // 5. WhatsApp Engineering Consultation Banner (Soft Mint Tone)
          _buildConsultationBanner(context, isDark),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ================= 1. BANNER CAROUSEL =================
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
                  _scrollToCatalog();
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

  // ================= 4. SECTION HEADER & CATALOG FILTER CONTROLS =================
  Widget _buildSectionHeader(
      BuildContext context, AppState appState, bool isDark, int count) {
    String headerTitle = "Katalog Mesin Industri";
    if (appState.searchQuery.isNotEmpty) {
      headerTitle = 'Hasil Cari: "${appState.searchQuery}"';
    } else if (appState.selectedCommodity == 'Kopi') {
      headerTitle = appState.selectedProcessStage == 'Semua'
          ? "Mesin Pengolahan Kopi (Hulu-Hilir)"
          : "Mesin Kopi • Alur ${appState.selectedProcessStage}";
    } else if (appState.selectedCommodity == 'Kakao') {
      headerTitle = appState.selectedProcessStage == 'Semua'
          ? "Mesin Pengolahan Kakao (Hulu-Hilir)"
          : "Mesin Kakao • Alur ${appState.selectedProcessStage}";
    } else if (appState.selectedProcessStage != 'Semua') {
      headerTitle = "Mesin Industri • Alur ${appState.selectedProcessStage}";
    }

    final isKakao = appState.selectedCommodity == 'Kakao';
    final isCoffee = appState.selectedCommodity == 'Kopi';

    return Container(
      key: _catalogSectionKey,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              Container(
                width: 3.5,
                height: 18,
                decoration: BoxDecoration(
                  color: isCoffee
                      ? AppColors.brandCoffee
                      : (isKakao ? AppColors.brandCocoa : AppColors.secondary),
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
                    fontSize: 16.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  ProductFilterBottomSheet.show(context);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: appState.activeFiltersCount > 0
                        ? AppColors.secondary.withValues(alpha: 0.12)
                        : (isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: appState.activeFiltersCount > 0
                          ? AppColors.secondary
                          : (isDark ? Colors.white12 : AppColors.border),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        size: 14,
                        color: appState.activeFiltersCount > 0
                            ? AppColors.secondary
                            : (isDark ? Colors.white70 : AppColors.textSecondary),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        appState.activeFiltersCount > 0
                            ? "Filter (${appState.activeFiltersCount})"
                            : "Filter",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: appState.activeFiltersCount > 0
                              ? AppColors.secondary
                              : (isDark ? Colors.white70 : AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Horizontal Filter Dropdowns Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                // 1. Dropdown Komoditas (if Semua)
                if (appState.selectedCommodity == 'Semua')
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterDropdown(
                      label: "Komoditas",
                      value: appState.selectedCommodity,
                      items: appState.availableCommodities,
                      onChanged: (val) {
                        if (val != null) appState.setCommodityFilter(val);
                      },
                      isDark: isDark,
                    ),
                  ),

                // 2. Dropdown Nama Mesin (Khusus Kakao: Nama Mesin Kakao; Kopi: Nama Mesin Kopi; Semua: Nama Mesin)
                _buildFilterDropdown(
                  label: isKakao ? "Mesin Kakao" : (isCoffee ? "Mesin Kopi" : "Nama Mesin"),
                  value: appState.selectedMachineType,
                  items: appState.availableMachineTypes,
                  onChanged: (val) {
                    if (val != null) appState.setMachineTypeFilter(val);
                  },
                  isDark: isDark,
                ),
                const SizedBox(width: 8),

                // 3. Dropdown Model Kapasitas (HANYA MUNCUL JIKA BUKAN KAKAO, SESUAI PERMINTAAN USER!)
                if (!isKakao) ...[
                  _buildFilterDropdown(
                    label: "Model Kapasitas",
                    value: appState.selectedCapacityScale,
                    items: appState.availableCapacityScales,
                    onChanged: (val) {
                      if (val != null) appState.setCapacityScaleFilter(val);
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                ],

                // 4. Dropdown Listrik
                _buildFilterDropdown(
                  label: "Listrik",
                  value: appState.selectedPowerSource,
                  items: const [
                    'Semua',
                    '220V 1-Phase',
                    '380V 3-Phase',
                    'Gas LPG',
                  ],
                  onChanged: (val) {
                    if (val != null) appState.setPowerSourceFilter(val);
                  },
                  isDark: isDark,
                ),
                const SizedBox(width: 8),

                // 5. Dropdown Urutan
                _buildFilterDropdown(
                  label: "Urutan",
                  value: appState.sortBy,
                  items: const [
                    'Populer',
                    'Harga Terendah',
                    'Harga Tertinggi',
                    'Rating',
                  ],
                  onChanged: (val) {
                    if (val != null) appState.setSortBy(val);
                  },
                  isDark: isDark,
                ),
              ],
            ),
          ),

          // Active filter tags (if any active)
          if (appState.hasActiveFilters) ...[
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  if (appState.searchQuery.isNotEmpty)
                    _buildActiveFilterChip(
                      label: 'Cari: "${appState.searchQuery}"',
                      onDelete: () => appState.setSearchQuery(''),
                      isDark: isDark,
                    ),
                  if (appState.selectedCommodity != 'Semua')
                    _buildActiveFilterChip(
                      label: 'Komoditas: ${appState.selectedCommodity}',
                      onDelete: () => appState.setCommodityFilter('Semua'),
                      isDark: isDark,
                    ),
                  if (appState.selectedProcessStage != 'Semua')
                    _buildActiveFilterChip(
                      label: 'Alur: ${appState.selectedProcessStage}',
                      onDelete: () => appState.setProcessStageFilter('Semua'),
                      isDark: isDark,
                    ),
                  if (appState.selectedMachineType != 'Semua')
                    _buildActiveFilterChip(
                      label: 'Mesin: ${appState.selectedMachineType}',
                      onDelete: () => appState.setMachineTypeFilter('Semua'),
                      isDark: isDark,
                    ),
                  if (appState.selectedCapacityScale != 'Semua')
                    _buildActiveFilterChip(
                      label: 'Model: ${appState.selectedCapacityScale}',
                      onDelete: () => appState.setCapacityScaleFilter('Semua'),
                      isDark: isDark,
                    ),
                  if (appState.selectedPowerSource != 'Semua')
                    _buildActiveFilterChip(
                      label: 'Listrik: ${appState.selectedPowerSource}',
                      onDelete: () => appState.setPowerSourceFilter('Semua'),
                      isDark: isDark,
                    ),
                  if (appState.sortBy != 'Populer')
                    _buildActiveFilterChip(
                      label: 'Urutan: ${appState.sortBy}',
                      onDelete: () => appState.setSortBy('Populer'),
                      isDark: isDark,
                    ),
                  InkWell(
                    onTap: () => appState.resetFilters(),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Text(
                        "Reset Semua",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Count & Sort subtitle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isKakao
                    ? "Menampilkan $count Mesin Kakao"
                    : (isCoffee
                        ? "Menampilkan $count Mesin Kopi"
                        : "Menampilkan $count Mesin Pengolahan"),
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
              InkWell(
                onTap: () {
                  ProductFilterBottomSheet.show(context);
                },
                child: Row(
                  children: [
                    const Icon(Icons.swap_vert, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 2),
                    Text(
                      "Urutan: ${appState.sortBy}",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required bool isDark,
  }) {
    final safeItems = items.isEmpty ? const ['Semua'] : items;
    final safeValue = safeItems.contains(value) ? value : safeItems.first;
    final isFiltered = safeValue != 'Semua' && safeValue != 'Populer';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isFiltered
              ? AppColors.secondary
              : (isDark ? Colors.white12 : AppColors.border),
          width: isFiltered ? 1.2 : 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeValue,
          isDense: true,
          dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: isFiltered ? FontWeight.bold : FontWeight.w500,
            color: isFiltered
                ? AppColors.secondary
                : (isDark ? Colors.white : AppColors.textPrimary),
          ),
          items: safeItems.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                "$label: $item",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildActiveFilterChip({
    required String label,
    required VoidCallback onDelete,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.only(left: 8, right: 4, top: 3, bottom: 3),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: 2),
          InkWell(
            onTap: onDelete,
            child: const Icon(
              Icons.close_rounded,
              size: 14,
              color: AppColors.secondary,
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
            // Clean Machinery Image with Commodity & Stage Badge Tag
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: AspectRatio(
                aspectRatio: 1.25,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
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
                    // Micro badge on top-left of photo
                    Positioned(
                      top: 7,
                      left: 7,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: isCoffee
                              ? const Color(0xFF78350F).withValues(alpha: 0.90)
                              : const Color(0xFF451A03).withValues(alpha: 0.90),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          "${product.commodity.toUpperCase()} • ${product.processStage.toUpperCase()}",
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 7.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Card Body Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Machine Type Micro Tag
                        Text(
                          product.machineType.isNotEmpty
                              ? product.machineType.toUpperCase()
                              : product.category.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            color: isCoffee ? AppColors.brandCoffee : AppColors.brandCocoa,
                            letterSpacing: 0.3,
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
                        const SizedBox(height: 5),

                        // Capacity / Multi-Model Indicator
                        if (hasMultipleModels)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.brandCoffeeDark.withValues(alpha: 0.4)
                                  : const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(4),
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
                                  size: 9.5,
                                  color: AppColors.brandCoffee,
                                ),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Text(
                                    "${product.capacityModels.length} Model Kapasitas",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 8.5,
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
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkSurface
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4),
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
                                  size: 9.5,
                                  color: isDark ? Colors.white60 : AppColors.textMuted,
                                ),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Text(
                                    product.specifications.kapasitas,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Power / Watt badge
                        Row(
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
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textMuted,
                                ),
                              ),
                            ),
                          ],
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
                                  fontSize: 8,
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
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isCoffee
                                ? AppColors.brandCoffee
                                : (isDark ? AppColors.secondary : AppColors.secondary),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 13,
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
