// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairings_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$PairingsStore on _PairingsStore, Store {
  Computed<List<PairingInfo>>? _$pairingsComputed;

  @override
  List<PairingInfo> get pairings =>
      (_$pairingsComputed ??= Computed<List<PairingInfo>>(() => super.pairings,
              name: '_PairingsStore.pairings'))
          .value;

  late final _$_pairingsAtom =
      Atom(name: '_PairingsStore._pairings', context: context);

  @override
  ObservableList<PairingInfo> get _pairings {
    _$_pairingsAtom.reportRead();
    return super._pairings;
  }

  @override
  set _pairings(ObservableList<PairingInfo> value) {
    _$_pairingsAtom.reportWrite(value, super._pairings, () {
      super._pairings = value;
    });
  }

  late final _$disconnectPairingAsyncAction =
      AsyncAction('_PairingsStore.disconnectPairing', context: context);

  @override
  Future<void> disconnectPairing(String topic) {
    return _$disconnectPairingAsyncAction
        .run(() => super.disconnectPairing(topic));
  }

  late final _$_PairingsStoreActionController =
      ActionController(name: '_PairingsStore', context: context);

  @override
  void initialize(IReownAppKit appKit) {
    final _$actionInfo = _$_PairingsStoreActionController.startAction(
        name: '_PairingsStore.initialize');
    try {
      return super.initialize(appKit);
    } finally {
      _$_PairingsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _onPairingChanged(PairingEvent? event) {
    final _$actionInfo = _$_PairingsStoreActionController.startAction(
        name: '_PairingsStore._onPairingChanged');
    try {
      return super._onPairingChanged(event);
    } finally {
      _$_PairingsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
pairings: ${pairings}
    ''';
  }
}
