import 'package:agentic_placeholder_attester/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:reown_appkit/reown_appkit.dart';

import '../controllers/pairings_store.dart';
import '../utils/string_constants.dart';

/// A stateless widget that builds the pairings page by observing [PairingsStore].
class PairingsPage extends StatefulWidget {
  final ReownAppKitModal appKitModal;

  const PairingsPage({
    super.key,
    required this.appKitModal,
  });

  @override
  State<PairingsPage> createState() => _PairingsPageState();
}

class _PairingsPageState extends State<PairingsPage> {
  var paringsStore = getIt<PairingsStore>();

  @override
  void initState() {
    super.initState();
    // Load the pairings on initialization
    paringsStore.initialize(widget.appKitModal.appKit!);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final pairings = paringsStore.pairings;
        if (pairings.isEmpty) {
          return const Center(
            child: Text('No relay pairings'),
          );
        }

        final List<Widget> pairingItems = pairings.map((pairing) {
          return SafeArea(
            child: PairingItem(
              key: ValueKey(pairing.topic),
              pairing: pairing,
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        StringConstants.deletePairing,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      content: Text(pairing.topic),
                      actions: [
                        TextButton(
                          child: Text(StringConstants.cancel),
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                        TextButton(
                          child: Text(StringConstants.delete),
                          onPressed: () async {
                            try {
                              await paringsStore.disconnectPairing(pairing.topic);
                              Navigator.of(context).pop(true);
                            } catch (e) {
                              // Log the error if needed.
                              Navigator.of(context).pop(false);
                            }
                          },
                        ),
                      ],
                    );
                  },
                );
                // Optionally use the [confirmed] result if needed.
              },
            ),
          );
        }).toList();

        return Center(
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: double.infinity,
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              children: pairingItems,
            ),
          ),
        );
      },
    );
  }
}

class PairingItem extends StatelessWidget {
  final PairingInfo pairing;
  final VoidCallback onTap;

  const PairingItem({
    Key? key,
    required this.pairing,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        pairing.topic,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        'Expires: ${DateTime.fromMillisecondsSinceEpoch(pairing.expiry * 1000)}',
        style: const TextStyle(fontSize: 14, color: Colors.grey),
      ),
      trailing: const Icon(Icons.delete, color: Colors.red),
      onTap: onTap,
    );
  }
}
