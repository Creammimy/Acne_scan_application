import 'dart:ui';

import 'package:flutter/src/widgets/framework.dart';

class Result {
  final String label;
  final double confidence;
  final Rect rect; // normalized box [0.0 - 1.0]

  Result({
    required this.label,
    required this.confidence,
    required this.rect,
  });

  /// สร้างจาก JSON ที่มี box normalized
  factory Result.fromJson(Map<String, dynamic> json) {
    final box = json['box'] as List<dynamic>;
     print('Box (normalized): ${box[0]}, ${box[1]}, ${box[2]}, ${box[3]}');

    return Result(
      label: json['class'],
      confidence: (json['confidence'] as num).toDouble(),
      rect: Rect.fromLTRB(
        (box[0] as num).toDouble(), // normalized x1
        (box[1] as num).toDouble(), // normalized y1
        (box[2] as num).toDouble(), // normalized x2
        (box[3] as num).toDouble(), // normalized y2
      ),
    );
  }

  /// แปลงพิกัด normalized ไปเป็นพิกัดจริงบนภาพ (ใช้ตอนวาดกรอบ)
  Rect getAbsoluteRect(double imageWidth, double imageHeight) {
    return Rect.fromLTRB(
      rect.left * imageWidth,
      rect.top * imageHeight,
      rect.right * imageWidth,
      rect.bottom * imageHeight,
    );
  }

  @override
  String toString() {
    return 'Result(label: $label, confidence: $confidence, rect: $rect)';
  }

  
}

class ImageAnalysisResult {
  final String filename;
  final List<Result> detections;
  final Map<String, int> acneCountByType;
  final int totalAcneCount;
  final String? renderedImagePath; // สำหรับอนาคต

  ImageAnalysisResult({
    required this.filename,
    required this.detections,
    required this.acneCountByType,
    required this.totalAcneCount,
    this.renderedImagePath,
  });

  factory ImageAnalysisResult.fromJson(Map<String, dynamic> json) {
  final detectionsJson = json['detections'] as List<dynamic>? ?? [];

  return ImageAnalysisResult(
    filename: json['filename'],
    detections: detectionsJson.map((e) => Result.fromJson(e)).toList(),
    acneCountByType: Map<String, int>.from(json['acne_count_by_type'] ?? {}),
    totalAcneCount: json['total_acne_count'] ?? 0,
    renderedImagePath: null,
  );
}

  @override
  String toString() {
    return 'ImageAnalysisResult(filename: $filename, total: $totalAcneCount, types: $acneCountByType)';
  }
}
