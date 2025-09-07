import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class DetailScreen extends StatefulWidget {
  final Map<String, dynamic> resultData;

  const DetailScreen({Key? key, required this.resultData}) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  List<String> selectedTypes = [];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
    'Pustula':
        'สิวตุ่มหนองควรได้รับการรักษาด้วยยาฆ่าเชื้อ เช่น Benzoyl Peroxide หรือยาปฏิชีวนะเฉพาะที่ เช่น Clindamycin เพื่อฆ่าเชื้อแบคทีเรียและลดการอักเสบ ในบางกรณีที่สิวรุนแรง อาจจำเป็นต้องใช้ยากินหรือเรตินอยด์ เช่น Isotretinoin ภายใต้การดูแลของแพทย์ ควรรักษาความสะอาด หลีกเลี่ยงการบีบสิว และเลือกใช้ผลิตภัณฑ์ดูแลผิวที่ไม่อุดตันรูขุมขน',
    'acne fulminans':
        'สิวชนิดนี้ต้องได้รับการรักษาโดยแพทย์ เนื่องจากมีการอักเสบรุนแรงและมักมีอาการระบบร่วม เช่น มีไข้หรือปวดข้อ การรักษามักเริ่มด้วยยาสเตียรอยด์เพื่อลดการอักเสบ แล้วตามด้วยไอโซเตรติโนอินในขนาดต่ำเพื่อควบคุมสิวในระยะยาว ห้ามรักษาด้วยยาสิวทั่วไปโดยไม่ได้รับคำแนะนำจากแพทย์',
    'blackhead':
        'สิวหัวดำควรใช้ผลิตภัณฑ์ผลัดเซลล์ผิว เช่น กรดซาลิไซลิกหรือเรตินอยด์ เพื่อเปิดรูขุมขนและลดการอุดตัน หมั่นล้างหน้าให้สะอาด หลีกเลี่ยงการล้างหน้ารุนแรงหรือใช้ผลิตภัณฑ์ที่อุดตันผิว และไม่ควรบีบสิวด้วยตนเองเพราะเสี่ยงต่อการติดเชื้อและเกิดรอยดำ',
    'fungal acne':
        'สิวชนิดนี้เกิดจากการเจริญของเชื้อราในรูขุมขน มักขึ้นเป็นตุ่มเล็ก ๆ หลายจุดพร้อมกัน การรักษาควรใช้ยาต้านเชื้อราทั้งแบบทาและรับประทาน เช่น Ketoconazole หรือ Fluconazole ควรรักษาความสะอาดผิวหนัง หลีกเลี่ยงความอับชื้น และไม่ใช้ยาปฏิชีวนะโดยไม่จำเป็น',
    'nodules':
        'สิวไตเป็นสิวอักเสบรุนแรงที่ลึกและเจ็บ การรักษาควรใช้ยาเรตินอยด์ชนิดรับประทาน เช่น Isotretinoin ภายใต้การดูแลของแพทย์เพื่อป้องกันแผลเป็น หลีกเลี่ยงการบีบหรือกด เพราะอาจทำให้สิวลุกลามหรือทิ้งรอยแผลลึก',
    'papula':
        'สิวตุ่มแดงควรรักษาด้วยยาทาเพื่อลดการอักเสบ เช่น Benzoyl Peroxide หรือยาปฏิชีวนะเฉพาะที่ เช่น Clindamycin หากสิวไม่ดีขึ้นอาจพิจารณาใช้ยารับประทานร่วมด้วย ควรหลีกเลี่ยงการสัมผัสหรือบีบสิว และดูแลผิวอย่างอ่อนโยน',
    'whitehead':
        'สิวหัวขาวสามารถรักษาได้ด้วยการใช้ผลิตภัณฑ์ที่ช่วยผลัดเซลล์ผิว เช่น กรดซาลิไซลิก หรือเรตินอยด์เพื่อลดการอุดตัน หมั่นล้างหน้าเป็นประจำ และหลีกเลี่ยงเครื่องสำอางที่อุดตันรูขุมขน ควรหลีกเลี่ยงการบีบสิวเพื่อไม่ให้เกิดการอักเสบ',
  };
  Future<void> _deleteResult() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text('คุณต้องการลบประวัตินี้ใช่หรือไม่?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('ยกเลิก')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('ลบ')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final supabase = Supabase.instance.client;
      final resultId = widget.resultData['result_id'];

      // ลบจากตาราง
      await supabase.from('results_info').delete().eq('result_id', resultId);

      // ลบภาพจาก Storage
      final imageUrls = List<String>.from(widget.resultData['image_urls']);
      for (var url in imageUrls) {
        final uri = Uri.parse(url);
        final segments = uri.pathSegments;
        final publicIndex = segments.indexOf('public');
        if (publicIndex >= 0 && publicIndex + 1 < segments.length) {
          final path = segments.sublist(publicIndex + 1).join('/');
          await supabase.storage.from('acne-images').remove([path]);
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('ลบสำเร็จ')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrls = (widget.resultData['image_urls'] is List)
        ? List<String>.from(widget.resultData['image_urls'])
        : <String>[];

    final predictions = (widget.resultData['predictions'] is List)
        ? List<dynamic>.from(widget.resultData['predictions'])
        : <dynamic>[];

    final summary = (widget.resultData['summary'] is Map)
        ? Map<String, dynamic>.from(widget.resultData['summary'])
        : <String, dynamic>{};

    final total = summary['total'] ?? 0;

    final types = (summary['types'] is Map)
        ? Map<String, int>.from(summary['types'])
        : <String, int>{};

    final createdAt = (widget.resultData['created_at'] != null)
        ? DateTime.parse(widget.resultData['created_at'])
        : DateTime.now(); // กรณีไม่มีค่าวันที่ ใช้เวลาปัจจุบันแทน

    final foundPimples = types.entries
        .where((e) =>
            e.value > 0 &&
            (selectedTypes.isEmpty || selectedTypes.contains(e.key)))
        .toList();

    final availableTypes =
        types.entries.where((e) => e.value > 0).map((e) => e.key).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดผลลัพธ์'),
        backgroundColor: Color(0xFFCDF8F7),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'วันที่ : ${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 22),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: PageView.builder(
                itemCount: imageUrls.length,
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  final detections = (predictions[index]['detections'] as List)
                      .whereType<Map<String, dynamic>>()
                      .toList();

                  final filtered = selectedTypes.isEmpty
                      ? detections
                      : detections
                          .where((d) => selectedTypes.contains(d['label']))
                          .toList();

                  return FutureBuilder<Size>(
                    future: _getImageSizeFromNetwork(imageUrls[index]),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(imageUrls[index],
                                fit: BoxFit.contain),
                          ),
                          Positioned.fill(
                            child: CustomPaint(
                              painter: BoundingBoxPainter(
                                filtered,
                                snapshot.data!,
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
              ),
            ),
            Center(child: Text('${_currentPage + 1}/${imageUrls.length}')),
            const SizedBox(height: 20),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ผลการวิเคราะห์สิวของคุณ',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                PopupMenuButton<String>(
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
                    return availableTypes.map((type) {
                      return CheckedPopupMenuItem<String>(
                        value: type,
                        checked: selectedTypes.contains(type),
                        child: Text(getDisplayLabel(type)),
                      );
                    }).toList();
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 143, 247, 238),
                      border: Border.all(color: Color.fromARGB(255, 143, 247, 238)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Text('สิวทั้งหมด'),
                        Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
                    'รวมทั้งหมด: $total จุด',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Text(
              'คำแนะนำการดูแลรักษา',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...foundPimples.map((entry) {
              final type = entry.key;
              final displayName = getDisplayLabel(type);
              final instruction =
                  careInstructionsByType[type] ?? 'ไม่มีข้อมูลคำแนะนำ';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                
                child: Card(
                  elevation: 2,
                  color: Color(0xFFE0F7FA),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: TextStyle(
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
            }),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.delete),
                label: const Text('ลบประวัตินี้'),
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: _deleteResult,
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<Size> _getImageSizeFromNetwork(String url) async {
    final completer = Completer<Size>();
    final image = NetworkImage(url);
    image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        final mySize =
            Size(info.image.width.toDouble(), info.image.height.toDouble());
        completer.complete(mySize);
      }),
    );
    return completer.future;
  }
}

class BoundingBoxPainter extends CustomPainter {
  final List<Map<String, dynamic>> results;
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

    for (var r in results) {
      final label = r['label'] as String;
      final confidence = (r['confidence'] as num).toDouble();
      final rect = r['rect'] as Map<String, dynamic>;

      final left = (rect['left'] as num?)?.toDouble() ?? 0.0;
      final top = (rect['top'] as num?)?.toDouble() ?? 0.0;
      final width = (rect['width'] as num?)?.toDouble() ?? 0.0;
      final height = (rect['height'] as num?)?.toDouble() ?? 0.0;

      final paint = Paint()
        ..color = getColorForLabel(label).withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      final scaledRect = Rect.fromLTWH(
        dx + left * scaleX,
        dy + top * scaleY,
        width * scaleX,
        height * scaleY,
      );

      // วาดกรอบ
      canvas.drawRect(scaledRect, paint);

      // เตรียมข้อความ
      final text = '${getDisplayLabel(label)} ${(confidence * 100).toStringAsFixed(1)}%';
      final textSpan = TextSpan(
        text: text,
        style: TextStyle(
          color: getColorForLabel(label),
          fontSize: 12,
          backgroundColor: Colors.white,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left,
      )..layout(); // ไม่ใช้ maxWidth เพื่อไม่บีบข้อความ

      // ป้องกันไม่ให้ข้อความล้นขอบด้านบน
      final textOffset = Offset(
        scaledRect.left,
        (scaledRect.top - textPainter.height - 4).clamp(0.0, size.height - textPainter.height),
      );

      // วาดข้อความ
      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
