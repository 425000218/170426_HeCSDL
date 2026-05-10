# BÁO CÁO ĐỒ ÁN MÔN HỌC
**MÔN: HỆ QUẢN TRỊ CƠ SỞ DỮ LIỆU**

**Đề tài:** Xây dựng phân hệ SEB_sub - Quản lý mượn trả thiết bị trường học
**Sinh viên thực hiện:** 
1. Đặng Bắc Nam (MSSV: 425000218) 
2. Lò Văn Duẩn (MSSV: 525000631)
**Giảng viên hướng dẫn:** Cô Phương

---

## 1. BÀI TOÁN THỰC TẾ
Trong môi trường giáo dục tại Đại học Lạc Hồng, việc quản lý thiết bị dạy học (máy chiếu, micro, cáp kết nối...) đóng vai trò quan trọng. Hiện nay, việc ghi chép thủ công mượn/trả bộc lộ nhiều yếu điểm: dễ thất thoát thông tin, khó tra cứu tình trạng nợ đồ của sinh viên/giảng viên, và khó thống kê được thiết bị nào đang rảnh để điều phối. 
Dự án **SEB_sub (School Equipment Borrowing)** được thiết kế nhằm số hóa quy trình trên hệ quản trị MS SQL Server, giúp tự động hóa việc theo dõi phiếu mượn, kiểm soát tồn kho thiết bị và phân quyền người dùng minh bạch.

## 2. CÁC CHỨC NĂNG CHÍNH
Hệ thống tập trung vào các chức năng cốt lõi sau:
- **Quản lý danh mục:** Quản lý Người dùng (Dựa trên MSSV) và Thiết bị (Máy chiếu, cáp...).
- **Quản lý Phiếu mượn thiết bị:** Tạo phiếu mượn mới, ghi nhận ngày mượn, ngày hẹn trả và số lượng. Hệ thống tự động trừ số lượng tồn kho.
- **Quản lý Nhật ký trả đồ:** Ghi nhận ngày trả thực tế, tự động cộng lại tồn kho.
- **Phân quyền và bảo mật (Audit Log):** Admin có quyền quản trị toàn hệ thống. Sinh viên chỉ quản lý phiếu của mình. Mọi thao tác cập nhật dữ liệu nhạy cảm đều được hệ thống tự động lưu vào Nhật ký.

## 3. PHÂN TÍCH THIẾT KẾ CƠ SỞ DỮ LIỆU (8 BẢNG)
Hệ thống sử dụng **MS SQL Server** với lược đồ 8 bảng, đáp ứng đầy đủ tính toàn vẹn dữ liệu:

1. **PhanQuyen:** Quản lý cấp độ truy cập (Admin, Sinh Viên...).
2. **NguoiDung:** Lưu thông tin cá nhân dựa trên khóa chính là MaND (MSSV).
3. **LoaiThietBi:** Danh mục các nhóm thiết bị.
4. **ThietBi:** Chi tiết từng thiết bị, số lượng tồn kho và trạng thái.
5. **PhieuMuon:** Lưu trữ thông tin chung của lượt mượn (Người mượn, ngày mượn, ngày hẹn trả).
6. **ChiTietMuon:** Chi tiết các món đồ cụ thể trong từng phiếu (Khóa chính kết hợp MaPhieu + MaTB).
7. **NhatKyTra:** Ghi nhận khi hoàn thành quy trình trả đồ và tiền phạt (nếu có).
8. **NhatKyHeThong:** Bảng lưu vết (Audit Log) để giám sát các thay đổi dữ liệu trái phép.

**Điểm nhấn Kỹ thuật (Transaction, Trigger & Ràng buộc toàn vẹn):**
- **Ràng buộc CHECK `CHK_NgayTra_NgayMuon`:** Cài đặt ở bảng `PhieuMuon` để đảm bảo tính hợp lý của dữ liệu, tuyệt đối không cho phép nhập ngày hẹn trả nhỏ hơn ngày tạo phiếu mượn.
- **Stored Procedure `sp_TaoPhieuMuon`:** Sử dụng khối `BEGIN TRAN...COMMIT...ROLLBACK` để đảm bảo tính toàn vẹn (ACID). Nếu việc mượn thiết bị thành công nhưng trừ số lượng tồn kho thất bại, toàn bộ phiếu mượn sẽ bị hủy, tránh rác dữ liệu.
- **Trigger `trg_CheckSoLuongMuon`:** Bẫy lỗi `INSTEAD OF INSERT`, tự động chặn đứng thao tác mượn nếu sinh viên mượn số lượng lớn hơn số lượng tồn kho đang có.
- **Trigger `trg_LogNguoiDung_Update`:** Tự động ghi lại lịch sử vào bảng `NhatKyHeThong` khi có bất kỳ ai sửa đổi tên người dùng.

## 4. GIAO DIỆN ỨNG DỤNG (MODULE WEB MOCKUP)
Giao diện ứng dụng được thiết kế dưới dạng Web App (Sử dụng HTML, CSS, JavaScript) với giao diện hiện đại, tối ưu cho cả máy tính và điện thoại (Responsive). Mã nguồn giao diện hiện đang được triển khai thực tế trên Github Pages.

Các chức năng nổi bật trên giao diện đáp ứng đầy đủ yêu cầu:
- **Trang Kho Thiết Bị (Quản lý chung):** Nơi hiển thị toàn bộ thiết bị hiện có của trường Trung học Cơ sở Lộc An. Tại đây, hệ thống cho phép quản trị viên xem tổng quan tình trạng thiết bị (sẵn sàng, đang cho mượn). Người dùng có thể thực hiện thao tác Đăng ký mượn mới.
- **Trang Kho Cá Nhân (Phân quyền dữ liệu):** Thể hiện rõ nét tính năng phân quyền. Mỗi sinh viên/giáo viên khi đăng nhập vào hệ thống sẽ chỉ thấy những thiết bị mà mình đang mượn hoặc đã mượn trong quá khứ ở "Kho cá nhân", bảo mật tuyệt đối thông tin giữa các tài khoản.
- **Chế độ Quản Trị Viên (Admin):** Có đặc quyền truy cập tất cả lịch sử mượn/trả và thao tác cập nhật trạng thái thiết bị.

*(Ghi chú: Giao diện web hiện tại đóng vai trò là Mockup Prototype (Bản mẫu) để thể hiện trực quan luồng thao tác (UI/UX). Ở tầng phía sau (Backend/Database), toàn bộ dữ liệu, logic bẫy lỗi và ràng buộc (Triggers, Transactions) đã được xây dựng và kiểm thử hoàn chỉnh bằng MS SQL Server).*
