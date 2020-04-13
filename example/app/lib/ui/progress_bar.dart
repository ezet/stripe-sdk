import 'package:flutter/material.dart';

void hideProgressDialog(BuildContext context) {
  Navigator.pop(context);
}

void showProgressDialog(BuildContext context) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()));
}
