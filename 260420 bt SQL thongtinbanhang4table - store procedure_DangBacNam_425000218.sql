/*
Bài tập ngày 
Mã số sinh viên: 
*/

/* bài tập phần store procedure */

--Phần 1. Viết thủ tục (Stored Procedure - No Param / Input Param)
--1. Viết thủ tục sp_TatCaSanPham để hiển thị danh sách tất cả sản phẩm hiện có.

--2. Viết thủ tục sp_TimKhachHang nhận vào MaKH và hiển thị thông tin chi tiết của khách hàng đó.

--3. Viết thủ tục sp_HoaDonTheoNgay nhận vào một giá trị ngày, hiển thị các hóa đơn lập trong ngày đó.

--4. Viết thủ tục sp_SanPhamGiaCao hiển thị các sản phẩm có đơn giá lớn hơn một giá trị X truyền vào.

--5. Viết thủ tục sp_ChiTietMuaHang nhận vào MaHD, hiển thị tên các sản phẩm và số lượng tương ứng của hóa đơn đó.

--Phần 2. Viết thủ tục (Stored Procedure - Output Param)
--1. Viết thủ tục nhận vào MaKH, trả về (Output) tổng số hóa đơn mà khách hàng đó đã mua.

--2. Viết thủ tục nhận vào MaHD, trả về tổng thành tiền (Số lượng * Đơn giá bán) của hóa đơn đó.

--3. Viết thủ tục nhận vào MaSP, trả về tổng số lượng sản phẩm đó đã bán được trên tất cả các hóa đơn.

--4. Viết thủ tục trả về tên sản phẩm có đơn giá cao nhất hiện nay.

--5. Viết thủ tục nhận vào tháng/năm, trả về tổng doanh thu của tháng đó.

/*
LỜI GIẢI DỰA THEO DATA CŨ TRONG FILE QUERY INSERT/UPDATE:
- SanPham(MaSP INT, TenSP NVARCHAR(100), DonGia DECIMAL(10,2))
- KhachHang(MaKH INT, HoTenKH NVARCHAR(100), SoDTKH VARCHAR(20), EmailKH VARCHAR(100))
- HoaDon(MaHD INT, MaKH INT, NgayLapHD DATE)
- CTHD(MaHD INT, MaKH INT, MaSP INT, SoLuong INT, DonGiaBan DECIMAL(10,2))

Lưu ý:
- Trước khi chạy file này, phải chạy file tạo bảng và dữ liệu mẫu trước.
- Các khóa chính/khóa ngoại ở bộ dữ liệu cũ đều là INT, nên tham số MaKH/MaHD/MaSP cũng dùng INT để khớp kiểu dữ liệu.
*/

-- ================================================================
-- PHẦN 1: STORED PROCEDURE - KHÔNG OUTPUT, CÓ THAM SỐ ĐẦU VÀO
-- ================================================================

-- 1) Hiển thị danh sách tất cả sản phẩm hiện có
CREATE OR ALTER PROCEDURE sp_TatCaSanPham
AS
BEGIN
	SET NOCOUNT ON;

	-- Lấy toàn bộ cột của bảng SanPham.
	-- Nếu bỏ SELECT này thì procedure vẫn chạy nhưng không trả về dữ liệu.
	SELECT MaSP, TenSP, DonGia
	FROM SanPham;
END;
GO

EXEC sp_TatCaSanPham;
GO


-- 2) Nhận vào MaKH và hiển thị thông tin chi tiết của khách hàng đó
CREATE OR ALTER PROCEDURE sp_TimKhachHang
	@MaKH INT
AS
BEGIN
	SET NOCOUNT ON;

	-- Lọc đúng 1 khách hàng theo mã.
	-- Nếu bỏ WHERE thì sẽ trả về tất cả khách hàng, sai yêu cầu bài.
	SELECT MaKH, HoTenKH, SoDTKH, EmailKH
	FROM KhachHang
	WHERE MaKH = @MaKH;
END;
GO

EXEC sp_TimKhachHang @MaKH = 1;
GO


-- 3) Nhận vào một ngày, hiển thị các hóa đơn lập trong ngày đó
CREATE OR ALTER PROCEDURE sp_HoaDonTheoNgay
	@Ngay DATE
AS
BEGIN
	SET NOCOUNT ON;

	-- Trong data cũ, NgayLapHD là kiểu DATE nên so sánh trực tiếp là đủ.
	-- Nếu cột là DATETIME thì thường phải dùng CAST/CONVERT để so sánh phần ngày.
	-- Nếu bỏ WHERE thì sẽ trả về mọi hóa đơn trong hệ thống.
	SELECT MaHD, MaKH, NgayLapHD
	FROM HoaDon
	WHERE NgayLapHD = @Ngay;
END;
GO

EXEC sp_HoaDonTheoNgay @Ngay = '2024-08-01';
GO


-- 4) Hiển thị các sản phẩm có đơn giá lớn hơn giá trị X truyền vào
CREATE OR ALTER PROCEDURE sp_SanPhamGiaCao
	@GiaX DECIMAL(10,2)
AS
BEGIN
	SET NOCOUNT ON;

	-- Dùng dấu > đúng nghĩa “lớn hơn” theo đề bài.
	-- Nếu đổi thành >= thì những sản phẩm bằng đúng ngưỡng cũng bị lấy lên.
	SELECT MaSP, TenSP, DonGia
	FROM SanPham
	WHERE DonGia > @GiaX;
END;
GO

EXEC sp_SanPhamGiaCao @GiaX = 500;
GO


-- 5) Nhận vào MaHD, hiển thị tên sản phẩm và số lượng tương ứng của hóa đơn đó
CREATE OR ALTER PROCEDURE sp_ChiTietMuaHang
	@MaHD INT
AS
BEGIN
	SET NOCOUNT ON;

	-- Phải JOIN CTHD với SanPham để lấy TenSP.
	-- Nếu bỏ JOIN thì chỉ còn MaSP ở CTHD, không đổi được ra tên sản phẩm.
	-- Nếu bỏ WHERE thì sẽ trả về chi tiết của mọi hóa đơn.
	SELECT sp.TenSP, cthd.SoLuong
	FROM CTHD AS cthd
	INNER JOIN SanPham AS sp ON cthd.MaSP = sp.MaSP
	WHERE cthd.MaHD = @MaHD;
END;
GO

EXEC sp_ChiTietMuaHang @MaHD = 101;
GO


-- ================================================================
-- PHẦN 2: STORED PROCEDURE - OUTPUT PARAMETER
-- ================================================================

-- 1) Nhận vào MaKH, trả về tổng số hóa đơn mà khách hàng đó đã mua
CREATE OR ALTER PROCEDURE sp_TongHoaDon_KH
	@MaKH INT,
	@TongHoaDon INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	-- COUNT(*) luôn trả về số dòng khớp điều kiện.
	-- Nếu không có hóa đơn nào, COUNT vẫn trả 0.
	-- Nếu bỏ OUTPUT thì biến bên ngoài không nhận được giá trị.
	SELECT @TongHoaDon = COUNT(*)
	FROM HoaDon
	WHERE MaKH = @MaKH;
END;
GO

DECLARE @SoHD INT;
EXEC sp_TongHoaDon_KH @MaKH = 1, @TongHoaDon = @SoHD OUTPUT;
SELECT @SoHD AS TongHoaDon;


-- 2) Nhận vào MaHD, trả về tổng thành tiền của hóa đơn đó
CREATE OR ALTER PROCEDURE sp_TongThanhTien_HD
	@MaHD INT,
	@TongTien DECIMAL(18,2) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	-- SUM có thể trả NULL nếu hóa đơn không có dòng chi tiết nào.
	-- ISNULL(..., 0) đổi NULL thành 0 để dễ xử lý ở phía gọi.
	-- Nếu bỏ ISNULL thì hóa đơn rỗng sẽ trả NULL, có thể gây lỗi logic.
	SELECT @TongTien = ISNULL(SUM(SoLuong * DonGiaBan), 0)
	FROM CTHD
	WHERE MaHD = @MaHD;
END;
GO

DECLARE @Tien DECIMAL(18,2);
EXEC sp_TongThanhTien_HD @MaHD = 101, @TongTien = @Tien OUTPUT;
SELECT @Tien AS TongThanhTien;


-- 3) Nhận vào MaSP, trả về tổng số lượng sản phẩm đó đã bán được
CREATE OR ALTER PROCEDURE sp_TongSoLuongBan_SP
	@MaSP INT,
	@TongSoLuong INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	-- Nếu sản phẩm chưa từng bán, SUM sẽ là NULL nên cần ISNULL để trả về 0.
	SELECT @TongSoLuong = ISNULL(SUM(SoLuong), 0)
	FROM CTHD
	WHERE MaSP = @MaSP;
END;
GO

DECLARE @SL INT;
EXEC sp_TongSoLuongBan_SP @MaSP = 1002, @TongSoLuong = @SL OUTPUT;
SELECT @SL AS TongSoLuong;


-- 4) Trả về tên sản phẩm có đơn giá cao nhất hiện nay
CREATE OR ALTER PROCEDURE sp_TenSanPhamGiaCaoNhat
	@TenSP NVARCHAR(100) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	-- TOP 1 để chỉ lấy 1 dòng; ORDER BY DonGia DESC để lấy giá cao nhất.
	-- Nếu bỏ TOP 1 thì không thể gán nhiều dòng vào một biến OUTPUT.
	-- Nếu bỏ ORDER BY thì TOP 1 sẽ lấy ngẫu nhiên, không chắc là sản phẩm đắt nhất.
	SELECT TOP 1 @TenSP = TenSP
	FROM SanPham
	ORDER BY DonGia DESC, MaSP ASC;
END;
GO

DECLARE @Ten NVARCHAR(100);
EXEC sp_TenSanPhamGiaCaoNhat @TenSP = @Ten OUTPUT;
SELECT @Ten AS SanPhamGiaCaoNhat;


-- 5) Nhận vào tháng/năm, trả về tổng doanh thu của tháng đó
CREATE OR ALTER PROCEDURE sp_DoanhThu_Thang
	@Thang INT,
	@Nam INT,
	@DoanhThu DECIMAL(18,2) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	-- Doanh thu = tổng của SoLuong * DonGiaBan trên toàn bộ chi tiết hóa đơn
	-- có ngày lập thuộc tháng/năm được truyền vào.
	-- Phải JOIN HoaDon với CTHD vì NgayLapHD nằm ở HoaDon, còn tiền nằm ở CTHD.
	-- Nếu bỏ JOIN thì không lọc được theo ngày hóa đơn.
	SELECT @DoanhThu = ISNULL(SUM(cthd.SoLuong * cthd.DonGiaBan), 0)
	FROM HoaDon AS hd
	INNER JOIN CTHD AS cthd ON hd.MaHD = cthd.MaHD
	WHERE MONTH(hd.NgayLapHD) = @Thang
	  AND YEAR(hd.NgayLapHD) = @Nam;
END;
GO

DECLARE @DT DECIMAL(18,2);
EXEC sp_DoanhThu_Thang @Thang = 8, @Nam = 2024, @DoanhThu = @DT OUTPUT;
SELECT @DT AS DoanhThuThang;

/*
Gợi ý cách chạy thử từng thủ tục:*/




















