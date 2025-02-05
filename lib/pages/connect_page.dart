import 'package:flutter/material.dart';
import 'package:reown_appkit/reown_appkit.dart';

class ConnectPage extends StatelessWidget {
  final ReownAppKitModal appKitModal;
  const ConnectPage({Key? key, required this.appKitModal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Connect Page'));
  }
}