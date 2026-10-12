class FilePickerHelper {
  static Future<String?> pickFileName({List<String>? allowedExtensions}) async {
    // Simulated smooth file selection for B2B document uploads
    await Future.delayed(const Duration(milliseconds: 300));
    final ext = (allowedExtensions != null && allowedExtensions.isNotEmpty)
        ? allowedExtensions.first
        : 'pdf';
    return "Dokumen_Bukti_Transfer_B2B.$ext";
  }
}
