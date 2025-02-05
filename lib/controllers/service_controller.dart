import 'dart:convert';

import 'package:agentic_placeholder_attester/injection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:mobx/mobx.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/deep_link_handler.dart';
import '../models/page_data.dart';
import '../pages/pairings_page.dart';
import '../pages/qr_scan_page.dart';
import '../utils/dart_defines.dart';
import '../utils/network_utils.dart';
import '../utils/string_constants.dart';
import 'barcode_scanner_store.dart';

part 'service_controller.g.dart';

@LazySingleton()
class ServiceController = _ServiceController with _$ServiceController;

abstract class _ServiceController with Store {
  @observable
  ReownAppKit? appKit;

  @observable
  ReownAppKitModal? appKitModal;

  @observable
  List<PageData> pageDatas = [];

  @observable
  bool initialized = false;

  // Returns the flavor string based on Dart defines.
  String get flavor {
    String flavorStr = '-${const String.fromEnvironment('FLUTTER_APP_FLAVOR')}';
    return flavorStr.replaceAll('-production', '');
  }

  String _universalLink() {
    Uri link = Uri.parse('https://appkit-lab.reown.com/flutter_appkit');
    if (flavor.isNotEmpty || kDebugMode) {
      return link.replace(path: '${link.path}_internal').toString();
    }
    return link.toString();
  }

  Redirect _constructRedirect() {
    return Redirect(
      native: 'wcflutterdapp$flavor://',
      universal: _universalLink(),
      linkMode: true,
    );
  }

  PairingMetadata _pairingMetadata() {
    return PairingMetadata(
      name: 'Placeholder',
      description: 'Reown\'s sample dapp with Flutter',
      url: _universalLink(),
      icons: [
        'https://raw.githubusercontent.com/reown-com/reown_flutter/refs/heads/develop/assets/appkit-icon$flavor.png',
      ],
      redirect: _constructRedirect(),
    );
  }

  SIWEConfig _siweConfig(bool enabled) => SIWEConfig(
        getNonce: () async {
          return SIWEUtils.generateNonce();
        },
        getMessageParams: () async {
          final url = appKit?.metadata.url ?? _universalLink();
          final uri = Uri.parse(url);
          return SIWEMessageArgs(
            domain: uri.authority,
            uri: 'https://${uri.authority}/login',
            statement: 'Welcome to AppKit $packageVersion for Flutter.',
            methods: MethodsConstants.allMethods,
          );
        },
        createMessage: (SIWECreateMessageArgs args) {
          return SIWEUtils.formatMessage(args);
        },
        verifyMessage: (SIWEVerifyMessageArgs args) async {
          final chainId = SIWEUtils.getChainIdFromMessage(args.message);
          final address = SIWEUtils.getAddressFromMessage(args.message);
          final cacaoSignature = args.cacao != null
              ? args.cacao!.s
              : CacaoSignature(
                  t: CacaoSignature.EIP191,
                  s: args.signature,
                );
          return await SIWEUtils.verifySignature(
            address,
            args.message,
            cacaoSignature,
            chainId,
            DartDefines.projectId,
          );
        },
        getSession: () async {
          final chainId = appKitModal?.selectedChain?.chainId ?? '1';
          final namespace =
              ReownAppKitModalNetworks.getNamespaceForChainId(chainId);
          final address = appKitModal?.session?.getAddress(namespace) ?? '';
          return SIWESession(address: address, chains: [chainId]);
        },
        onSignIn: (SIWESession session) {
          debugPrint('[SIWEConfig] onSignIn()');
        },
        signOut: () async {
          return true;
        },
        onSignOut: () {
          debugPrint('[SIWEConfig] onSignOut()');
        },
        enabled: enabled,
        signOutOnDisconnect: true,
        signOutOnAccountChange: false,
        signOutOnNetworkChange: false,
      );

  @action
  Future<void> initializeService(BuildContext context) async {
    // Initialize the AppKit service.
    appKit = ReownAppKit(
      core: ReownCore(
        projectId: DartDefines.projectId,
        logLevel: LogLevel.all,
      ),
      metadata: _pairingMetadata(),
    );

    // Subscribe to relay client events.
    appKit!.core.relayClient.onRelayClientError.subscribe(_relayClientError);
    appKit!.core.relayClient.onRelayClientConnect.subscribe(_setState);
    appKit!.core.relayClient.onRelayClientDisconnect.subscribe(_setState);
    appKit!.core.relayClient.onRelayClientMessage.subscribe(_onRelayMessage);

    // Subscribe to session events.
    appKit!.onSessionPing.subscribe(_onSessionPing);
    appKit!.onSessionEvent.subscribe(_onSessionEvent);
    appKit!.onSessionUpdate.subscribe(_onSessionUpdate);
    appKit!.onSessionConnect.subscribe(_onSessionConnect);
    appKit!.onSessionAuthResponse.subscribe(_onSessionAuthResponse);

    final prefs = await SharedPreferences.getInstance();
    final linkMode = prefs.getBool('appkit_sample_linkmode') ?? false;
    if (!linkMode) {
      ReownAppKitModalNetworks.addSupportedNetworks('polkadot', [
        ReownAppKitModalNetworkInfo(
          name: 'Polkadot',
          chainId: '91b171bb158e2d3848fa23a9f1c25182',
          chainIcon: 'https://cryptologos.cc/logos/polkadot-new-dot-logo.png',
          currency: 'DOT',
          rpcUrl: 'https://rpc.polkadot.io',
          explorerUrl: 'https://polkadot.subscan.io',
        ),
        ReownAppKitModalNetworkInfo(
          name: 'Westend',
          chainId: 'e143f23803ac50e8f6f8e62695d1ce9e',
          currency: 'DOT',
          rpcUrl: 'https://westend-rpc.polkadot.io',
          explorerUrl: 'https://westend.subscan.io',
          isTestNetwork: true,
        ),
      ]);
    } else {
      ReownAppKitModalNetworks.removeSupportedNetworks('solana');
    }

    appKitModal = ReownAppKitModal(
      context: context,
      appKit: appKit,
      siweConfig: _siweConfig(linkMode),
      enableAnalytics: true,
      featuresConfig: FeaturesConfig(
        email: true,
        socials: [
          AppKitSocialOption.Farcaster,
          AppKitSocialOption.X,
          AppKitSocialOption.Apple,
          AppKitSocialOption.Discord,
        ],
        showMainWallets: false,
      ),
      featuredWalletIds: {
        'fd20dc426fb37566d803205b19bbc1d4096b248ac04548e3cfb6b3a38bd033aa',
        '18450873727504ae9315a084fa7624b5297d2fe5880f0982979c17345a138277',
        'c57ca95b47569778a828d19178114f4db188b89b763c899ba0be274e97267d96',
        '1ae92b26df02f0abca6304df07debccd18262fdf5fe82daa81593582dac9a369',
        'c03dfee351b6fcc421b4494ea33b9d4b92a984f87aa76d1663bb28705e95034a',
        '38f5d18bd8522c244bdd70cb4a68e0e718865155811c043f052fb9f1c51de662',
      },
      optionalNamespaces: !linkMode
          ? {
              'eip155': RequiredNamespace.fromJson({
                'chains': ReownAppKitModalNetworks.getAllSupportedNetworks(
                  namespace: 'eip155',
                ).map((chain) => 'eip155:${chain.chainId}').toList(),
                'methods':
                    NetworkUtils.defaultNetworkMethods['eip155']!.toList(),
                'events': NetworkUtils.defaultNetworkEvents['eip155']!.toList(),
              }),
            }
          : null,
    );

    // Subscribe to modal events.
    appKitModal!.onModalConnect.subscribe(_onModalConnect);
    appKitModal!.onModalUpdate.subscribe(_onModalUpdate);
    appKitModal!.onModalNetworkChange.subscribe(_onModalNetworkChange);
    appKitModal!.onModalDisconnect.subscribe(_onModalDisconnect);
    appKitModal!.onModalError.subscribe(_onModalError);

    pageDatas = [
      PageData(
        page: BarcodeScannerWithOverlay(
          store: getIt<BarcodeScannerStore>(),

          linkMode: false,

          appKitModal: appKitModal!,
          reinitialize: (bool linkMode) {
            return true;
          }, // dummy flag for illustration
        ),
        title: StringConstants.scanPageTitle,
        icon: Icons.qr_code,
      ),
      PageData(
        page: PairingsPage(
          appKitModal: appKitModal!,
        ),
        title: StringConstants.pairingsPageTitle,
        icon: Icons.vertical_align_center_rounded,
      ),
    ];

    await appKitModal!.init();
    await _registerEventHandlers();

    DeepLinkHandler.init(appKitModal!);
    DeepLinkHandler.checkInitialLink();

    final allChains = ReownAppKitModalNetworks.getAllSupportedNetworks();
    for (final chain in allChains) {
      final namespace =
          ReownAppKitModalNetworks.getNamespaceForChainId(chain.chainId);
      for (final event in getChainEvents(namespace)) {
        appKit!.registerEventHandler(
          chainId: chain.chainId,
          event: event,
        );
      }
    }

    initialized = true;
  }

  Future<void> _registerEventHandlers() async {
    final onLine = appKit!.core.connectivity.isOnline.value;
    if (!onLine) {
      await Future.delayed(const Duration(milliseconds: 500));
      await _registerEventHandlers();
      return;
    }
    final allChains = ReownAppKitModalNetworks.getAllSupportedNetworks();
    for (final chain in allChains) {
      final namespace =
          ReownAppKitModalNetworks.getNamespaceForChainId(chain.chainId);
      for (final event in getChainEvents(namespace)) {
        appKit!.registerEventHandler(
          chainId: chain.chainId,
          event: event,
        );
      }
    }
  }

  void _onSessionConnect(SessionConnect? event) {
    log('[SampleDapp] _onSessionConnect ${jsonEncode(event?.session.toJson())}');
  }

  void _onSessionAuthResponse(SessionAuthResponse? response) {
    debugPrint('[SampleDapp] _onSessionAuthResponse $response');
  }

  void _setState(dynamic _) {
    debugPrint('[SampleDapp] _setState');
  }

  void _relayClientError(ErrorEvent? event) {
    debugPrint('[SampleDapp] _relayClientError ${event?.error}');
  }

  void _onSessionPing(SessionPing? args) {
    debugPrint('[SampleDapp] _onSessionPing $args');
  }

  void _onSessionEvent(SessionEvent? args) {
    debugPrint('[SampleDapp] _onSessionEvent $args');
  }

  void _onSessionUpdate(SessionUpdate? args) {
    debugPrint('[SampleDapp] _onSessionUpdate $args');
  }

  void _onRelayMessage(MessageEvent? args) async {
    if (args != null) {
      try {
        final payloadString = await appKit!.core.crypto.decode(
          args.topic,
          args.message,
        );
        final data = jsonDecode(payloadString ?? '{}') as Map<String, dynamic>;
        debugPrint('[SampleDapp] _onRelayMessage data $data');
      } catch (e) {
        debugPrint('[SampleDapp] _onRelayMessage error $e');
      }
    }
  }

  void _onModalConnect(ModalConnect? event) {
    debugPrint('[ExampleApp] _onModalConnect ${event?.session.toJson()}');
  }

  void _onModalUpdate(ModalConnect? event) {
    debugPrint('[ExampleApp] _onModalUpdate ${event?.session.toJson()}');
  }

  void _onModalNetworkChange(ModalNetworkChange? event) {
    debugPrint('[ExampleApp] _onModalNetworkChange ${event?.toString()}');
  }

  void _onModalDisconnect(ModalDisconnect? event) {
    debugPrint('[ExampleApp] _onModalDisconnect ${event?.toString()}');
  }

  void _onModalError(ModalError? event) {
    debugPrint('[ExampleApp] _onModalError ${event?.toString()}');
    if ((event?.message ?? '').contains('Coinbase Wallet Error')) {
      appKitModal?.disconnect();
    }
  }
}
