import 'package:flutter/material.dart';
import 'package:muslimjin/widgets/development_notice.dart';

class IslamicContentScreen extends StatelessWidget {
  const IslamicContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Islamic Content')),
      body: const DevelopmentNotice(featureName: 'Islamic Content'),
    );
  }
}
