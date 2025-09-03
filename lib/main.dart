import 'package:flutter/material.dart';

import 'pass_gen_view.dart';

void main() {
  runApp(const FortiPass());
}

class FortiPass extends StatelessWidget {
  const FortiPass({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FortiPass',
      home: PassGenView(),
    );
  }
}
