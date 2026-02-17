import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class PexelsServices {
  static String get _apiKey => dotenv.env['PEXELS_API_KEY'] ?? '';

  static Future<List<Map<String, dynamic>>> fetchImages({
    int page = 1,
    int perPage = 20,
    String query = 'aesthetic',
  }) async {
    final url = Uri.parse(
      'https://api.pexels.com/v1/search?query=$query&per_page=$perPage&page=$page',
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': _apiKey,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List photos = data['photos'];

      return photos.map<Map<String, dynamic>>((photo) {
        return {
          'id': photo['id'].toString(),
          'imageUrl': photo['src']['large'],
          'width': photo['width'],
          'height': photo['height'],
          'photographer': photo['photographer'],
        };
      }).toList();
    } else {
      throw Exception('Failed to fetch images');
    }
  }
}
