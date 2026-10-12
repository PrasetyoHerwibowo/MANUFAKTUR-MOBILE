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
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final tickets = appState.serviceTickets;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.handyman_outlined,
                          color: AppColors.secondary, size: 36),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Layanan Teknisi On-Site Pabrik",
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Jadwalkan kunjungan teknisi resmi untuk perawatan rutin & perbaikan.",
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Booking Form
                _buildSectionTitle("Form Jadwal Teknisi Datang"),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Nomor Seri Mesin (Serial Number)"),
                      TextField(
                        controller: _serialNumberController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.qr_code_scanner),
                          hintText: "Contoh: SN-2024-CRAFT-092",
                        ),
                      ),
                      const SizedBox(height: 14),

                      _buildLabel("Model / Tipe Mesin Kopi"),
                      TextField(
                        controller: _machineModelController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.coffee_maker),
                          hintText: "Contoh: Artisan Espresso Craft Pro 2G",
                        ),
                      ),
                      const SizedBox(height: 14),

                      _buildLabel("Kategori Layanan Servis"),
                      DropdownButtonFormField<ServiceTicketType>(
                        initialValue: _selectedServiceType,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.build),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: ServiceTicketType.maintenanceRutin,
                            child: Text("Maintenance Rutin (6 Bulan)"),
                          ),
                          DropdownMenuItem(
                            value: ServiceTicketType.kalibrasiBoiler,
                            child: Text("Kalibrasi & Descaling Boiler"),
                          ),
                          DropdownMenuItem(
                            value: ServiceTicketType.repairMesin,
                            child: Text("Perbaikan / Repair Mesin"),
                          ),
                          DropdownMenuItem(
                            value: ServiceTicketType.emergencyService,
                            child: Text("Emergency Service 24/7"),
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
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Tanggal Datang"),
                                TextField(
                                  controller: _dateController,
                                  readOnly: true,
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
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.calendar_today),
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
                                _buildLabel("Jam Kunjungan"),
                                TextField(
                                  controller: _timeController,
                                  readOnly: true,
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
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.access_time),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      _buildLabel("Alamat Lokasi Kafe / Pabrik"),
                      TextField(
                        controller: _addressController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.location_on),
                        ),
                      ),
                      const SizedBox(height: 14),

                      _buildLabel("Catatan Keluhan / Instruksi Teknisi"),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: "Deskripsikan keluhan atau bagian yang ingin diservis...",
                        ),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
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
                          child: const Text("KONFIRMASI BOOKING SERVIS"),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Ticket History List
                _buildSectionTitle("Tiket Servis Terdaftar (${tickets.length})"),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    final t = tickets[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(t.ticketNumber,
                                  style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary)),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  t.statusTitle,
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade800),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(t.typeName,
                              style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                          Text("No. Seri: ${t.serialNumber} • ${t.preferredDate} ${t.preferredTime}",
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11, color: AppColors.textSecondary)),
                          if (t.technicianName != null) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.person,
                                    size: 14, color: AppColors.secondary),
                                const SizedBox(width: 4),
                                Text(
                                  "Teknisi: ${t.technicianName} (${t.technicianPhone})",
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
