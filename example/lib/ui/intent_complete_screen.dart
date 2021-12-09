import 'package:flutter/material.dart';

class IntentCompleteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3DS intent completed'),
      ),
      body: const Text('complete'),
    );
  }

  const IntentCompleteScreen({Key? key}) : super(key: key);
}
