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
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleManualRegister(AppState appState) {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Silakan masukkan nama lengkap Anda"),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Silakan masukkan email Anda"),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (phone.isNotEmpty && phone.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Silakan masukkan nomor telepon yang valid"),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Silakan masukkan kata sandi Anda"),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _isLoading = false);

      appState.login(email, password, 'Pengguna', name: name);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Pendaftaran berhasil! Selamat datang, $name."),
          backgroundColor: AppColors.success,
        ),
      );

      // Kembali ke halaman sebelumnya / home
      Navigator.pop(context);
    });
  }

  void _showGoogleAccountPicker(BuildContext context, AppState appState) {
    final googleAccounts = [
      {
        'name': 'Ferry Salim',
        'email': 'ferry.salim@gmail.com',
      },
      {
        'name': 'Citra Dewi',
        'email': 'citra.dewi@gmail.com',
      },
      {
        'name': 'Bambang Soediro',
        'email': 'bambang.soediro@gmail.com',
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        final isDark = appState.isDarkMode;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCardBg : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                    color: isDark ? Colors.white24 : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildGoogleIcon(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Daftar dengan Google",
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          "Pilih akun Google Anda untuk membuat profil",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: isDark ? Colors.white12 : AppColors.border),
              const SizedBox(height: 8),

              ...googleAccounts.map((acc) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(modalCtx);
                      _executeGoogleRegister(acc['name']!, acc['email']!);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.white10 : AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.secondary,
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
                                Text(
                                  acc['name']!,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: isDark ? Colors.white : AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  acc['email']!,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 13,
                            color: AppColors.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Future<void> _executeGoogleRegister(String name, String email) async {
    final appState = Provider.of<AppState>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.secondary),
              const SizedBox(height: 18),
              Text(
                "Mendaftarkan akun Google...",
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 6),
              Text(
                email,
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 700));

    await appState.loginWithSSO(
      provider: 'google',
      name: name,
      email: email,
      company: 'Mitra',
    );

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // Tutup dialog loading

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Akun berhasil dibuat untuk $name!"),
        backgroundColor: AppColors.success,
      ),
    );

    // Kembali ke home/layout
    Navigator.pop(context);
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: CustomPaint(
        size: const Size(20, 20),
        painter: _GoogleRegisterLogoPainter(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
          tooltip: "Kembali",
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Daftar Akun",
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Buat Akun Baru",
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Daftar untuk menikmati kemudahan pemesanan & konsultasi mesin.",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // Form Container
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCardBg : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.white10 : AppColors.border,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama Lengkap
                    Text(
                      "Nama Lengkap",
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameController,
                      style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                        hintText: "Contoh: Budi Santoso",
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Email
                    Text(
                      "Email",
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.mail_outline_rounded, size: 20),
                        hintText: "nama@email.com",
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Nomor Telepon / WA
                    Text(
                      "Nomor Telepon / WhatsApp",
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.phone_outlined, size: 20),
                        hintText: "0812-xxxx-xxxx",
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Kata Sandi
                    Text(
                      "Kata Sandi",
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
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
                    const SizedBox(height: 22),

                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => _handleManualRegister(appState),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                "Daftar Sekarang",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // OAuth Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: isDark ? Colors.white12 : AppColors.border,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            "atau daftar dengan",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: isDark ? Colors.white12 : AppColors.border,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Google OAuth Button
                    InkWell(
                      onTap: () => _showGoogleAccountPicker(context, appState),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? Colors.white12 : AppColors.border,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildGoogleIcon(),
                            const SizedBox(width: 10),
                            Text(
                              "Daftar dengan Google",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Login Footer Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Sudah memiliki akun? ",
                    style: GoogleFonts.plusJakartaSans(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      "Masuk di sini",
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleRegisterLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.22;
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -2.4, 1.25, false, paint);

    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, -1.15, -1.25, false, paint);

    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 0.1, 1.5, false, paint);

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.6, 0.7, false, paint);

    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.44,
        size.height * 0.39,
        size.width * 0.52,
        strokeWidth,
      ),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
