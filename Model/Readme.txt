Model/
├── args.yaml                        # พารามิเตอร์ที่ใช้ตอนฝึกโมเดล
├── results.csv                      # ผลลัพธ์ค่าประเมินของโมเดล (เช่น mAP, Precision)
├── results.png                      # กราฟผลการเทรน (loss, mAP ฯลฯ)
├── results1.png                     # กราฟผลการเทรนเพิ่มเติม
├── results2.png                     # กราฟผลการเทรนเพิ่มเติม
├── F1_curve.png                     # กราฟแสดง F1-score
├── P_curve.png                      # กราฟแสดง Precision
├── R_curve.png                      # กราฟแสดง Recall
├── PR_curve.png                     # กราฟ Precision-Recall
├── confusion_matrix.png            # Confusion Matrix
├── confusion_matrix_normalized.png # Confusion Matrix แบบ normalized
├── labels.jpg                       # การกระจายของ label ในชุดข้อมูล
├── labels_correlogram.jpg           # ความสัมพันธ์ระหว่าง label
├── train_batch0.jpg ~ train_batchXXXX.jpg     # ตัวอย่างภาพจากชุดเทรน
├── val_batchX_labels.jpg            # ภาพจาก validation set พร้อม label จริง
├── val_batchX_pred.jpg              # ภาพจาก validation set พร้อมผลทำนาย

Model/weights/
├── best.pt   # โมเดลที่มีประสิทธิภาพดีที่สุดระหว่างการฝึก 
└── last.pt   # โมเดลจาก epoch สุดท้ายของการฝึก