ในโฟลเดอร์ lib
main.dart                        # จุดเริ่มต้นของแอป Flutter
screens/                         # โฟลเดอร์สำหรับหน้าจอต่าง ๆ ของแอป
├── acne_tpye.dart               # หน้าประเภทสิว
├── details_screen.dart          # หน้ารายละเอียดประวัติการวิเคราะห์
├── graph_screen.dart            # หน้ากราฟแสดงผลวิเคราะห์ย้อนหลัง
├── history_screen.dart          # หน้าประวัติการวิเคราะห์
├── home_screen.dart             # หน้าโฮม
├── login_screen.dart            # หน้าล็อกอิน
├── result_screen.dart           # หน้าผลการวิเคราะห์
├── scan_screen.dart             # หน้าตรวจสอบรูปภาพ
├── settings_screen.dart         # หน้าตั้งค่า
├── signup_screen.dart           # หน้าสมัครสมาชิก
└── welcome_screen.dart          # หน้าต้อนรับ

services/                        # โฟลเดอร์สำหรับบริการเบื้องหลัง (backend/API)
├── result_model.dart            # โมเดลข้อมูลของผลการวิเคราะห์
└── roboflow_service.dart        # ส่วนเชื่อมต่อกับ Model

