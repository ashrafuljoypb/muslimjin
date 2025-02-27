import 'package:flutter/material.dart';

class DevelopmentScreen extends StatelessWidget {
  final String title;
  final String featureName;
  final IconData icon;

  const DevelopmentScreen({
    super.key,
    required this.title,
    required this.featureName,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 100,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 30),
            Icon(
              Icons.construction,
              size: 60,
              color: Colors.orange[700],
            ),
            const SizedBox(height: 30),
            Text(
              'Under Development',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.orange[700],
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                '$featureName is coming soon InShaAllah',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
