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
  void dispose() {
    _serialController.dispose();
    _purchaseDateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final claims = appState.warrantyClaims;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // — Banner Garansi with gradient
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF14532D), const Color(0xFF166534)]
                    : [Colors.green.shade800, Colors.green.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: isDark
                  ? Border.all(color: Colors.green.withValues(alpha: 0.2))
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.verified, color: Colors.amber, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Klaim Garansi Official",
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Garansi suku cadang & unit penuh selama 2 tahun sejak serah terima.",
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white70,
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

          // — Section: Form Klaim
          _buildSectionTitle("Form Pengajuan Klaim", isDark),
          const SizedBox(height: 4),

          // Serial Number & Purchase Date
          _buildFieldCard(
            isDark: isDark,
            children: [
              _buildLabel("Nomor Seri Mesin", isDark),
              TextField(
                controller: _serialController,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.qr_code, size: 20,
                      color: isDark ? Colors.white54 : null),
                  hintText: "Cek stiker di belakang bodi mesin...",
                ),
              ),
              const SizedBox(height: 16),
              _buildLabel("Tanggal Pembelian / Serah Terima", isDark),
              TextField(
                controller: _purchaseDateController,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.calendar_today, size: 18,
                      color: isDark ? Colors.white54 : null),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Description & Upload
          _buildFieldCard(
            isDark: isDark,
            children: [
              _buildLabel("Deskripsi Kendala / Kerusakan", isDark),
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
                  hintText: "Jelaskan bagian komponen yang mengalami kendala...",
                  hintStyle: TextStyle(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildLabel("Foto / Video Kerusakan", isDark),
              InkWell(
                onTap: () async {
                  final name = await FilePickerHelper.pickFileName();
                  setState(() {
                    _uploadedPhotoName =
                        name ?? 'foto_kerusakan_display_grinder.jpg';
                  });
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: _uploadedPhotoName != null
                        ? (isDark ? const Color(0xFF14332A) : Colors.green.shade50)
                        : (isDark ? AppColors.darkBackground : AppColors.background),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _uploadedPhotoName != null
                          ? (isDark ? Colors.green.shade700 : Colors.green.shade300)
                          : (isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _uploadedPhotoName != null
                            ? Icons.check_circle
                            : Icons.add_a_photo_outlined,
                        color: _uploadedPhotoName != null
                            ? (isDark ? const Color(0xFF86EFAC) : Colors.green)
                            : (isDark ? Colors.white38 : AppColors.textMuted),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _uploadedPhotoName ?? "Unggah Foto / Video Komponen",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: _uploadedPhotoName != null
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: _uploadedPhotoName != null
                                ? (isDark ? const Color(0xFF86EFAC) : Colors.green.shade800)
                                : (isDark ? Colors.white60 : AppColors.textSecondary),
                          ),
                        ),
                      ),
                      if (_uploadedPhotoName == null)
                        Icon(Icons.upload_outlined,
                            size: 18,
                            color: isDark ? Colors.white38 : AppColors.textMuted),
                    ],
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
              icon: const Icon(Icons.send_rounded, size: 18),
              label: Text(
                "KIRIM KLAIM GARANSI",
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // — Section: Riwayat Klaim
          Row(
            children: [
              _buildSectionTitle("Status Klaim Garansi", isDark),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "${claims.length}",
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFF86EFAC) : Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: claims.length,
            itemBuilder: (context, index) {
              final clm = claims[index];

              // Dynamic status color
              final isApproved = clm.status.toLowerCase().contains('disetujui');
              final isRejected = clm.status.toLowerCase().contains('ditolak');

              final statusBg = isApproved
                  ? (isDark ? const Color(0xFF14332A) : const Color(0xFFF0FDF4))
                  : isRejected
                      ? (isDark ? const Color(0xFF3B1010) : const Color(0xFFFEF2F2))
                      : (isDark ? const Color(0xFF3D2A10) : const Color(0xFFFFF7ED));
              final statusFg = isApproved
                  ? (isDark ? const Color(0xFF86EFAC) : const Color(0xFF15803D))
                  : isRejected
                      ? (isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626))
                      : (isDark ? const Color(0xFFFDBA74) : const Color(0xFFC2410C));

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(clm.claimNumber,
                            style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.primary)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            clm.status,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: statusFg,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.confirmation_number_outlined,
                            size: 13,
                            color: isDark ? Colors.white38 : AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text("No. Seri: ${clm.serialNumber}",
                            style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: isDark ? Colors.white : AppColors.textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(clm.damageDescription,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: isDark ? Colors.white60 : AppColors.textSecondary,
                            height: 1.4)),
                  ],
                ),
              );
            },
          ),
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
