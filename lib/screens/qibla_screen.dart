import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math.dart' as vector;
import 'package:geolocator/geolocator.dart';
import 'package:muslimjin/services/qibla_service.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double? _direction;
  double? _qiblaDirection;
  bool _hasPermission = false;
  final double kaabaLat = 21.4225; // Kaaba latitude
  final double kaabaLng = 39.8262; // Kaaba longitude
  final QiblaService _qiblaService = QiblaService();
  Map<String, dynamic>? _apiQiblaData;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    FlutterCompass.events?.listen((event) {
      setState(() {
        _direction = event.heading;
      });
    });
    _fetchApiQiblaDirection();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError('Location services are disabled');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showError('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showError('Location permissions are permanently denied');
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    _calculateQiblaDirection(position.latitude, position.longitude);
    setState(() {
      _hasPermission = true;
    });
  }

  Future<void> _fetchApiQiblaDirection() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      final qiblaData = await _qiblaService.getQiblaDirection(
        position.latitude,
        position.longitude,
      );
      setState(() {
        _apiQiblaData = qiblaData;
      });
    } catch (e) {
      _showError('Failed to fetch Qibla direction from API');
    }
  }

  void _calculateQiblaDirection(double latitude, double longitude) {
    final double phi = (latitude * math.pi) / 180;
    final double phiK = (kaabaLat * math.pi) / 180;
    final double lambda = (longitude * math.pi) / 180;
    final double lambdaK = (kaabaLng * math.pi) / 180;

    double qiblaDirection = vector.degrees(math.atan2(
      math.sin(lambdaK - lambda),
      math.cos(phi) * math.tan(phiK) -
          math.sin(phi) * math.cos(lambdaK - lambda),
    ));

    setState(() {
      _qiblaDirection = qiblaDirection;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qibla Direction'),
      ),
      body: _hasPermission
          ? SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Qibla Finder',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _getDirectionText(),
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.green, width: 2),
                        ),
                        child: _direction != null
                            ? Transform.rotate(
                                angle: ((_direction! + (_qiblaDirection ?? 0)) *
                                    (math.pi / 180) *
                                    -1),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/compass.png',
                                      width: 200,
                                      height: 200,
                                    ),
                                    const Positioned(
                                      top: 20,
                                      child: Icon(
                                        Icons.arrow_upward,
                                        color: Colors.green,
                                        size: 40,
                                      ),
                                    ),
                                    const Positioned(
                                      child: Icon(
                                        Icons.mosque,
                                        color: Colors.green,
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const Center(
                                child: Text('Calibrating compass...')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Align the arrow with the Kaaba icon to find Qibla direction. '
                      'Make sure you\'re holding your device flat and away from magnetic interference.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Divider(thickness: 2),
                  const SizedBox(height: 20),
                  _buildApiQiblaInfo(),
                ],
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget _buildApiQiblaInfo() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'API Qibla Verification',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            if (_apiQiblaData != null) ...[
              _buildInfoRow('Direction', '${_apiQiblaData!['direction']}°'),
              const SizedBox(height: 8),
              _buildInfoRow('Kaaba Latitude', '${_apiQiblaData!['latitude']}°'),
              const SizedBox(height: 8),
              _buildInfoRow(
                  'Kaaba Longitude', '${_apiQiblaData!['longitude']}°'),
              const SizedBox(height: 16),
              Text(
                _getComparisonText(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ] else
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  String _getComparisonText() {
    if (_apiQiblaData == null || _qiblaDirection == null) return '';

    double difference = (_apiQiblaData!['direction'] - _qiblaDirection!).abs();
    if (difference <= 5) {
      return '✅ Compass calculation matches API direction';
    } else {
      return '⚠️ Consider calibrating your compass or using API direction';
    }
  }

  String _getDirectionText() {
    if (_direction == null || _qiblaDirection == null) return 'Calculating...';

    double rotation = (_direction! + _qiblaDirection!).abs() % 360;
    if (rotation <= 5 || rotation >= 355) {
      return 'You are facing the Qibla! 🕌';
    }
    return 'Rotate ${rotation <= 180 ? "right" : "left"} to face Qibla';
  }
}
