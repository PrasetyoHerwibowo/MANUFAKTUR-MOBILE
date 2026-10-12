import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/pdf_preview_dialog.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final orders = appState.orders;

    double totalDpPaid = 0;
    double totalPending = 0;

    for (var o in orders) {
      if (o.dpProofPath != null) {
        totalDpPaid += o.dpAmount;
      }
      if (o.pelunasanProofPath == null) {
        totalPending += o.pelunasanAmount;
      }
    }

    final fmtDp =
        "Rp ${totalDpPaid.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
    final fmtPending =
        "Rp ${totalPending.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";

    return Scaffold(
      backgroundColor: appState.isDarkMode ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text("Log Semua Pembayaran & Transaksi"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Corporate Finance Summary Card
          Container(
            padding: const EdgeInsets.all(18),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "RINGKASAN PEMBAYARAN B2B",
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "Rekening PT MDI",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Total DP 50% Masuk",
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            fmtDp,
                            style: GoogleFonts.outfit(
                              color: Colors.greenAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: Colors.white24,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Sisa Menunggu Pelunasan",
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            fmtPending,
                            style: GoogleFonts.outfit(
                              color: Colors.amberAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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

          Text(
            "Daftar Transaksi Purchase Order",
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: appState.isDarkMode ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          ...orders.map((o) {
            final dp =
                "Rp ${o.dpAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
            final pelunasan =
                "Rp ${o.pelunasanAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
            final total =
                "Rp ${o.totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: appState.isDarkMode ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: appState.isDarkMode ? Colors.white10 : AppColors.border,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                o.poNumber,
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: appState.isDarkMode ? Colors.white : AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              o.orderDate,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),

                        // Action: Launch Invoice PDF
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => PdfPreviewModal(
                                title: "PDF Invoice & Faktur Pajak",
                                subtitle: o.poNumber,
                                pdfType: "INVOICE",
                                data: {
                                  'poNumber': o.poNumber,
                                  'company': o.companyName,
                                  'productName': o.productName,
                                  'total': total,
                                  'dp': dp,
                                  'pelunasan': pelunasan,
                                },
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.picture_as_pdf, size: 14, color: AppColors.secondary),
                                const SizedBox(width: 4),
                                Text(
                                  "Invoice PDF",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      o.productName,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: appState.isDarkMode ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      "No Seri: ${o.serialNumber} • Rekening: BCA Corporate 088-2930-112",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const Divider(height: 20),

                    // Log 1: DP 50%
                    _buildLogItem(
                      title: "Uang Muka (DP 50%)",
                      refCode: "TRX-DP-${o.poNumber.replaceAll('PO-', '')}",
                      amount: dp,
                      status: "VERIFIED & DITERIMA",
                      isSuccess: true,
                    ),

                    const SizedBox(height: 10),

                    // Log 2: Pelunasan 50%
                    if (o.pelunasanProofPath != null) ...[
                      _buildLogItem(
                        title: "Pelunasan Sisa 50%",
                        refCode: "TRX-LUNAS-${o.poNumber.replaceAll('PO-', '')}",
                        amount: pelunasan,
                        status: "TERVERIFIKASI (LUNAS)",
                        isSuccess: true,
                      ),
                    ] else ...[
                      _buildLogItem(
                        title: "Pelunasan Sisa 50%",
                        refCode: "TRX-PENDING-PELUNASAN",
                        amount: pelunasan,
                        status: "MENUNGGU PELUNASAN",
                        isSuccess: false,
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLogItem({
    required String title,
    required String refCode,
    required String amount,
    required String status,
    required bool isSuccess,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.pending,
              color: isSuccess ? AppColors.success : AppColors.warning,
              size: 18,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        refCode,
                        style: const TextStyle(fontSize: 9, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isSuccess ? AppColors.success : AppColors.warning,
                  ),
                ),
              ],
            ),
          ],
        ),
        Text(
          amount,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: isSuccess ? AppColors.success : AppColors.warning,
          ),
        ),
      ],
    );
  }
}
