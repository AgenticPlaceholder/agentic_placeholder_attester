// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ServiceController on _ServiceController, Store {
  late final _$appKitAtom =
      Atom(name: '_ServiceController.appKit', context: context);

  @override
  ReownAppKit? get appKit {
    _$appKitAtom.reportRead();
    return super.appKit;
  }

  @override
  set appKit(ReownAppKit? value) {
    _$appKitAtom.reportWrite(value, super.appKit, () {
      super.appKit = value;
    });
  }

  late final _$appKitModalAtom =
      Atom(name: '_ServiceController.appKitModal', context: context);

  @override
  ReownAppKitModal? get appKitModal {
    _$appKitModalAtom.reportRead();
    return super.appKitModal;
  }

  @override
  set appKitModal(ReownAppKitModal? value) {
    _$appKitModalAtom.reportWrite(value, super.appKitModal, () {
      super.appKitModal = value;
    });
  }

  late final _$pageDatasAtom =
      Atom(name: '_ServiceController.pageDatas', context: context);

  @override
  List<PageData> get pageDatas {
    _$pageDatasAtom.reportRead();
    return super.pageDatas;
  }

  @override
  set pageDatas(List<PageData> value) {
    _$pageDatasAtom.reportWrite(value, super.pageDatas, () {
      super.pageDatas = value;
    });
  }

  late final _$initializedAtom =
      Atom(name: '_ServiceController.initialized', context: context);

  @override
  bool get initialized {
    _$initializedAtom.reportRead();
    return super.initialized;
  }

  @override
  set initialized(bool value) {
    _$initializedAtom.reportWrite(value, super.initialized, () {
      super.initialized = value;
    });
  }

  late final _$initializeServiceAsyncAction =
      AsyncAction('_ServiceController.initializeService', context: context);

  @override
  Future<void> initializeService(BuildContext context) {
    return _$initializeServiceAsyncAction
        .run(() => super.initializeService(context));
  }

  @override
  String toString() {
    return '''
appKit: ${appKit},
appKitModal: ${appKitModal},
pageDatas: ${pageDatas},
initialized: ${initialized}
    ''';
  }
}
