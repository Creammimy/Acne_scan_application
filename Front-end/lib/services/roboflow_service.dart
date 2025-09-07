import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'result_model.dart';

class RoboflowService {
  static Future<List<ImageAnalysisResult>> analyzeImages(List<File> imageFiles) async {
    Uri uri = Uri.parse('https://acne-backend-qukb.onrender.com/analyze/');

    http.StreamedResponse streamedResponse;

    // ✅ ส่งคำขอรอบแรก
    var request = http.MultipartRequest('POST', uri);
    for (var image in imageFiles) {
      request.files.add(await http.MultipartFile.fromPath('files', image.path));
    }

    streamedResponse = await request.send();

    // ✅ ถ้าโดน redirect → ดึง URL ใหม่ แล้วส่งอีกครั้ง
    if (streamedResponse.statusCode == 307 || streamedResponse.isRedirect) {
      final location = streamedResponse.headers['location'];
      if (location == null) {
        throw Exception("Redirect response but no Location header");
      }

      print("🔁 Redirected to: $location");

      uri = Uri.parse(location);
      request = http.MultipartRequest('POST', uri);
      for (var image in imageFiles) {
        request.files.add(await http.MultipartFile.fromPath('files', image.path));
      }
      streamedResponse = await request.send();
    }

    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      print("Error body: ${response.body}");
      throw Exception("วิเคราะห์ภาพล้มเหลว: ${response.statusCode}");
    }

    final jsonData = jsonDecode(response.body);
    final List results = jsonData['results'];

    return results.map((e) => ImageAnalysisResult.fromJson(e)).toList();
  }
}
