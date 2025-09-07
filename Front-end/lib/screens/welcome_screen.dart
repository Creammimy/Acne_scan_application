import 'package:flutter/material.dart';

import 'package:project_acne_scan/screens/login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color(0xFFCDF8F7),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ใช้ Row เพื่อจัดวางข้อความและรูปภาพ
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Acne",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 110,
                    color: Color(0xFF06D1D0),
                    fontWeight: FontWeight.bold,
                    height: 0.3, 
                    fontFamily: 'FCMinimal', 
                  ),
                ),
                // รูปภาพจะอยู่หลังตัว "e"
                Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: Image.asset(
                    'assets/images/aa.PNG',
                    width: 100,
                    height: 100,
                  ),
                ),
              ],
            ),

            // คำว่า "Scan"
            Text(
              "Analysis",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 110,
                color: Color(0xFF06D1D0),
                fontWeight: FontWeight.bold,
                height: 0.3, 
                fontFamily: 'FCMinimal', 
              ),
            ),
            SizedBox(height: 150),

            // ปุ่มเริ่มต้นใช้งาน
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                backgroundColor: Color(0xFF06D1D0),
                foregroundColor: Colors.white,
              ),
              child: Text(" เริ่มต้นใช้งาน  ",
                  style: TextStyle(
                      fontSize: 25,
                      fontFamily: 'FCMinimal',
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
