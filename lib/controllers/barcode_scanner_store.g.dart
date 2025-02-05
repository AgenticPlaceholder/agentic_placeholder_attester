// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'barcode_scanner_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$BarcodeScannerStore on _BarcodeScannerStore, Store {
  late final _$ratingAtom =
      Atom(name: '_BarcodeScannerStore.rating', context: context);

  @override
  double get rating {
    _$ratingAtom.reportRead();
    return super.rating;
  }

  @override
  set rating(double value) {
    _$ratingAtom.reportWrite(value, super.rating, () {
      super.rating = value;
    });
  }

  late final _$qrPayloadAtom =
      Atom(name: '_BarcodeScannerStore.qrPayload', context: context);

  @override
  String get qrPayload {
    _$qrPayloadAtom.reportRead();
    return super.qrPayload;
  }

  @override
  set qrPayload(String value) {
    _$qrPayloadAtom.reportWrite(value, super.qrPayload, () {
      super.qrPayload = value;
    });
  }

  late final _$userWalletAddressAtom =
      Atom(name: '_BarcodeScannerStore.userWalletAddress', context: context);

  @override
  String get userWalletAddress {
    _$userWalletAddressAtom.reportRead();
    return super.userWalletAddress;
  }

  @override
  set userWalletAddress(String value) {
    _$userWalletAddressAtom.reportWrite(value, super.userWalletAddress, () {
      super.userWalletAddress = value;
    });
  }

  late final _$isSubmittingAtom =
      Atom(name: '_BarcodeScannerStore.isSubmitting', context: context);

  @override
  bool get isSubmitting {
    _$isSubmittingAtom.reportRead();
    return super.isSubmitting;
  }

  @override
  set isSubmitting(bool value) {
    _$isSubmittingAtom.reportWrite(value, super.isSubmitting, () {
      super.isSubmitting = value;
    });
  }

  late final _$submissionMessageAtom =
      Atom(name: '_BarcodeScannerStore.submissionMessage', context: context);

  @override
  String get submissionMessage {
    _$submissionMessageAtom.reportRead();
    return super.submissionMessage;
  }

  @override
  set submissionMessage(String value) {
    _$submissionMessageAtom.reportWrite(value, super.submissionMessage, () {
      super.submissionMessage = value;
    });
  }

  late final _$submitRatingAsyncAction =
      AsyncAction('_BarcodeScannerStore.submitRating', context: context);

  @override
  Future<bool> submitRating(
      String chainId, ReownAppKitModal appKitModal, double ratingValue) {
    return _$submitRatingAsyncAction
        .run(() => super.submitRating(chainId, appKitModal, ratingValue));
  }

  late final _$_BarcodeScannerStoreActionController =
      ActionController(name: '_BarcodeScannerStore', context: context);

  @override
  void setRating(double value) {
    final _$actionInfo = _$_BarcodeScannerStoreActionController.startAction(
        name: '_BarcodeScannerStore.setRating');
    try {
      return super.setRating(value);
    } finally {
      _$_BarcodeScannerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setQrPayload(String payload) {
    final _$actionInfo = _$_BarcodeScannerStoreActionController.startAction(
        name: '_BarcodeScannerStore.setQrPayload');
    try {
      return super.setQrPayload(payload);
    } finally {
      _$_BarcodeScannerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setUserWalletAddress(String address) {
    final _$actionInfo = _$_BarcodeScannerStoreActionController.startAction(
        name: '_BarcodeScannerStore.setUserWalletAddress');
    try {
      return super.setUserWalletAddress(address);
    } finally {
      _$_BarcodeScannerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void handleSessionConnect(SessionConnect? event) {
    final _$actionInfo = _$_BarcodeScannerStoreActionController.startAction(
        name: '_BarcodeScannerStore.handleSessionConnect');
    try {
      return super.handleSessionConnect(event);
    } finally {
      _$_BarcodeScannerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
rating: ${rating},
qrPayload: ${qrPayload},
userWalletAddress: ${userWalletAddress},
isSubmitting: ${isSubmitting},
submissionMessage: ${submissionMessage}
    ''';
  }
}
