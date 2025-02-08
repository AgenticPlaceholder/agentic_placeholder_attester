import 'package:agentic_placeholder_attester/injection.dart';
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
class BarcodeScannerWithOverlay extends StatefulWidget {
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

  @override
  State<BarcodeScannerWithOverlay> createState() => _BarcodeScannerWithOverlayState();
}

class _BarcodeScannerWithOverlayState extends State<BarcodeScannerWithOverlay> with WidgetsBindingObserver{


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.store.controller.start();
    } else {
      widget.store.controller.stop();
    }
    if(state == AppLifecycleState.detached){
      widget.store.controller.stop();
    }
    if(state == AppLifecycleState.inactive){
      widget.store.controller.stop();
    }
    if(state == AppLifecycleState.paused){
      widget.store.controller.stop();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void initState() {
    widget.store.controller.start();
    super.initState();
  }

  /// Called when the rating bar changes.
  Future<void> _updateRating(BuildContext context, double value) async {
    widget.store.setRating(value);

    // Retrieve wallet address from the current chain, if available.
    final chainId = widget.appKitModal.selectedChain?.chainId ?? '';
    if (chainId.isNotEmpty) {
      final namespace =
          ReownAppKitModalNetworks.getNamespaceForChainId(chainId);
      widget.store.setUserWalletAddress(
          widget.appKitModal.session?.getAddress(namespace) ?? '');
    }
    if (widget.store.userWalletAddress.isEmpty) {
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
      widget.store.setRating(0);
      return;
    }

    // Show a confirmation dialog before submitting.
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Rating'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to submit this rating?'),
            const SizedBox(height: 10),
            TextField(
              controller: getIt<BarcodeScannerStore>().commentController,
              decoration: const InputDecoration(
                labelText: 'Add a comment',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            // Null means canceled
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              print(getIt<BarcodeScannerStore>().commentController.text);
              print(getIt<BarcodeScannerStore>().fetchQRSataSeperately(
                  getIt<BarcodeScannerStore>().qrPayload, 0));
              print(getIt<BarcodeScannerStore>().fetchQRSataSeperately(
                  getIt<BarcodeScannerStore>().qrPayload, 1));
              Navigator.of(context).pop(true);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (confirm != true) {
      widget.store.setRating(0);
      return;
    }

    if (widget.store.qrPayload.isEmpty) {
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Uh Oh!',
          message: 'Please scan a QR code to rate',
          contentType: ContentType.failure,
        ),
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
      widget.store.setRating(0);
      return;
    }

    // Show a loader while submitting.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final success = await widget.store.submitRating(chainId, widget.appKitModal, value);
    Navigator.of(context).pop(); // Remove loader.

    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: success ? 'Thank you for rating!' : 'Uh Oh!',
        message: success
            ? 'Checkout the reputation score to validate'
            : widget.store.submissionMessage,
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
              controller: widget.store.controller,
              scanWindow: scanWindow,
              errorBuilder: (context, error, child) =>
                  ScannerErrorWidget(error: error),
              overlayBuilder: (context, constraints) {
                return Container(
                  margin: const EdgeInsets.only(top: 500),
                  child: Observer(
                    builder: (_) {
                      // Create a dummy list of Barcodes from the stored QR payload.
                      final barcodes = widget.store.qrPayload.isNotEmpty
                          ? [Barcode(displayValue: widget.store.qrPayload)]
                          : <Barcode>[];
                      return ScannedBarcodeLabel(
                        barcodes: barcodes,
                        onTokenScanned: widget.store.setQrPayload,
                      );
                    },
                  ),
                );
              },
            ),
          ),
          // Custom overlay painted on top of the camera preview.
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: widget.store.controller,
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
                  rate: widget.store.rating,
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
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              width: double.infinity,
              height: 130,
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 25),
              child: SizedBox(
                  width: double.infinity,
                  height: 90,
                  child: FittedBox(
                      fit: BoxFit.contain,
                      clipBehavior: Clip.antiAlias,
                      child: AppKitModalConnectButton(
                        appKit: widget.appKitModal,
                        size: BaseButtonSize.small,
                      ))),
            ),
          ),
        ],
      ),
    );
  }
}
