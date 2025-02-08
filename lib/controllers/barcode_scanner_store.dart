import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mobx/mobx.dart';
import 'package:reown_appkit/reown_appkit.dart';

part 'barcode_scanner_store.g.dart';

/// The store manages all state:
/// - It instantiates and manages the MobileScannerController and its subscription,
/// - Holds the scanned QR payload, rating, and wallet address,
/// - Provides an asynchronous action to submit the rating.
@LazySingleton()
class BarcodeScannerStore = _BarcodeScannerStore with _$BarcodeScannerStore;

abstract class _BarcodeScannerStore with Store {
  /// The MobileScannerController is created here and its lifecycle is managed by the store.
  final MobileScannerController controller;

  StreamSubscription<BarcodeCapture>? _subscription;

  _BarcodeScannerStore()
      : controller = MobileScannerController(
          formats: const [BarcodeFormat.qrCode],
          autoStart: true,
          torchEnabled: false,
          useNewCameraSelector: true,
        ) {
    // Subscribe to barcode scanning events.
    _subscription = controller.barcodes.listen((capture) {
      if (capture.barcodes.isNotEmpty) {
        setQrPayload(capture.barcodes.first.displayValue ?? '');
      } else {
        setQrPayload('');
      }
    });
  }

  TextEditingController commentController = TextEditingController();

  @observable
  double rating = 0;

  @observable
  String qrPayload = '';

  @observable
  String userWalletAddress = '';

  @observable
  bool isSubmitting = false;

  @observable
  String submissionMessage = '';

  @action
  void setRating(double value) {
    rating = value;
  }

  @action
  void setQrPayload(String payload) {
    qrPayload = payload;
  }

  @action
  void setUserWalletAddress(String address) {
    userWalletAddress = address;
  }

  @action
  void handleSessionConnect(SessionConnect? event) {
    if (event != null) {
      setUserWalletAddress(event.session.self.publicKey);
    }
  }

  @action
  Future<bool> submitRating(
      String chainId, ReownAppKitModal appKitModal, double ratingValue) async {
    isSubmitting = true;

    // If a chain is selected, update the wallet address accordingly.
    if (chainId.isNotEmpty) {
      final namespace =
          ReownAppKitModalNetworks.getNamespaceForChainId(chainId);
      userWalletAddress = appKitModal.session?.getAddress(namespace) ?? '';
    }

    if (userWalletAddress.isEmpty) {
      submissionMessage = 'Please connect your wallet to rate';
      isSubmitting = false;
      return false;
    }

    try {
      // Generate the message to sign.
      final message = json.encode({
        "adId": fetchQRSataSeperately(qrPayload, 1),
        "operatorAddress": "0xecba9756092b7851f4918ec6bab2085b8f88b8ff",
        "publisherAddress": fetchQRSataSeperately(qrPayload, 0),
        "userAddress": userWalletAddress,
        "rating": ratingValue.round(),
        "comment": commentController.text,
        "signature": "0x789ghi"
      });

      // In a real app, call your signing method here.
      // final signature = "0x1234567890";

      final headers = {'Content-Type': 'application/json'};
      // final data = json.encode({
      //   "publisherAddress": qrPayload,
      //   "userAddress": userWalletAddress,
      //   "rating": ratingValue.toInt(),
      //   "signature": signature,
      // });
      final dio = Dio();
      final response = await dio.post(
        'https://placeholder.taraxio.com/api/user/attest',
        options: Options(headers: headers),
        data: message,
      );

      if (response.statusCode == 200) {
        submissionMessage = 'Thank you for rating!';
        rating = 0;
        isSubmitting = false;
        return true;
      } else {
        submissionMessage = 'Could not submit rating';
        rating = 0;
        isSubmitting = false;
        return false;
      }
    } catch (e) {
      submissionMessage = 'Error signing the message';
      rating = 0;
      isSubmitting = false;
      return false;
    }
  }

  /// Dispose of resources when no longer needed.
  void dispose() {
    _subscription?.cancel();
    controller.dispose();
  }

  @action
  String fetchQRSataSeperately(String qrData, int index) {
    return qrData.split(',')[index];
  }
}
