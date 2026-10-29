import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state.dart';
import '../../../core/models/custom_order_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/status_badge.dart';

class AdminRfqScreen extends StatelessWidget {
  const AdminRfqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final rfqList = appState.customOrders;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Manajemen Custom Order (RFQ)",
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              "Lihat pengajuan spesifikasi khusus dari klien & kirimkan Surat Penawaran (Quotation).",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 20),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rfqList.length,
              itemBuilder: (context, index) {
                final rfq = rfqList[index];

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
                                  rfq.rfqNumber,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text(
                                  "${rfq.companyName} • ${rfq.contactPerson} (${rfq.phone})",
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
                          CustomOrderStatusBadge(status: rfq.status),
                        ],
                      ),
                      const Divider(height: 20),

                      Text("Mesin Custom: ${rfq.machineType}",
                          style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text("Kapasitas: ${rfq.targetCapacity} • Listrik: ${rfq.electricalSpecs}",
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 11, color: AppColors.textSecondary)),
                      Text("Fitur Khusus: ${rfq.customFeatures}",
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 11, color: AppColors.textSecondary)),
                      Text("Target Delivery: ${rfq.targetDeliveryDate} • Budget: ${rfq.budgetRange}",
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 11, color: AppColors.textMuted)),

                      if (rfq.quotationPrice != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Quotation Dikirim: ${rfq.quotationPrice} (${rfq.quotationNotes})",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade900,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      ElevatedButton.icon(
                        onPressed: () {
                          _showSendQuotationModal(context, appState, rfq);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        icon: const Icon(Icons.send_outlined, size: 16),
                        label: const Text("Balas dengan File Quotation & Harga"),
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

  void _showSendQuotationModal(
      BuildContext context, AppState appState, CustomOrderModel rfq) {
    final priceCtrl = TextEditingController(text: 'Rp 145.000.000');
    final notesCtrl = TextEditingController(
        text: 'Harga termasuk garansi resmi 2 tahun & jasa instalasi teknisi pabrik.');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Kirim Quotation Penawaran",
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Perusahaan: ${rfq.companyName}"),
            Text("RFQ No: ${rfq.rfqNumber}"),
            const SizedBox(height: 12),
            TextField(
              controller: priceCtrl,
              decoration: const InputDecoration(labelText: "Harga Penawaran Final (Rp)"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: notesCtrl,
              maxLines: 2,
              decoration: const InputDecoration(labelText: "Catatan Penawaran / Scope Garansi"),
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
              appState.sendQuotationOffer(rfq.id, priceCtrl.text, notesCtrl.text);
              Navigator.pop(context);
            },
            child: const Text("Kirim Penawaran (Quotation)"),
          ),
        ],
      ),
    );
  }
}
