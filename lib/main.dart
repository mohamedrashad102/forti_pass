import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'views/pass_gen_view.dart';

void main() {
  runApp(const ProviderScope(child: FortiPass()));
}

class FortiPass extends StatelessWidget {
  const FortiPass({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FortiPass',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const PassGenView(),
    );
  }
}
