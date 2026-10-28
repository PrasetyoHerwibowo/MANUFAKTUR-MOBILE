import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/app_state.dart';

class ProductFilterBottomSheet extends StatelessWidget {
  const ProductFilterBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ProductFilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;

    final commodities = [
      {'id': 'Semua', 'label': 'Semua Komoditas', 'icon': Icons.apps_rounded},
      {'id': 'Kopi', 'label': 'Kopi (Hulu-Hilir)', 'icon': Icons.coffee_rounded},
      {'id': 'Kakao', 'label': 'Kakao (Hulu-Hilir)', 'icon': Icons.spa_rounded},
    ];

    final processStages = [
      {'id': 'Semua', 'label': 'Semua Alur'},
      {'id': 'Hulu', 'label': 'Hulu (Pasca Panen)'},
      {'id': 'Hilir', 'label': 'Hilir (Pengolahan)'},
    ];

    final powerSources = [
      'Semua',
      '220V 1-Phase',
      '380V 3-Phase',
      'Gas LPG',
    ];

    final sortOptions = [
      {'id': 'Populer', 'label': 'Terpopuler (Rekomendasi)'},
      {'id': 'Harga Terendah', 'label': 'Harga: Terendah ke Tertinggi'},
      {'id': 'Harga Tertinggi', 'label': 'Harga: Tertinggi ke Terendah'},
      {'id': 'Rating', 'label': 'Rating Tertinggi'},
    ];

    final availableMachines = appState.availableMachineTypes;
    final isKakaoSelected = appState.selectedCommodity == 'Kakao';

    return Container(
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
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
                      Icons.tune_rounded,
                      size: 18,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Filter Mesin Pengolahan",
                    style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              if (appState.hasActiveFilters)
                TextButton(
                  onPressed: () {
                    appState.resetFilters();
                  },
                  child: Text(
                    "Reset Semua",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          // Scrollable filter options
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.60,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Komoditas (Kopi / Kakao)
                  _buildSectionTitle("Komoditas Industri", isDark),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: commodities.map((c) {
                      final isSelected = appState.selectedCommodity == c['id'];
                      return ChoiceChip(
                        avatar: Icon(
                          c['icon'] as IconData,
                          size: 15,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white70 : AppColors.textSecondary),
                        ),
                        label: Text(c['label'] as String),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            appState.setCommodityFilter(c['id'] as String);
                          }
                        },
                        selectedColor: AppColors.secondary,
                        backgroundColor: isDark ? AppColors.darkCardBg : const Color(0xFFF1F5F9),
                        labelStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white : AppColors.textPrimary),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.secondary
                                : (isDark ? Colors.white10 : AppColors.border),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 18),

                  // 2. Alur Pengolahan (Hulu / Hilir)
                  _buildSectionTitle("Alur Proses Pengolahan", isDark),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: processStages.map((s) {
                      final isSelected = appState.selectedProcessStage == s['id'];
                      return ChoiceChip(
                        label: Text(s['label'] as String),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            appState.setProcessStageFilter(s['id'] as String);
                          }
                        },
                        selectedColor: AppColors.secondary,
                        backgroundColor: isDark ? AppColors.darkCardBg : const Color(0xFFF1F5F9),
                        labelStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white : AppColors.textPrimary),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.secondary
                                : (isDark ? Colors.white10 : AppColors.border),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 18),

                  // 3. Nama / Jenis Mesin
                  _buildSectionTitle(
                    isKakaoSelected
                        ? "Nama Mesin Kakao"
                        : (appState.selectedCommodity == 'Kopi'
                            ? "Nama Mesin Kopi"
                            : "Nama / Tipe Mesin"),
                    isDark,
                    subtitle: isKakaoSelected
                        ? "Kategori mesin kakao difilter langsung berdasarkan nama mesin."
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableMachines.map((machine) {
                      final isSelected = appState.selectedMachineType == machine;
                      return ChoiceChip(
                        label: Text(machine == 'Semua' ? 'Semua Mesin' : machine),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            appState.setMachineTypeFilter(machine);
                          }
                        },
                        selectedColor: AppColors.secondary,
                        backgroundColor: isDark ? AppColors.darkCardBg : const Color(0xFFF1F5F9),
                        labelStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white : AppColors.textPrimary),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.secondary
                                : (isDark ? Colors.white10 : AppColors.border),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // 4. Model / Kapasitas Produksi (Khusus Kopi, disembunyikan untuk Kakao)
                  if (!isKakaoSelected) ...[
                    const SizedBox(height: 18),
                    _buildSectionTitle(
                      "Model Kapasitas (Khusus Mesin Kopi)",
                      isDark,
                      subtitle: "1 nama mesin kopi memiliki beberapa varian model kapasitas.",
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: appState.availableCapacityScales.map((scale) {
                        final isSelected = appState.selectedCapacityScale == scale;
                        return ChoiceChip(
                          avatar: Icon(
                            Icons.speed_rounded,
                            size: 14,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white70 : AppColors.textSecondary),
                          ),
                          label: Text(scale == 'Semua' ? 'Semua Kapasitas' : scale),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              appState.setCapacityScaleFilter(scale);
                            }
                          },
                          selectedColor: AppColors.brandCoffee,
                          backgroundColor:
                              isDark ? AppColors.darkCardBg : const Color(0xFFF1F5F9),
                          labelStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white : AppColors.textPrimary),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.brandCoffee
                                  : (isDark ? Colors.white10 : AppColors.border),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 18),

                  // 5. Sumber Daya Listrik
                  _buildSectionTitle("Sumber Daya Mesin", isDark),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: powerSources.map((power) {
                      final isSelected = appState.selectedPowerSource == power;
                      return ChoiceChip(
                        avatar: Icon(
                          Icons.flash_on_rounded,
                          size: 15,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white70 : AppColors.textSecondary),
                        ),
                        label: Text(power),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            appState.setPowerSourceFilter(power);
                          }
                        },
                        selectedColor: AppColors.secondary,
                        backgroundColor: isDark ? AppColors.darkCardBg : const Color(0xFFF1F5F9),
                        labelStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white : AppColors.textPrimary),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.secondary
                                : (isDark ? Colors.white10 : AppColors.border),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 18),

                  // 6. Urutkan
                  _buildSectionTitle("Urutkan Berdasarkan", isDark),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: sortOptions.map((opt) {
                      final isSelected = appState.sortBy == opt['id'];
                      return ChoiceChip(
                        avatar: Icon(
                          Icons.swap_vert_rounded,
                          size: 15,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white70 : AppColors.textSecondary),
                        ),
                        label: Text(opt['label'] as String),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            appState.setSortBy(opt['id'] as String);
                          }
                        },
                        selectedColor: AppColors.secondary,
                        backgroundColor: isDark ? AppColors.darkCardBg : const Color(0xFFF1F5F9),
                        labelStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white : AppColors.textPrimary),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.secondary
                                : (isDark ? Colors.white10 : AppColors.border),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Tampilkan ${appState.filteredProducts.length} Mesin Sesuai Filter",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}
