import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showAwesomeSnackbar({
  required String title,
  required String message,
  required ContentType contentType,
}) {
  Get.rawSnackbar(
    messageText: AwesomeSnackbarContent(
      title: title,
      message: message,
      contentType: contentType,
    ),
    backgroundColor: Colors.transparent,
    snackPosition: SnackPosition.TOP,
    duration: const Duration(seconds: 2),
    padding: EdgeInsets.zero,
    margin: const EdgeInsets.only(
      top: 16,
      left: 16,
      right: 16,
    ),
  );
}