import 'package:flutter/material.dart';
import 'package:muslimjin/widgets/development_notice.dart';

class DuaScreen extends StatelessWidget {
  const DuaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Duas')),
      body: const DevelopmentNotice(featureName: 'Dua Collection'),
    );
  }
}
