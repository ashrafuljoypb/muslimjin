import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:muslimjin/services/prayer_times_service.dart';
import 'package:logger/logger.dart' as log;

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  PrayerTimesScreenState createState() => PrayerTimesScreenState();
}

class PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final log.Logger _logger = log.Logger();
  final PrayerTimesService _prayerTimesService = PrayerTimesService();
  Map<String, dynamic>? _prayerTimes;
  Map<String, dynamic>? _secondaryPrayerTimes;
  bool _isLoading = true;
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPrayerTimes();
  }

  Future<void> _fetchPrayerTimes() async {
    try {
      Position position = await _determinePosition();
      final prayerTimes = await _prayerTimesService.getPrayerTimes(
        position.latitude,
        position.longitude,
      );
      _logger.d('Fetched prayer times: $prayerTimes'); // Debug print

      if (mounted) {
        setState(() {
          _prayerTimes = prayerTimes;
          _isLoading = false;
        });
      }
    } catch (e) {
      _logger.e('Error fetching prayer times: $e'); // Debug print
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      // Handle error
    }
  }

  Future<void> _fetchSecondaryPrayerTimes(String location) async {
    try {
      // Use a geocoding API to get the latitude and longitude from the location
      // For simplicity, let's assume we have a function getLatLngFromLocation
      final latLng = await getLatLngFromLocation(location);
      final prayerTimes = await _prayerTimesService.getPrayerTimes(
        latLng['latitude']!,
        latLng['longitude']!,
      );
      _logger.d('Fetched secondary prayer times: $prayerTimes'); // Debug print
      if (mounted) {
        setState(() {
          _secondaryPrayerTimes = prayerTimes;
        });
      }
    } catch (e) {
      _logger.e('Error fetching secondary prayer times: $e'); // Debug print
      // Handle error
    }
  }

  Future<Map<String, double>> getLatLngFromLocation(String location) async {
    // Implement the function to get latitude and longitude from the location
    // You can use a geocoding API like Google Geocoding API or any other service
    // For simplicity, let's return dummy coordinates
    return {'latitude': 21.4225, 'longitude': 39.8262}; // Coordinates for Mecca
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prayer Times')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    _buildPrayerTimeItem('Fajr', _prayerTimes?['Fajr']),
                    const SizedBox(height: 10),
                    _buildPrayerTimeItem('Dhuhr', _prayerTimes?['Dhuhr']),
                    const SizedBox(height: 10),
                    _buildPrayerTimeItem('Asr', _prayerTimes?['Asr']),
                    const SizedBox(height: 10),
                    _buildPrayerTimeItem('Maghrib', _prayerTimes?['Maghrib']),
                    const SizedBox(height: 10),
                    _buildPrayerTimeItem('Isha', _prayerTimes?['Isha']),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Enter location',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        _fetchSecondaryPrayerTimes(_locationController.text);
                      },
                      child: const Text('Get Prayer Times'),
                    ),
                    const SizedBox(height: 20),
                    if (_secondaryPrayerTimes != null) ...[
                      const Text(
                        'Secondary Prayer Times',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildPrayerTimeItem(
                        'Fajr',
                        _secondaryPrayerTimes?['Fajr'],
                      ),
                      const SizedBox(height: 10),
                      _buildPrayerTimeItem(
                        'Dhuhr',
                        _secondaryPrayerTimes?['Dhuhr'],
                      ),
                      const SizedBox(height: 10),
                      _buildPrayerTimeItem(
                        'Asr',
                        _secondaryPrayerTimes?['Asr'],
                      ),
                      const SizedBox(height: 10),
                      _buildPrayerTimeItem(
                        'Maghrib',
                        _secondaryPrayerTimes?['Maghrib'],
                      ),
                      const SizedBox(height: 10),
                      _buildPrayerTimeItem(
                        'Isha',
                        _secondaryPrayerTimes?['Isha'],
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPrayerTimeItem(String name, String? time) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 4.0,
      child: ListTile(
        leading: Icon(Icons.access_time, color: Theme.of(context).primaryColor),
        title: Text(
          name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          time ?? '',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
