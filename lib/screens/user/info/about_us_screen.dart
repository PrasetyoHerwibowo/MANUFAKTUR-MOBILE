import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Tentang Kami"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Header Banner
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.coffee_maker,
                        color: AppColors.secondary, size: 50),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "PT KOPI INDUSTRI PRECISION",
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    "Pabrik Manufaktur Mesin Kopi Espresso & Roaster B2B",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Profile Card
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
                  Text(
                    "Visi & Misi Manufaktur",
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Kami adalah pabrikan manufaktur mesin kopi komersial pertama di Indonesia dengan standar kualitas presisi Eropa. Seluruh unit kami dirakit dengan material Stainless Steel 304 food-grade, dual boiler tembaga murni, serta kontrol suhu PID berteknologi tinggi untuk mendukung pertumbuhan ekosistem roastery & kafe B2B nasional.",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      height: 1.6,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Certifications
            Text(
              "Sertifikasi Kualitas Manufaktur",
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                _buildCertCard(
                  icon: Icons.verified_user,
                  title: "ISO 9001:2015",
                  subtitle: "Sistem Manajemen Mutu Manufaktur",
                ),
                const SizedBox(width: 12),
                _buildCertCard(
                  icon: Icons.security,
                  title: "Sertifikat CE",
                  subtitle: "Standar Keamanan Listrik & Tekanan",
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Factory Specs
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Kapasitas Manufaktur Pabrik",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFactoryStat("Kapasitas Produksi", "50 Unit / Bulan"),
                  _buildFactoryStat("Luas Workshop", "3.500 m² (Kawasan Industri Cikarang)"),
                  _buildFactoryStat("Teknisi & Engineer", "45 Ahli Manufaktur Precision"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertCard(
      {required IconData icon, required String title, required String subtitle}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.secondary, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFactoryStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  color: Colors.white70, fontSize: 12)),
          Text(value,
              style: GoogleFonts.plusJakartaSans(
                  color: AppColors.secondaryLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
        ],
      ),
    );
  }
}
