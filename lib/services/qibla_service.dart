import 'dart:convert';
import 'package:http/http.dart' as http;

class QiblaService {
  final String _baseUrl = 'http://api.aladhan.com/v1/qibla';

  Future<Map<String, dynamic>> getQiblaDirection(double lat, double lng) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$lat/$lng'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'direction': data['data']['direction'],
          'latitude': data['data']['latitude'],
          'longitude': data['data']['longitude'],
        };
      } else {
        throw Exception('Failed to load Qibla direction');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
