import 'package:flutter/material.dart';

void hideProgressDialog(BuildContext context) {
  Navigator.pop(context);
}

Future<bool?> showProgressDialog(BuildContext context) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()));
}
