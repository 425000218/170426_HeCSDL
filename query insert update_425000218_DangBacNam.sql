/* --------------------------------------------------------------
   BÀI TẬP NGÀY – CÁC CÂU LỆNH INSERT, UPDATE, DELETE
   Mục đích: Thực hành các thao tác DML trên cơ sở dữ liệu bán hàng.
   Giải thích chi tiết từng dòng lệnh để cô có thể đánh giá hiểu biết
   của sinh viên và trả lời các câu hỏi liên quan.
---------------------------------------------------------------- */

/* ------------------- PHẦN 1: INSERT ------------------- */

/* 1. Thêm một khách hàng mới vào bảng KhachHang */
-- Mã KH = 4, tên 'Lê Văn Tám', số điện thoại '0909123456', email 'tamlv@example.com'
INSERT INTO KhachHang (MaKH, HoTenKH, SoDTKH, EmailKH)
VALUES (4, N'Lê Văn Tám', '0909123456', 'tamlv@example.com');
-- Giải thích: 
--   * MaKH là khóa chính, phải là giá trị duy nhất.
--   * Sử dụng N'...' để lưu chuỗi Unicode (có dấu tiếng Việt).


/* 2. Thêm một sản phẩm mới vào bảng SanPham */
-- Mã SP = 1005, tên 'Mouse Wireless', đơn giá 25
INSERT INTO SanPham (MaSP, TenSP, DonGia)
VALUES (1005, N'Mouse Wireless', 25);
-- Giải thích: 
--   * Đảm bảo MaSP không trùng với các mã đã tồn tại.
--   * Đơn giá được lưu dưới dạng DECIMAL, không cần ký hiệu tiền tệ.


-- 3. Thêm một hóa đơn mới cho khách hàng có mã 2 (Trần Hùng) vào ngày hiện tại
--    Giả sử mã HD tiếp theo là 106 (sau các HD đã có 101‑105)
INSERT INTO HoaDon (MaHD, MaKH, NgayLapHD)
VALUES (106, 2, GETDATE());   -- GETDATE() trả về ngày‑giờ hiện tại của server
-- Giải thích:
--   * MaHD là khóa chính, cần chọn giá trị chưa dùng.
--   * Ngày lập sử dụng hàm GETDATE() để tự động lấy ngày hiện tại.


-- 4. Thêm một bản ghi vào bảng CTHD cho biết hóa đơn 101 mua thêm sản phẩm 1003
--    với số lượng 1 và đơn giá bán là 400
INSERT INTO CTHD (MaHD, MaKH, MaSP, SoLuong, DonGiaBan)
VALUES (101, 1, 1003, 1, 400);
-- Giải thích:
--   * MaKH được ghi lại để duy trì thông tin khách hàng trong chi tiết.
--   * MaHD và MaSP tạo thành khóa chính (MaHD, MaSP) trong CTHD.

-- 5. Thêm nhanh 2 sản phẩm cùng lúc vào bảng SanPham
INSERT INTO SanPham (MaSP, TenSP, DonGia) VALUES
    (1006, N'Keyboard Mechanical', 150),
    (1007, N'External HDD 1TB', 80);
-- Giải thích:
--   * Cú pháp VALUES cho phép chèn nhiều dòng trong một câu lệnh.
--   * Giúp giảm số lần round‑trip tới server và tăng hiệu suất.


/* ------------------- PHẦN 2: UPDATE ------------------- */

/* 1. Cập nhật lại số điện thoại của khách hàng 'Nguyễn Văn An' */
UPDATE KhachHang
SET SoDTKH = '0111222333'
WHERE HoTenKH = N'Nguyễn Văn An';
-- Giải thích:
--   * WHERE giới hạn cập nhật chỉ cho khách hàng có tên đúng như trên.
--   * Nếu có nhiều khách hàng cùng tên, nên dùng MaKH để xác định duy nhất.


/* 2. Tăng đơn giá của tất cả các sản phẩm trong bảng SanPham lên 10% */
UPDATE SanPham
SET DonGia = DonGia * 1.10;   -- nhân 1.10 để tăng 10%
-- Giải thích:
--   * Không cần WHERE vì áp dụng cho toàn bộ bảng.
--   * DECIMAL sẽ tự động làm tròn theo cấu hình mặc định của SQL Server.


/* 3. Cập nhật lại ngày lập hóa đơn của hóa đơn số 102 thành '2024-08-15' */
UPDATE HoaDon
SET NgayLapHD = '2024-08-15'
WHERE MaHD = 102;
-- Giải thích:
--   * Ngày được ghi dưới dạng chuỗi ISO (YYYY-MM-DD) sẽ được chuyển sang DATE.


/* 4. Giảm giá 5% DonGiaBan trong bảng CTHD cho tất cả các chi tiết thuộc hóa đơn 101 */
UPDATE CTHD
SET DonGiaBan = DonGiaBan * 0.95   -- giảm 5%
WHERE MaHD = 101;
-- Giải thích:
--   * WHERE MaHD = 101 chỉ ảnh hưởng tới các dòng chi tiết của hóa đơn 101.


/* 5. Thay đổi tên sản phẩm 'Cable' thành 'USB Type‑C Cable' và cập nhật đơn giá mới là 15 */
UPDATE SanPham
SET TenSP = N'USB Type‑C Cable',
    DonGia = 15
WHERE TenSP = N'Cable';
-- Giải thích:
--   * Cập nhật đồng thời cả tên và giá trong một câu lệnh.
--   * Sử dụng N'...' để bảo toàn ký tự Unicode.


/* ------------------- PHẦN 3: DELETE ------------------- */

/* 1. Xóa sản phẩm có mã 1004 khỏi bảng SanPham (cần kiểm tra ràng buộc FK) */
-- Trước tiên, cần xóa các chi tiết liên quan trong CTHD (nếu có)
DELETE FROM CTHD WHERE MaSP = 1004;
-- Sau khi không còn ràng buộc, xóa sản phẩm
DELETE FROM SanPham WHERE MaSP = 1004;
-- Giải thích:
--   * SQL Server không cho phép xóa bản ghi nếu còn ràng buộc khóa ngoại.
--   * Vì CTHD tham chiếu SanPham, phải xóa các dòng phụ thuộc trước.



/* 2. Xóa tất cả các chi tiết hóa đơn của hóa đơn số 105 trong bảng CTHD */
DELETE FROM CTHD WHERE MaHD = 105;
-- Giải thích:
--   * Xóa toàn bộ các dòng chi tiết, không ảnh hưởng tới bảng HoaDon.


/* 3. Xóa khách hàng có tên 'Ngô Đình Khoa' (giả sử chưa có hóa đơn) */
-- Kiểm tra ràng buộc: nếu khách hàng này không xuất hiện trong HoaDon, có thể xóa trực tiếp
DELETE FROM KhachHang WHERE HoTenKH = N'Ngô Đình Khoa';
-- Giải thích:
--   * Nếu có hóa đơn liên quan, lệnh sẽ thất bại do FK; cần xóa hoặc cập nhật hóa đơn trước.


/* 4. Xóa các hóa đơn được lập trước ngày '2024-08-01' */
-- Trước tiên, xóa các chi tiết liên quan để tránh vi phạm FK
DELETE FROM CTHD
WHERE MaHD IN (SELECT MaHD FROM HoaDon WHERE NgayLapHD < '2024-08-01');
-- Sau đó, xóa các hóa đơn
DELETE FROM HoaDon WHERE NgayLapHD < '2024-08-01';
-- Giải thích:
--   * Hai bước để giữ tính toàn vẹn dữ liệu: xóa phụ thuộc trước, rồi mới xóa cha.


/* 5. Xóa tất cả các sản phẩm có đơn giá nhỏ hơn 50 */
-- Cần xóa chi tiết liên quan trước
DELETE FROM CTHD
WHERE MaSP IN (SELECT MaSP FROM SanPham WHERE DonGia < 50);
-- Sau đó, xóa sản phẩm
DELETE FROM SanPham WHERE DonGia < 50;
-- Giải thích:
--   * Đảm bảo không còn bản ghi trong CTHD tham chiếu các sản phẩm sẽ bị xóa.
--   * Điều này ngăn lỗi “The DELETE statement conflicted with the REFERENCE constraint”.

/* --------------------------------------------------------------
   KẾT THÚC BÀI TẬP
   - Các câu lệnh trên đã thực hiện đầy đủ các thao tác INSERT, UPDATE,
     DELETE theo yêu cầu.
   - Mỗi câu lệnh được chú thích chi tiết để giải thích mục đích và
     lý do cần thực hiện, giúp cô có thể đánh giá quá trình suy nghĩ
     và hiểu biết của sinh viên.
---------------------------------------------------------------- */
