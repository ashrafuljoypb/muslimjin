import 'package:flutter/material.dart';
import 'package:muslimjin/screens/home_screen.dart';
import 'package:muslimjin/services/logger_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LoggerService.info('Starting Muslimjin App');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Muslimjin App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}
