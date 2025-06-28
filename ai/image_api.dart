import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:arts/api/apis.dart';

class ImageApi {
  static Future<List<Uint8List>> generateImages(String prompt) async {
    final response = await http.post(
      Uri.parse(APIs.baseURL), // already defined correctly in apis.dart
      headers: {
        'Authorization': 'Bearer ${APIs.apiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'inputs': prompt}),
    );

    if (response.statusCode == 200) {
      return [response.bodyBytes]; // returns image as bytes
    } else {
      throw Exception('Failed to generate image: ${response.statusCode} ${response.body}');
    }
  }
}
