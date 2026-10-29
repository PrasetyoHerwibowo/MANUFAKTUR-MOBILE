import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state.dart';
import '../../../core/models/service_ticket_model.dart';
import '../../../core/theme/app_colors.dart';

class AdminTicketsScreen extends StatelessWidget {
  const AdminTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final tickets = appState.serviceTickets;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Manajemen Tiket Servis & Maintenance Datang",
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              "Lihat permintaan kunjungan teknisi dari user, tetapkan teknisi, & perbarui status pengerjaan.",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 20),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final t = tickets[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.ticketNumber,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text(
                                  "${t.companyName} • Seri: ${t.serialNumber}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              t.statusTitle,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal.shade800),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),

                      Text("Layanan: ${t.typeName}",
                          style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      Text("Jadwal Datang: ${t.preferredDate} ${t.preferredTime}",
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 11, color: AppColors.textSecondary)),
                      Text("Alamat: ${t.address}",
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 11, color: AppColors.textSecondary)),
                      Text("Keluhan: ${t.issueDescription}",
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 11, color: AppColors.textMuted)),

                      if (t.technicianName != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          "Teknisi Bertugas: ${t.technicianName} (${t.technicianPhone})",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              _showAssignTechModal(context, appState, t);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                            ),
                            icon: const Icon(Icons.person_add, size: 16),
                            label: const Text("Tugaskan Teknisi & Update Status"),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignTechModal(
      BuildContext context, AppState appState, ServiceTicketModel t) {
    final techCtrl = TextEditingController(text: t.technicianName ?? 'Teknisi Budi Santoso');
    TicketStatus status = t.status;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text("Update Tiket Servis",
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("No. Tiket: ${t.ticketNumber}"),
              const SizedBox(height: 12),
              TextField(
                controller: techCtrl,
                decoration: const InputDecoration(labelText: "Nama Teknisi Bertugas"),
              ),
              const SizedBox(height: 12),
              const Text("Pilih Status Pengerjaan:"),
              DropdownButton<TicketStatus>(
                value: status,
                isExpanded: true,
                items: TicketStatus.values.map((st) {
                  return DropdownMenuItem(
                    value: st,
                    child: Text(ServiceTicketModel(
                      id: '',
                      ticketNumber: '',
                      companyName: '',
                      serialNumber: '',
                      machineModel: '',
                      type: ServiceTicketType.maintenanceRutin,
                      preferredDate: '',
                      preferredTime: '',
                      address: '',
                      issueDescription: '',
                      status: st,
                    ).statusTitle),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setModalState(() {
                      status = val;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                appState.updateTicketStatus(t.id, status, techCtrl.text);
                Navigator.pop(context);
              },
              child: const Text("Simpan Update"),
            ),
          ],
        ),
      ),
    );
  }
}
