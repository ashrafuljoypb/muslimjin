import 'package:flutter/material.dart';
import 'package:muslimjin/widgets/development_notice.dart';

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Al-Quran')),
      body: const DevelopmentNotice(featureName: 'Al-Quran'),
    );
  }
}
