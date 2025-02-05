import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannedBarcodeLabel extends StatelessWidget {
  final List<Barcode> barcodes;
  final Function(String) onTokenScanned;

  const ScannedBarcodeLabel({
    Key? key,
    required this.barcodes,
    required this.onTokenScanned,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String displayText = '';
    if (barcodes.isNotEmpty) {
      displayText = barcodes.first.displayValue ?? '';
      onTokenScanned(displayText);
    }
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        displayText.isNotEmpty ? 'Scanned Code: $displayText' : 'No code detected',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}