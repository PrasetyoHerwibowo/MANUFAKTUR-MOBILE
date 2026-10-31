import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/app_state.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Step indicator: 1 = Input Email, 2 = Input 10-Digit Code, 3 = Input New Password
  int _currentStep = 1;

  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNewPass = true;
  bool _obscureConfirmPass = true;
  bool _isLoading = false;
  bool _isResending = false;
  int _resendCountdown = 60;
  Timer? _countdownTimer;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _resendCountdown = 60;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        if (mounted) setState(() => _resendCountdown--);
      } else {
        _countdownTimer?.cancel();
      }
    });
  }

  // ==========================================
  // STEP 1: REQUEST 10-DIGIT OTP CODE
  // ==========================================
  Future<void> _handleRequestCode(AppState appState) async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Silakan masukkan email aktif yang valid."),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await appState.forgotPassword(email);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (res['success'] == true) {
        _startCountdown();
        setState(() => _currentStep = 2);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? "Kode pemulihan telah dikirimkan ke email Anda."),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? "Gagal mengirimkan kode pemulihan."),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi kesalahan: $e"),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // ==========================================
  // RESEND CODE
  // ==========================================
  Future<void> _handleResendCode(AppState appState) async {
    if (_resendCountdown > 0) return;

    setState(() => _isResending = true);

    try {
      final res = await appState.forgotPassword(_emailController.text.trim());

      if (!mounted) return;
      setState(() => _isResending = false);

      if (res['success'] == true) {
        _startCountdown();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? "Kode baru telah dikirimkan ke email Anda."),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? "Gagal mengirim ulang kode."),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isResending = false);
    }
  }

  // ==========================================
  // STEP 2: VERIFY 10-DIGIT CODE
  // ==========================================
  Future<void> _handleVerifyCode(AppState appState) async {
    final code = _codeController.text.trim().toUpperCase();

    if (code.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kode verifikasi harus tepat 10 digit angka & huruf."),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await appState.verifyResetCode(
        email: _emailController.text.trim(),
        code: code,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (res['success'] == true) {
        setState(() => _currentStep = 3);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? "Kode valid! Silakan buat kata sandi baru."),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? "Kode verifikasi tidak valid."),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi kesalahan: $e"),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // ==========================================
  // STEP 3: RESET PASSWORD
  // ==========================================
  Future<void> _handleResetPassword(AppState appState) async {
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    if (newPass.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kata sandi baru minimal 8 karakter demi keamanan."),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!RegExp(r'[0-9]').hasMatch(newPass) || !RegExp(r'[a-zA-Z]').hasMatch(newPass)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kata sandi harus mengandung kombinasi huruf dan angka."),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Konfirmasi kata sandi tidak cocok."),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await appState.resetPassword(
        email: _emailController.text.trim(),
        code: _codeController.text.trim().toUpperCase(),
        newPassword: newPass,
        passwordConfirmation: confirmPass,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? "Kata sandi berhasil diperbarui! Silakan login kembali."),
            backgroundColor: AppColors.success,
          ),
        );

        // Kembali ke halaman Login
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? "Gagal mereset kata sandi."),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi kesalahan: $e"),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () {
            if (_currentStep > 1) {
              setState(() => _currentStep--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          "Pemulihan Kata Sandi",
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),

              // Step Progress Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStepDot(1, "Email", isDark),
                  _buildStepLine(1, isDark),
                  _buildStepDot(2, "Kode 10 Digit", isDark),
                  _buildStepLine(2, isDark),
                  _buildStepDot(3, "Sandi Baru", isDark),
                ],
              ),
              const SizedBox(height: 28),

              // Top Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  _currentStep == 1
                      ? Icons.lock_reset_rounded
                      : (_currentStep == 2
                          ? Icons.mark_email_read_outlined
                          : Icons.security_rounded),
                  color: AppColors.secondary,
                  size: 36,
                ),
              ),
              const SizedBox(height: 18),

              // Title & Description
              Text(
                _currentStep == 1
                    ? "Lupa Kata Sandi?"
                    : (_currentStep == 2
                        ? "Masukkan Kode Verifikasi"
                        : "Buat Kata Sandi Baru"),
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _currentStep == 1
                    ? "Masukkan email resmi Anda. Kami akan mengirimkan 10 digit kode verifikasi rahasia untuk mereset kata sandi."
                    : (_currentStep == 2
                        ? "Masukkan 10 digit kode acak yang telah dikirim ke inbox/spam email terdaftar Anda."
                        : "Buat kata sandi baru yang kuat untuk melindungi akun manufaktur Anda."),
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Card Content Per Step
              if (_currentStep == 1) _buildStep1(isDark, appState),
              if (_currentStep == 2) _buildStep2(isDark, appState),
              if (_currentStep == 3) _buildStep3(isDark, appState),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET STEP 1: INPUT EMAIL
  // ==========================================
  Widget _buildStep1(bool isDark, AppState appState) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white12 : AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Alamat Email Terdaftar",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: "nama@perusahaan.com",
              prefixIcon: const Icon(Icons.email_outlined, color: AppColors.secondary, size: 20),
              filled: true,
              fillColor: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? Colors.white12 : AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.secondary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : () => _handleRequestCode(appState),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      "Kirim Kode Verifikasi",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET STEP 2: INPUT 10-DIGIT CODE
  // ==========================================
  Widget _buildStep2(bool isDark, AppState appState) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white12 : AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Email Target Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? Colors.white12 : AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.email_outlined, size: 14, color: AppColors.secondary),
                const SizedBox(width: 6),
                Text(
                  _emailController.text,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _currentStep = 1),
                  child: const Icon(Icons.edit, size: 13, color: AppColors.secondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text(
            "KODE PEMULIHAN 10 DIGIT",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 12),

          // Input Box 10 Digit
          TextField(
            controller: _codeController,
            textAlign: TextAlign.center,
            textCapitalization: TextCapitalization.characters,
            maxLength: 10,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
            ],
            style: GoogleFonts.sourceCodePro(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: 6,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              counterText: "",
              hintText: "XXXXXXXXXX",
              hintStyle: GoogleFonts.sourceCodePro(
                fontSize: 22,
                letterSpacing: 6,
                color: isDark ? Colors.white24 : AppColors.textMuted,
              ),
              filled: true,
              fillColor: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? Colors.white12 : AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.secondary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted),
              const SizedBox(width: 5),
              Text(
                "Periksa kotak masuk email Anda (berlaku 15 menit)",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Submit Verify Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : () => _handleVerifyCode(appState),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      "Verifikasi Kode",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 18),

          // Resend Cooldown
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Tidak menerima email? ",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
              if (_resendCountdown > 0)
                Text(
                  "Kirim ulang dalam ${_resendCountdown}s",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                  ),
                )
              else
                GestureDetector(
                  onTap: _isResending ? null : () => _handleResendCode(appState),
                  child: Text(
                    _isResending ? "Mengirim..." : "Kirim Ulang Kode",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET STEP 3: INPUT NEW PASSWORD
  // ==========================================
  Widget _buildStep3(bool isDark, AppState appState) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white12 : AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Kata Sandi Baru",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _newPasswordController,
            obscureText: _obscureNewPass,
            style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: "Minimal 8 karakter (huruf & angka)",
              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.secondary, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNewPass ? Icons.visibility_off : Icons.visibility,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscureNewPass = !_obscureNewPass),
              ),
              filled: true,
              fillColor: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? Colors.white12 : AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.secondary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            "Konfirmasi Kata Sandi Baru",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPass,
            style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: "Masukkan ulang kata sandi baru",
              prefixIcon: const Icon(Icons.lock_reset, color: AppColors.secondary, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPass ? Icons.visibility_off : Icons.visibility,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscureConfirmPass = !_obscureConfirmPass),
              ),
              filled: true,
              fillColor: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? Colors.white12 : AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.secondary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : () => _handleResetPassword(appState),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      "Perbarui Kata Sandi Sekarang",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PROGRESS INDICATOR HELPER
  // ==========================================
  Widget _buildStepDot(int step, String label, bool isDark) {
    final isActive = _currentStep == step;
    final isDone = _currentStep > step;

    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone
                ? AppColors.success
                : (isActive ? AppColors.secondary : (isDark ? Colors.white12 : const Color(0xFFE2E8F0))),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    "$step",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : (isDark ? Colors.white54 : AppColors.textMuted),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive
                ? (isDark ? Colors.white : AppColors.textPrimary)
                : (isDark ? AppColors.darkTextSecondary : AppColors.textMuted),
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int afterStep, bool isDark) {
    final isDone = _currentStep > afterStep;
    return Container(
      width: 32,
      height: 2,
      margin: const EdgeInsets.only(bottom: 16, left: 4, right: 4),
      color: isDone ? AppColors.success : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
    );
  }
}
