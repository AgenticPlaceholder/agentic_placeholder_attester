import 'package:flutter/material.dart';

class ScannerErrorWidget extends StatelessWidget {
  final Object error;

  const ScannerErrorWidget({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Scanner Error:\n${error.toString()}',
        style: const TextStyle(color: Colors.red, fontSize: 18),
        textAlign: TextAlign.center,
      ),
    );
  }
}