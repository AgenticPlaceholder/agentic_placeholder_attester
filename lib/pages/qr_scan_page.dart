import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_pannable_rating_bar/flutter_pannable_rating_bar.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:reown_appkit/reown_appkit.dart';

import '../controllers/barcode_scanner_store.dart';
import '../widgets/scanned_barcode_label.dart';
import '../widgets/scanner_error_widget.dart';
import '../widgets/scanner_overlay.dart';

/// A stateless widget that builds its UI solely from observing [BarcodeScannerStore].
class BarcodeScannerWithOverlay extends StatelessWidget {
  final BarcodeScannerStore store;
  final ReownAppKitModal appKitModal;
  final bool linkMode;
  final Function(bool linkMode) reinitialize;

  const BarcodeScannerWithOverlay({
    Key? key,
    required this.store,
    required this.appKitModal,
    required this.reinitialize,
    this.linkMode = false,
  }) : super(key: key);

  /// Called when the rating bar changes.
  Future<void> _updateRating(BuildContext context, double value) async {
    store.setRating(value);

    // Retrieve wallet address from the current chain, if available.
    final chainId = appKitModal.selectedChain?.chainId ?? '';
    if (chainId.isNotEmpty) {
      final namespace =
      ReownAppKitModalNetworks.getNamespaceForChainId(chainId);
      store.setUserWalletAddress(
          appKitModal.session?.getAddress(namespace) ?? '');
    }
    if (store.userWalletAddress.isEmpty) {
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Uh Oh!',
          message: 'Please connect your wallet to rate',
          contentType: ContentType.failure,
        ),
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
      store.setRating(0);
      return;
    }

    // Show a confirmation dialog before submitting.
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Rating'),
        content: const Text('Are you sure you want to submit this rating?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (confirm != true) {
      store.setRating(0);
      return;
    }

    // Show a loader while submitting.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final success = await store.submitRating(chainId, appKitModal, value);
    Navigator.of(context).pop(); // Remove loader.

    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: success ? 'Thank you for rating!' : 'Uh Oh!',
        message: success
            ? 'Checkout the reputation score to validate'
            : store.submissionMessage,
        contentType: success ? ContentType.success : ContentType.failure,
      ),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    // Define the scanning window rectangle.
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.of(context).size.center(Offset.zero),
      width: 200,
      height: 200,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // The MobileScanner widget uses the controller from the store.
          Center(
            child: MobileScanner(
              fit: BoxFit.cover,
              controller: store.controller,
              scanWindow: scanWindow,
              errorBuilder: (context, error, child) =>
                  ScannerErrorWidget(error: error),
              overlayBuilder: (context, constraints) {
                return Container(
                  margin: const EdgeInsets.only(top: 500),
                  child: Observer(
                    builder: (_) {
                      // Create a dummy list of Barcodes from the stored QR payload.
                      final barcodes = store.qrPayload.isNotEmpty
                          ? [Barcode(displayValue: store.qrPayload)]
                          : <Barcode>[];
                      return ScannedBarcodeLabel(
                        barcodes: barcodes,
                        onTokenScanned: store.setQrPayload,
                      );
                    },
                  ),
                );
              },
            ),
          ),
          // Custom overlay painted on top of the camera preview.
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: store.controller,
            builder: (context, value, child) {
              if (!value.isInitialized ||
                  !value.isRunning ||
                  value.error != null) {
                return const SizedBox();
              }
              return CustomPaint(
                painter: ScannerOverlay(scanWindow: scanWindow),
              );
            },
          ),
          // Rating bar at the bottom. Its value is observed from the store.
          Align(
            alignment: Alignment.bottomCenter,
            child: Observer(
              builder: (_) => Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                padding: const EdgeInsets.all(16.0),
                child: PannableRatingBar(
                  rate: store.rating,
                  onChanged: (value) => _updateRating(context, value),
                  spacing: 20,
                  items: List.generate(
                    5,
                        (index) => const RatingWidget(
                      selectedColor: Colors.yellow,
                      unSelectedColor: Colors.grey,
                      child: Icon(
                        Icons.star,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // A top overlay for the “connect” button.
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: double.infinity,
              height: 100,
              padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
              child: AppKitModalConnectButton(appKit: appKitModal),
            ),
          ),
        ],
      ),
    );
  }
}
