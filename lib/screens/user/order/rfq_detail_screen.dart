import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/models/custom_order_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/app_state.dart';
import '../../../widgets/pdf_preview_dialog.dart';
import '../../../widgets/status_badge.dart';
import '../info/contact_whatsapp_screen.dart';

class RfqDetailScreen extends StatelessWidget {
  final CustomOrderModel rfq;

  const RfqDetailScreen({super.key, required this.rfq});

  String _resolveRfqImage(CustomOrderModel rfq) {
    final typeLower = rfq.machineType.toLowerCase();
    if (typeLower.contains('espresso')) {
      return 'https://images.unsplash.com/photo-1517256064527-09c73fc73e38?w=800&auto=format&fit=crop&q=80';
    } else if (typeLower.contains('roast')) {
      return 'https://images.unsplash.com/photo-1518832553480-cd0e625ed3e6?w=800&auto=format&fit=crop&q=80';
    } else if (typeLower.contains('grind')) {
      return 'https://images.unsplash.com/photo-1589396575653-c09c794ff6a6?w=800&auto=format&fit=crop&q=80';
    } else if (typeLower.contains('kakao') ||
        typeLower.contains('kering') ||
        typeLower.contains('pengering')) {
      return 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=800&auto=format&fit=crop&q=80';
    }
    return 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=800&auto=format&fit=crop&q=80';
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;

    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? Colors.white10 : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtextColor =
        isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);
    final imageUrl = _resolveRfqImage(rfq);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Detail Custom RFQ",
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: Color(0xFF16A34A),
              size: 20,
            ),
            tooltip: "Chat WhatsApp Engineer",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ContactWhatsappScreen(),
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: borderColor, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= 1. KARTU HEADER & IDENTITAS MESIN (DENGAN LAYOUT FOTO) =================
            Container(
              width: double.infinity,
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
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Foto Mesin Custom (Layout Sesuai Gambar 2)
                  Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 190,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: double.infinity,
                      height: 160,
                      color: isDark
                          ? AppColors.darkSurface
                          : const Color(0xFFF1F5F9),
                      child: Center(
                        child: Icon(
                          Icons.precision_manufacturing_rounded,
                          size: 42,
                          color:
                              isDark ? Colors.white60 : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),

                  // Header Info Mesin
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row Chips: No RFQ & Status Badge (Bebas Overflow)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white10
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white12
                                        : const Color(0xFFE2E8F0),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  rfq.rfqNumber,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white70
                                        : AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            CustomOrderStatusBadge(status: rfq.status),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Judul Mesin Custom
                        Text(
                          rfq.machineType,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Tanggal Pengajuan
                        Text(
                          "Diajukan pada: ${rfq.requestDate}",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= 2. SPESIFIKASI & KEBUTUHAN CUSTOM =================
            _buildSectionHeader("Spesifikasi & Kebutuhan Custom", textColor),
            Container(
              width: double.infinity,
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
                  _buildDetailRow(
                    icon: Icons.speed_rounded,
                    label: "Target Kapasitas",
                    value: rfq.targetCapacity,
                    textColor: textColor,
                    subtextColor: subtextColor,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  Divider(height: 1, color: borderColor),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.bolt_rounded,
                    label: "Spesifikasi Daya Listrik",
                    value: rfq.electricalSpecs,
                    textColor: textColor,
                    subtextColor: subtextColor,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  Divider(height: 1, color: borderColor),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.payments_outlined,
                    label: "Estimasi Budget Perusahaan",
                    value: rfq.budgetRange,
                    textColor: textColor,
                    subtextColor: subtextColor,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  Divider(height: 1, color: borderColor),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: "Target Ready / Pengiriman",
                    value: rfq.targetDeliveryDate,
                    textColor: textColor,
                    subtextColor: subtextColor,
                    isDark: isDark,
                  ),

                  // Catatan Fitur Khusus / Modifikasi (Sesuai Gambar 1)
                  if (rfq.customFeatures.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.amber.withValues(alpha: 0.1)
                            : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? Colors.amber.withValues(alpha: 0.25)
                              : const Color(0xFFFDE68A),
                          width: 0.8,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.tune_rounded,
                                size: 15,
                                color: Color(0xFFD97706),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "Fitur Khusus / Catatan Modifikasi:",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.amber.shade200
                                        : const Color(0xFF92400E),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            rfq.customFeatures,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              height: 1.4,
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF78350F),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Lampiran Blueprint
                  if (rfq.attachmentFileName != null &&
                      rfq.attachmentFileName!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.attach_file_rounded,
                          size: 15,
                          color: subtextColor,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "Blueprint: ${rfq.attachmentFileName!}",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: subtextColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= 3. INFORMASI PEMESAN (SESUAI GAMBAR 2) =================
            _buildSectionHeader("Informasi Pemesan", textColor),
            Container(
              width: double.infinity,
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
                children: [
                  _buildDetailRow(
                    icon: Icons.business_rounded,
                    label: "Perusahaan Pemesan",
                    value: rfq.companyName,
                    textColor: textColor,
                    subtextColor: subtextColor,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  Divider(height: 1, color: borderColor),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.person_outline_rounded,
                    label: "Kontak PIC & WhatsApp",
                    value: "${rfq.contactPerson} (${rfq.phone})",
                    textColor: textColor,
                    subtextColor: subtextColor,
                    isDark: isDark,
                  ),
                  if (rfq.email.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Divider(height: 1, color: borderColor),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.mail_outline_rounded,
                      label: "Email Perusahaan",
                      value: rfq.email,
                      textColor: textColor,
                      subtextColor: subtextColor,
                      isDark: isDark,
                    ),
                  ],
                ],
              ),
            ),

            // ================= 4. SURAT PENAWARAN RESMI PABRIK (JIKA ADA) =================
            if (rfq.quotationPrice != null) ...[
              const SizedBox(height: 20),
              _buildSectionHeader("Surat Penawaran Resmi Pabrik", textColor),
              Container(
                width: double.infinity,
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Total Penawaran Pabrik:",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  color: subtextColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                rfq.quotationPrice!,
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => PdfPreviewModal(
                                title: "Surat Penawaran Resmi (Quotation)",
                                subtitle: rfq.rfqNumber,
                                pdfType: "QUOTATION",
                                data: {
                                  'rfqNumber': rfq.rfqNumber,
                                  'company': rfq.companyName,
                                  'productName': rfq.machineType,
                                  'total': rfq.quotationPrice,
                                },
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.picture_as_pdf_outlined,
                            size: 14,
                          ),
                          label: const Text("Lihat PDF"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: textColor,
                            side: BorderSide(
                              color: isDark
                                  ? Colors.white24
                                  : const Color(0xFFCBD5E1),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (rfq.quotationNotes != null &&
                        rfq.quotationNotes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        "Catatan: ${rfq.quotationNotes!}",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: subtextColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ================= 5. BUTTON KONSULTASI (SESUAI GAMBAR 2) =================
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ContactWhatsappScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                label: Text(
                  "KONSULTASI TIM TEKNIK PABRIK",
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDark ? Colors.white : const Color(0xFF0F172A),
                  foregroundColor:
                      isDark ? const Color(0xFF0F172A) : Colors.white,
                  elevation: isDark ? 2 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 14.5,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color textColor,
    required Color subtextColor,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          child: Icon(
            icon,
            size: 16,
            color: isDark ? Colors.white60 : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  color: subtextColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
