import 'dart:convert';
import 'package:http/http.dart' as http;

class PrayerTimesService {
  final String _baseUrl = 'http://api.aladhan.com/v1/timings';

  Future<Map<String, dynamic>> getPrayerTimes(
    double latitude,
    double longitude,
  ) async {
    final response = await http.get(
      Uri.parse('$_baseUrl?latitude=$latitude&longitude=$longitude&method=2'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['data']['timings'];
    } else {
      throw Exception('Failed to load prayer times');
    }
  }
}
