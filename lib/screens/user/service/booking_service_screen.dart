import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state.dart';
import '../../../core/models/service_ticket_model.dart';
import '../../../core/theme/app_colors.dart';
import 'warranty_claim_screen.dart';
import 'sparepart_catalog_screen.dart';

class BookingServiceScreen extends StatefulWidget {
  const BookingServiceScreen({super.key});

  @override
  State<BookingServiceScreen> createState() => _BookingServiceScreenState();
}

class _BookingServiceScreenState extends State<BookingServiceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Booking Form State
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
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _serialNumberController.dispose();
    _machineModelController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Helper: get color pair for ticket status badge
  Color _statusBgColor(TicketStatus status, bool isDark) {
    switch (status) {
      case TicketStatus.dijadwalkan:
        return isDark ? const Color(0xFF1E3A5F) : const Color(0xFFEFF6FF);
      case TicketStatus.teknisiOtw:
        return isDark ? const Color(0xFF4A2810) : const Color(0xFFFFF7ED);
      case TicketStatus.dalamPengerjaan:
        return isDark ? const Color(0xFF3D3010) : const Color(0xFFFEFCE8);
      case TicketStatus.selesai:
        return isDark ? const Color(0xFF14332A) : const Color(0xFFF0FDF4);
    }
  }

  Color _statusTextColor(TicketStatus status, bool isDark) {
    switch (status) {
      case TicketStatus.dijadwalkan:
        return isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF);
      case TicketStatus.teknisiOtw:
        return isDark ? const Color(0xFFFDBA74) : const Color(0xFFC2410C);
      case TicketStatus.dalamPengerjaan:
        return isDark ? const Color(0xFFFDE047) : const Color(0xFFA16207);
      case TicketStatus.selesai:
        return isDark ? const Color(0xFF86EFAC) : const Color(0xFF15803D);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final tickets = appState.serviceTickets;

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
            labelColor: isDark ? AppColors.secondaryLight : AppColors.secondary,
            unselectedLabelColor:
                isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
            labelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            dividerColor: isDark ? Colors.white10 : AppColors.border,
            tabs: const [
              Tab(text: "Booking Servis"),
              Tab(text: "Klaim Garansi"),
              Tab(text: "Katalog Sparepart"),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Booking Maintenance / Servis Form & History
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // — Header Banner with gradient
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF1E293B), const Color(0xFF334155)]
                          : [const Color(0xFF0B111A), const Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: isDark
                        ? Border.all(color: Colors.white.withValues(alpha: 0.08))
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.handyman_outlined,
                            color: AppColors.secondary, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Layanan Teknisi On-Site",
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Jadwalkan kunjungan teknisi resmi untuk perawatan rutin & perbaikan.",
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF94A3B8),
                                fontSize: 11,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // — Section: Form
                _buildSectionTitle("Form Booking Servis", isDark),
                const SizedBox(height: 4),

                // Serial Number & Machine Model
                _buildFieldCard(
                  isDark: isDark,
                  children: [
                    _buildLabel("Nomor Seri Mesin", isDark),
                    TextField(
                      controller: _serialNumberController,
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.qr_code_scanner, size: 20,
                            color: isDark ? Colors.white54 : null),
                        hintText: "Contoh: SN-2024-CRAFT-092",
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLabel("Model / Tipe Mesin Kopi", isDark),
                    TextField(
                      controller: _machineModelController,
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.coffee_maker, size: 20,
                            color: isDark ? Colors.white54 : null),
                        hintText: "Contoh: Artisan Espresso Craft Pro 2G",
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Service Type
                _buildFieldCard(
                  isDark: isDark,
                  children: [
                    _buildLabel("Kategori Layanan Servis", isDark),
                    DropdownButtonFormField<ServiceTicketType>(
                      initialValue: _selectedServiceType,
                      dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.build_outlined, size: 20,
                            color: isDark ? Colors.white54 : null),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: ServiceTicketType.maintenanceRutin,
                          child: Text("Maintenance Rutin (6 Bulan)",
                              style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary)),
                        ),
                        DropdownMenuItem(
                          value: ServiceTicketType.kalibrasiBoiler,
                          child: Text("Kalibrasi & Descaling Boiler",
                              style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary)),
                        ),
                        DropdownMenuItem(
                          value: ServiceTicketType.repairMesin,
                          child: Text("Perbaikan / Repair Mesin",
                              style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary)),
                        ),
                        DropdownMenuItem(
                          value: ServiceTicketType.emergencyService,
                          child: Text("Emergency Service 24/7",
                              style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary)),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedServiceType = val;
                          });
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Date & Time
                _buildFieldCard(
                  isDark: isDark,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Tanggal Datang", isDark),
                              TextField(
                                controller: _dateController,
                                readOnly: true,
                                style: TextStyle(
                                  color: isDark ? Colors.white : AppColors.textPrimary,
                                ),
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now().add(const Duration(days: 2)),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(const Duration(days: 60)),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _dateController.text =
                                          "${picked.day} ${_getMonthName(picked.month)} ${picked.year}";
                                    });
                                  }
                                },
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.calendar_today, size: 18,
                                      color: isDark ? Colors.white54 : null),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Jam Kunjungan", isDark),
                              TextField(
                                controller: _timeController,
                                readOnly: true,
                                style: TextStyle(
                                  color: isDark ? Colors.white : AppColors.textPrimary,
                                ),
                                onTap: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: const TimeOfDay(hour: 10, minute: 0),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _timeController.text =
                                          "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')} WIB";
                                    });
                                  }
                                },
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.access_time, size: 18,
                                      color: isDark ? Colors.white54 : null),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Address & Description
                _buildFieldCard(
                  isDark: isDark,
                  children: [
                    _buildLabel("Alamat Lokasi Kafe / Pabrik", isDark),
                    TextField(
                      controller: _addressController,
                      minLines: 1,
                      maxLines: 4,
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        prefixIcon: Icon(
                          Icons.location_on_outlined,
                          size: 20,
                          color: isDark ? Colors.white54 : AppColors.textMuted,
                        ),
                        hintText: "Alamat lengkap lokasi kafe / pabrik...",
                        hintStyle: TextStyle(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLabel("Catatan Keluhan / Instruksi Teknisi", isDark),
                    TextField(
                      controller: _descriptionController,
                      minLines: 1,
                      maxLines: 4,
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        prefixIcon: Icon(
                          Icons.notes_outlined,
                          size: 20,
                          color: isDark ? Colors.white54 : AppColors.textMuted,
                        ),
                        hintText:
                            "Deskripsikan keluhan atau bagian yang ingin diservis...",
                        hintStyle: TextStyle(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      appState.createServiceTicket(
                        serialNumber: _serialNumberController.text,
                        machineModel: _machineModelController.text,
                        type: _selectedServiceType,
                        preferredDate: _dateController.text,
                        preferredTime: _timeController.text,
                        address: _addressController.text,
                        issueDescription: _descriptionController.text,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Jadwal servis berhasil dikonfirmasi!"),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_circle_outline, size: 20),
                    label: Text(
                      "KONFIRMASI BOOKING",
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // — Section: Ticket History
                Row(
                  children: [
                    _buildSectionTitle("Tiket Servis Terdaftar", isDark),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.secondary.withValues(alpha: 0.2)
                            : AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "${tickets.length}",
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFFFCA5A5) : AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    final t = tickets[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.border,
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
                          // Ticket header row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(t.ticketNumber,
                                  style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : AppColors.primary)),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _statusBgColor(t.status, isDark),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  t.statusTitle,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: _statusTextColor(t.status, isDark),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Service type
                          Text(t.typeName,
                              style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: isDark ? Colors.white : AppColors.textPrimary)),
                          const SizedBox(height: 4),

                          // Info row
                          Row(
                            children: [
                              Icon(Icons.confirmation_number_outlined,
                                  size: 13,
                                  color: isDark ? Colors.white38 : AppColors.textMuted),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  "${t.serialNumber} · ${t.preferredDate} ${t.preferredTime}",
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: isDark ? Colors.white60 : AppColors.textSecondary),
                                ),
                              ),
                            ],
                          ),

                          // Technician info
                          if (t.technicianName != null) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Divider(
                                height: 1,
                                color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.border,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.secondary.withValues(alpha: 0.2)
                                        : AppColors.secondary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.engineering,
                                      size: 14, color: AppColors.secondary),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "${t.technicianName} (${t.technicianPhone})",
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : AppColors.textPrimary),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Tab 2: Klaim Garansi Form
          const WarrantyClaimScreen(),

          // Tab 3: Pemesanan Sparepart Catalog
          const SparepartCatalogScreen(),
        ],
      ),
    );
  }

  /// Card wrapper for form field groups
  Widget _buildFieldCard({required List<Widget> children, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: isDark ? Colors.white70 : AppColors.textSecondary,
        ),
      ),
    );
  }
}
