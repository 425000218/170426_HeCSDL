# Kế hoạch Thực thi Dự án Cơ sở dữ liệu: SEB_sub (School Equipment Borrowing)

Dựa trên yêu cầu của bạn (dự án nhóm 2 người), phân hệ **SEB_sub** trên hệ quản trị **MS SQL Server** sẽ được tập trung thiết kế xoay quanh 2 luồng chính: **Users (Người dùng)** và **Flow (Giao dịch mượn/trả)**.

Dưới đây là kế hoạch triển khai chi tiết:

## User Review Required

> [!IMPORTANT]
> Bạn cần xem xét và phê duyệt cấu trúc các bảng (Tables) cũng như các tính năng dự kiến (Procedures, Triggers) để đảm bảo phù hợp với yêu cầu của giảng viên và giới hạn phạm vi đồ án của nhóm 2 người.

## Open Questions

> [!WARNING]
> 1. Thiết bị (Equipment) sẽ được quản lý theo từng cá thể riêng biệt (mỗi cái máy chiếu có 1 mã số quét riêng) hay quản lý theo số lượng tổng (ví dụ: Micro - Số lượng kho: 10)? *Gợi ý: Quản lý từng cá thể sẽ chuyên nghiệp và dễ truy vết lỗi hỏng hóc hơn.*
> 2. Có cần phân quyền phức tạp (Admin duyệt phiếu mượn) hay hệ thống tự động cho mượn ngay nếu thiết bị ở trạng thái "Sẵn sàng"?
> 3. Bạn có muốn tôi tiến hành viết luôn các file script SQL tạo bảng (`CREATE TABLE`) và đổ dữ liệu mẫu (`INSERT`) sau khi chốt cấu trúc này không?

## Proposed Changes

Dự án sẽ được xây dựng qua 3 giai đoạn: Thiết kế CSDL (Tables), Xử lý nghiệp vụ (Stored Procedures), và Đảm bảo toàn vẹn dữ liệu (Triggers). 

### Giai đoạn 1: Thiết kế Lược đồ CSDL (Schema Design)

Cấu trúc gồm 4 bảng chính tạo thành luồng (Flow) hoàn chỉnh và bao quát phần Người dùng:

1. **Bảng `Users` (Người dùng)**:
   - `UserID` (INT, PK): Mã người dùng (Mã sinh viên / Mã giảng viên)
   - `FullName` (NVARCHAR): Họ và tên
   - `Role` (VARCHAR): Vai trò (Student, Teacher, Admin)
   - `Department` (NVARCHAR): Khoa/Lớp
   - `ContactInfo` (VARCHAR): Số điện thoại/Email

2. **Bảng `Equipment` (Thiết bị - Yếu tố cần mượn)**:
   - `EquipmentID` (VARCHAR, PK): Mã thiết bị (VD: MC-001, LOA-002)
   - `EquipName` (NVARCHAR): Tên thiết bị
   - `Category` (NVARCHAR): Loại thiết bị (Máy chiếu, Cáp, Loa...)
   - `Status` (NVARCHAR): Trạng thái (Sẵn sàng, Đang cho mượn, Đang bảo trì, Hỏng)

3. **Bảng `BorrowTransaction` (Giao dịch mượn/trả - Cốt lõi Flow)**:
   - `TransactionID` (INT, PK, IDENTITY): Mã phiếu mượn
   - `UserID` (INT, FK): Người mượn
   - `BorrowDate` (DATETIME): Thời gian mượn
   - `ExpectedReturnDate` (DATETIME): Thời gian dự kiến trả
   - `ActualReturnDate` (DATETIME, NULL): Thời gian trả thực tế (mặc định để trống)
   - `Status` (NVARCHAR): Trạng thái phiếu (Đang mượn, Đã trả, Quá hạn)

4. **Bảng `BorrowDetail` (Chi tiết mượn thiết bị)**:
   - `TransactionID` (INT, FK)
   - `EquipmentID` (VARCHAR, FK)
   - `ConditionBefore` (NVARCHAR): Tình trạng thiết bị lúc nhận
   - `ConditionAfter` (NVARCHAR, NULL): Tình trạng thiết bị lúc trả
   - *(Khóa chính hợp nhất/Composite PK là TransactionID + EquipmentID)*

### Giai đoạn 2: Lập trình Logic Nghiệp vụ (Stored Procedures)

Để tương tác với CSDL, chúng ta sẽ tạo các thủ tục lưu trữ:
- `sp_CreateBorrowTransaction`: Tạo phiếu mượn mới (sử dụng **TRANSACTION** để đảm bảo chèn vào bảng Transaction và BorrowDetail thành công cùng lúc).
- `sp_ReturnEquipment`: Xử lý luồng trả thiết bị, cập nhật ngày trả thực tế và đánh giá tình trạng thiết bị.
- `sp_ReportOverdueBorrowers`: Thống kê danh sách người dùng đang mượn quá hạn để gửi cảnh báo.

### Giai đoạn 3: Bẫy Lỗi và Ràng buộc (Triggers)

- `trg_CheckEquipmentAvailability`: (INSTEAD OF / AFTER INSERT) Ngăn chặn việc tạo phiếu mượn thiết bị đang ở trạng thái không "Sẵn sàng".
- `trg_UpdateEquipmentStatus`: (AFTER INSERT/UPDATE) Tự động chuyển đổi `Status` của bảng Equipment (từ "Sẵn sàng" sang "Đang cho mượn" và ngược lại) dựa trên các sự kiện thêm/cập nhật phiếu mượn.
- `trg_PreventDeleteActiveUser`: Ngăn không cho xóa User khỏi hệ thống nếu họ vẫn còn phiếu mượn chưa hoàn tất (đang nợ đồ).

## Verification Plan

### Automated Tests
1. Chạy script tạo CSDL và chèn dữ liệu mẫu (Mock data) cho 4 bảng.
2. Viết các đoạn lệnh `EXEC` test thử kịch bản: Sinh viên mượn thành công -> Sinh viên trả đồ -> Sinh viên mượn quá hạn.
3. Cố tình vi phạm logic (ví dụ: mượn một cái máy chiếu đang bị người khác giữ) để xem Trigger hoặc Procedure có chặn lại báo lỗi chuẩn xác không.

### Manual Verification
Review lại toàn bộ code SQL với bạn, viết sẵn các comment giải thích cặn kẽ từng khối lệnh để 2 thành viên nhóm có thể phân công nhau trình bày. Hệ thống kiến thức này sẽ bám sát những khái niệm bảo vệ đồ án như trong file `cau_hoi_bao_ve_HQTCSDL.md`.
