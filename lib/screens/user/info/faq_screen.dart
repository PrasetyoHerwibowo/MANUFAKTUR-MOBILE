import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'q': 'Bagaimana skema pembayaran PO Standar (DP 50%)?',
        'a': 'Pemesanan PO mewajibkan pembayaran DP 50% di awal untuk mengunci slot produksi. Sisa pelunasan 50% dibayarkan setelah unit mesin dinyatakan LULUS Quality Control (QC) & siap dikirim.'
      },
      {
        'q': 'Berapa lama estimasi masa garansi mesin?',
        'a': 'Seluruh mesin espresso komersial & roaster mendapatkan garansi manufaktur resmi selama 2 tahun (mencakup suku cadang & kunjungan teknisi).'
      },
      {
        'q': 'Apakah harga sudah termasuk instalasi & training barista?',
        'a': 'Ya, setiap pembelian unit komersial sudah gratis jasa instalasi on-site serta sesi training pengoperasian & pemeliharaan untuk tim barista Anda.'
      },
      {
        'q': 'Bagaimana cara mengajukan mesin dengan spesifikasi Custom?',
        'a': 'Anda dapat mengisi formulir Request for Quotation (RFQ) di menu Custom Order. Tim Engineer kami akan menghubungi Anda dalam 1x24 jam dengan Surat Penawaran Resmi.'
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Pertanyaan Umum (FAQ)"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final item = faqs[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              title: Text(
                item['q']!,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.primary,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    item['a']!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
