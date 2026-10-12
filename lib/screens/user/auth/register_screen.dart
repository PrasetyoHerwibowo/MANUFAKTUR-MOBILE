import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state.dart';
import '../../../core/theme/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _companyController = TextEditingController();
  final _picController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSsoRegistering = false;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Pendaftaran Mitra B2B"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Daftarkan Perusahaan Anda",
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              "Dapatkan akses harga pabrik (distributor), quotation custom order, & garansi manufaktur.",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),

            // SSO Quick Registration Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.flash_on, color: AppColors.secondary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pendaftaran Cepat via SSO Korporat",
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              "Verifikasi identitas instan dengan akun perusahaan",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Google SSO Register Button
                  InkWell(
                    onTap: _isSsoRegistering ? null : () => _handleSsoRegister(context, 'google'),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          _buildGoogleIcon(),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Daftar dengan Google Workspace",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_forward, size: 14, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Microsoft SSO Register Button
                  InkWell(
                    onTap: _isSsoRegistering ? null : () => _handleSsoRegister(context, 'microsoft'),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          _buildMicrosoftIcon(),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Daftar dengan Microsoft 365 (Entra ID)",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_forward, size: 14, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Divider Manual Form
            Row(
              children: [
                const Expanded(child: Divider(color: AppColors.border)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    "ATAU ISI FORMULIR KEMITRAAN MANUAL",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                const Expanded(child: Divider(color: AppColors.border)),
              ],
            ),

            const SizedBox(height: 16),

            // Manual Registration Form Card
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
                  _buildLabel("Nama Perusahaan / PT / CV / Kafe"),
                  TextField(
                    controller: _companyController,
                    decoration: const InputDecoration(
                      hintText: "Contoh: PT Kopi Indonesia Perkasa",
                      prefixIcon: Icon(Icons.domain),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildLabel("Nama Penanggung Jawab (PIC) Procurement"),
                  TextField(
                    controller: _picController,
                    decoration: const InputDecoration(
                      hintText: "Nama Lengkap PIC",
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildLabel("Email Perusahaan (Resmi)"),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: "procurement@perusahaan.com",
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildLabel("Nomor WhatsApp Active"),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: "0812-xxxx-xxxx",
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildLabel("Kata Sandi"),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: "Minimal 8 Karakter",
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_companyController.text.isEmpty ||
                            _emailController.text.isEmpty ||
                            _picController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Mohon lengkapi semua data pendaftaran!"),
                              backgroundColor: AppColors.error,
                            ),
                          );
                          return;
                        }
                        appState.login(
                          _emailController.text,
                          _passwordController.text,
                          _companyController.text,
                          name: _picController.text,
                        );
                        Navigator.pop(context);
                      },
                      child: const Text("DAFTAR SEKARANG"),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
          fontSize: 13,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  // Google 4-color stylized icon
  Widget _buildGoogleIcon() {
    return Text(
      "G",
      style: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: const Color(0xFF4285F4),
      ),
    );
  }

  // Microsoft 4-color corporate tile icon
  Widget _buildMicrosoftIcon() {
    return SizedBox(
      width: 16,
      height: 16,
      child: Column(
        children: [
          Row(
            children: [
              Container(width: 7, height: 7, color: const Color(0xFFF25022)),
              const SizedBox(width: 2),
              Container(width: 7, height: 7, color: const Color(0xFF7FBA00)),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Container(width: 7, height: 7, color: const Color(0xFF00A4EF)),
              const SizedBox(width: 2),
              Container(width: 7, height: 7, color: const Color(0xFFFFB900)),
            ],
          ),
        ],
      ),
    );
  }

  // Handle SSO Registration Dialog
  void _handleSsoRegister(BuildContext context, String provider) {
    final isGoogle = provider.toLowerCase() == 'google';
    final providerTitle = isGoogle ? 'Google Workspace' : 'Microsoft 365';

    final sampleAccounts = isGoogle
        ? [
            {
              'name': 'Ferry Salim',
              'email': 'ferry.salim@javaroasters.co.id',
              'company': 'PT Java Roasters Industri',
            },
            {
              'name': 'Citra Dewi',
              'email': 'citra@nusantaracacao.com',
              'company': 'PT Nusantara Cacao Mandiri',
            },
          ]
        : [
            {
              'name': 'Bambang Soediro',
              'email': 'bambang@kopiandalas.co.id',
              'company': 'PT Kopi Andalas Perkasa',
            },
            {
              'name': 'Maya Anggraini',
              'email': 'maya.a@agroperkasa.id',
              'company': 'PT Agro Perkasa Teknik',
            },
          ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Pendaftaran SSO $providerTitle",
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              "Pilih akun atau gunakan profil korporat untuk auto-registrasi:",
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            ...sampleAccounts.map((acc) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  tileColor: AppColors.background,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.secondary,
                    child: Text(
                      acc['name']!.substring(0, 1),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(acc['name']!, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13)),
                  subtitle: Text("${acc['email']!} • ${acc['company']!}", style: GoogleFonts.plusJakartaSans(fontSize: 11)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () async {
                    Navigator.pop(modalCtx);
                    _executeSsoRegistration(
                      context,
                      provider: provider,
                      name: acc['name']!,
                      email: acc['email']!,
                      company: acc['company']!,
                    );
                  },
                ),
              );
            }),

            const SizedBox(height: 8),

            // Pre-fill manual form option
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(modalCtx);
                // Pre-fill the form fields for manual confirmation
                setState(() {
                  _companyController.text = "PT Korporat $providerTitle";
                  _picController.text = "PIC $providerTitle";
                  _emailController.text = "pic@korporat-${provider.toLowerCase()}.com";
                  _phoneController.text = "0811-2345-6789";
                  _passwordController.text = "SecureSSO@2026";
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Data terisi dari profil SSO. Anda dapat mereview dan menekan 'Daftar Sekarang'."),
                    backgroundColor: AppColors.info,
                  ),
                );
              },
              icon: const Icon(Icons.edit_note, size: 18),
              label: const Text("Isi Otomatis ke Formulir Pendaftaran"),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // Execute SSO Registration
  Future<void> _executeSsoRegistration(
    BuildContext context, {
    required String provider,
    required String name,
    required String email,
    required String company,
  }) async {
    final appState = Provider.of<AppState>(context, listen: false);
    final rootNav = Navigator.of(context, rootNavigator: true);
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _isSsoRegistering = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (loadingCtx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.secondary),
              const SizedBox(height: 18),
              Text(
                "Mendaftarkan Akun via ${provider.toUpperCase()} SSO...",
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 6),
              Text(
                "Membuat profil kemitraan untuk $company",
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 900));

    await appState.loginWithSSO(
      provider: provider,
      name: name,
      email: email,
      company: company,
    );

    if (!mounted) return;
    rootNav.pop(); // dismiss loading dialog
    setState(() => _isSsoRegistering = false);
    nav.pop(); // return to login/home screen

    messenger.showSnackBar(
      SnackBar(
        content: Text("Registrasi kemitraan $company via ${provider.toUpperCase()} SSO berhasil!"),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
