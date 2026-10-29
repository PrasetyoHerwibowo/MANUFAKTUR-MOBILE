import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state.dart';
import '../../../core/models/service_ticket_model.dart';
import '../../../core/theme/app_colors.dart';
import 'warranty_claim_screen.dart';

class BookingServiceScreen extends StatefulWidget {
  final int initialTab;
  const BookingServiceScreen({super.key, this.initialTab = 0});

  @override
  State<BookingServiceScreen> createState() => _BookingServiceScreenState();
}

class _BookingServiceScreenState extends State<BookingServiceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _mainTabController;
  int _currentTab = 0;

  // Sub-view: 0 = Buat Jadwal Baru, 1 = Daftar Tiket
  int _bookingSubTab = 0;

  // Form Controllers
  final _serialNumberController =
      TextEditingController(text: 'SN-2024-CRAFT-092');
  final _machineModelController =
      TextEditingController(text: 'Artisan Espresso Craft Pro 2G');
  final _dateController = TextEditingController(text: '12 Oktober 2026');
  final _timeController = TextEditingController(text: '10:00 WIB');
  final _addressController = TextEditingController(
      text: 'Jl. Sudirman No. 45, Jakarta Selatan (Kafe Utama)');
  final _descriptionController = TextEditingController(
      text: 'Maintenance rutin 6 bulanan, descaling boiler & penggantian seal group head.');

  ServiceTicketType _selectedServiceType = ServiceTicketType.maintenanceRutin;

  // Business hours time slots for easy 1-tap selection (No radial dial clock!)
  final List<String> _timeSlots = [
    '09:00 WIB',
    '10:00 WIB',
    '11:00 WIB',
    '13:00 WIB',
    '14:00 WIB',
    '15:00 WIB',
    '16:00 WIB',
    '17:00 WIB',
  ];

  // Registered machine presets
  final List<Map<String, String>> _myMachines = [
    {
      'model': 'Artisan Espresso Craft Pro 2G',
      'sn': 'SN-2024-CRAFT-092',
      'label': 'Artisan Craft 2G (Bar Utama)',
    },
    {
      'model': 'AromaMax Commercial 3G Heavy Duty',
      'sn': 'SN-2025-AROMA-014',
      'label': 'AromaMax 3G (Cabang Bali)',
    },
    {
      'model': 'TitanGrind Commercial 84mm Flat Burr',
      'sn': 'SN-2025-TITAN-881',
      'label': 'TitanGrind 84mm (Bar Espresso)',
    },
  ];

  String _getMonthName(int month) {
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return (month >= 1 && month <= 12) ? months[month] : '';
  }

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab.clamp(0, 1);
    _mainTabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: _currentTab,
    );
    _mainTabController.addListener(() {
      if (!_mainTabController.indexIsChanging &&
          _mainTabController.index != _currentTab) {
        setState(() {
          _currentTab = _mainTabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _serialNumberController.dispose();
    _machineModelController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Smooth, non-jarring status badge colors
  Color _statusBgColor(TicketStatus status, bool isDark) {
    if (isDark) {
      switch (status) {
        case TicketStatus.dijadwalkan:
          return const Color(0xFF1E293B);
        case TicketStatus.teknisiOtw:
        case TicketStatus.dalamPengerjaan:
          return const Color(0xFF332A15);
        case TicketStatus.selesai:
          return const Color(0xFF14332A);
      }
    } else {
      switch (status) {
        case TicketStatus.dijadwalkan:
          return const Color(0xFFEFF6FF); // Pastel blue
        case TicketStatus.teknisiOtw:
        case TicketStatus.dalamPengerjaan:
          return const Color(0xFFFEF3C7); // Pastel amber
        case TicketStatus.selesai:
          return const Color(0xFFECFDF5); // Pastel mint
      }
    }
  }

  Color _statusTextColor(TicketStatus status, bool isDark) {
    if (isDark) {
      switch (status) {
        case TicketStatus.dijadwalkan:
          return const Color(0xFF93C5FD);
        case TicketStatus.teknisiOtw:
        case TicketStatus.dalamPengerjaan:
          return const Color(0xFFFDE047);
        case TicketStatus.selesai:
          return const Color(0xFF86EFAC);
      }
    } else {
      switch (status) {
        case TicketStatus.dijadwalkan:
          return const Color(0xFF1D4ED8);
        case TicketStatus.teknisiOtw:
        case TicketStatus.dalamPengerjaan:
          return const Color(0xFFB45309);
        case TicketStatus.selesai:
          return const Color(0xFF047857);
      }
    }
  }

  IconData _statusIcon(TicketStatus status) {
    switch (status) {
      case TicketStatus.dijadwalkan:
        return Icons.calendar_today_rounded;
      case TicketStatus.teknisiOtw:
      case TicketStatus.dalamPengerjaan:
        return Icons.pending_actions_rounded;
      case TicketStatus.selesai:
        return Icons.check_circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF8F9FA),
      appBar: canPop
          ? AppBar(
              backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                "Layanan Servis & Garansi",
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            // Top Segmented Switcher (Booking Servis vs Klaim Garansi)
            _buildTopSegmentedTabs(isDark),

            // Main Views
            Expanded(
              child: TabBarView(
                controller: _mainTabController,
                children: [
                  _buildBookingServisTab(context, appState, isDark),
                  const WarrantyClaimScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Modern Segmented Capsule Switcher (Smooth, Gentle on Eyes)
  Widget _buildTopSegmentedTabs(bool isDark) {
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
                icon: Icons.handyman_outlined,
                activeIcon: Icons.handyman_rounded,
                label: "Booking Servis",
                isDark: isDark,
              ),
            ),
            Expanded(
              child: _buildTopTabButton(
                index: 1,
                icon: Icons.verified_user_outlined,
                activeIcon: Icons.verified_user_rounded,
                label: "Klaim Garansi",
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
          _mainTabController.animateTo(index);
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
            const SizedBox(width: 7),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? activeFg : inactiveFg,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Booking Servis Content (Ultra Clean, Non-Stacked)
  Widget _buildBookingServisTab(
      BuildContext context, AppState appState, bool isDark) {
    final tickets = appState.serviceTickets;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sub-Switcher: [Jadwalkan Servis Baru] vs [Daftar Tiket]
          _buildSubSwitcher(tickets.length, isDark),

          const SizedBox(height: 12),

          // Show Form View or Direct Ticket List View
          if (_bookingSubTab == 0) ...[
            _buildBookingFormView(context, appState, isDark),
          ] else ...[
            _buildCleanTicketListView(context, appState, tickets, isDark),
          ],
        ],
      ),
    );
  }

  /// Sub-Switcher: [Jadwalkan Servis Baru] vs [Daftar Tiket]
  Widget _buildSubSwitcher(int ticketCount, bool isDark) {
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
              title: "Jadwalkan Servis Baru",
              icon: Icons.edit_calendar_rounded,
              isSelected: _bookingSubTab == 0,
              badgeCount: null,
              onTap: () {
                setState(() {
                  _bookingSubTab = 0;
                });
              },
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildSubTabItem(
              title: "Daftar Tiket",
              icon: Icons.receipt_long_rounded,
              isSelected: _bookingSubTab == 1,
              badgeCount: ticketCount,
              onTap: () {
                setState(() {
                  _bookingSubTab = 1;
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
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
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

  /// 4A. Clean, Well-Organized Booking Form (Direct, Non-Stacked)
  Widget _buildBookingFormView(
      BuildContext context, AppState appState, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- CARD 1: Mesin & Jenis Servis ---
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
                icon: Icons.coffee_maker_rounded,
                iconColor: const Color(0xFFC07F42), // Warm Coffee Accent
                iconBg: isDark
                    ? const Color(0xFFC07F42).withValues(alpha: 0.25)
                    : const Color(0xFFFEF3C7),
                title: "1. Data Mesin & Jenis Servis",
                subtitle: "Tentukan mesin yang perlu diservis dan tindakan teknisi",
                isDark: isDark,
              ),
              const SizedBox(height: 14),

              Text(
                "Pilih Cepat Dari Mesin Anda:",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextSecondary : const Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _myMachines.map((m) {
                    final isSelected =
                        _serialNumberController.text == m['sn'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(m['label']!),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _serialNumberController.text = m['sn']!;
                              _machineModelController.text = m['model']!;
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
                              : (isDark
                                  ? Colors.white10
                                  : const Color(0xFFE5E7EB)),
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

              _buildInputLabel("Nomor Seri Mesin", isDark),
              TextField(
                controller: _serialNumberController,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F9FA),
                  filled: true,
                  prefixIcon: const Icon(Icons.qr_code_scanner_rounded,
                      size: 18,
                      color: Color(0xFF2563EB)), // Distinct Blue icon
                  suffixIcon: IconButton(
                    tooltip: "Scan Barcode Mesin",
                    icon: const Icon(Icons.document_scanner_rounded,
                        size: 18, color: Color(0xFF2563EB)),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Scanner QR Code / Barcode aktif"),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  hintText: "Contoh: SN-2024-CRAFT-092",
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

              _buildInputLabel("Model / Tipe Mesin Kopi", isDark),
              TextField(
                controller: _machineModelController,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F9FA),
                  filled: true,
                  prefixIcon: const Icon(Icons.precision_manufacturing_outlined,
                      size: 18,
                      color: Color(0xFFC07F42)), // Distinct Warm Bronze icon
                  hintText: "Contoh: Artisan Espresso Craft Pro 2G",
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

              const SizedBox(height: 16),

              _buildInputLabel("Kategori Tindakan Servis", isDark),
              const SizedBox(height: 4),
              _buildServiceTypeSelector(isDark),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // --- CARD 2: Jadwal & Lokasi Kunjungan ---
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
                icon: Icons.calendar_month_rounded,
                iconColor: const Color(0xFF2563EB), // Blue Accent
                iconBg: isDark
                    ? const Color(0xFF2563EB).withValues(alpha: 0.22)
                    : const Color(0xFFEFF6FF),
                title: "2. Waktu Kunjungan & Lokasi",
                subtitle: "Tentukan tanggal kedatangan dan alamat fasilitas kafe/pabrik",
                isDark: isDark,
              ),
              const SizedBox(height: 14),

              // Date & Time (With user-friendly Time Slot picker modal!)
              Row(
                children: [
                  Expanded(
                    child: _buildPickerCard(
                      label: "Tanggal Kunjungan",
                      value: _dateController.text,
                      icon: Icons.calendar_today_rounded,
                      iconColor: const Color(0xFF2563EB),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate:
                              DateTime.now().add(const Duration(days: 2)),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 60)),
                        );
                        if (picked != null) {
                          setState(() {
                            _dateController.text =
                                "${picked.day} ${_getMonthName(picked.month)} ${picked.year}";
                          });
                        }
                      },
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildPickerCard(
                      label: "Jam Kedatangan",
                      value: _timeController.text,
                      icon: Icons.access_time_rounded,
                      iconColor: const Color(0xFFD97706),
                      onTap: () {
                        // Open user-friendly business hour time slot sheet!
                        _showEasyTimePickerModal(context, isDark);
                      },
                      isDark: isDark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInputLabel("Alamat Lokasi Kafe / Pabrik", isDark),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _addressController.text =
                            "Jl. Sudirman No. 45, Jakarta Selatan (Kafe Utama)";
                      });
                    },
                    child: Text(
                      "Gunakan Alamat Profil",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ],
              ),
              TextField(
                controller: _addressController,
                minLines: 2,
                maxLines: 3,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F9FA),
                  filled: true,
                  prefixIcon: const Icon(Icons.location_on_outlined,
                      size: 19,
                      color: Color(0xFFE11D48)), // Distinct Rose Red icon
                  hintText: "Alamat lengkap lokasi unit mesin...",
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

              _buildInputLabel("Catatan Keluhan / Instruksi Tambahan", isDark),
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
                      color: Color(0xFF7C3AED)), // Distinct Purple icon
                  hintText:
                      "Deskripsikan bagian mesin yang ingin dicek atau keluhan...",
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

        const SizedBox(height: 18),

        // Submit Button (Deep Slate in Light Mode, Accent in Dark Mode)
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () {
              if (_serialNumberController.text.trim().isEmpty ||
                  _machineModelController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Harap lengkapi nomor seri dan model mesin!"),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              appState.createServiceTicket(
                serialNumber: _serialNumberController.text.trim(),
                machineModel: _machineModelController.text.trim(),
                type: _selectedServiceType,
                preferredDate: _dateController.text.trim(),
                preferredTime: _timeController.text.trim(),
                address: _addressController.text.trim(),
                issueDescription: _descriptionController.text.trim(),
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Jadwal servis berhasil dikonfirmasi! Tiket Anda telah tercatat.",
                    style: TextStyle(fontSize: 12.5),
                  ),
                  backgroundColor: Color(0xFF15803D),
                  duration: Duration(seconds: 3),
                ),
              );

              setState(() {
                _bookingSubTab = 1;
              });
            },
            icon: const Icon(Icons.check_circle_rounded, size: 18),
            label: Text(
              "KONFIRMASI JADWAL SERVIS",
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 0.3,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.secondary : const Color(0xFF0F172A),
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

  /// User-friendly Business Hour Time Slot Sheet (Solves the frustrating analog clock dial!)
  void _showEasyTimePickerModal(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Pilih Jam Kedatangan Teknisi",
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Pilih slot jam kunjungan kerja operasional teknisi:",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),

              // Grid of easy 1-tap time chips
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _timeSlots.map((slot) {
                  final isSelected = _timeController.text == slot;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _timeController.text = slot;
                      });
                      Navigator.pop(ctx);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: (MediaQuery.of(context).size.width - 62) / 3,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? const Color(0xFF334155) : const Color(0xFF0F172A))
                            : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F9FA)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? (isDark ? Colors.white60 : const Color(0xFF0F172A))
                              : (isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        slot,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white70 : const Color(0xFF334155)),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Optional manual keyboard entry fallback
              Center(
                child: TextButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 10, minute: 0),
                      initialEntryMode: TimePickerEntryMode.input, // Keyboard input!
                    );
                    if (picked != null) {
                      setState(() {
                        _timeController.text =
                            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')} WIB";
                      });
                    }
                  },
                  icon: const Icon(Icons.keyboard_outlined, size: 16),
                  label: const Text("Ketik Jam Manual"),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                    textStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Interactive Service Category Selector
  Widget _buildServiceTypeSelector(bool isDark) {
    final categories = [
      {
        'type': ServiceTicketType.maintenanceRutin,
        'title': 'Maintenance Rutin (6 Bulan)',
        'subtitle': 'Pengecekan seal, gasket, tekanan boiler & pelumasan',
        'icon': Icons.tune_rounded,
        'color': const Color(0xFF2563EB),
      },
      {
        'type': ServiceTicketType.kalibrasiBoiler,
        'title': 'Kalibrasi & Descaling Boiler',
        'subtitle': 'Pembersihan kerak kapur & kalibrasi presisi temperatur',
        'icon': Icons.speed_rounded,
        'color': const Color(0xFFD97706),
      },
      {
        'type': ServiceTicketType.repairMesin,
        'title': 'Perbaikan / Repair Mesin',
        'subtitle': 'Perbaikan komponen error, kebocoran, atau macet',
        'icon': Icons.build_rounded,
        'color': const Color(0xFFE11D48),
      },
      {
        'type': ServiceTicketType.emergencyService,
        'title': 'Emergency Service 24/7',
        'subtitle': 'Penanganan darurat kendala mesin mati di jam operasional',
        'icon': Icons.emergency_rounded,
        'color': const Color(0xFF7C3AED),
      },
    ];

    return Column(
      children: categories.map((cat) {
        final type = cat['type'] as ServiceTicketType;
        final isSelected = _selectedServiceType == type;
        final accentColor = cat['color'] as Color;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedServiceType = type;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark
                        ? accentColor.withValues(alpha: 0.15)
                        : const Color(0xFFF1F5F9))
                    : (isDark
                        ? const Color(0xFF1E293B).withValues(alpha: 0.5)
                        : const Color(0xFFF8F9FA)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? (isDark ? accentColor : const Color(0xFF0F172A))
                      : (isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? accentColor.withValues(alpha: 0.28) : const Color(0xFF0F172A))
                          : accentColor.withValues(alpha: isDark ? 0.22 : 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      cat['icon'] as IconData,
                      size: 16,
                      color: isSelected
                          ? (isDark ? accentColor : Colors.white)
                          : accentColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat['title'] as String,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          cat['subtitle'] as String,
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
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    size: 18,
                    color: isSelected
                        ? (isDark ? accentColor : const Color(0xFF0F172A))
                        : (isDark ? Colors.white30 : const Color(0xFFCBD5E1)),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Interactive Date / Time Picker Tile
  Widget _buildPickerCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white12 : const Color(0xFFE5E7EB),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: iconColor),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 4B. Clean, Unstacked Ticket List View (No Role: User, No Duplicates)
  Widget _buildCleanTicketListView(BuildContext context, AppState appState,
      List<ServiceTicketModel> tickets, bool isDark) {
    if (tickets.isEmpty) {
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
              Icons.receipt_long_outlined,
              size: 44,
              color: isDark ? Colors.white30 : const Color(0xFF94A3B8),
            ),
            const SizedBox(height: 12),
            Text(
              "Belum Ada Tiket Servis",
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Jadwalkan kunjungan teknisi untuk pemeliharaan mesin kopi Anda.",
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
                  _bookingSubTab = 0;
                });
              },
              icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
              label: const Text("Jadwalkan Servis Sekarang"),
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
        // Clean Title without Role: User!
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Riwayat Kunjungan Servis (${tickets.length})",
                style: GoogleFonts.outfit(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Pantau jadwal kunjungan teknisi atau konfirmasi selesai saat servis telah rampung.",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Streamlined Ticket Cards
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            final t = tickets[index];
            return _buildCompactTicketCard(context, appState, t, isDark);
          },
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  /// Compact, Clean Ticket Card
  Widget _buildCompactTicketCard(BuildContext context, AppState appState,
      ServiceTicketModel t, bool isDark) {
    final isDone = t.status == TicketStatus.selesai;

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
          // Header: Ticket ID & Status
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    t.ticketNumber,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: _statusBgColor(t.status, isDark),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _statusIcon(t.status),
                        size: 11,
                        color: _statusTextColor(t.status, isDark),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        t.statusTitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _statusTextColor(t.status, isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, indent: 14, endIndent: 14),

          // Body Info
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.typeName,
                  style: GoogleFonts.outfit(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 5),

                // Machine Chip
                Row(
                  children: [
                    const Icon(Icons.coffee_maker_rounded,
                        size: 13, color: Color(0xFFC07F42)), // Warm bronze
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        "${t.machineModel} (${t.serialNumber})",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : const Color(0xFF334155),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Schedule & Location
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 12, color: Color(0xFF2563EB)), // Blue
                    const SizedBox(width: 5),
                    Text(
                      "${t.preferredDate} · ${t.preferredTime}",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: isDark ? Colors.white70 : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 12, color: Color(0xFFE11D48)), // Rose
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        t.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: isDark ? Colors.white60 : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),

                if (t.issueDescription.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    "“${t.issueDescription}”",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : const Color(0xFF475569),
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                // Clean Footer Row: Technician + Action Buttons
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? Colors.white10 : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.engineering_rounded,
                          size: 15, color: Color(0xFF4F46E5)), // Indigo
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          t.technicianName != null
                              ? "${t.technicianName}"
                              : "Menunggu Penugasan",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ),

                      if (t.technicianName != null) ...[
                        InkWell(
                          onTap: () => _showContactTechnicianDialog(t),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.phone_outlined, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  "Hubungi",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],

                      if (!isDone) ...[
                        InkWell(
                          onTap: () => _showConfirmDoneDialog(context, appState, t),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF15803D),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_rounded, size: 12, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  "Selesai",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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

  /// User dialog to confirm service is finished
  void _showConfirmDoneDialog(
      BuildContext context, AppState appState, ServiceTicketModel ticket) {
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Konfirmasi Servis Selesai",
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          content: Text(
            "Apakah teknisi telah menyelesaikan pekerjaan servis untuk ${ticket.machineModel} di lokasi Anda?",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: isDark ? Colors.white70 : const Color(0xFF475569),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                "Belum",
                style: TextStyle(
                  color: isDark ? Colors.white60 : const Color(0xFF64748B),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                appState.updateTicketStatus(
                    ticket.id, TicketStatus.selesai, ticket.technicianName ?? '');
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Servis berhasil ditandai selesai! Terima kasih."),
                    backgroundColor: Color(0xFF15803D),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF15803D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Ya, Servis Selesai"),
            ),
          ],
        );
      },
    );
  }

  void _showContactTechnicianDialog(ServiceTicketModel ticket) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Hubungi Teknisi Resmi",
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${ticket.technicianName} • ${ticket.technicianPhone}",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.chat_bubble_outline_rounded,
                      color: Colors.green),
                ),
                title: const Text("Chat WhatsApp Teknisi"),
                subtitle: const Text("Koordinasi jadwal kedatangan atau alamat"),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "Membuka chat WhatsApp dengan ${ticket.technicianName}..."),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white12 : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.phone_forwarded_rounded,
                      color: isDark ? Colors.white : const Color(0xFF0F172A)),
                ),
                title: const Text("Panggil Telepon Langsung"),
                subtitle: Text("Hubungi ${ticket.technicianPhone}"),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "Melakukan panggilan suara ke ${ticket.technicianPhone}..."),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
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
