import 'package:flutter/material.dart';

class ErrorHandler {
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Tutup',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showWarningSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_outlined, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange.shade600,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue.shade600,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Ya',
    String cancelText = 'Batal',
    Color? confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor ?? Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
  }

  static void showLoadingDialog(BuildContext context, {String message = 'Memuat...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Text(message),
            ],
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        );
      },
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  static String getErrorMessage(dynamic error) {
    if (error == null) return 'Terjadi kesalahan yang tidak diketahui';
    
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('network')) {
      return 'Tidak ada koneksi internet. Periksa koneksi Anda.';
    } else if (errorString.contains('timeout')) {
      return 'Waktu tunggu habis. Coba lagi.';
    } else if (errorString.contains('permission')) {
      return 'Izin tidak diberikan. Periksa pengaturan aplikasi.';
    } else if (errorString.contains('not found')) {
      return 'Data tidak ditemukan.';
    } else if (errorString.contains('already exists')) {
      return 'Data sudah ada.';
    } else if (errorString.contains('invalid')) {
      return 'Data tidak valid.';
    } else if (errorString.contains('unauthorized')) {
      return 'Akses ditolak. Silakan login kembali.';
    } else if (errorString.contains('server')) {
      return 'Kesalahan server. Coba lagi nanti.';
    } else {
      return 'Terjadi kesalahan: ${error.toString()}';
    }
  }

  static void handleError(BuildContext context, dynamic error, {String? customMessage}) {
    final message = customMessage ?? getErrorMessage(error);
    showErrorSnackBar(context, message);
  }

  static void handleSuccess(BuildContext context, String message) {
    showSuccessSnackBar(context, message);
  }

  static void handleWarning(BuildContext context, String message) {
    showWarningSnackBar(context, message);
  }

  static void handleInfo(BuildContext context, String message) {
    showInfoSnackBar(context, message);
  }
}
