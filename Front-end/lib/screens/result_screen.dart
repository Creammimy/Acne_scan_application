import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:project_acne_scan/services/result_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // ✅ เพิ่มบรรทัดนี้
import 'package:uuid/uuid.dart'; // ✅ สำหรับสร้าง result_id

class ResultScreen extends StatefulWidget {
  final List<String> imagePaths;
  final List<ImageAnalysisResult> detectionResultsPerImage;
  final Map<String, int> pimpleTypes;
  final String careInstructions;

  const ResultScreen({
    Key? key,
    required this.imagePaths,
    required this.detectionResultsPerImage,
    required this.pimpleTypes,
    required this.careInstructions,
  }) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  List<String> selectedTypes = [];
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _saveResult(BuildContext context) async {
  final supabase = Supabase.instance.client;
  final uuid = const Uuid();
  final user = supabase.auth.currentUser;

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ยังไม่ได้เข้าสู่ระบบ')),
    );
    return;
  }

  final resultId = uuid.v4();
  final now = DateTime.now().toIso8601String();

  final summary = {
    "types": widget.pimpleTypes,
    "total": widget.pimpleTypes.values.fold(0, (sum, val) => sum + val),
  };

  final predictions = widget.detectionResultsPerImage.map((result) {
    return {
      "detections": result.detections.map((d) {
        return {
          "label": d.label,
          "confidence": d.confidence,
          "rect": {
            "left": d.rect.left,
            "top": d.rect.top,
            "width": d.rect.width,
            "height": d.rect.height,
          }
        };
      }).toList(),
    };
  }).toList();

  try {
    final List<String> uploadedUrls = [];

    for (final path in widget.imagePaths) {
      final file = File(path);
      final fileName = path.split('/').last;
      final storagePath = 'public/$resultId/$fileName';

      final fileBytes = await file.readAsBytes();
      final response = await supabase.storage
          .from('acne-images')
          .uploadBinary(storagePath, fileBytes, fileOptions: FileOptions(contentType: 'image/jpeg'));

      final publicUrl = supabase.storage
          .from('acne-images')
          .getPublicUrl(storagePath);

      uploadedUrls.add(publicUrl);
    }

    await supabase.from('results_info').insert({
      'result_id': resultId,
      'user_id': user.id,
      'created_at': now,
      'image_urls': uploadedUrls,
      'summary': summary,
      'predictions': predictions,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('บันทึกผลลัพธ์เรียบร้อย')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('เกิดข้อผิดพลาดในการบันทึก: $e')),
    );
  }
}

  Future<Size> _getImageSize(String path) async {
    final completer = Completer<Size>();
    final image = FileImage(File(path));
    final stream = image.resolve(const ImageConfiguration());
    stream.addListener(ImageStreamListener((info, _) {
      completer.complete(Size(
        info.image.width.toDouble(),
        info.image.height.toDouble(),
      ));
    }));
    return completer.future;
  }

  Color getColorForLabel(String label) {
    const colorMap = {
      'Pustula': Colors.red,
      'blackhead': Colors.orange,
      'whitehead': Colors.blue,
      'papula': Colors.purple,
      'nodules': Colors.green,
      'fungal acne': Colors.teal,
      'acne fulminans': Colors.brown,
    };
    return colorMap[label] ?? Colors.grey;
  }

  String getDisplayLabel(String label) {
    const nameMap = {
      'Pustula': 'สิวตุ่มหนอง',
      'blackhead': 'สิวหัวดำ',
      'whitehead': 'สิวหัวขาว',
      'papula': 'สิวตุ่มแดง',
      'nodules': 'สิวไต',
      'fungal acne': 'สิวเชื้อรา',
      'acne fulminans': 'acne fulminans',
    };
    return nameMap[label] ?? label;
  }
  final Map<String, String> careInstructionsByType = {
    'Pustula': 'สิวตุ่มหนองควรได้รับการรักษาด้วยยาฆ่าเชื้อ เช่น Benzoyl Peroxide หรือยาปฏิชีวนะเฉพาะที่ เช่น Clindamycin เพื่อฆ่าเชื้อแบคทีเรียและลดการอักเสบ ในบางกรณีที่สิวรุนแรง อาจจำเป็นต้องใช้ยากินหรือเรตินอยด์ เช่น Isotretinoin ภายใต้การดูแลของแพทย์ ควรรักษาความสะอาด หลีกเลี่ยงการบีบสิว และเลือกใช้ผลิตภัณฑ์ดูแลผิวที่ไม่อุดตันรูขุมขน',
    'acne fulminans': 'สิวชนิดนี้ต้องได้รับการรักษาโดยแพทย์ เนื่องจากมีการอักเสบรุนแรงและมักมีอาการระบบร่วม เช่น มีไข้หรือปวดข้อ การรักษามักเริ่มด้วยยาสเตียรอยด์เพื่อลดการอักเสบ แล้วตามด้วยไอโซเตรติโนอินในขนาดต่ำเพื่อควบคุมสิวในระยะยาว ห้ามรักษาด้วยยาสิวทั่วไปโดยไม่ได้รับคำแนะนำจากแพทย์',
    'blackhead': 'สิวหัวดำควรใช้ผลิตภัณฑ์ผลัดเซลล์ผิว เช่น กรดซาลิไซลิกหรือเรตินอยด์ เพื่อเปิดรูขุมขนและลดการอุดตัน หมั่นล้างหน้าให้สะอาด หลีกเลี่ยงการล้างหน้ารุนแรงหรือใช้ผลิตภัณฑ์ที่อุดตันผิว และไม่ควรบีบสิวด้วยตนเองเพราะเสี่ยงต่อการติดเชื้อและเกิดรอยดำ',
    'fungal acne': 'สิวชนิดนี้เกิดจากการเจริญของเชื้อราในรูขุมขน มักขึ้นเป็นตุ่มเล็ก ๆ หลายจุดพร้อมกัน การรักษาควรใช้ยาต้านเชื้อราทั้งแบบทาและรับประทาน เช่น Ketoconazole หรือ Fluconazole ควรรักษาความสะอาดผิวหนัง หลีกเลี่ยงความอับชื้น และไม่ใช้ยาปฏิชีวนะโดยไม่จำเป็น',
    'nodules': 'สิวไตเป็นสิวอักเสบรุนแรงที่ลึกและเจ็บ การรักษาควรใช้ยาเรตินอยด์ชนิดรับประทาน เช่น Isotretinoin ภายใต้การดูแลของแพทย์เพื่อป้องกันแผลเป็น หลีกเลี่ยงการบีบหรือกด เพราะอาจทำให้สิวลุกลามหรือทิ้งรอยแผลลึก',
    'papula': 'สิวตุ่มแดงควรรักษาด้วยยาทาเพื่อลดการอักเสบ เช่น Benzoyl Peroxide หรือยาปฏิชีวนะเฉพาะที่ เช่น Clindamycin หากสิวไม่ดีขึ้นอาจพิจารณาใช้ยารับประทานร่วมด้วย ควรหลีกเลี่ยงการสัมผัสหรือบีบสิว และดูแลผิวอย่างอ่อนโยน',
    'whitehead': 'สิวหัวขาวสามารถรักษาได้ด้วยการใช้ผลิตภัณฑ์ที่ช่วยผลัดเซลล์ผิว เช่น กรดซาลิไซลิก หรือเรตินอยด์เพื่อลดการอุดตัน หมั่นล้างหน้าเป็นประจำ และหลีกเลี่ยงเครื่องสำอางที่อุดตันรูขุมขน ควรหลีกเลี่ยงการบีบสิวเพื่อไม่ให้เกิดการอักเสบ',
  };

  @override
  Widget build(BuildContext context) {
    final foundPimples = widget.pimpleTypes.entries
        .where((e) =>
            e.value > 0 &&
            (selectedTypes.isEmpty || selectedTypes.contains(e.key)))
        .toList();

    final foundTypes = widget.pimpleTypes.entries
        .where((e) => e.value > 0)
        .map((e) => e.key)
        .toList();

    final totalAcne = foundPimples.fold<int>(0, (sum, e) => sum + e.value);
    return Scaffold(
      appBar: AppBar(
        title: const Text('ผลลัพธ์การวิเคราะห์'),
        backgroundColor: const Color(0xFFCDF8F7),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- Slide รูป ----------
            Column(
              children: [
                SizedBox(
                  height: 300,
                  child: PageView.builder(
                    itemCount: widget.detectionResultsPerImage.length,
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (context, index) {
                      final result = widget.detectionResultsPerImage[index];
                      final filteredDetections = selectedTypes.isEmpty
                          ? result.detections
                          : result.detections
                              .where((d) => selectedTypes.contains(d.label))
                              .toList();

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return FutureBuilder<Size>(
                            future: _getImageSize(widget.imagePaths[index]),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              final imageSize = snapshot.data!;
                              return Stack(
                                children: [
                                  Positioned.fill(
                                    child: Image.file(
                                      File(widget.imagePaths[index]),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: BoundingBoxPainter(
                                        filteredDetections,
                                        imageSize,
                                        getColorForLabel,
                                        getDisplayLabel,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_currentPage + 1}/${widget.imagePaths.length}',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ---------- Header + Dropdown Filter ----------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ผลการวิเคราะห์สิวของคุณ',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 143, 247, 238),
                        border: Border.all(
                            color: Color.fromARGB(255, 143, 247, 238)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: PopupMenuButton<String>(
                        tooltip: 'เลือกประเภทสิว',
                        onSelected: (String? value) {
                          setState(() {
                            if (value != null) {
                              if (selectedTypes.contains(value)) {
                                selectedTypes.remove(value);
                              } else {
                                selectedTypes.add(value);
                              }
                            }
                          });
                        },
                        itemBuilder: (BuildContext context) {
                          return foundTypes.map((type) {
                            return CheckedPopupMenuItem<String>(
                              value: type,
                              checked: selectedTypes.contains(type),
                              child: Text(getDisplayLabel(type)),
                            );
                          }).toList();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: Row(
                            children: const [
                              Text('สิวทั้งหมด'),
                              Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 2),

            // ---------- รายการสิว ----------
            if (foundPimples.isEmpty)
              const Center(
                child: Text(
                  'ไม่พบสิวบนใบหน้าของคุณ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: foundPimples.map((entry) {
                  final isAreaBased = entry.key == 'fungal acne' ||
                      entry.key == 'acne fulminans';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: getColorForLabel(entry.key),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Text(
                          'พบ ${getDisplayLabel(entry.key)} : ${entry.value} ${isAreaBased ? 'บริเวณ' : 'จุด'}',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

            if (foundPimples.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Center(
                  child: Text(
                    'รวมทั้งหมด: $totalAcne จุด',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // ---------- คำแนะนำ ----------
           Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
     Text(
        'คำแนะนำการดูแลรักษา',
        style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
      ),
    
    const SizedBox(height: 10),
    ...foundPimples.map((entry) {
      final type = entry.key;
      final displayName = getDisplayLabel(type); // เช่น สิวอุดตัน, สิวอักเสบ
      final instruction = careInstructionsByType[type] ?? 'ไม่มีข้อมูลคำแนะนำ';

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F7FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFB2EBF2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  instruction,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList(),
  ],
),
            const SizedBox(height: 30),

            // ---------- ปุ่ม ----------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _saveResult(context),
                  icon: const Icon(Icons.save),
                  label: const Text('บันทึกผลลัพธ์'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCDF8F7)),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/home', (route) => false);
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('กลับไปหน้าโฮม'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFCD9D9)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// ---------- Custom Painter สำหรับกรอบ ----------
class BoundingBoxPainter extends CustomPainter {
  final List<Result> results;
  final Size imageSize;
  final Color Function(String) getColorForLabel;
  final String Function(String) getDisplayLabel;

  BoundingBoxPainter(
    this.results,
    this.imageSize,
    this.getColorForLabel,
    this.getDisplayLabel,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final imageRatio = imageSize.width / imageSize.height;
    final widgetRatio = size.width / size.height;

    double drawWidth, drawHeight;
    double dx = 0, dy = 0;

    if (widgetRatio > imageRatio) {
      drawHeight = size.height;
      drawWidth = imageRatio * drawHeight;
      dx = (size.width - drawWidth) / 2;
    } else {
      drawWidth = size.width;
      drawHeight = drawWidth / imageRatio;
      dy = (size.height - drawHeight) / 2;
    }

    final scaleX = drawWidth / imageSize.width;
    final scaleY = drawHeight / imageSize.height;

    for (final result in results) {
      final paint = Paint()
        ..color = getColorForLabel(result.label).withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      final rect = Rect.fromLTWH(
        dx + result.rect.left * scaleX,
        dy + result.rect.top * scaleY,
        result.rect.width * scaleX,
        result.rect.height * scaleY,
      );

      canvas.drawRect(rect, paint);

      final text = '${getDisplayLabel(result.label)} ${(result.confidence * 100).toStringAsFixed(1)}%';

      final textSpan = TextSpan(
        text: text,
        style: TextStyle(
          color: getColorForLabel(result.label),
          fontSize: 12,
          backgroundColor: Colors.white,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left,
      )..layout(); // ไม่จำกัด maxWidth เพื่อให้ข้อความแนวนอน

      // ปรับตำแหน่งข้อความให้อยู่เหนือกรอบและไม่หลุดจอ
      final textX = rect.left;
      final textY = (rect.top - textPainter.height - 4).clamp(0.0, size.height - textPainter.height);

      textPainter.paint(canvas, Offset(textX, textY));
    }
  }

  @override
  bool shouldRepaint(covariant BoundingBoxPainter oldDelegate) {
    return oldDelegate.results != results || oldDelegate.imageSize != imageSize;
  }
}
