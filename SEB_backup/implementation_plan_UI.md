# Kế hoạch Bổ sung: Giao diện Ứng dụng & Báo cáo Word

Dựa trên hình ảnh yêu cầu của môn học mà bạn vừa cung cấp, đồ án của chúng ta đã hoàn thành xuất sắc mục 1, 2, và 3 (với 8 bảng SQL, dữ liệu mẫu, Proc, Trigger đầy đủ).

Tuy nhiên, để thỏa mãn **Mục 4: Giao diện ứng dụng** và **Nội dung nộp**, chúng ta cần bổ sung thêm các hạng mục sau:

## User Review Required

> [!IMPORTANT]
> **Chọn Ngôn ngữ lập trình cho Giao diện (Mục 4):**
> Yêu cầu chỉ cần 1 module có Thêm/Sửa/Xóa và Phân quyền. Bạn muốn làm giao diện bằng ngôn ngữ nào?
> - **Option A: WinForms (C# .NET)** - Rất phổ biến ở các trường Đại học khi làm việc với SQL Server. Dễ kéo thả giao diện.
> - **Option B: Web App (HTML/CSS/JS + Node.js)** - Giao diện đẹp, hiện đại.
> - **Option C: Lập trình Console (C/C++ hoặc C#)** - Chỉ hiện chữ đen trắng trên Terminal (nếu cô giáo cho phép làm đơn giản).
> 
> *Hãy phản hồi cho tôi biết bạn chọn Option nào để tôi viết mã Source Code nhé!*

## Open Questions

> [!WARNING]
> Về phần **"File Nhật ký AI"**, bạn nhớ chụp màn hình lại các đoạn chat của chúng ta hoặc Export nội dung chat để làm minh chứng nhé. Cô Phương có vẻ rất khuyến khích sinh viên biết dùng AI để phân tích và viết code.

## Proposed Changes

Chúng ta sẽ thực hiện 2 công việc chính tiếp theo:

### 1. Viết File Báo Cáo Word (Nội dung nộp 1)
Tôi sẽ soạn sẵn cho bạn một cấu trúc file Word (hoặc Markdown) chứa đầy đủ 4 phần:
1. **Bài toán:** Trình bày lý do chọn đề tài Quản lý mượn trả thiết bị.
2. **Chức năng:** Liệt kê các chức năng chính.
3. **Phân tích CSDL:** Giải thích Lược đồ 8 bảng, lý do thiết kế, giải thích các Transaction và Trigger đã làm (Rất quan trọng để cô thấy nhóm có đầu tư).
4. **Giao diện ứng dụng:** Hướng dẫn sử dụng module chức năng.

### 2. Xây dựng Source Code Giao diện (Nội dung nộp 3 & 4)
Chúng ta sẽ tập trung làm 1 màn hình duy nhất: **Quản lý Phiếu Mượn**.
- **Phân quyền:** Nếu đăng nhập bằng mã Sinh Viên (425000218), chỉ thấy phiếu mượn của mình. Nếu đăng nhập bằng Admin (ADMIN01), thấy toàn bộ phiếu của mọi người.
- **Thêm/Sửa/Xóa:** Sẽ gọi đến các đoạn code SQL và Stored Procedure `sp_TaoPhieuMuon` mà chúng ta đã làm ở bước trước.

## Verification Plan

1. Bạn xác nhận chọn ngôn ngữ lập trình.
2. Tôi sẽ viết mã nguồn (Source code) cho Giao diện.
3. Tôi sẽ soạn sẵn nội dung File Word chuẩn để bạn copy vào báo cáo nộp lấy điểm.
4. Bạn quay video màn hình chạy thử giao diện để thêm vào báo cáo.
