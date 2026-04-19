/*
Bài tập ngày 19/04/2026
Mã số sinh viên: 425000218 - Đặng Bắc Nam
*/

/* ============================================================
   CẤU TRÚC 4 BẢNG SỬ DỤNG TRONG BÀI:
   - SanPham   (MaSP, TenSP, DonGia)
   - KhachHang (MaKH, TenKH, DiaChi, DienThoai)
   - HoaDon    (MaHD, MaKH, NgayLap)
   - CTHD      (MaHD, MaSP, SoLuong, DonGiaBan)
   ============================================================ */

-- ================================================================
-- PHẦN 1: STORED PROCEDURE - KHÔNG CÓ THAM SỐ / CÓ THAM SỐ ĐẦU VÀO
-- ================================================================

-- ----------------------------------------------------------------
-- BÀI 1: sp_TatCaSanPham - Hiển thị tất cả sản phẩm hiện có
-- ----------------------------------------------------------------
CREATE PROCEDURE sp_TatCaSanPham
AS
BEGIN
    -- SET NOCOUNT ON: tắt thông báo "X row(s) affected" để tránh
    -- gây nhiễu cho ứng dụng client đọc kết quả trả về.
    -- NẾU THIẾU: một số framework/driver sẽ báo lỗi hoặc đọc nhầm
    --            "rows affected" như một result set bổ sung.
    SET NOCOUNT ON;

    -- Lấy toàn bộ dữ liệu từ bảng SanPham.
    -- NẾU THIẾU dòng SELECT này: procedure chạy thành công nhưng
    --            không trả về dữ liệu nào → ứng dụng nhận bộ rỗng.
    SELECT *
    FROM   SanPham;
END;
GO

-- Cách gọi thủ tục:
-- EXEC sp_TatCaSanPham;


-- ----------------------------------------------------------------
-- BÀI 2: sp_TimKhachHang - Tìm thông tin khách hàng theo MaKH
-- ----------------------------------------------------------------
CREATE PROCEDURE sp_TimKhachHang
    -- @MaKH là tham số đầu vào kiểu CHAR(5) để nhận mã khách hàng.
    -- NẾU THIẾU tham số: không thể lọc theo MaKH → phải trả về hết.
    @MaKH CHAR(5)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM   KhachHang
    -- Điều kiện lọc theo mã khách hàng được truyền vào.
    -- NẾU THIẾU WHERE: trả về toàn bộ khách hàng, không đúng yêu cầu.
    WHERE  MaKH = @MaKH;
END;
GO

-- Cách gọi:
-- EXEC sp_TimKhachHang @MaKH = 'KH001';


-- ----------------------------------------------------------------
-- BÀI 3: sp_HoaDonTheoNgay - Hiển thị hóa đơn theo ngày lập
-- ----------------------------------------------------------------
CREATE PROCEDURE sp_HoaDonTheoNgay
    -- @Ngay nhận giá trị ngày kiểu DATE từ người gọi.
    @Ngay DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM   HoaDon
    -- CAST(NgayLap AS DATE): chuyển cột DATETIME về DATE để so sánh
    -- chỉ phần ngày, bỏ qua phần giờ:phút:giây.
    -- NẾU THIẾU CAST: nếu NgayLap là DATETIME, câu lệnh '= @Ngay'
    --   sẽ chỉ khớp khi giờ đúng 00:00:00 → có thể bỏ sót hóa đơn
    --   được lập trong ngày nhưng có giờ khác 0.
    WHERE  CAST(NgayLap AS DATE) = @Ngay;
END;
GO

-- Cách gọi:
-- EXEC sp_HoaDonTheoNgay @Ngay = '2024-04-19';


-- ----------------------------------------------------------------
-- BÀI 4: sp_SanPhamGiaCao - Hiển thị sản phẩm có đơn giá > X
-- ----------------------------------------------------------------
CREATE PROCEDURE sp_SanPhamGiaCao
    -- @GiaMin nhận giá trị ngưỡng giá từ người gọi.
    -- NẾU THIẾU tham số: không thể lọc theo giá → phải trả về hết.
    @GiaMin MONEY
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM   SanPham
    -- Lọc các sản phẩm có DonGia STRICTLY lớn hơn @GiaMin.
    -- NẾU DÙNG >= thay vì >: sẽ bao gồm cả sản phẩm đúng bằng ngưỡng,
    --   không đúng đề bài yêu cầu "lớn hơn".
    -- NẾU THIẾU WHERE: trả về mọi sản phẩm, không lọc theo giá.
    WHERE  DonGia > @GiaMin;
END;
GO

-- Cách gọi:
-- EXEC sp_SanPhamGiaCao @GiaMin = 500000;


-- ----------------------------------------------------------------
-- BÀI 5: sp_ChiTietMuaHang - Tên & số lượng sản phẩm của một hóa đơn
-- ----------------------------------------------------------------
CREATE PROCEDURE sp_ChiTietMuaHang
    -- @MaHD nhận mã hóa đơn cần xem chi tiết.
    @MaHD CHAR(5)
AS
BEGIN
    SET NOCOUNT ON;

    -- Lấy tên sản phẩm và số lượng từ hai bảng CTHD và SanPham.
    SELECT sp.TenSP,       -- Tên sản phẩm lấy từ bảng SanPham
           cthd.SoLuong    -- Số lượng lấy từ bảng CTHD
    FROM   CTHD cthd
           -- JOIN để nối CTHD với SanPham qua khóa ngoại MaSP.
           -- NẾU THIẾU JOIN: không lấy được TenSP, câu lệnh lỗi biên dịch.
           INNER JOIN SanPham sp ON cthd.MaSP = sp.MaSP
    -- Lọc theo mã hóa đơn.
    -- NẾU THIẾU WHERE: trả về chi tiết của MỌI hóa đơn trong hệ thống.
    WHERE  cthd.MaHD = @MaHD;
END;
GO

-- Cách gọi:
-- EXEC sp_ChiTietMuaHang @MaHD = 'HD001';


-- ================================================================
-- PHẦN 2: STORED PROCEDURE - CÓ THAM SỐ OUTPUT (TRẢ VỀ GIÁ TRỊ)
-- ================================================================

-- ----------------------------------------------------------------
-- BÀI 1: Tổng số hóa đơn của một khách hàng (OUTPUT)
-- ----------------------------------------------------------------
CREATE PROCEDURE sp_TongHoaDon_KH
    @MaKH       CHAR(5),      -- Tham số đầu vào: mã khách hàng
    -- OUTPUT: tham số trả về giá trị cho người gọi.
    -- NẾU THIẾU từ khóa OUTPUT: biến sẽ được xử lý như tham số IN bình thường,
    --   người gọi KHÔNG thể đọc giá trị trả về → lỗi logic.
    @TongHoaDon INT OUTPUT    -- Tham số đầu ra: tổng số hóa đơn
AS
BEGIN
    SET NOCOUNT ON;

    -- Gán kết quả COUNT(*) vào biến OUTPUT thay vì SELECT thành result set.
    -- NẾU DÙNG SELECT * thay vì SELECT @TongHoaDon = COUNT(*):
    --   trả về bảng kết quả chứ không gán vào biến OUTPUT.
    SELECT @TongHoaDon = COUNT(*)
    FROM   HoaDon
    WHERE  MaKH = @MaKH;
END;
GO

-- Cách gọi:
-- DECLARE @So INT;
-- EXEC sp_TongHoaDon_KH @MaKH = 'KH001', @TongHoaDon = @So OUTPUT;
-- SELECT @So AS TongHoaDon;


-- ----------------------------------------------------------------
-- BÀI 2: Tổng thành tiền (SoLuong * DonGiaBan) của một hóa đơn (OUTPUT)
-- ----------------------------------------------------------------
CREATE PROCEDURE sp_TongThanhTien_HD
    @MaHD     CHAR(5),       -- Tham số đầu vào: mã hóa đơn
    @TongTien MONEY OUTPUT   -- Tham số đầu ra: tổng thành tiền
AS
BEGIN
    SET NOCOUNT ON;

    -- Tính tổng = SoLuong nhân DonGiaBan cho tất cả dòng trong hóa đơn.
    -- Dùng ISNULL(..., 0) để xử lý trường hợp hóa đơn không có dòng nào
    -- → SUM trả về NULL thay vì 0.
    -- NẾU THIẾU ISNULL: @TongTien = NULL khi hóa đơn rỗng → có thể gây lỗi
    --   cho ứng dụng đọc giá trị số.
    SELECT @TongTien = ISNULL(SUM(SoLuong * DonGiaBan), 0)
    FROM   CTHD
    WHERE  MaHD = @MaHD;
END;
GO

-- Cách gọi:
-- DECLARE @Tien MONEY;
-- EXEC sp_TongThanhTien_HD @MaHD = 'HD001', @TongTien = @Tien OUTPUT;
-- SELECT @Tien AS TongThanhTien;


-- ----------------------------------------------------------------
-- BÀI 3: Tổng số lượng bán được của một sản phẩm (OUTPUT)
-- ----------------------------------------------------------------
CREATE PROCEDURE sp_TongSoLuongBan_SP
    @MaSP        CHAR(5),    -- Tham số đầu vào: mã sản phẩm
    @TongSoLuong INT OUTPUT  -- Tham số đầu ra: tổng số lượng đã bán
AS
BEGIN
    SET NOCOUNT ON;

    -- ISNULL(..., 0): nếu sản phẩm chưa có trong bất kỳ hóa đơn nào,
    -- SUM sẽ trả NULL → cần trả 0 thay thế.
    -- NẾU THIẾU ISNULL: client nhận NULL thay vì 0 → có thể gây lỗi chia
    --   hay so sánh trong ứng dụng.
    SELECT @TongSoLuong = ISNULL(SUM(SoLuong), 0)
    FROM   CTHD
    WHERE  MaSP = @MaSP;
END;
GO

-- Cách gọi:
-- DECLARE @SL INT;
-- EXEC sp_TongSoLuongBan_SP @MaSP = 'SP001', @TongSoLuong = @SL OUTPUT;
-- SELECT @SL AS TongSoLuong;


-- ----------------------------------------------------------------
-- BÀI 4: Trả về tên sản phẩm có đơn giá cao nhất (OUTPUT)
-- ----------------------------------------------------------------
CREATE PROCEDURE sp_TenSanPhamGiaCaoNhat
    -- Tham số OUTPUT chứa tên sản phẩm có giá cao nhất.
    @TenSP NVARCHAR(100) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- TOP 1 + ORDER BY DESC: lấy 1 bản ghi có DonGia lớn nhất.
    -- NẾU THIẾU TOP 1: câu lệnh lỗi vì không thể gán nhiều hàng vào 1 biến.
    -- NẾU THIẾU ORDER BY DonGia DESC: TOP 1 lấy ngẫu nhiên 1 sản phẩm,
    --   không đảm bảo là sản phẩm có giá cao nhất.
    SELECT TOP 1 @TenSP = TenSP
    FROM   SanPham
    ORDER BY DonGia DESC;
END;
GO

-- Cách gọi:
-- DECLARE @Ten NVARCHAR(100);
-- EXEC sp_TenSanPhamGiaCaoNhat @TenSP = @Ten OUTPUT;
-- SELECT @Ten AS SanPhamDatNhat;


-- ----------------------------------------------------------------
-- BÀI 5: Tổng doanh thu theo tháng/năm (OUTPUT)
-- ----------------------------------------------------------------
CREATE PROCEDURE sp_DoanhThu_Thang
    @Thang    INT,           -- Tham số đầu vào: tháng (1-12)
    @Nam      INT,           -- Tham số đầu vào: năm (vd: 2024)
    @DoanhThu MONEY OUTPUT   -- Tham số đầu ra: tổng doanh thu tháng đó
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @DoanhThu = ISNULL(SUM(cthd.SoLuong * cthd.DonGiaBan), 0)
    FROM   HoaDon hd
           -- JOIN HoaDon với CTHD để lấy chi tiết từng dòng hàng.
           -- NẾU THIẾU JOIN với CTHD: không có SoLuong, DonGiaBan → lỗi biên dịch.
           INNER JOIN CTHD cthd ON hd.MaHD = cthd.MaHD
    -- MONTH() và YEAR(): tách phần tháng và năm từ cột NgayLap.
    -- NẾU THIẾU điều kiện MONTH/YEAR: tính doanh thu toàn bộ, không lọc theo tháng/năm.
    WHERE  MONTH(hd.NgayLap) = @Thang
      AND  YEAR(hd.NgayLap)  = @Nam;
END;
GO

-- Cách gọi:
-- DECLARE @DT MONEY;
-- EXEC sp_DoanhThu_Thang @Thang = 4, @Nam = 2024, @DoanhThu = @DT OUTPUT;
-- SELECT @DT AS DoanhThuThang4_2024;


-- ================================================================
-- PHẦN 3: TRANSACTION
-- ================================================================

-- ----------------------------------------------------------------
-- BÀI 1: Thêm khách hàng mới VÀ hóa đơn đầu tiên (all-or-nothing)
-- ----------------------------------------------------------------
BEGIN TRANSACTION Tran_ThemKH_Va_HoaDon;
    BEGIN TRY
        -- Bước 1: Thêm khách hàng mới vào bảng KhachHang.
        -- NẾU DÒNG NÀY THẤT BẠI (vd trùng MaKH): CATCH sẽ ROLLBACK
        --   toàn bộ → hóa đơn cũng không được thêm → đảm bảo nhất quán.
        INSERT INTO KhachHang (MaKH, TenKH, DiaChi, DienThoai)
        VALUES ('KH999', N'Nguyễn Văn A', N'123 Đường ABC, TP.HCM', '0900123456');

        -- Bước 2: Thêm hóa đơn đầu tiên cho khách hàng vừa tạo.
        -- GETDATE(): lấy ngày giờ hiện tại làm ngày lập hóa đơn.
        -- NẾU THIẾU dòng này: chỉ tạo khách hàng mà không có hóa đơn,
        --   không đúng yêu cầu bài.
        INSERT INTO HoaDon (MaHD, MaKH, NgayLap)
        VALUES ('HD999', 'KH999', GETDATE());

        -- COMMIT: xác nhận và lưu vĩnh viễn cả 2 thao tác INSERT.
        -- NẾU THIẾU COMMIT: transaction vẫn mở, dữ liệu bị khóa (lock)
        --   → các session khác không đọc/ghi được → deadlock tiềm ẩn.
        COMMIT TRANSACTION Tran_ThemKH_Va_HoaDon;
        PRINT 'Thêm khách hàng và hóa đơn thành công.';
    END TRY
    BEGIN CATCH
        -- ROLLBACK: hủy toàn bộ nếu bất kỳ bước nào gặp lỗi.
        -- NẾU THIẾU ROLLBACK: transaction treo ở trạng thái lỗi,
        --   tiếp tục giữ lock → nghẽn hệ thống.
        ROLLBACK TRANSACTION Tran_ThemKH_Va_HoaDon;
        PRINT 'Lỗi: ' + ERROR_MESSAGE();
    END CATCH;
GO


-- ----------------------------------------------------------------
-- BÀI 2: Giảm giá 10% sản phẩm 'Laptop', cập nhật DonGiaBan trong CTHD.
--         ROLLBACK nếu giá sau khi giảm < 500.
-- ----------------------------------------------------------------
BEGIN TRANSACTION Tran_GiamGia_Laptop;
    BEGIN TRY
        -- Bước 1: Tính giá mới = 90% giá gốc.
        DECLARE @GiaMoi MONEY;
        SELECT @GiaMoi = DonGia * 0.9
        FROM   SanPham
        WHERE  TenSP = N'Laptop';

        -- Bước 2: Kiểm tra ràng buộc nghiệp vụ - giá không được < 500.
        -- RAISERROR với severity 16 sẽ nhảy sang CATCH.
        -- NẾU THIẾU KIỂM TRA NÀY: giá có thể bị cập nhật xuống dưới 500,
        --   vi phạm quy tắc kinh doanh mà không có cảnh báo.
        IF @GiaMoi < 500
        BEGIN
            RAISERROR(N'Giá sau khi giảm nhỏ hơn 500. Hủy giao dịch.', 16, 1);
        END;

        -- Bước 3: Cập nhật giá trong bảng SanPham.
        -- NẾU THIẾU: bảng SanPham không được cập nhật → dữ liệu gốc không thay đổi.
        UPDATE SanPham
        SET    DonGia = @GiaMoi
        WHERE  TenSP = N'Laptop';

        -- Bước 4: Cập nhật DonGiaBan trong CTHD để đồng bộ với giá mới.
        -- NẾU THIẾU: CTHD vẫn giữ giá cũ → mất đồng bộ dữ liệu giữa hai bảng.
        UPDATE cthd
        SET    cthd.DonGiaBan = @GiaMoi
        FROM   CTHD cthd
               INNER JOIN SanPham sp ON cthd.MaSP = sp.MaSP
        WHERE  sp.TenSP = N'Laptop';

        COMMIT TRANSACTION Tran_GiamGia_Laptop;
        PRINT N'Cập nhật giá Laptop thành công. Giá mới: ' + CAST(@GiaMoi AS NVARCHAR);
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION Tran_GiamGia_Laptop;
        PRINT 'Lỗi: ' + ERROR_MESSAGE();
    END CATCH;
GO


-- ----------------------------------------------------------------
-- BÀI 3: Xóa hóa đơn an toàn (xóa CTHD trước, rồi mới xóa HoaDon)
-- ----------------------------------------------------------------
DECLARE @MaHD_Xoa CHAR(5) = 'HD001'; -- Khai báo mã hóa đơn cần xóa

BEGIN TRANSACTION Tran_XoaHoaDon;
    BEGIN TRY
        -- Bước 1: Xóa tất cả dòng chi tiết trong CTHD trước.
        -- NẾU THIẾU BƯỚC NÀY và bảng có FOREIGN KEY: SQL Server sẽ báo lỗi
        --   "The DELETE statement conflicted with the REFERENCE constraint"
        --   → xóa HoaDon thất bại khi CTHD còn dữ liệu.
        -- NẾU THIẾU và không có FK: xóa HoaDon thành công nhưng CTHD còn lại
        --   → dữ liệu mồ côi (orphan records), vi phạm toàn vẹn dữ liệu.
        DELETE FROM CTHD
        WHERE  MaHD = @MaHD_Xoa;

        -- Bước 2: Sau khi CTHD đã được dọn sạch, mới xóa HoaDon cha.
        DELETE FROM HoaDon
        WHERE  MaHD = @MaHD_Xoa;

        COMMIT TRANSACTION Tran_XoaHoaDon;
        PRINT N'Xóa hóa đơn ' + @MaHD_Xoa + N' thành công.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION Tran_XoaHoaDon;
        PRINT 'Lỗi: ' + ERROR_MESSAGE();
    END CATCH;
GO


-- ----------------------------------------------------------------
-- BÀI 4: Chuyển mặt hàng từ hóa đơn HD101 sang HD102
-- ----------------------------------------------------------------
DECLARE @MaSP_Chuyen   CHAR(5) = 'SP001'; -- Mã sản phẩm cần chuyển
DECLARE @SoLuong_Chuyen INT;               -- Biến lưu số lượng tạm thời
DECLARE @Gia            MONEY;             -- Biến lưu đơn giá tạm thời

BEGIN TRANSACTION Tran_ChuyenHangHoa;
    BEGIN TRY
        -- Bước 1: Đọc số lượng và đơn giá từ hóa đơn nguồn (HD101).
        -- NẾU THIẾU: biến @SoLuong_Chuyen và @Gia = NULL → INSERT sau này
        --   sẽ ghi NULL vào CTHD, vi phạm NOT NULL constraint (nếu có).
        SELECT @SoLuong_Chuyen = cthd.SoLuong,
               @Gia            = cthd.DonGiaBan
        FROM   CTHD cthd
        WHERE  cthd.MaHD = 'HD101'
          AND  cthd.MaSP = @MaSP_Chuyen;

        -- Kiểm tra sản phẩm tồn tại trong HD101 trước khi thực hiện.
        IF @SoLuong_Chuyen IS NULL
        BEGIN
            RAISERROR(N'Sản phẩm không tồn tại trong hóa đơn HD101.', 16, 1);
        END;

        -- Bước 2: Xóa sản phẩm khỏi hóa đơn nguồn HD101.
        -- NẾU THIẾU: sản phẩm vẫn còn ở HD101 trong khi đã được thêm vào HD102
        --   → trùng lặp dữ liệu, sai nghiệp vụ "chuyển".
        DELETE FROM CTHD
        WHERE  MaHD = 'HD101'
          AND  MaSP = @MaSP_Chuyen;

        -- Bước 3: Thêm vào HD102 (nếu đã tồn tại thì cộng số lượng,
        --         chưa tồn tại thì INSERT mới).
        -- NẾU THIẾU kiểm tra EXISTS: INSERT trùng khóa chính (MaHD, MaSP)
        --   → lỗi constraint violation.
        IF EXISTS (SELECT 1 FROM CTHD WHERE MaHD = 'HD102' AND MaSP = @MaSP_Chuyen)
        BEGIN
            -- Cộng thêm số lượng nếu sản phẩm đã có sẵn trong HD102.
            UPDATE CTHD
            SET    SoLuong = SoLuong + @SoLuong_Chuyen
            WHERE  MaHD = 'HD102'
              AND  MaSP = @MaSP_Chuyen;
        END
        ELSE
        BEGIN
            -- Thêm mới dòng nếu sản phẩm chưa có trong HD102.
            INSERT INTO CTHD (MaHD, MaSP, SoLuong, DonGiaBan)
            VALUES ('HD102', @MaSP_Chuyen, @SoLuong_Chuyen, @Gia);
        END;

        COMMIT TRANSACTION Tran_ChuyenHangHoa;
        PRINT N'Chuyển hàng hóa từ HD101 sang HD102 thành công.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION Tran_ChuyenHangHoa;
        PRINT 'Lỗi: ' + ERROR_MESSAGE();
    END CATCH;
GO


-- ================================================================
-- PHẦN 4: TRIGGER
-- ================================================================

-- ----------------------------------------------------------------
-- BÀI 1: trg_CheckDonGia - Ngăn chặn DonGia < 0 trên bảng SanPham
-- ----------------------------------------------------------------
CREATE TRIGGER trg_CheckDonGia
ON   SanPham
-- AFTER INSERT, UPDATE: trigger kích hoạt SAU khi INSERT hoặc UPDATE xảy ra.
-- NẾU DÙNG INSTEAD OF: phải tự thực hiện lại thao tác INSERT/UPDATE bên trong
--   trigger, phức tạp hơn không cần thiết.
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Bảng 'inserted' (virtual table): chứa các hàng vừa được INSERT hoặc UPDATE.
    -- NẾU THIẾU kiểm tra từ 'inserted': trigger không kiểm tra được giá trị mới
    --   → hàng có DonGia âm vẫn được lưu vào bảng.
    IF EXISTS (SELECT 1 FROM inserted WHERE DonGia < 0)
    BEGIN
        -- RAISERROR: thông báo lỗi cho người dùng / ứng dụng.
        RAISERROR(N'Lỗi: DonGia không được nhỏ hơn 0.', 16, 1);
        -- ROLLBACK: hủy toàn bộ thao tác INSERT/UPDATE gây ra trigger.
        -- NẾU THIẾU ROLLBACK: lỗi được thông báo nhưng hàng sai vẫn được lưu
        --   → dữ liệu không hợp lệ trong bảng.
        ROLLBACK TRANSACTION;
    END;
END;
GO

-- Kiểm tra trigger (sẽ bị hủy):
-- INSERT INTO SanPham VALUES ('SP999', N'Test', -100);


-- ----------------------------------------------------------------
-- BÀI 2: trg_DefaultDonGiaBan - Tự động điền DonGiaBan từ SanPham
--         khi người dùng để trống hoặc bằng 0
-- ----------------------------------------------------------------
CREATE TRIGGER trg_DefaultDonGiaBan
ON   CTHD
-- INSTEAD OF INSERT: thay thế hoàn toàn lệnh INSERT gốc.
-- Cho phép kiểm tra và sửa dữ liệu TRƯỚC khi ghi vào bảng.
-- NẾU DÙNG AFTER INSERT: dữ liệu đã ghi rồi mới sửa → tốn thêm 1 lần UPDATE,
--   cũng có thể vi phạm NOT NULL constraint trong lúc INSERT.
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Thực hiện INSERT thực sự với giá trị DonGiaBan đã được kiểm tra/sửa.
    INSERT INTO CTHD (MaHD, MaSP, SoLuong, DonGiaBan)
    SELECT
        i.MaHD,
        i.MaSP,
        i.SoLuong,
        -- CASE WHEN: nếu DonGiaBan = NULL hoặc = 0 thì lấy DonGia từ SanPham,
        --            ngược lại giữ nguyên giá trị người dùng nhập.
        -- NẾU THIẾU CASE: DonGiaBan = NULL/0 vẫn được ghi vào → sai nghiệp vụ.
        CASE
            WHEN i.DonGiaBan IS NULL OR i.DonGiaBan = 0
                THEN sp.DonGia   -- Lấy giá chính thức từ bảng SanPham
            ELSE i.DonGiaBan     -- Giữ nguyên giá người dùng nhập
        END AS DonGiaBan
    -- Bảng 'inserted': chứa dữ liệu mà người dùng cố gắng INSERT.
    FROM inserted i
    -- LEFT JOIN: nếu MaSP không tồn tại trong SanPham, sp.DonGia = NULL
    --   → DonGiaBan sẽ = NULL (trường hợp người dùng nhập MaSP sai).
    -- NẾU DÙNG INNER JOIN: dòng CTHD sẽ bị bỏ qua nếu MaSP không tồn tại
    --   trong SanPham → mất dữ liệu silently.
    LEFT JOIN SanPham sp ON i.MaSP = sp.MaSP;
END;
GO


-- ----------------------------------------------------------------
-- BÀI 3: Ngăn xóa khách hàng đã có hóa đơn
-- ----------------------------------------------------------------
CREATE TRIGGER trg_PreventDeleteKhachHang
ON   KhachHang
-- INSTEAD OF DELETE: chặn lệnh DELETE gốc, xử lý điều kiện trước.
-- NẾU DÙNG AFTER DELETE: hàng đã bị xóa rồi mới kiểm tra → không thể khôi phục
--   nếu ROLLBACK quên viết; dữ liệu tạm thời bị mất trong transaction.
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Bảng 'deleted': chứa các hàng sắp bị xóa.
    -- Kiểm tra xem khách hàng bị xóa có hóa đơn nào không.
    -- NẾU THIẾU kiểm tra này: trigger cho phép xóa mọi khách hàng
    --   dù họ đã có hóa đơn → vi phạm toàn vẹn nghiệp vụ.
    IF EXISTS (
        SELECT 1
        FROM   HoaDon hd
               INNER JOIN deleted d ON hd.MaKH = d.MaKH
    )
    BEGIN
        RAISERROR(N'Không thể xóa khách hàng đã có hóa đơn trong hệ thống.', 16, 1);
        -- RETURN: dừng trigger, lệnh DELETE bị hủy (không cần ROLLBACK vì INSTEAD OF).
        RETURN;
    END;

    -- Nếu không có hóa đơn, cho phép xóa bình thường.
    -- NẾU THIẾU dòng DELETE này: khách hàng hợp lệ (không có HD) cũng không thể xóa
    --   → trigger chặn toàn bộ lệnh DELETE, kể cả hợp lệ.
    DELETE FROM KhachHang
    WHERE MaKH IN (SELECT MaKH FROM deleted);
END;
GO

-- Kiểm tra: xóa khách hàng đã có hóa đơn (sẽ báo lỗi):
-- DELETE FROM KhachHang WHERE MaKH = 'KH001';


-- ----------------------------------------------------------------
-- BÀI 4: Tự động cập nhật NgayLap = GETDATE() khi sửa hóa đơn
-- ----------------------------------------------------------------
CREATE TRIGGER trg_UpdateNgayLap_OnHoaDon
ON   HoaDon
-- AFTER UPDATE: chỉ kích hoạt khi có lệnh UPDATE, không ảnh hưởng INSERT.
-- NẾU DÙNG AFTER INSERT, UPDATE: NgayLap sẽ bị ghi đè ngay cả khi INSERT
--   → người dùng không thể tự đặt ngày lập ban đầu.
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Cập nhật NgayLap về thời điểm hiện tại cho các hàng vừa được UPDATE.
    -- JOIN với bảng 'inserted' để chỉ cập nhật đúng các hàng bị ảnh hưởng.
    -- NẾU THIẾU JOIN inserted: UPDATE toàn bộ bảng HoaDon → sai, mọi hóa đơn
    --   đều bị đổi NgayLap.
    -- NẾU DÙNG GETUTCDATE(): lưu giờ UTC, không phải giờ địa phương → có thể
    --   gây nhầm lẫn khi hiển thị trong giao diện theo giờ Việt Nam (UTC+7).
    UPDATE hd
    SET    NgayLap = GETDATE()
    FROM   HoaDon hd
           INNER JOIN inserted i ON hd.MaHD = i.MaHD;
END;
GO


-- ----------------------------------------------------------------
-- BÀI 5: Tự động xóa HoaDon khi CTHD không còn sản phẩm nào
-- ----------------------------------------------------------------
CREATE TRIGGER trg_DeleteHoaDon_WhenEmpty
ON   CTHD
-- AFTER DELETE: kích hoạt SAU khi dòng CTHD đã bị xóa.
-- NẾU DÙNG INSTEAD OF DELETE: phải tự thực hiện lại DELETE trên CTHD bên trong
--   trigger → phức tạp không cần thiết.
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Bảng 'deleted': chứa các dòng CTHD vừa bị xóa (lưu MaHD để kiểm tra).
    -- LEFT JOIN CTHD với MaHD từ 'deleted': nếu cthd.MaHD IS NULL tức là
    --   không còn dòng nào trong CTHD cho hóa đơn đó → hóa đơn rỗng → xóa.
    -- NẾU THIẾU điều kiện cthd.MaHD IS NULL: sẽ xóa hóa đơn ngay cả khi
    --   còn sản phẩm khác → mất dữ liệu.
    -- NẾU THIẾU điều kiện IN (SELECT MaHD FROM deleted): xóa TẤT CẢ hóa đơn
    --   rỗng trong toàn bộ database, không chỉ các hóa đơn liên quan → rất nguy hiểm.
    DELETE hd
    FROM   HoaDon hd
           LEFT JOIN CTHD cthd ON hd.MaHD = cthd.MaHD
    WHERE  cthd.MaHD IS NULL  -- Hóa đơn không còn dòng nào trong CTHD
      AND  hd.MaHD IN (SELECT DISTINCT MaHD FROM deleted); -- Chỉ HD liên quan
END;
GO

-- Kiểm tra: xóa sản phẩm cuối cùng trong HD001 → HD001 tự động bị xóa:
-- DELETE FROM CTHD WHERE MaHD = 'HD001' AND MaSP = 'SP001'; -- (nếu đây là SP cuối)
