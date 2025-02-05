import 'package:injectable/injectable.dart';
import 'package:mobx/mobx.dart';
import 'package:reown_appkit/reown_appkit.dart';

part 'pairings_store.g.dart';

@LazySingleton()
class PairingsStore = _PairingsStore with _$PairingsStore;

abstract class _PairingsStore with Store {
  IReownAppKit? _appKit; // Nullable because it is initialized later.

  @observable
  ObservableList<PairingInfo> _pairings = ObservableList<PairingInfo>();

  @computed
  List<PairingInfo> get pairings => _pairings.toList();

  /// Set `appKit` manually from the dashboard when available.
  @action
  void initialize(IReownAppKit appKit) {
    _appKit = appKit;
    _pairings = ObservableList.of(_appKit!.pairings.getAll());

    // Subscribe to pairing deletion and expiry events.
    _appKit!.core.pairing.onPairingDelete.subscribe(_onPairingChanged);
    _appKit!.core.pairing.onPairingExpire.subscribe(_onPairingChanged);
  }

  /// Called when a pairing is deleted or expires.
  @action
  void _onPairingChanged(PairingEvent? event) {
    if (_appKit != null) {
      _pairings = ObservableList.of(_appKit!.pairings.getAll());
    }
  }

  /// Disconnect a pairing and update the list.
  @action
  Future<void> disconnectPairing(String topic) async {
    if (_appKit == null) return;
    await _appKit!.core.pairing.disconnect(topic: topic);
    _pairings = ObservableList.of(_appKit!.pairings.getAll());
  }

  /// Unsubscribe when the store is no longer needed.
  void dispose() {
    if (_appKit != null) {
      _appKit!.core.pairing.onPairingDelete.unsubscribe(_onPairingChanged);
      _appKit!.core.pairing.onPairingExpire.unsubscribe(_onPairingChanged);
    }
  }
}