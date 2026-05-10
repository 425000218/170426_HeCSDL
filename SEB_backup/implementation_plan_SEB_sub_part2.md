# Kế hoạch Thực thi Dự án CSDL: Quản lý Mượn/Trả Thiết bị Trường học (8 Bảng)

Dựa trên thông tin bạn cung cấp, đây là một dự án đồ án quy mô khá tốt cho nhóm 2 người (Đặng Bắc Nam & Lò Văn Duẩn) trình bày trong 30 phút. Cấu trúc 8 bảng do Gemini phiên trước gợi ý là một bộ khung tuyệt vời để thể hiện năng lực lập trình CSDL.

## User Review Required

> [!IMPORTANT]
> **Nhận xét về cấu trúc cũ của bạn:**
> Cấu trúc 8 bảng bạn đưa ra rất hợp lý. Tuy nhiên, dân IT chuyên ngành thường KHÔNG đặt tiền tố `Bang...` trước tên bảng (Ví dụ: đặt là `NguoiDung` thay vì `BangNguoiDung`). Tôi đã chuẩn hóa lại cách đặt tên bảng theo chuẩn thực tế của doanh nghiệp để Giảng viên đánh giá cao tính chuyên nghiệp của nhóm.

## Open Questions

> [!WARNING]
> Thời lượng báo cáo 30 phút là khá dài cho 1 nhóm 2 người. Giảng viên (Cô Phương) chắc chắn sẽ hỏi xoáy vào logic của Triggers và Transactions (giống y hệt nội dung file `cau_hoi_bao_ve_HQTCSDL.md` mà nhóm đang ôn tập).
> **Bạn có muốn tôi viết File Script SQL bằng cách lồng ghép các "bẫy logic" này vào luôn không?** Ví dụ: Viết Transaction lúc mượn đồ, và Trigger lưu lịch sử tự động vào bảng NhatKyHeThong.

## Proposed Changes

Tôi đề xuất chốt cấu trúc **8 Bảng Tường Minh** như sau (bỏ tiền tố "Bang"):

### Giai đoạn 1: Thiết kế Lược đồ (Schema Design)

1. **`PhanQuyen`**: Quản lý cấp độ truy cập.
   - `MaQuyen` (INT, PK), `TenQuyen` (NVARCHAR) - VD: Admin, SinhVien, GiangVien.

2. **`NguoiDung`**: Thông tin user.
   - `MaND` (VARCHAR, PK) - Lưu MSSV (như 425000218, 525000631).
   - `HoTen`, `MaQuyen` (FK), `SDT`, `Lop`.

3. **`LoaiThietBi`**: Phân loại danh mục.
   - `MaLoai` (INT, PK), `TenLoai` (NVARCHAR) - VD: Thiết bị trình chiếu, Thiết bị âm thanh.

4. **`ThietBi`**: Quản lý thiết bị.
   - `MaTB` (VARCHAR, PK), `TenTB`, `MaLoai` (FK), `SoLuongTon` (INT), `TrangThai`.

5. **`PhieuMuon`**: Giao dịch mượn.
   - `MaPhieu` (INT, PK, IDENTITY), `MaND` (FK), `NgayMuon`, `NgayHenTra`, `TrangThaiPhieu` (Đang mượn, Đã trả xong).

6. **`ChiTietMuon`**: Món đồ cụ thể trong phiếu.
   - `MaPhieu` (FK), `MaTB` (FK), `SoLuongMuon`, `TinhTrangTruocMuon`.
   - *Composite PK: MaPhieu + MaTB*.

7. **`NhatKyTra`**: Ghi nhận lúc trả.
   - `MaTra` (INT, PK), `MaPhieu` (FK), `NgayTraThucTe`, `TienPhat` (nếu làm hỏng/trễ), `GhiChuHuy`.

8. **`NhatKyHeThong` (Bảng ăn điểm Trigger)**: Lưu log.
   - `MaLog` (INT, PK), `ThoiGian`, `HanhDong` (Insert/Update/Delete), `TenBang`, `ChiTiet`.

### Giai đoạn 2: Lập trình Logic Nghiệp vụ (Procedures & Transactions)

Sẽ viết các Proc quan trọng, có áp dụng `BEGIN TRAN ... COMMIT ... ROLLBACK` theo chuẩn file ôn tập:
- `sp_TaoPhieuMuon`: Nhận vào MSSV và danh sách đồ. Sẽ trừ đi `SoLuongTon` trong bảng `ThietBi`. (Có kiểm tra lỗi số lượng).
- `sp_TraThietBi`: Trả đồ, cộng lại `SoLuongTon`, tính tiền phạt (nếu trễ).

### Giai đoạn 3: Bẫy Lỗi Tự Động (Triggers)

- `trg_LogNguoiDung`: (AFTER UPDATE, DELETE) Tự động ghi vào bảng `NhatKyHeThong` khi có ai đó sửa thông tin người dùng (Giám sát bảo mật).
- `trg_CheckSoLuongMuon`: (INSTEAD OF INSERT) Chặn không cho mượn nếu `SoLuongMuon` > `SoLuongTon` trong kho.

## Verification Plan
1. Viết toàn bộ Script SQL File 2.
2. Nhóm lấy mã chạy tạo DB, chạy thử kịch bản Nam và Duẩn đi mượn đồ.
3. Test thử các trường hợp bẫy lỗi để tự tin đứng thuyết trình trong 30 phút.
