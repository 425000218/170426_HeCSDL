
CREATE DATABASE QuanLyBan_Hang;
go
USE QuanLyBan_Hang;

-- Bảng Sản phẩm
CREATE TABLE SanPham (
    MaSP INT PRIMARY KEY,
    TenSP NVARCHAR(100) NOT NULL,
    DonGia DECIMAL(10,2) NOT NULL
);

-- Bảng Khách hàng
CREATE TABLE KhachHang (
    MaKH INT PRIMARY KEY,
    HoTenKH NVARCHAR(100) NOT NULL,
    SoDTKH VARCHAR(20),
    EmailKH VARCHAR(100)
);

-- Bảng Hóa đơn
CREATE TABLE HoaDon (
    MaHD INT PRIMARY KEY,
    MaKH INT NOT NULL,
    NgayLapHD DATE,
    FOREIGN KEY (MaKH) REFERENCES KhachHang(MaKH)
);

-- Bảng Chi tiết hóa đơn
CREATE TABLE CTHD (
    MaHD INT,
    MaKH INT,
    MaSP INT,
    SoLuong INT NOT NULL,
    DonGiaBan DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (MaHD, MaSP),
    FOREIGN KEY (MaHD) REFERENCES HoaDon(MaHD),
    FOREIGN KEY (MaKH) REFERENCES KhachHang(MaKH),
    FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP)
);

-- Dữ liệu mẫu cho bảng SanPham
INSERT INTO SanPham (MaSP, TenSP, DonGia) VALUES
(1001, 'Laptop', 1200),
(1002, 'Smartphone', 800),
(1003, 'Tablet', 400),
(1004, 'Cable', 10);

-- Dữ liệu mẫu cho bảng KhachHang
INSERT INTO KhachHang (MaKH, HoTenKH, SoDTKH, EmailKH) VALUES
(1, N'Nguyễn Văn An', '123456789', 'an@example.com'),
(2, N'Trần Hùng', '987654321', 'hung@example.com'),
(3, N'Ngô Đình Khoa', '555444333', 'nkh@example.com');

-- Dữ liệu mẫu cho bảng HoaDon
INSERT INTO HoaDon (MaHD, MaKH, NgayLapHD) VALUES
(101, 1, '2024-08-01'),
(102, 2, '2024-08-02'),
(103, 3, '2024-08-03'),
(104, 1, '2024-08-04'),
(105, 3, '2024-08-05'); -- Lưu ý: Ngày 45514 trong Excel là số serial, tương ứng 2024-08-05

-- Dữ liệu mẫu cho bảng CTHD
INSERT INTO CTHD (MaHD, MaKH, MaSP, SoLuong, DonGiaBan) VALUES
(101, 1, 1001, 1, 1200),
(101, 1, 1002, 2, 800),
(102, 2, 1003, 1, 400),
(103, 3, 1002, 1, 800),
(104, 1, 1002, 1, 800),
(105, 3, 1004, 4, 10);

--Sau khi tạo xong, sử dụng SQL đã có để biên dịch và tạo DB
SELECT * FROM SanPham;
SELECT * FROM KhachHang;
SELECT * FROM HoaDon;
SELECT * FROM CTHD;




/*
Bài tập ngày 
Mã số sinh viên: 
*/

/* bài tập phần insert, update, delete */

--Phần 1. Thêm dữ liệu (INSERT)
--1. Thêm một khách hàng mới vào bảng KhachHang với các thông tin: Mã KH là 4, tên 'Lê Văn Tám', số điện thoại '0909123456', email 'tamlv@example.com'.
INSERT INTO KhachHang (MaKH, HoTenKH, SoDTKH, EmailKH)
VALUES (4, N'Lê Văn Tám', '0909123456', 'tamlv@example.com');

--2. Thêm một sản phẩm mới vào bảng SanPham có mã 1005, tên 'Mouse Wireless', đơn giá 25.
INSERT INTO SanPham (MaSP, TenSP, DonGia)
VALUES (1005, N'Mouse Wireless', 25);

--3. Thêm một hóa đơn mới cho khách hàng có mã 2 vào ngày hiện tại (mã HD tự chọn hoặc theo thứ tự tiếp theo).
INSERT INTO HoaDon (MaHD, MaKH, NgayLapHD)
VALUES (106, 2, GETDATE());

--4. Thêm một bản ghi vào bảng CTHD cho biết hóa đơn 101 mua thêm sản phẩm 1003 với số lượng 1 và đơn giá bán là 400.
NSERT INTO CTHD (MaHD, MaKH, MaSP, SoLuong, DonGiaBan)
VALUES (101, 1, 1003, 1, 400);

--5. Thực hiện thêm nhanh 2 sản phẩm cùng lúc vào bảng SanPham bằng một câu lệnh INSERT.
INSERT INTO SanPham (MaSP, TenSP, DonGia) VALUES
    (1006, N'Keyboard Mechanical', 150),
    (1007, N'External HDD 1TB', 80);


--Phần 2. Cập nhật dữ liệu (UPDATE)
--1. Cập nhật lại số điện thoại của khách hàng 'Nguyễn Văn An' thành '0111222333'.
UPDATE KhachHang
SET SoDTKH = '0111222333'
WHERE HoTenKH = N'Nguyễn Văn An';

--2. Tăng đơn giá của tất cả các sản phẩm trong bảng SanPham lên 10%.
UPDATE SanPham
SET DonGia = DonGia * 1.10;

--3. Cập nhật lại ngày lập hóa đơn của hóa đơn số 102 thành '2024-08-15'.
UPDATE HoaDon
SET NgayLapHD = '2024-08-15'
WHERE MaHD = 102;

--4. Giảm giá 5% DonGiaBan trong bảng CTHD cho tất cả các chi tiết thuộc hóa đơn 101.
UPDATE CTHD
SET DonGiaBan = DonGiaBan * 0.95
WHERE MaHD = 101;

--5. Thay đổi tên sản phẩm 'Cable' thành 'USB Type-C Cable' và cập nhật đơn giá mới là 15.
UPDATE SanPham
SET TenSP = N'USB Type-C Cable',
    DonGia = 15
WHERE TenSP = N'Cable';

--Phần 3. Xóa dữ liệu (DELETE)
--1. Xóa sản phẩm có mã 1004 khỏi bảng SanPham (Lưu ý kiểm tra ràng buộc khóa ngoại).
DELETE FROM CTHD WHERE MaSP = 1004;
DELETE FROM SanPham WHERE MaSP = 1004;

--2. Xóa tất cả các chi tiết hóa đơn của hóa đơn số 105 trong bảng CTHD.
DELETE FROM CTHD WHERE MaHD = 105;

--3. Xóa khách hàng có tên 'Ngô Đình Khoa' (Giả sử khách hàng này chưa có hóa đơn).
DELETE FROM KhachHang WHERE HoTenKH = N'Ngô Đình Khoa';

--4. Xóa các hóa đơn được lập trước ngày '2024-08-01'.
DELETE FROM CTHD
WHERE MaHD IN (SELECT MaHD FROM HoaDon WHERE NgayLapHD < '2024-08-01');
DELETE FROM HoaDon WHERE NgayLapHD < '2024-08-01';

--Cách 2:
-- Bước 1: Xóa các dòng con trong bảng CTHD dựa trên ngày của bảng HoaDon
DELETE CTHD
FROM CTHD
JOIN HoaDon ON CTHD.MaHD = HoaDon.MaHD
WHERE HoaDon.NgayLapHD < '2024-08-01';

-- Bước 2: Xóa chính các hóa đơn đó trong bảng HoaDon
DELETE FROM HoaDon 
WHERE NgayLapHD < '2024-08-01';



--5. Xóa tất cả các sản phẩm có đơn giá nhỏ hơn 50.
DELETE FROM CTHD
WHERE MaSP IN (SELECT MaSP FROM SanPham WHERE DonGia < 50);
DELETE FROM SanPham WHERE DonGia < 50;

--Cách 2
-- Bước 1: Xóa các chi tiết hóa đơn (CTHD) liên quan đến sản phẩm giá rẻ
DELETE CTHD
FROM CTHD
JOIN SanPham ON CTHD.MaSP = SanPham.MaSP
WHERE SanPham.DonGia < 50;

-- Bước 2: Xóa các sản phẩm đó khỏi bảng SanPham
DELETE FROM SanPham 
WHERE DonGia < 50;

