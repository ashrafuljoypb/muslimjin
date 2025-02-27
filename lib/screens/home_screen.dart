import 'package:flutter/material.dart';
import 'package:muslimjin/screens/development_screen.dart';
import 'package:muslimjin/screens/kalima_screen.dart';
import 'package:muslimjin/screens/auth_screen.dart';
import 'package:muslimjin/screens/prayer_times_screen.dart';
import 'package:muslimjin/screens/qibla_screen.dart';
import 'package:muslimjin/services/prayer_times_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:muslimjin/screens/ramadhan_calendar_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:intl/intl.dart';
import 'package:muslimjin/services/adhan_service.dart';
import 'package:muslimjin/services/notification_service.dart';
import 'package:muslimjin/services/logger_service.dart';
import 'package:muslimjin/screens/settings_screen.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PrayerTimesService _prayerTimesService = PrayerTimesService();
  final AdhanService _adhanService = AdhanService();
  final NotificationService _notificationService = NotificationService();
  final player = AudioPlayer();
  Map<String, dynamic>? _prayerTimes;
  bool _isLoading = true;
  DateTime? _lastAdhanTime;
  Timer? _adhanCheckTimer;
  bool _adhanEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _notificationService.initNotification();
    _fetchPrayerTimes();
    // Check for prayer times every minute
    _adhanCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkPrayerTimes();
    });
  }

  @override
  void dispose() {
    _adhanCheckTimer?.cancel();
    player.dispose();
    super.dispose();
  }

  Future<void> _fetchPrayerTimes() async {
    try {
      await _determinePosition();
      final position = await _determinePosition();
      final prayerTimes = await _prayerTimesService.getPrayerTimes(
        position.latitude,
        position.longitude,
      );
      if (mounted) {
        setState(() {
          _prayerTimes = prayerTimes;
          _isLoading = false;
        });
        _schedulePrayerNotifications(prayerTimes);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition();
  }

  void _checkPrayerTimes() {
    if (_prayerTimes == null) return;

    final now = DateTime.now();
    final currentTime = DateFormat('HH:mm').format(now);

    _prayerTimes!.forEach((name, time) {
      if (time == currentTime && _shouldPlayAdhan(now)) {
        _playAdhan();
        _lastAdhanTime = now;
      }
    });
  }

  bool _shouldPlayAdhan(DateTime now) {
    if (_lastAdhanTime == null) return true;
    return now.difference(_lastAdhanTime!).inMinutes >= 5;
  }

  Future<void> _playAdhan() async {
    if (!_adhanEnabled) return;

    try {
      // Get city name from location (you should implement this)
      String city = await _getCityFromLocation();
      String adhanUrl = _adhanService.getAdhanUrl(city);

      await player.play(UrlSource(adhanUrl));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prayer time has arrived')),
        );
      }
    } catch (e) {
      LoggerService.error('Error playing Adhan', e);
      // Fallback to local adhan file if API fails
      await player.play(AssetSource('audio/adhan.mp3'));
    }
  }

  Future<String> _getCityFromLocation() async {
    try {
      await _determinePosition();
      // Use reverse geocoding to get city name (implement this)
      // For now, return a default city
      return 'Mecca';
    } catch (e) {
      return 'Mecca'; // Default fallback
    }
  }

  void _schedulePrayerNotifications(Map<String, dynamic> prayerTimes) {
    prayerTimes.forEach((name, time) {
      try {
        final prayerTime = DateFormat.jm().parse(time);
        final now = DateTime.now();
        final scheduledTime = DateTime(
          now.year,
          now.month,
          now.day,
          prayerTime.hour,
          prayerTime.minute,
        ).subtract(const Duration(minutes: 5));

        if (scheduledTime.isAfter(now)) {
          _notificationService.scheduleNotification(
            'Prayer Time Approaching',
            '$name prayer time will begin in 5 minutes',
            scheduledTime,
          );
        }
      } catch (e) {
        LoggerService.error('Error scheduling notification', e);
      }
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _adhanEnabled = prefs.getBool('adhan_enabled') ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Muslimjin App'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.login),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AuthScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            _buildDrawerItem(
              context,
              'Kalima',
              Icons.book,
              const KalimaScreen(),
            ),
            _buildDrawerItem(
              context,
              'Qibla',
              Icons.explore,
              const QiblaScreen(),
            ),
            _buildDrawerItem(
              context,
              'Ramadhan Calendar',
              Icons.calendar_month,
              RamadhanCalendarScreen(hasLocation: _prayerTimes != null),
            ),
            // Updated development notice screens
            _buildDrawerItem(
              context,
              'Al-Quran',
              Icons.menu_book,
              const DevelopmentScreen(
                title: 'Al-Quran',
                featureName: 'Digital Quran with Translation',
                icon: Icons.menu_book,
              ),
            ),
            _buildDrawerItem(
              context,
              'Hadith',
              Icons.library_books,
              const DevelopmentScreen(
                title: 'Hadith Collection',
                featureName: 'Hadith Database',
                icon: Icons.library_books,
              ),
            ),
            _buildDrawerItem(
              context,
              'Duas',
              Icons.bookmark,
              const DevelopmentScreen(
                title: 'Duas Collection',
                featureName: 'Daily Duas',
                icon: Icons.bookmark,
              ),
            ),
            _buildDrawerItem(
              context,
              'Islamic Content',
              Icons.article,
              const DevelopmentScreen(
                title: 'Islamic Content',
                featureName: 'Islamic Articles and Resources',
                icon: Icons.article,
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Prayer Times',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Icon(
                        Icons.mosque,
                        size: 80,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
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
                    const Divider(thickness: 2),
                    const SizedBox(height: 10),
                    _buildJummahTime(),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PrayerTimesScreen(),
                            ),
                          );
                        },
                        child: const Text('View Detailed Prayer Times'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    String title,
    IconData icon,
    Widget screen,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // Close drawer
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
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
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          time ?? '',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildJummahTime() {
    // You can customize these times based on your local mosque
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 4.0,
      color: Colors.green.shade50,
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jummah Prayer',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'First Jamaat: 1:30 PM',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 5),
            Text(
              'Second Jamaat: 2:30 PM',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
