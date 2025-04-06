import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastUtil {
  static final FToast _fToast = FToast();
  static bool _isInitialized = false;

  static void init(BuildContext context) {
    if (!_isInitialized) {
      _fToast.init(context);
      _isInitialized = true;
    }
  }

  static void showCustomToast(String message, {Color borderColor = Colors.black}) {
    if (!_isInitialized) {
      debugPrint("ToastUtil not initialized! Call init(context) first.");
      return;
    }

    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 0)],
      ),
      child: Text(
        message,
        style: TextStyle(
          color: borderColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    _fToast.showToast(
      child: toast,
      gravity: ToastGravity.TOP,
      toastDuration: Duration(seconds: 2),
    );
  }
}
