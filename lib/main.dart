import 'package:agentic_placeholder_attester/injection.dart';
import 'package:agentic_placeholder_attester/widgets/app.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const MyApp());
}