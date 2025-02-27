import 'package:flutter/material.dart';
import 'package:muslimjin/widgets/development_notice.dart';

class HadithScreen extends StatelessWidget {
  const HadithScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hadith')),
      body: const DevelopmentNotice(featureName: 'Hadith Collection'),
    );
  }
}
