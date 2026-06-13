import 'package:flutter/material.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/core/error/network_error_handler.dart';
import 'package:etsAndroid/core/theme/app_colors.dart';
import 'package:etsAndroid/core/theme/app_text_styles.dart';

class ErrorSnackbar {
  ErrorSnackbar._();

  static const Duration _durationWithRetry = Duration(seconds: 5);
  static const Duration _durationDefault = Duration(seconds: 3);
  static const Duration _durationSuccess = Duration(seconds: 2);
  static const String _labelRetry = 'Reintentar';

  static void show(
    BuildContext context, {
    required Failure failure,
    VoidCallback? onRetry,
  }) {
    final type = NetworkErrorHandler.typeFor(failure);
    final message = NetworkErrorHandler.messageFor(failure);

    final (icon, color) = switch (type) {
      NetworkErrorType.noConnection => (
          Icons.wifi_off_rounded,
          AppColors.warning,
        ),
      NetworkErrorType.timeout => (
          Icons.timer_off_outlined,
          AppColors.warning,
        ),
      NetworkErrorType.auth => (
          Icons.lock_outline_rounded,
          AppColors.error,
        ),
      NetworkErrorType.server => (
          Icons.cloud_off_rounded,
          AppColors.error,
        ),
      NetworkErrorType.cache => (
          Icons.storage_rounded,
          AppColors.error,
        ),
      NetworkErrorType.unknown => (
          Icons.error_outline_rounded,
          AppColors.error,
        ),
    };

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        duration: onRetry != null ? _durationWithRetry : _durationDefault,
        content: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.darkSnackbarBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.darkTextPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      onRetry();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: color.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _labelRetry,
                        style: AppTextStyles.caption.copyWith(
                          color: color,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void showSuccess(BuildContext context, {required String message}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        duration: _durationSuccess,
        content: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.darkSnackbarBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.success.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.success,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.darkTextPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
