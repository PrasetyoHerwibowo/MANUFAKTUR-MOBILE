import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state.dart';
import '../../../core/theme/app_colors.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'procurement@kopinusantara.co.id');
  final _passwordController = TextEditingController(text: '12345678');
  final _companyController = TextEditingController(text: 'PT Kopi Nusantara Jaya');
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isSsoLoading = false;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Manufacturer Logo Header
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.coffee_maker,
                      size: 48,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        "Easy | Economic | Excellent",
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "PT MANUFACTUR DYNAMIC INDONESIA",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  "Portal B2B & E-Commerce Mesin Pengolahan Kopi & Kakao",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),

                // Card Container
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Masuk ke Akun B2B",
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Kelola pesanan PO, DP 50%, pelacakan produksi, & servis resmi.",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Company Name Input
                      Text(
                        "Nama Perusahaan / Kafe",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _companyController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.business),
                          hintText: "Contoh: PT Kopi Nusantara Jaya",
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Email Input
                      Text(
                        "Email Perusahaan",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.email_outlined),
                          hintText: "email@perusahaan.com",
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password Input
                      Text(
                        "Kata Sandi",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          hintText: "••••••••",
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Remember Me & Forgot Password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: Checkbox(
                                  value: _rememberMe,
                                  activeColor: AppColors.secondary,
                                  onChanged: (val) {
                                    setState(() {
                                      _rememberMe = val ?? true;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Ingat Saya",
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "Lupa Password?",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            appState.login(
                              _emailController.text,
                              _passwordController.text,
                              _companyController.text,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Berhasil masuk ke portal B2B!"),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          },
                          child: const Text("MASUK SEKARANG"),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // SSO Divider
                      Row(
                        children: [
                          const Expanded(child: Divider(color: AppColors.border)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "ATAU MASUK DENGAN SSO",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider(color: AppColors.border)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Google SSO Button
                      _buildSsoButton(
                        context: context,
                        provider: 'Google',
                        title: 'Lanjutkan dengan Google',
                        subtitle: 'Google Workspace Enterprise',
                        iconWidget: _buildGoogleIcon(),
                        onTap: () => _handleSsoLogin(context, 'google'),
                      ),

                      const SizedBox(height: 12),

                      // Microsoft SSO Button
                      _buildSsoButton(
                        context: context,
                        provider: 'Microsoft',
                        title: 'Lanjutkan dengan Microsoft',
                        subtitle: 'Microsoft 365 / Entra ID SSO',
                        iconWidget: _buildMicrosoftIcon(),
                        onTap: () => _handleSsoLogin(context, 'microsoft'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Belum memiliki akun B2B? ",
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Daftar Kemitraan",
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // SSO Action Button Widget
  Widget _buildSsoButton({
    required BuildContext context,
    required String provider,
    required String title,
    required String subtitle,
    required Widget iconWidget,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: _isSsoLoading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: iconWidget,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  // Google 4-color stylized icon
  Widget _buildGoogleIcon() {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            "G",
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF4285F4),
            ),
          ),
        ],
      ),
    );
  }

  // Microsoft 4-color corporate tile icon
  Widget _buildMicrosoftIcon() {
    return SizedBox(
      width: 18,
      height: 18,
      child: Column(
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, color: const Color(0xFFF25022)),
              const SizedBox(width: 2),
              Container(width: 8, height: 8, color: const Color(0xFF7FBA00)),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Container(width: 8, height: 8, color: const Color(0xFF00A4EF)),
              const SizedBox(width: 2),
              Container(width: 8, height: 8, color: const Color(0xFFFFB900)),
            ],
          ),
        ],
      ),
    );
  }

  // Interactive SSO Modal & Account Selection
  void _handleSsoLogin(BuildContext context, String provider) {
    final isGoogle = provider.toLowerCase() == 'google';
    final providerTitle = isGoogle ? 'Google Workspace' : 'Microsoft 365';

    // Sample Verified Corporate Accounts
    final ssoAccounts = isGoogle
        ? [
            {
              'name': 'Budi Santoso',
              'email': 'budi.santoso@indocoffee.com',
              'company': 'PT Indo Coffee Export',
              'role': 'Head of Procurement',
            },
            {
              'name': 'Hendra Wijaya',
              'email': 'procurement@kopinusantara.co.id',
              'company': 'PT Kopi Nusantara Jaya',
              'role': 'Supply Chain Director',
            },
            {
              'name': 'Rina Wijaya',
              'email': 'procurement@balicoffeelab.com',
              'company': 'Bali Artisan Coffee Lab',
              'role': 'Roastery Owner',
            },
          ]
        : [
            {
              'name': 'Agus Pratama',
              'email': 'a.pratama@roasterycorp.id',
              'company': 'PT Roastery Perkasa Indonesia',
              'role': 'Factory Operations Manager',
            },
            {
              'name': 'Siti Rahmawati',
              'email': 'purchasing@javakopi.co.id',
              'company': 'PT Java Kopi Makmur',
              'role': 'Senior Purchasing Specialist',
            },
            {
              'name': 'Dedi Mulyadi',
              'email': 'dedi@sumatracocoa.com',
              'company': 'PT Sumatra Cocoa & Coffee Industry',
              'role': 'Technical Lead',
            },
          ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: isGoogle ? _buildGoogleIcon() : _buildMicrosoftIcon(),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Single Sign-On (SSO)",
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        "Pilih akun korporat $providerTitle Anda",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.border),
            const SizedBox(height: 12),

            Text(
              "AKUN KORPORAT TERDETEKSI",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textMuted,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 10),

            // Account List
            ...ssoAccounts.map((acc) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () async {
                    Navigator.pop(modalCtx);
                    _executeSsoLogin(
                      context,
                      provider: provider,
                      name: acc['name']!,
                      email: acc['email']!,
                      company: acc['company']!,
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            acc['name']!.substring(0, 1),
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    acc['name']!,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.verified, size: 14, color: AppColors.info),
                                ],
                              ),
                              Text(
                                acc['email']!,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                "${acc['company']!} • ${acc['role']!}",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.check_circle_outline, color: AppColors.secondary, size: 20),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 8),

            // Custom Account Option
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(modalCtx);
                _showCustomSsoDialog(context, provider);
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Gunakan Akun Korporat Lain"),
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

  // Custom Account Dialog
  void _showCustomSsoDialog(BuildContext context, String provider) {
    final customEmailCtrl = TextEditingController();
    final customNameCtrl = TextEditingController();
    final customCompanyCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(
          "SSO ${provider.toUpperCase()}",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Masukkan data akun korporat Anda:",
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: customNameCtrl,
              decoration: const InputDecoration(
                hintText: "Nama Lengkap PIC",
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: customEmailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: "email.kerja@perusahaan.com",
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: customCompanyCtrl,
              decoration: const InputDecoration(
                hintText: "Nama Perusahaan / PT / Kafe",
                prefixIcon: Icon(Icons.business_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              if (customEmailCtrl.text.isEmpty || customNameCtrl.text.isEmpty) {
                return;
              }
              Navigator.pop(dialogCtx);
              _executeSsoLogin(
                context,
                provider: provider,
                name: customNameCtrl.text,
                email: customEmailCtrl.text,
                company: customCompanyCtrl.text.isNotEmpty 
                    ? customCompanyCtrl.text 
                    : 'Mitra ${customNameCtrl.text}',
              );
            },
            child: const Text("Autentikasi SSO"),
          ),
        ],
      ),
    );
  }

  // Execute SSO Authentication with realistic loading overlay
  Future<void> _executeSsoLogin(
    BuildContext context, {
    required String provider,
    required String name,
    required String email,
    required String company,
  }) async {
    final appState = Provider.of<AppState>(context, listen: false);
    final rootNav = Navigator.of(context, rootNavigator: true);
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _isSsoLoading = true);

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
                "Memverifikasi ${provider.toUpperCase()} SSO...",
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 6),
              Text(
                "Menghubungkan ke $email",
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
    setState(() => _isSsoLoading = false);

    messenger.showSnackBar(
      SnackBar(
        content: Text("Berhasil login via ${provider.toUpperCase()} SSO ($company)!"),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
