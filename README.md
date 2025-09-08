
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

## 📱 ตัวอย่างภาพหน้าจอแอปป
<img width="319" height="568" alt="m1" src="https://github.com/user-attachments/assets/44b2626c-a231-45d3-9a5e-b5af18ed0144" />
<img width="319" height="568" alt="m2" src="https://github.com/user-attachments/assets/bda1c318-9ec8-483c-b7ad-21560a963a63" />
<img width="319" height="568" alt="m3" src="https://github.com/user-attachments/assets/e66044fd-2fa1-4412-bacd-9ee5501bd5a8" />
<img width="319" height="568" alt="m4" src="https://github.com/user-attachments/assets/93789cc6-3a6d-49c0-a65e-3afca863e406" />
<img width="319" height="568" alt="m5" src="https://github.com/user-attachments/assets/2efb853b-a770-4153-b356-acd6d981b0a8" />
<img width="319" height="568" alt="m6" src="https://github.com/user-attachments/assets/0b079ce6-ddf7-4221-977b-ffe72b50aa8b" />
<img width="319" height="568" alt="m7" src="https://github.com/user-attachments/assets/683482c0-573f-4fa4-ad33-792814fa2fb0" />
<img width="319" height="568" alt="m8" src="https://github.com/user-attachments/assets/9ecfc884-d87b-4684-b49e-acf46ba631f9" />

- โฟลเดอร์ Back-end คือโฟลเดอร์โครงสร้างของแอปพลิเคชันวิเคราะห์สิวที่เขียนด้วย flutter
- โฟลเดอร์ Back-end คือ back-end ที่เป็นตัว run model ทำการวิเคราะห์ภาพสิวจากผู้ใช้ที่ส่งมา ทำการวิเคราะห์แล้วส่งผลลัพธ์กลับไปที่แอปพลิเคัชั่น
- โฟลเดอร์ model คือ model ที่ใช้ในการวิเคราะห์สิว พัฒนาด้วย yolov12 ภายในโฟลเดอร์ ตัวโมเดลจะอยู่ที่ Model>weights>best.pt ส่วนอื่นจะคือรายงานผลลัพธ์ต่างๆของโมเดล


