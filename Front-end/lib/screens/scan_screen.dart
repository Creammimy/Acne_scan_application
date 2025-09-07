import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_acne_scan/screens/result_screen.dart';
import 'package:project_acne_scan/services/result_model.dart';
import 'package:project_acne_scan/services/roboflow_service.dart';

class ScanScreen extends StatefulWidget {
  final List<String> imagePaths;

  const ScanScreen({Key? key, required this.imagePaths}) : super(key: key);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  List<XFile> _images = [];
  bool _isAnalyzing = false;

  final Map<String, String> acneTypeToThai = {
    'Pustula': 'สิวตุ่มหนอง',
    'acne fulminans': 'acne fulminans',
    'blackhead': 'สิวหัวดำ',
    'fungal acne': 'สิวเชื้อรา',
    'nodules': 'สิวไต',
    'papula': 'สิวตุ่มแดง',
    'whitehead': 'สิวหัวขาว',
  };

  final Map<String, String> careInstructionsByType = {
    'Pustula': 'สิวตุ่มหนองควรได้รับการรักษาด้วยยาฆ่าเชื้อ เช่น Benzoyl Peroxide หรือยาปฏิชีวนะเฉพาะที่ เช่น Clindamycin เพื่อฆ่าเชื้อแบคทีเรียและลดการอักเสบ ในบางกรณีที่สิวรุนแรง อาจจำเป็นต้องใช้ยากินหรือเรตินอยด์ เช่น Isotretinoin ภายใต้การดูแลของแพทย์ ควรรักษาความสะอาด หลีกเลี่ยงการบีบสิว และเลือกใช้ผลิตภัณฑ์ดูแลผิวที่ไม่อุดตันรูขุมขน',
    'acne fulminans': 'สิวชนิดนี้ต้องได้รับการรักษาโดยแพทย์ เนื่องจากมีการอักเสบรุนแรงและมักมีอาการระบบร่วม เช่น มีไข้หรือปวดข้อ การรักษามักเริ่มด้วยยาสเตียรอยด์เพื่อลดการอักเสบ แล้วตามด้วยไอโซเตรติโนอินในขนาดต่ำเพื่อควบคุมสิวในระยะยาว ห้ามรักษาด้วยยาสิวทั่วไปโดยไม่ได้รับคำแนะนำจากแพทย์',
    'blackhead': 'สิวหัวดำควรใช้ผลิตภัณฑ์ผลัดเซลล์ผิว เช่น กรดซาลิไซลิกหรือเรตินอยด์ เพื่อเปิดรูขุมขนและลดการอุดตัน หมั่นล้างหน้าให้สะอาด หลีกเลี่ยงการล้างหน้ารุนแรงหรือใช้ผลิตภัณฑ์ที่อุดตันผิว และไม่ควรบีบสิวด้วยตนเองเพราะเสี่ยงต่อการติดเชื้อและเกิดรอยดำ',
    'fungal acne': 'สิวชนิดนี้เกิดจากการเจริญของเชื้อราในรูขุมขน มักขึ้นเป็นตุ่มเล็ก ๆ หลายจุดพร้อมกัน การรักษาควรใช้ยาต้านเชื้อราทั้งแบบทาและรับประทาน เช่น Ketoconazole หรือ Fluconazole ควรรักษาความสะอาดผิวหนัง หลีกเลี่ยงความอับชื้น และไม่ใช้ยาปฏิชีวนะโดยไม่จำเป็น',
    'nodules': 'สิวไตเป็นสิวอักเสบรุนแรงที่ลึกและเจ็บ การรักษาควรใช้ยาเรตินอยด์ชนิดรับประทาน เช่น Isotretinoin ภายใต้การดูแลของแพทย์เพื่อป้องกันแผลเป็น หลีกเลี่ยงการบีบหรือกด เพราะอาจทำให้สิวลุกลามหรือทิ้งรอยแผลลึก',
    'papula': 'สิวตุ่มแดงควรรักษาด้วยยาทาเพื่อลดการอักเสบ เช่น Benzoyl Peroxide หรือยาปฏิชีวนะเฉพาะที่ เช่น Clindamycin หากสิวไม่ดีขึ้นอาจพิจารณาใช้ยารับประทานร่วมด้วย ควรหลีกเลี่ยงการสัมผัสหรือบีบสิว และดูแลผิวอย่างอ่อนโยน',
    'whitehead': 'สิวหัวขาวสามารถรักษาได้ด้วยการใช้ผลิตภัณฑ์ที่ช่วยผลัดเซลล์ผิว เช่น กรดซาลิไซลิก หรือเรตินอยด์เพื่อลดการอุดตัน หมั่นล้างหน้าเป็นประจำ และหลีกเลี่ยงเครื่องสำอางที่อุดตันรูขุมขน ควรหลีกเลี่ยงการบีบสิวเพื่อไม่ให้เกิดการอักเสบ',
  };

  Map<String, int> pimpleTypes = {
    'Pustula': 0,
    'acne fulminans': 0,
    'blackhead': 0,
    'fungal acne': 0,
    'nodules': 0,
    'papula': 0,
    'whitehead': 0,
  };

  List<ImageAnalysisResult> detectionResultsPerImage = [];

  @override
  void initState() {
    super.initState();
    _images = widget.imagePaths.map((path) => XFile(path)).toList();
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _addImage(ImageSource source) async {
    if (_images.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("สามารถเพิ่มได้สูงสุด 3 ภาพเท่านั้น"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        _images.add(pickedImage);
      });
    }
  }

  Future<void> _startAnalysis() async {
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("กรุณาเลือกรูปภาพอย่างน้อย 1 รูป"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      detectionResultsPerImage.clear();
      pimpleTypes.updateAll((key, value) => 0);
    });

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("กำลังวิเคราะห์ภาพทั้งหมด..."),
          duration: Duration(seconds: 2),
        ),
      );

      final results = await RoboflowService.analyzeImages(
        _images.map((x) => File(x.path)).toList(),
      );

      detectionResultsPerImage = results;

      for (var analysis in results) {
        analysis.acneCountByType.forEach((type, count) {
          if (pimpleTypes.containsKey(type)) {
            pimpleTypes[type] = pimpleTypes[type]! + count;
          } else {
            pimpleTypes[type] = count;
          }
        });
      }

      print('[✅] วิเคราะห์เสร็จ ${results.length} ภาพ');
    } catch (e) {
      print('[❌] วิเคราะห์ล้มเหลว: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("วิเคราะห์ภาพล้มเหลว: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isAnalyzing = false);
    _showResultDialog();
  }

  void _showResultDialog() {
    final detectedCareInstructions = pimpleTypes.entries
        .where((entry) => entry.value > 0)
        .map((entry) {
          final type = entry.key;
          final thaiName = acneTypeToThai[type] ?? type;
          final instruction = careInstructionsByType[type] ?? "ไม่มีคำแนะนำ";
          return '• $thaiName:\n$instruction';
        })
        .join('\n\n');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("วิเคราะห์เสร็จสิ้น"),
        content: const Text("คลิกเพื่อดูผลลัพธ์"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultScreen(
                    imagePaths: _images.map((x) => x.path).toList(),
                    detectionResultsPerImage: detectionResultsPerImage,
                    pimpleTypes: pimpleTypes,
                    careInstructions: detectedCareInstructions,
                  ),
                ),
              );
            },
            child: const Text("ดูผลลัพธ์"),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            backgroundColor: const Color(0xFFCDF8F7),
            radius: 30,
            child: Icon(icon, color: Colors.black),
          ),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ตรวจสอบรูปภาพ"),
        backgroundColor: const Color(0xFF06D1D0),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (_images.isNotEmpty)
                  Column(
                    children: [
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _images.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.all(8),
                                  child: Image.file(
                                    File(_images[index].path),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
                                    child: const Icon(Icons.cancel,
                                        color: Colors.red),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      Text(
                        "เลือกแล้ว ${_images.length}/3 รูป",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAddButton(Icons.camera_alt, 'กล้อง',
                        () => _addImage(ImageSource.camera)),
                    const SizedBox(width: 30),
                    _buildAddButton(Icons.photo, 'คลัง',
                        () => _addImage(ImageSource.gallery)),
                  ],
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _isAnalyzing ? null : _startAnalysis,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF06D1D0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                  ),
                  child: const Text(
                    "วิเคราะห์สิว",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          if (_isAnalyzing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      "กำลังวิเคราะห์...",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
