import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/file_picker_helper.dart';
import '../../../providers/app_state.dart';
import '../../../core/models/service_ticket_model.dart';
import '../../../core/theme/app_colors.dart';
import 'warranty_claim_screen.dart';

class BookingServiceScreen extends StatefulWidget {
  final int initialTab;
  final String? initialSerialNumber;
  final String? initialMachineModel;
  final String? initialAddress;
  final String? initialOrderId;
  final String? initialPurchaseDate;

  const BookingServiceScreen({
    super.key,
    this.initialTab = 0,
    this.initialSerialNumber,
    this.initialMachineModel,
    this.initialAddress,
    this.initialOrderId,
    this.initialPurchaseDate,
  });

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
  final _serialNumberController = TextEditingController(text: '');
  final _machineModelController = TextEditingController(text: '');
  final _dateController = TextEditingController(text: '');
  final _timeController = TextEditingController(text: '');
  final _addressController = TextEditingController(text: '');
  final _descriptionController = TextEditingController(text: '');

  String? _selectedDateIso;
  String? _selectedOrderId;

  ServiceTicketType _selectedServiceType = ServiceTicketType.maintenanceRutin;

  // Upload Foto Kerusakan Mesin (Opsional)
  String? _uploadedPhotoName;
  String? _uploadedFilePath;
  Uint8List? _uploadedFileBytes;

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
    if (widget.initialSerialNumber != null && widget.initialSerialNumber!.isNotEmpty) {
      _serialNumberController.text = widget.initialSerialNumber!;
    }
    if (widget.initialMachineModel != null && widget.initialMachineModel!.isNotEmpty) {
      _machineModelController.text = widget.initialMachineModel!;
    }
    if (widget.initialAddress != null && widget.initialAddress!.isNotEmpty) {
      _addressController.text = widget.initialAddress!;
    }
    if (widget.initialOrderId != null && widget.initialOrderId!.isNotEmpty) {
      _selectedOrderId = widget.initialOrderId;
    }

    _currentTab = widget.initialTab.clamp(0, 2);
    _mainTabController = TabController(
      length: 3,
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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final appState = Provider.of<AppState>(context, listen: false);
      await appState.loadMyCustomerMachines();
      await appState.loadAvailableServiceDates();
      await appState.loadServiceBookingsFromBackend();
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
        case TicketStatus.menungguVerifikasi:
          return const Color(0xFF332A15);
        case TicketStatus.dijadwalkan:
          return const Color(0xFF1E293B);
        case TicketStatus.teknisiOtw:
        case TicketStatus.dalamPengerjaan:
          return const Color(0xFF332A15);
        case TicketStatus.selesai:
          return const Color(0xFF14332A);
        case TicketStatus.dibatalkan:
          return const Color(0xFF3B1E1E);
      }
    } else {
      switch (status) {
        case TicketStatus.menungguVerifikasi:
          return const Color(0xFFFEF3C7);
        case TicketStatus.dijadwalkan:
          return const Color(0xFFEFF6FF); // Pastel blue
        case TicketStatus.teknisiOtw:
        case TicketStatus.dalamPengerjaan:
          return const Color(0xFFFEF3C7); // Pastel amber
        case TicketStatus.selesai:
          return const Color(0xFFECFDF5); // Pastel mint
        case TicketStatus.dibatalkan:
          return const Color(0xFFFEE2E2);
      }
    }
  }

  Color _statusTextColor(TicketStatus status, bool isDark) {
    if (isDark) {
      switch (status) {
        case TicketStatus.menungguVerifikasi:
          return const Color(0xFFFDE047);
        case TicketStatus.dijadwalkan:
          return const Color(0xFF93C5FD);
        case TicketStatus.teknisiOtw:
        case TicketStatus.dalamPengerjaan:
          return const Color(0xFFFDE047);
        case TicketStatus.selesai:
          return const Color(0xFF86EFAC);
        case TicketStatus.dibatalkan:
          return const Color(0xFFFCA5A5);
      }
    } else {
      switch (status) {
        case TicketStatus.menungguVerifikasi:
          return const Color(0xFFB45309);
        case TicketStatus.dijadwalkan:
          return const Color(0xFF1D4ED8);
        case TicketStatus.teknisiOtw:
        case TicketStatus.dalamPengerjaan:
          return const Color(0xFFB45309);
        case TicketStatus.selesai:
          return const Color(0xFF047857);
        case TicketStatus.dibatalkan:
          return const Color(0xFFB91C1C);
      }
    }
  }

  IconData _statusIcon(TicketStatus status) {
    switch (status) {
      case TicketStatus.menungguVerifikasi:
        return Icons.hourglass_top_rounded;
      case TicketStatus.dijadwalkan:
        return Icons.calendar_today_rounded;
      case TicketStatus.teknisiOtw:
      case TicketStatus.dalamPengerjaan:
        return Icons.pending_actions_rounded;
      case TicketStatus.selesai:
        return Icons.check_circle_rounded;
      case TicketStatus.dibatalkan:
        return Icons.cancel_outlined;
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
                  WarrantyClaimScreen(
                    initialSerialNumber: widget.initialSerialNumber,
                    initialMachineModel: widget.initialMachineModel,
                    initialPurchaseDate: widget.initialPurchaseDate,
                    initialOrderId: widget.initialOrderId,
                    initialAddress: widget.initialAddress,
                  ),
                  _buildWarrantyVisitsTab(context, appState, isDark),
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
                icon: Icons.shield_outlined,
                activeIcon: Icons.shield_rounded,
                label: "Klaim Garansi",
                isDark: isDark,
              ),
            ),
            Expanded(
              child: _buildTopTabButton(
                index: 2,
                icon: Icons.calendar_month_outlined,
                activeIcon: Icons.calendar_month_rounded,
                label: "Jadwal Garansi",
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
    final myMachines = appState.myCustomerMachines;
    final bool hasSelectedMachine = _serialNumberController.text.isNotEmpty &&
        _machineModelController.text.isNotEmpty;

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

              if (hasSelectedMachine) ...[
                // Kartu Unit Mesin Terpilih (Bersih, Elegan, Tidak Perlu Input Manual)
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFC07F42).withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC07F42).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.coffee_maker_rounded,
                            size: 22, color: Color(0xFFC07F42)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    _machineModelController.text,
                                    style: GoogleFonts.outfit(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _serialNumberController.text = '';
                                      _machineModelController.text = '';
                                      _selectedOrderId = null;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.white10 : Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.swap_horiz_rounded,
                                            size: 13, color: Color(0xFF2563EB)),
                                        const SizedBox(width: 3),
                                        Text(
                                          "Ganti Mesin",
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF2563EB),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.black26 : Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.qr_code_scanner_rounded,
                                          size: 12, color: Color(0xFF2563EB)),
                                      const SizedBox(width: 4),
                                      Text(
                                        "SN: ${_serialNumberController.text}",
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? Colors.white70 : const Color(0xFF334155),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.verified_rounded,
                                          size: 11, color: Color(0xFF10B981)),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Unit Terpilih",
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF10B981),
                                        ),
                                      ),
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
                ),
              ] else ...[
                // Belum Memilih Mesin: Tampilkan Opsi Pilih Cepat Mesin Customer
                Text(
                  "Pilih Cepat Dari Mesin Anda:",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Pilih mesin yang ingin dijadwalkan kunjungan servis teknisi:",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),

                if (myMachines.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 18,
                            color: isDark ? Colors.white60 : const Color(0xFF64748B)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Belum ada unit mesin yang terdaftar di akun Anda. Anda perlu memiliki pesanan mesin untuk booking servis.",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: isDark ? Colors.white70 : const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: myMachines.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, idx) {
                      final m = myMachines[idx];
                      final model = m['model']?.toString() ?? 'Mesin Manufaktur';
                      final sn = m['serial_number']?.toString() ?? '-';
                      final orderCode = m['order_code']?.toString() ?? '';
                      final address = m['delivery_address']?.toString() ?? '';

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _serialNumberController.text = sn;
                            _machineModelController.text = model;
                            _selectedOrderId = m['order_id']?.toString();
                            if (_addressController.text.isEmpty && address.isNotEmpty) {
                              _addressController.text = address;
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(11),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC07F42).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.coffee_maker_rounded,
                                    size: 18, color: Color(0xFFC07F42)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      model,
                                      style: GoogleFonts.outfit(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "SN: $sn ${orderCode.isNotEmpty ? '• PO: $orderCode' : ''}",
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
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "Pilih",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2563EB),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],

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

              // Selector Tanggal Kunjungan Servis
              _buildAvailableDateSelector(isDark),

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

              // Upload Foto Kerusakan / Error Mesin (Opsional, terutama untuk Perbaikan / Repair Mesin)
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInputLabel(
                    _selectedServiceType == ServiceTicketType.repairMesin
                        ? "Foto Kerusakan / Error Mesin (Opsional)"
                        : "Foto Kendala / Kondisi Mesin (Opsional)",
                    isDark,
                  ),
                  if (_uploadedPhotoName != null)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _uploadedPhotoName = null;
                          _uploadedFilePath = null;
                          _uploadedFileBytes = null;
                        });
                      },
                      child: Text(
                        "Hapus Foto",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE11D48),
                        ),
                      ),
                    ),
                ],
              ),
              InkWell(
                onTap: () async {
                  final result = await FilePickerHelper.showUploadSourceSheet(
                    context: context,
                    title: "Unggah Foto Kerusakan / Kendala Mesin",
                    subtitle: "Ambil foto langsung atau pilih dari galeri (JPG, JPEG, PNG • Maks. 5 MB)",
                    isDark: isDark,
                    brandColor: const Color(0xFFE11D48),
                    allowedExtensions: ['jpg', 'jpeg', 'png'],
                    maxSizeBytes: 5 * 1024 * 1024,
                    allowVideo: false,
                    allowPdf: false,
                    isService: true,
                  );
                  if (result != null) {
                    final bytesLen = result.fileBytes?.length ?? 0;
                    if (bytesLen > 5 * 1024 * 1024) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Ukuran foto melebihi batas maksimal 5 MB!"),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }

                    final ext = result.fileName.toLowerCase().split('.').last;
                    if (!['jpg', 'jpeg', 'png'].contains(ext)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Format berkas harus berupa gambar JPG, JPEG, atau PNG."),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }

                    setState(() {
                      _uploadedPhotoName = result.fileName;
                      _uploadedFilePath = result.filePath;
                      _uploadedFileBytes = result.fileBytes;
                    });
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: _uploadedPhotoName != null
                        ? (isDark ? const Color(0xFF14332A) : const Color(0xFFECFDF5))
                        : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F9FA)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _uploadedPhotoName != null
                          ? const Color(0xFF15803D)
                          : (_selectedServiceType == ServiceTicketType.repairMesin
                              ? (isDark ? const Color(0xFFE11D48).withValues(alpha: 0.5) : const Color(0xFFFECDD3))
                              : (isDark ? Colors.white10 : const Color(0xFFE5E7EB))),
                      width: _uploadedPhotoName != null ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: _uploadedPhotoName != null
                              ? const Color(0xFF15803D).withValues(alpha: 0.15)
                              : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _uploadedPhotoName != null
                              ? Icons.check_circle_rounded
                              : Icons.camera_alt_outlined,
                          color: _uploadedPhotoName != null
                              ? const Color(0xFF15803D)
                              : (isDark ? Colors.white70 : const Color(0xFF0F172A)),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _uploadedPhotoName ?? "Ambil / Unggah Foto Kerusakan (Kamera / Galeri)",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                fontWeight: _uploadedPhotoName != null ? FontWeight.bold : FontWeight.w600,
                                color: _uploadedPhotoName != null
                                    ? const Color(0xFF15803D)
                                    : (isDark ? Colors.white : const Color(0xFF0F172A)),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _uploadedPhotoName != null
                                  ? "Foto siap dilampirkan ke laporan servis teknisi"
                                  : (_selectedServiceType == ServiceTicketType.repairMesin
                                      ? "Disarankan untuk mempermudah identifikasi suku cadang/error (Maks. 5 MB)"
                                      : "Opsional · Format JPG, JPEG, PNG (Maks. 5 MB)"),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_uploadedPhotoName != null)
                        const Icon(Icons.check_rounded, color: Color(0xFF15803D), size: 18)
                      else
                        const Icon(Icons.cloud_upload_outlined, color: Color(0xFF94A3B8), size: 18),
                    ],
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
            onPressed: () async {
              if (_serialNumberController.text.trim().isEmpty ||
                  _machineModelController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Harap pilih mesin yang ingin diservis terlebih dahulu!"),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              if (_dateController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Harap pilih tanggal kunjungan servis yang tersedia!"),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              // Konversi foto kerusakan ke base64 jika dilampirkan (opsional)
              String? base64Photo;
              if (_uploadedFileBytes != null || _uploadedFilePath != null) {
                Uint8List? bytes = _uploadedFileBytes;
                if (bytes == null && _uploadedFilePath != null) {
                  try {
                    bytes = await File(_uploadedFilePath!).readAsBytes();
                  } catch (_) {}
                }

                if (bytes != null && bytes.isNotEmpty) {
                  final ext = (_uploadedPhotoName ?? '').toLowerCase().endsWith('.png') ? 'png' : 'jpeg';
                  base64Photo = 'data:image/$ext;base64,${base64Encode(bytes)}';
                }
              }

              final res = await appState.createServiceTicket(
                serialNumber: _serialNumberController.text.trim(),
                machineModel: _machineModelController.text.trim(),
                orderId: _selectedOrderId ?? widget.initialOrderId,
                type: _selectedServiceType,
                preferredDate: _selectedDateIso ?? _dateController.text.trim(),
                preferredTime: '', // Jam fleksibel sesuai rute teknisi
                address: _addressController.text.trim(),
                issueDescription: _descriptionController.text.trim(),
                photo: base64Photo,
              );

              if (res['success'] == true && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      res['message'] ?? "Pengajuan booking berhasil dikirim! Status Pending menunggu konfirmasi admin pabrik.",
                      style: const TextStyle(fontSize: 12.5),
                    ),
                    backgroundColor: const Color(0xFF15803D),
                    duration: const Duration(seconds: 4),
                  ),
                );

                setState(() {
                  _serialNumberController.clear();
                  _machineModelController.clear();
                  _dateController.clear();
                  _selectedDateIso = null;
                  _addressController.clear();
                  _descriptionController.clear();
                  _selectedOrderId = null;
                  _uploadedPhotoName = null;
                  _uploadedFilePath = null;
                  _uploadedFileBytes = null;
                  _bookingSubTab = 1;
                });
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(res['message'] ?? "Gagal mengirim pengajuan booking ke backend."),
                    backgroundColor: AppColors.error,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            },
            icon: const Icon(Icons.send_rounded, size: 18),
            label: Text(
              "KIRIM PENGAJUAN BOOKING SERVIS",
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

  /// Modal Bottom Sheet Kalender Pemilihan Tanggal dengan Batas Kuota 3 Servis / Hari
  Future<void> _showDatePickerWithQuota(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appState = Provider.of<AppState>(context, listen: false);

    if (appState.availableServiceDates.isEmpty) {
      await appState.loadAvailableServiceDates();
    }

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF111827) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalCtx) {
        final dates = appState.availableServiceDates.isNotEmpty
            ? appState.availableServiceDates
            : List.generate(30, (i) {
                final d = DateTime.now().add(Duration(days: i + 1));
                final isSunday = d.weekday == DateTime.sunday;
                final y = d.year.toString().padLeft(4, '0');
                final m = d.month.toString().padLeft(2, '0');
                final day = d.day.toString().padLeft(2, '0');
                const dayNames = ['', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
                return {
                  'date': '$y-$m-$day',
                  'day_name': dayNames[d.weekday],
                  'formatted_date': '${d.day} ${_getMonthName(d.month)} ${d.year}',
                  'is_open': !isSunday,
                  'technician_standby_count': isSunday ? 0 : 2,
                  'max_quota': isSunday ? 0 : 3,
                  'booked_count': 0,
                  'remaining_quota': isSunday ? 0 : 3,
                  'is_full': isSunday,
                  'can_book': !isSunday,
                  'notes': isSunday ? 'Tutup / Libur' : 'Tersedia 3 dari 3 slot',
                };
              });

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.82,
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle Bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pilih Tanggal Servis",
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Maksimal kuota 3 servis per hari (Penuh tidak dapat dipilih)",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(modalCtx),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: isDark ? Colors.white70 : const Color(0xFF64748B),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // List of Dates
              Expanded(
                child: ListView.separated(
                  itemCount: dates.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (listCtx, idx) {
                    final item = dates[idx];
                    final dateStr = item['date']?.toString() ?? '';
                    final dayName = item['day_name']?.toString() ?? '';
                    final formattedDate = item['formatted_date']?.toString() ?? dateStr;
                    final isFull = item['is_full'] == true || (item['remaining_quota'] ?? 1) <= 0;
                    final isOpen = item['is_open'] != false;
                    final canBook = item['can_book'] == true && !isFull && isOpen;
                    final remaining = (item['remaining_quota'] as num?)?.toInt() ?? (isFull ? 0 : 3);
                    final isSelected = _selectedDateIso == dateStr;

                    return InkWell(
                      onTap: canBook
                          ? () {
                              setState(() {
                                _selectedDateIso = dateStr;
                                _dateController.text = "$dayName, $formattedDate";
                              });
                              Navigator.pop(modalCtx);
                            }
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isFull
                                        ? "Tanggal ini sudah penuh (maksimal 3 servis per hari). Silakan pilih hari lain."
                                        : "Layanan servis tidak beroperasi pada hari tersebut.",
                                  ),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: const Color(0xFFDC2626),
                                ),
                              );
                            },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.3) : const Color(0xFFEFF6FF))
                              : (!canBook
                                  ? (isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF8FAFC))
                                  : (isDark ? const Color(0xFF1F2937) : Colors.white)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF2563EB)
                                : (!canBook
                                    ? (isDark ? Colors.white10 : const Color(0xFFE2E8F0))
                                    : (isDark ? Colors.white12 : const Color(0xFFE2E8F0))),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Calendar Icon
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: !canBook
                                    ? (isDark ? Colors.white10 : const Color(0xFFE2E8F0))
                                    : (isSelected
                                        ? const Color(0xFF2563EB)
                                        : (isDark ? const Color(0xFF374151) : const Color(0xFFF1F5F9))),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                !canBook ? Icons.block_rounded : Icons.calendar_today_rounded,
                                size: 18,
                                color: !canBook
                                    ? (isDark ? Colors.white38 : const Color(0xFF94A3B8))
                                    : (isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF475569))),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Date info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "$dayName, $formattedDate",
                                    style: GoogleFonts.outfit(
                                      fontSize: 13.5,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                      color: !canBook
                                          ? (isDark ? Colors.white38 : const Color(0xFF94A3B8))
                                          : (isDark ? Colors.white : const Color(0xFF0F172A)),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    !canBook
                                        ? (isFull ? "Penuh (Maks. 3/3 servis terisi)" : "Tutup / Libur")
                                        : "Tersedia $remaining dari 3 slot servis",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: !canBook
                                          ? (isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626))
                                          : (isDark ? const Color(0xFF34D399) : const Color(0xFF059669)),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Badge Status
                            if (!canBook)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF7F1D1D).withValues(alpha: 0.3)
                                      : const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF991B1B)
                                        : const Color(0xFFFCA5A5),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.cancel_outlined,
                                      size: 11,
                                      color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isFull ? "Penuh" : "Tutup",
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF2563EB)
                                      : (isDark
                                          ? const Color(0xFF064E3B).withValues(alpha: 0.3)
                                          : const Color(0xFFDCFCE7)),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF1D4ED8)
                                        : (isDark ? const Color(0xFF065F46) : const Color(0xFF86EFAC)),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  isSelected ? "Terpilih" : "Tersedia",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF15803D)),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Card Selector Tanggal Kunjungan Servis
  Widget _buildAvailableDateSelector(bool isDark) {
    final hasSelection = _dateController.text.isNotEmpty;
    return InkWell(
      onTap: () => _showDatePickerWithQuota(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasSelection
                ? const Color(0xFF2563EB).withValues(alpha: 0.5)
                : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
            width: hasSelection ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.calendar_month_rounded,
                      size: 18, color: Color(0xFF2563EB)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "TANGGAL RENCANA KUNJUNGAN",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2563EB),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasSelection ? _dateController.text : "Pilih Tanggal Kunjungan Servis",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        hasSelection ? "Ganti" : "Pilih Tanggal",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(Icons.edit_calendar_rounded,
                          size: 14, color: Color(0xFF2563EB)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 13, color: Color(0xFF10B981)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      hasSelection
                          ? "Tanggal dipilih. Maksimal kuota 3 servis per hari. Admin akan mengonfirmasi penugasan teknisi."
                          : "Klik untuk memilih tanggal (kuota maksimal 3 servis per hari). Tanggal penuh tidak dapat diklik.",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF047857),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
              "Jadwalkan kunjungan teknisi untuk pemeliharaan unit mesin Anda.",
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

                // Schedule & Location (Hari Kunjungan Kustom & Lokasi)
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 12, color: Color(0xFF2563EB)), // Blue
                    const SizedBox(width: 5),
                    Text(
                      t.preferredDate,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
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

                if (t.photoUrl != null && t.photoUrl!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.photo_camera_rounded, size: 13, color: Color(0xFFE11D48)),
                      const SizedBox(width: 4),
                      Text(
                        "Foto Kerusakan Terlampir",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE11D48),
                        ),
                      ),
                    ],
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
                      Icon(
                        t.technicianName != null && t.technicianName!.isNotEmpty
                            ? Icons.engineering_rounded
                            : Icons.hourglass_top_rounded,
                        size: 15,
                        color: t.technicianName != null && t.technicianName!.isNotEmpty
                            ? const Color(0xFF4F46E5)
                            : const Color(0xFFD97706),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          t.technicianName != null && t.technicianName!.isNotEmpty
                              ? "${t.technicianName}"
                              : "Menunggu Penugasan Teknisi",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ),

                      if (t.technicianName != null && t.technicianName!.isNotEmpty) ...[
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

                      if (isDone) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF10B981)),
                              const SizedBox(width: 4),
                              Text(
                                "Tuntas",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF10B981),
                                ),
                              ),
                            ],
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

  /// Tab ke-3: Menampilkan Penjadwalan Kunjungan Perbaikan Teknisi untuk Klaim Garansi yang telah diverifikasi Admin Pabrik
  Widget _buildWarrantyVisitsTab(BuildContext context, AppState appState, bool isDark) {
    final visits = appState.scheduledWarrantyVisits;

    if (visits.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  size: 38,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                "Belum Ada Jadwal Kunjungan Garansi",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Setelah pengajuan klaim garansi Anda diverifikasi valid oleh Tim Engineering Pabrik, jadwal kedatangan teknisi dan nomor kontak akan otomatis ditampilkan di sini.",
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _currentTab = 1;
                    _mainTabController.animateTo(1);
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF047857),
                  side: const BorderSide(color: Color(0xFF047857), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                icon: const Icon(Icons.shield_outlined, size: 16),
                label: const Text(
                  "Ajukan Klaim Garansi Baru",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await appState.loadWarrantyClaimsFromBackend();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: visits.length,
        itemBuilder: (context, index) {
          final item = visits[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 12, color: Color(0xFF2563EB)),
                          const SizedBox(width: 5),
                          Text(
                            item.friendlyStatus,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      item.claimNumber,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Unit Mesin
                Text(
                  item.machineModel,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "No. Seri: ${item.serialNumber}",
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF047857),
                  ),
                ),
                const SizedBox(height: 12),

                // Jadwal & Teknisi Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 15, color: Color(0xFF2563EB)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Kunjungan: ${item.scheduledVisitDate ?? '-'} · ${item.scheduledVisitTime ?? '10:00 WIB'}",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.person_rounded, size: 15, color: Color(0xFF047857)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Teknisi: ${item.technicianName ?? 'Tim Teknisi Garansi Pabrik'}${item.technicianPhone != null && item.technicianPhone!.isNotEmpty ? ' (${item.technicianPhone})' : ''}",
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark ? Colors.white70 : const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (item.visitAddress != null && item.visitAddress!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on_rounded, size: 15, color: Color(0xFFE11D48)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.visitAddress!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isDark ? Colors.white60 : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                if (item.responseNotes != null && item.responseNotes!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    "Catatan Pabrik: ${item.responseNotes}",
                    style: TextStyle(
                      fontSize: 11.5,
                      fontStyle: FontStyle.italic,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}