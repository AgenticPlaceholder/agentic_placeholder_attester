import 'package:flutter/material.dart';
import 'package:reown_appkit/reown_appkit.dart';

class BarcodeScannerWithOverlay extends StatelessWidget {
  final ReownAppKitModal? appKitModal;
  final bool linkMode;
  final Future<void> Function(bool)? reinitialize;


  final bool appKitModalPlaceholder;

  const BarcodeScannerWithOverlay({
    Key? key,
    required this.linkMode,
    this.reinitialize,
    this.appKitModal,
    this.appKitModalPlaceholder = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('QR Scanner Page\nLink Mode: $linkMode'),
    );
  }
}