import 'package:flutter/material.dart';

class AcneTypesScreen extends StatelessWidget {
  final List<Map<String, String>> acneTypes = [
    {
      'name': 'สิวหัวดำ',
      'image': 'assets/images/blackhead.jpg',
      'description': 'เกิดจากการอุดตันของรูขุมขนและสัมผัสอากาศจนเปลี่ยนเป็นสีดำ',
    },
    {
      'name': 'สิวหัวขาว',
      'image': 'assets/images/whitehead.png',
      'description': 'สิวอุดตันที่ยังไม่เปิดสัมผัสอากาศ ผิวเรียบเล็ก ๆ สีขาว',
    },
    {
      'name': 'สิวตุ่มแดง',
      'image': 'assets/images/papu.jpg',
      'description': 'ตุ่มแดงเล็ก ๆ ไม่มีหัว เกิดจากการอักเสบของสิวอุดตัน',
    },
    {
      'name': 'สิวตุ่มหนอง',
      'image': 'assets/images/pustu.jpg',
      'description': 'ตุ่มสิวที่มีหนองสีขาวอยู่ตรงกลาง มีการอักเสบ',
    },
    {
      'name': 'สิวไต',
      'image': 'assets/images/nodule.jpg',
      'description': 'ตุ่มนูนใหญ่ลึกใต้ผิวหนัง มักเจ็บและทิ้งรอยแผลเป็น',
    },
    {
      'name': 'Acne Fulminans',
      'image': 'assets/images/acne_Fu.jpg',
      'description': 'สิวขนาดใหญ่ มีหนองภายใน ลึกและเจ็บ มักต้องพบแพทย์',
    },
    {
      'name': 'สิวเชื้อรา',
      'image': 'assets/images/fungal.jpg',
      'description': 'สิวจากยีสต์ รูปร่างคล้ายสิวผด มักคันและเกิดที่ลำตัว',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ชนิดของสิว'),
        backgroundColor: const Color(0xFF06D1D0),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: ListView(
          scrollDirection: Axis.vertical, // เปลี่ยนจากแนวนอนเป็นแนวตั้ง
          children: acneTypes.map((acne) {
            return Container(
              width: 100, // ลดความกว้างลง
              margin: const EdgeInsets.symmetric(vertical: 15), // เพิ่มระยะห่างแนวตั้ง
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFCDF8F7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    acne['image']!,
                    width: 240,
                    height: 240,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    acne['name']!,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    acne['description']!,
                    style: const TextStyle(fontSize: 20, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
