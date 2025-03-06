import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomSnackBar extends SnackBar {
  CustomSnackBar({
    super.key,
    required String message,
    bool isSuccess = true,
    VoidCallback? onAction,
    String? actionLabel,
  }) : super(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSuccess ? AppColors.success : AppColors.warning,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuccess ? Icons.check : Icons.info_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (onAction != null && actionLabel != null)
                TextButton(
                  onPressed: onAction,
                  child: Text(
                    actionLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          backgroundColor: isSuccess 
              ? AppColors.success.withOpacity(0.9)
              : AppColors.warning.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
          elevation: 6,
        );

  static void show(
    BuildContext context, {
    required String message,
    bool isSuccess = true,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      CustomSnackBar(
        message: message,
        isSuccess: isSuccess,
        onAction: onAction,
        actionLabel: actionLabel,
      ),
    );
  }
}
