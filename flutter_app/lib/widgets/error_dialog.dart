import 'package:flutter/material.dart';
import '../config/theme_config.dart';

class ErrorDialog {
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onRetry,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: AppTheme.error, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onRetry();
              },
              child: const Text('Retry'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static void showNetworkError(BuildContext context, {VoidCallback? onRetry}) {
    show(
      context,
      title: 'Network Error',
      message: 'Unable to connect to the server. Please check your internet connection and try again.',
      onRetry: onRetry,
    );
  }

  static void showBookingFailed(BuildContext context, String reason) {
    show(
      context,
      title: 'Booking Failed',
      message: reason,
    );
  }
}

class SuccessDialog {
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onClose,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: AppTheme.success, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onClose?.call();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class LoadingDialog {
  static void show(BuildContext context, {String message = 'Loading...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(message),
            ],
          ),
        ),
      ),
    );
  }

  static void hide(BuildContext context) {
    Navigator.pop(context);
  }
}
