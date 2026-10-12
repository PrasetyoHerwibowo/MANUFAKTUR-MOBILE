import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/file_picker_helper.dart';

class WarrantyClaimScreen extends StatefulWidget {
  const WarrantyClaimScreen({super.key});

  @override
  State<WarrantyClaimScreen> createState() => _WarrantyClaimScreenState();
}

class _WarrantyClaimScreenState extends State<WarrantyClaimScreen> {
  final _serialController = TextEditingController(text: 'SN-2025-TITAN-881');
  final _purchaseDateController = TextEditingController(text: '15 Januari 2026');
  final _descriptionController = TextEditingController(
      text: 'Sensor display sentuh grinder TitanGrind tidak merespon saat suhu ruang naik.');

  String? _uploadedPhotoName;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final claims = appState.warrantyClaims;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Garansi 2 Tahun
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade800,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified, color: Colors.amber, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Klaim Garansi Manufaktur Official",
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Garansi suku cadang & unit penuh selama 2 tahun sejak tanggal serah terima.",
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

          // Form Klaim
          _buildSectionTitle("Form Pengajuan Klaim Garansi"),
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
                  controller: _serialController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.qr_code),
                    hintText: "Cek stiker di belakang bodi mesin...",
                  ),
                ),
                const SizedBox(height: 14),

                _buildLabel("Tanggal Pembelian / Serah Terima Unit"),
                TextField(
                  controller: _purchaseDateController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                ),
                const SizedBox(height: 14),

                _buildLabel("Deskripsi Detail Kendala / Kerusakan"),
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: "Jelaskan bagian komponen yang mengalami kendala...",
                  ),
                ),
                const SizedBox(height: 14),

                _buildLabel("Upload Foto / Video Kerusakan Komponen"),
                InkWell(
                  onTap: () async {
                    final name = await FilePickerHelper.pickFileName();
                    setState(() {
                      _uploadedPhotoName =
                          name ?? 'foto_kerusakan_display_grinder.jpg';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _uploadedPhotoName != null
                          ? Colors.green.shade50
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _uploadedPhotoName != null
                            ? Colors.green
                            : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _uploadedPhotoName != null
                              ? Icons.check_circle
                              : Icons.add_a_photo_outlined,
                          color: _uploadedPhotoName != null
                              ? Colors.green
                              : AppColors.secondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _uploadedPhotoName ?? "Unggah Foto / Video Komponen",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: _uploadedPhotoName != null
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      final photo =
                          _uploadedPhotoName ?? 'foto_kerusakan_display_grinder.jpg';
                      appState.submitWarrantyClaim(
                        serialNumber: _serialController.text,
                        purchaseDate: _purchaseDateController.text,
                        damageDescription: _descriptionController.text,
                        photoPath: photo,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Klaim garansi berhasil dikirim ke pabrik!"),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    child: const Text("KIRIM KLAIM GARANSI"),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Riwayat Klaim
          _buildSectionTitle("Status Klaim Garansi (${claims.length})"),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: claims.length,
            itemBuilder: (context, index) {
              final clm = claims[index];
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
                        Text(clm.claimNumber,
                            style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            clm.status,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text("No. Seri: ${clm.serialNumber}",
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(clm.damageDescription,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              );
            },
          ),
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
