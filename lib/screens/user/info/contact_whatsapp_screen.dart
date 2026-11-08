import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state.dart';
import '../../../core/theme/app_colors.dart';

class ContactWhatsappScreen extends StatelessWidget {
  final String? ticketNumber;
  final String? machineContext;

  const ContactWhatsappScreen({
    super.key,
    this.ticketNumber,
    this.machineContext,
  });

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;

    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtextColor = isDark ? AppColors.darkTextSecondary : AppColors.textMuted;
    final inputFill = isDark ? const Color(0xFF18181B) : const Color(0xFFF4F4F5);

    final bool hasTicket = ticketNumber != null && ticketNumber!.isNotEmpty;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          hasTicket ? "WhatsApp Lead Engineer" : "Pusat Bantuan & WhatsApp Sales",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16.5,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: textColor,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: borderColor, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. JIKA ADA TIKET: BANNER TIKET MONOKROM
            if (hasTicket) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF18181B) : const Color(0xFF09090B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: Colors.white24, width: 0.8),
                          ),
                          child: Text(
                            "TIKET KUSTOMISASI AKTIF",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          ticketNumber!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      machineContext ?? "Custom Industrial Machine",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Salin atau sebutkan nomor tiket di atas saat terhubung di chat WhatsApp agar Engineer PT MDI dapat langsung membuka riwayat spesifikasi Anda.",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white70,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              // Banner Pengantar Umum (Monokrom Zinc)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF18181B) : const Color(0xFF09090B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Official Support PT MDI",
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "Konsultasi penawaran resmi PO, kustomisasi teknis mesin, serta asistensi teknisi pabrik.",
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 11,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 2. KARTU KONTAK TUNGGAL RESMI (LEAD ENGINEER & OFFICIAL SUPPORT)
            _buildSectionLabel("Kontak Resmi Lead Engineer", textColor),

            _buildContactCard(
              context: context,
              isDark: isDark,
              cardBg: cardBg,
              borderColor: borderColor,
              textColor: textColor,
              subtextColor: subtextColor,
              pillBadgeText: "LEAD ENGINEER & SUPPORT",
              title: "Lead Engineer & Sales Pabrik",
              phoneDisplay: "+62 812-9876-5432",
              desc: "Konsultasi langsung dengan Lead Engineer untuk pembahasan gambar teknik 3D, diskusi modifikasi kustom, penawaran harga PO, serta jadwal kunjungan workshop.",
              buttonLabel: hasTicket ? "Chat Lead Engineer via WhatsApp" : "Buka Chat WhatsApp Resmi",
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF09090B),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    content: Text(
                      hasTicket
                          ? "Membuka WhatsApp Lead Engineer untuk Tiket $ticketNumber..."
                          : "Membuka WhatsApp Resmi Lead Engineer (+62 812-9876-5432)...",
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 18),

            // 3. KARTU ALAMAT WORKSHOP & PABRIK (MONOKROM INDUSTRIAL)
            _buildSectionLabel("Lokasi Workshop & Fabrikasi", textColor),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: inputFill,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderColor, width: 0.8),
                        ),
                        child: Icon(
                          Icons.precision_manufacturing_rounded,
                          color: textColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "PT Manufactur Dynamic Indonesia",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                                letterSpacing: -0.2,
                              ),
                            ),
                            Text(
                              "Pabrik Perakitan Mesin Kopi & Kakao",
                              style: GoogleFonts.inter(
                                fontSize: 10.5,
                                color: subtextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: borderColor, height: 1),
                  const SizedBox(height: 10),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: subtextColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Kawasan Industri Jababeka V, Blok C-12, Cikarang, Jawa Barat 17530",
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: textColor,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.schedule_outlined, size: 16, color: subtextColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Senin – Sabtu (08.00 – 17.00 WIB)\nKunjungan fisik untuk uji coba mesin wajib reservasi terlebih dahulu.",
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: subtextColor,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: textColor,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required BuildContext context,
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
    required Color textColor,
    required Color subtextColor,
    required String pillBadgeText,
    required String title,
    required String phoneDisplay,
    required String desc,
    required String buttonLabel,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: borderColor, width: 0.8),
                ),
                child: Text(
                  pillBadgeText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    color: isDark ? Colors.white70 : const Color(0xFF09090B),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                phoneDisplay,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            desc,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: subtextColor,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),

          // Inverted Zinc Pill Button (999px)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white : const Color(0xFF09090B),
                foregroundColor: isDark ? const Color(0xFF09090B) : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                elevation: 0,
              ),
              icon: Icon(
                Icons.chat_bubble_rounded,
                size: 15,
                color: isDark ? const Color(0xFF09090B) : Colors.white,
              ),
              label: Text(
                buttonLabel,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
