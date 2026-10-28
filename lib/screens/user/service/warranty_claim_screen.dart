import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state.dart';
import '../../../core/models/service_ticket_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/file_picker_helper.dart';

class WarrantyClaimScreen extends StatefulWidget {
  final bool asStandalonePage;
  const WarrantyClaimScreen({super.key, this.asStandalonePage = false});

  @override
  State<WarrantyClaimScreen> createState() => _WarrantyClaimScreenState();
}

class _WarrantyClaimScreenState extends State<WarrantyClaimScreen> {
  // Sub-view: 0 = Form Pengajuan, 1 = Riwayat Klaim
  int _claimSubTab = 0;

  final _serialController = TextEditingController(text: 'SN-2025-TITAN-881');
  final _modelController =
      TextEditingController(text: 'TitanGrind Commercial 84mm Flat Burr');
  final _purchaseDateController =
      TextEditingController(text: '15 Januari 2026');
  final _descriptionController = TextEditingController(
      text:
          'Sensor display sentuh grinder TitanGrind tidak merespon saat suhu ruang naik.');

  String? _uploadedPhotoName;

  // Machine quick presets
  final List<Map<String, String>> _machinePresets = [
    {
      'model': 'TitanGrind Commercial 84mm Flat Burr',
      'sn': 'SN-2025-TITAN-881',
      'date': '15 Januari 2026',
    },
    {
      'model': 'Artisan Espresso Craft Pro 2G',
      'sn': 'SN-2024-CRAFT-092',
      'date': '10 Oktober 2025',
    },
    {
      'model': 'AromaMax Commercial 3G Heavy Duty',
      'sn': 'SN-2025-AROMA-014',
      'date': '01 Februari 2026',
    },
  ];

  @override
  void dispose() {
    _serialController.dispose();
    _modelController.dispose();
    _purchaseDateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _getMonthName(int month) {
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return (month >= 1 && month <= 12) ? months[month] : '';
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final claims = appState.warrantyClaims;
    final canPop = widget.asStandalonePage || Navigator.canPop(context);

    final content = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sub-Switcher: [Ajukan Klaim Baru] vs [Riwayat Klaim (N)]
          _buildSubSwitcher(claims.length, isDark),

          const SizedBox(height: 12),

          // Show Form View or Direct Claim List View (No Stacking Banners on History!)
          if (_claimSubTab == 0) ...[
            _buildCompactWarrantyHeader(isDark),
            const SizedBox(height: 12),
            _buildClaimFormView(context, appState, isDark),
          ] else ...[
            _buildCleanClaimListView(claims, isDark),
          ],
        ],
      ),
    );

    if (widget.asStandalonePage) {
      return Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: canPop
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  onPressed: () => Navigator.pop(context),
                )
              : null,
          title: Text(
            "Klaim Garansi Resmi",
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ),
        body: SafeArea(child: content),
      );
    }

    return content;
  }

  /// Compact, Elegant Warranty Header (Warm, Soft, No Overflows)
  Widget _buildCompactWarrantyHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0F172A)
                  : const Color(0xFFECFDF5), // Soft mint tint
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.verified_rounded,
              color: Color(0xFF047857), // Forest green
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Garansi Resmi Pabrik 2 Tahun",
                  style: GoogleFonts.outfit(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Penggantian komponen original & perbaikan tanpa biaya untuk kerusakan manufaktur.",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Sub-Switcher: [Ajukan Klaim Baru] vs [Riwayat Klaim]
  Widget _buildSubSwitcher(int claimCount, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(3.5),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSubTabItem(
              title: "Ajukan Klaim Baru",
              icon: Icons.shield_outlined,
              isSelected: _claimSubTab == 0,
              badgeCount: null,
              onTap: () {
                setState(() {
                  _claimSubTab = 0;
                });
              },
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildSubTabItem(
              title: "Riwayat Klaim",
              icon: Icons.assignment_outlined,
              isSelected: _claimSubTab == 1,
              badgeCount: claimCount,
              onTap: () {
                setState(() {
                  _claimSubTab = 1;
                });
              },
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTabItem({
    required String title,
    required IconData icon,
    required bool isSelected,
    required int? badgeCount,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final activeBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final activeFg = isDark ? Colors.white : const Color(0xFF0F172A);
    final inactiveFg = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8.5, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? activeFg : inactiveFg,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? activeFg : inactiveFg,
                ),
              ),
            ),
            if (badgeCount != null) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? Colors.white12 : const Color(0xFFE2E8F0))
                      : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "$badgeCount",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? (isDark ? Colors.white : const Color(0xFF0F172A))
                        : (isDark ? Colors.white70 : const Color(0xFF475569)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 3A. Modern Claim Form (Grouped, Non-Stacked)
  Widget _buildClaimFormView(
      BuildContext context, AppState appState, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- CARD 1: Unit Mesin & Tanggal Pembelian ---
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white10 : const Color(0xFFE5E7EB),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFormSectionHeader(
                icon: Icons.precision_manufacturing_rounded,
                iconColor: const Color(0xFFC07F42), // Warm Coffee Accent
                iconBg: isDark ? const Color(0xFF332A15) : const Color(0xFFFEF3C7),
                title: "1. Data Mesin & Pembelian",
                subtitle:
                    "Nomor seri unit dan tanggal serah terima untuk verifikasi garansi",
                isDark: isDark,
              ),
              const SizedBox(height: 14),

              Text(
                "Pilih Cepat Unit Mesin:",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : const Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _machinePresets.map((m) {
                    final isSelected = _serialController.text == m['sn'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(m['model']!),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _serialController.text = m['sn']!;
                              _modelController.text = m['model']!;
                              _purchaseDateController.text = m['date']!;
                            });
                          }
                        },
                        selectedColor: isDark
                            ? const Color(0xFF78350F).withValues(alpha: 0.35)
                            : const Color(0xFFFEF3C7),
                        backgroundColor: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF8F9FA),
                        labelStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? (isDark
                                  ? const Color(0xFFFBBF24)
                                  : const Color(0xFF92400E))
                              : (isDark
                                  ? AppColors.darkTextSecondary
                                  : const Color(0xFF64748B)),
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFFD97706)
                              : (isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 14),

              _buildInputLabel("Nomor Seri Mesin (Lihat Nameplate)", isDark),
              TextField(
                controller: _serialController,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F9FA),
                  filled: true,
                  prefixIcon: const Icon(Icons.qr_code_rounded,
                      size: 18,
                      color: Color(0xFFC07F42)), // Distinct bronze coffee icon
                  hintText: "Contoh: SN-2025-TITAN-881",
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white10 : const Color(0xFFE5E7EB),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white54 : const Color(0xFF0F172A),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              _buildInputLabel("Tanggal Pembelian / Serah Terima", isDark),
              TextField(
                controller: _purchaseDateController,
                readOnly: true,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 13,
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().subtract(const Duration(days: 120)),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _purchaseDateController.text =
                          "${picked.day} ${_getMonthName(picked.month)} ${picked.year}";
                    });
                  }
                },
                decoration: InputDecoration(
                  fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F9FA),
                  filled: true,
                  prefixIcon: const Icon(Icons.calendar_today_rounded,
                      size: 18,
                      color: Color(0xFF2563EB)), // Distinct blue calendar icon
                  hintText: "Pilih tanggal pembelian...",
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white10 : const Color(0xFFE5E7EB),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white54 : const Color(0xFF0F172A),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // --- CARD 2: Deskripsi Kendala & Bukti Foto/Video ---
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white10 : const Color(0xFFE5E7EB),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFormSectionHeader(
                icon: Icons.report_problem_rounded,
                iconColor: const Color(0xFFE11D48), // Rose red accent
                iconBg: isDark
                    ? const Color(0xFFE11D48).withValues(alpha: 0.22)
                    : const Color(0xFFFFE4E6),
                title: "2. Kendala Kerusakan & Bukti Fisik",
                subtitle:
                    "Jelaskan gejala kerusakan komponen dan lampirkan foto/video unit",
                isDark: isDark,
              ),
              const SizedBox(height: 14),

              _buildInputLabel("Deskripsi Kendala / Kerusakan Komponen", isDark),
              TextField(
                controller: _descriptionController,
                minLines: 2,
                maxLines: 4,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F9FA),
                  filled: true,
                  prefixIcon: const Icon(Icons.notes_rounded,
                      size: 19,
                      color: Color(0xFFE11D48)), // Distinct Rose red icon
                  hintText:
                      "Jelaskan bagian komponen atau modul yang mengalami malfungsi...",
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white10 : const Color(0xFFE5E7EB),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white54 : const Color(0xFF0F172A),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              _buildInputLabel("Lampiran Bukti Foto / Dokumen Unit", isDark),
              InkWell(
                onTap: () async {
                  final name = await FilePickerHelper.pickFileName();
                  setState(() {
                    _uploadedPhotoName =
                        name ?? 'foto_kerusakan_display_grinder.jpg';
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: _uploadedPhotoName != null
                        ? (isDark
                            ? const Color(0xFF14332A)
                            : const Color(0xFFECFDF5))
                        : (isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF8F9FA)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _uploadedPhotoName != null
                          ? const Color(0xFF047857)
                          : (isDark ? Colors.white12 : const Color(0xFFE5E7EB)),
                      width: _uploadedPhotoName != null ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: _uploadedPhotoName != null
                              ? const Color(0xFF047857).withValues(alpha: 0.15)
                              : (isDark
                                  ? Colors.white10
                                  : const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _uploadedPhotoName != null
                              ? Icons.check_circle_rounded
                              : Icons.add_a_photo_outlined,
                          color: _uploadedPhotoName != null
                              ? const Color(0xFF047857)
                              : (isDark
                                  ? Colors.white60
                                  : const Color(0xFF64748B)),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _uploadedPhotoName ?? "Unggah Foto / Video Bukti Kerusakan",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                fontWeight: _uploadedPhotoName != null
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: _uploadedPhotoName != null
                                    ? const Color(0xFF047857)
                                    : (isDark
                                        ? Colors.white
                                        : const Color(0xFF0F172A)),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _uploadedPhotoName != null
                                  ? "File siap dikirim ke tim teknik evaluasi"
                                  : "Format JPG, PNG, MP4 (Maks. 25 MB)",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_uploadedPhotoName != null)
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          color: isDark ? Colors.white54 : const Color(0xFF64748B),
                          onPressed: () {
                            setState(() {
                              _uploadedPhotoName = null;
                            });
                          },
                        )
                      else
                        const Icon(Icons.cloud_upload_outlined,
                            size: 19, color: Color(0xFF94A3B8)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () {
              if (_serialController.text.trim().isEmpty ||
                  _descriptionController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        "Harap lengkapi nomor seri dan deskripsi kerusakan!"),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              final photo =
                  _uploadedPhotoName ?? 'foto_kerusakan_display_grinder.jpg';
              appState.submitWarrantyClaim(
                serialNumber: _serialController.text.trim(),
                purchaseDate: _purchaseDateController.text.trim(),
                damageDescription: _descriptionController.text.trim(),
                photoPath: photo,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Klaim garansi berhasil dikirim ke pabrik! Tim teknik akan mengevaluasi dalam 1x24 jam.",
                    style: TextStyle(fontSize: 12.5),
                  ),
                  backgroundColor: Color(0xFF047857),
                  duration: Duration(seconds: 3),
                ),
              );

              setState(() {
                _claimSubTab = 1;
              });
            },
            icon: const Icon(Icons.send_rounded, size: 17),
            label: Text(
              "KIRIM PENGAJUAN KLAIM GARANSI",
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 0.3,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? const Color(0xFF16A34A) : const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  /// 3B. Direct Clean Claim List View (No Role: User, No Stacking)
  Widget _buildCleanClaimListView(List<WarrantyClaimModel> claims, bool isDark) {
    if (claims.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white10 : const Color(0xFFE5E7EB),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.verified_outlined,
              size: 44,
              color: isDark ? Colors.white30 : const Color(0xFF94A3B8),
            ),
            const SizedBox(height: 12),
            Text(
              "Belum Ada Riwayat Klaim",
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Ajukan klaim baru jika unit mesin mengalami kendala selama masa garansi aktif.",
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _claimSubTab = 0;
                });
              },
              icon: const Icon(Icons.shield_outlined, size: 16),
              label: const Text("Ajukan Klaim Sekarang"),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
                side: BorderSide(
                  color: isDark ? Colors.white54 : const Color(0xFF0F172A),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Clean Title without Role: User
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Riwayat Pengajuan Garansi (${claims.length})",
                style: GoogleFonts.outfit(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Seluruh klaim diverifikasi langsung oleh Departemen Teknik & Suku Cadang Pabrik.",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: claims.length,
          itemBuilder: (context, index) {
            final clm = claims[index];
            return _buildCompactClaimCard(clm, isDark);
          },
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  /// Compact, Clean Claim Card
  Widget _buildCompactClaimCard(WarrantyClaimModel clm, bool isDark) {
    final isApproved = clm.status.toLowerCase().contains('disetujui');
    final isRejected = clm.status.toLowerCase().contains('ditolak');

    final statusBg = isApproved
        ? (isDark ? const Color(0xFF14332A) : const Color(0xFFECFDF5))
        : isRejected
            ? (isDark ? const Color(0xFF3B1010) : const Color(0xFFFEF2F2))
            : (isDark ? const Color(0xFF332A15) : const Color(0xFFFEF3C7));

    final statusFg = isApproved
        ? (isDark ? const Color(0xFF86EFAC) : const Color(0xFF047857))
        : isRejected
            ? (isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626))
            : (isDark ? const Color(0xFFFDE047) : const Color(0xFFB45309));

    final statusIcon = isApproved
        ? Icons.check_circle_rounded
        : isRejected
            ? Icons.cancel_rounded
            : Icons.hourglass_top_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Claim Number & Status Badge
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  clm.claimNumber,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 11, color: statusFg),
                      const SizedBox(width: 4),
                      Text(
                        clm.status,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: statusFg,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, indent: 14, endIndent: 14),

          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.confirmation_number_outlined,
                        size: 13, color: Color(0xFFC07F42)), // Warm Bronze
                    const SizedBox(width: 5),
                    Text(
                      "No. Seri: ${clm.serialNumber}",
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text("•",
                        style: TextStyle(
                            color: isDark ? Colors.white38 : const Color(0xFFCBD5E1))),
                    const SizedBox(width: 8),
                    Text(
                      "Beli: ${clm.purchaseDate}",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: isDark ? Colors.white60 : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  clm.damageDescription,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: isDark ? Colors.white70 : const Color(0xFF475569),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 8),

                // Attached photo chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDark ? Colors.white10 : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.image_outlined,
                          size: 13, color: Color(0xFF047857)),
                      const SizedBox(width: 5),
                      Text(
                        clm.photoPath,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(Icons.check_circle,
                          size: 11, color: Color(0xFF047857)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSectionHeader({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
          fontSize: 11.5,
          color: isDark ? Colors.white70 : const Color(0xFF334155),
        ),
      ),
    );
  }
}
