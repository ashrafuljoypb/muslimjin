import 'dart:convert';
import 'package:http/http.dart' as http;

class AdhanService {
  final String _baseUrl = 'http://api.aladhan.com/v1/timingsByAddress';

  Future<Map<String, dynamic>> getPrayerTimesForCity(String city) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?address=$city&method=2'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['timings'];
      } else {
        throw Exception('Failed to load prayer times');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  String getAdhanUrl(String city) {
    return 'https://api.aladhan.com/play/$city';
  }
}
