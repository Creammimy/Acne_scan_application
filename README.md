1.โฟลเดอร์ Back-end คือโฟลเดอร์โครงสร้างของแอปพลิเคชันวิเคราะห์สิวที่เขียนด้วย flutter 
2.โฟลเดอร์ Back-end คือ back-end ที่เป็นตัว run model ทำการวิเคราะห์ภาพสิวจากผู้ใช้ที่ส่งมา ทำการวิเคราะห์แล้วส่งผลลัพธ์กลับไปที่แอปพลิเคัชั่น
3.โฟลเดอร์ model คือ model ที่ใช้ในการวิเคราะห์สิว พัฒนาด้วย yolov12 ภายในโฟลเดอร์ ตัวโมเดลจะอยู่ที่ Model>weights>best.pt ส่วนอื่นจะคือรายงานผลลัพธ์ต่างๆของโมเดล

# Acne Analysis System Using Deep Learning on Mobile Applications

ระบบวิเคราะห์สิวบนแอปพลิเคชันมือถือที่ใช้เทคนิค **Deep Learning** เพื่อจำแนกและนับจำนวนสิว พร้อมให้คำแนะนำการรักษาเบื้องต้น และติดตามพัฒนาการของผิวหน้า

---

## 📌 Features

- จำแนกสิวได้ 7 ประเภท:
  - สิวหัวขาว (Whitehead)
  - สิวหัวดำ (Blackhead)
  - สิวตุ่มแดง (Papule)
  - สิวตุ่มหนอง (Pustule)
  - สิวไต (Nodule)
  - สิวเชื้อรา (Fungal Acne)
  - สิวอักเสบเฉียบพลัน (Acne Fulminans)
- ตรวจจับและนับจำนวนสิวในภาพ (ยกเว้นสิวเชื้อราและ Acne Fulminans ที่นับเป็นบริเวณ)
- แสดงตำแหน่งสิวด้วย **Bounding Box**
- ให้คำแนะนำการรักษาเบื้องต้นของสิวแต่ละประเภท
- ระบบล็อกอิน/สมัครสมาชิก
- บันทึกประวัติการวิเคราะห์สิวและแสดงกราฟพัฒนาการของผิว

---

## 🧠 Technologies Used

- **Model**: YOLOv12 (Object Detection)
- **Dataset**: Skin-90 (Kaggle) + ข้อมูลเพิ่มเติมรวม 1,167 ภาพ
- **Backend**: FastAPI (Python)
- **Frontend**: Flutter
- **Database**: Supabase
- **Other Tools**: PyTorch, Roboflow, VS Code

---
## 📊 Model Performance
- Precision: 76.8%
- Recall: 75.3%
- F1-score: 76.0%

## 📱 Screenshots


