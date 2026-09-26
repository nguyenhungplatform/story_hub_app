import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme/app_colors.dart';
import '../network/api_response.dart';

String errorMessage(Object error) {
  if (error is ApiException) return error.displayMessage;
  if (error is ParallelWaitError) {
    final errors = error.errors;
    if (errors is (AsyncError?, AsyncError?)) {
      final first = errors.$1 ?? errors.$2;
      if (first != null) return errorMessage(first.error);
    }
  }
  return 'Đã có lỗi xảy ra, vui lòng thử lại.';
}

void showMessage(String message, {bool isError = false}) {
  Get.closeCurrentSnackbar();
  Get.rawSnackbar(
    message: message,
    backgroundColor: isError ? AppColors.danger : AppColors.ink,
    borderRadius: 12,
    margin: const EdgeInsets.all(16),
    duration: const Duration(seconds: 2),
    snackPosition: SnackPosition.TOP,
  );
}

void showError(Object error) => showMessage(errorMessage(error), isError: true);
