/*
Bài tập ngày 
Mã số sinh viên: 
*/



--Phần: Transaction

--1. Viết thủ tục (có Transaction) thực hiện việc thêm một khách hàng mới và đồng thời thêm một hóa đơn đầu tiên cho khách hàng đó. Nếu một trong hai lệnh lỗi thì hủy bỏ toàn bộ.
CREATE PROCEDURE sp_ThemKhachHang_HoaDon
    @MaKH INT,
    @HoTenKH NVARCHAR(100),
    @SoDTKH VARCHAR(20),
    @EmailKH VARCHAR(100),
    @MaHD INT,
    @NgayLapHD DATE
AS
BEGIN
    -- Bắt đầu giao dịch để đảm bảo tính toàn vẹn dữ liệu
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Thêm thông tin khách hàng mới vào bảng KhachHang
        INSERT INTO KhachHang (MaKH, HoTenKH, SoDTKH, EmailKH)
        VALUES (@MaKH, @HoTenKH, @SoDTKH, @EmailKH);

        -- Thêm hóa đơn đầu tiên cho khách hàng mới vừa tạo vào bảng HoaDon
        INSERT INTO HoaDon (MaHD, MaKH, NgayLapHD)
        VALUES (@MaHD, @MaKH, @NgayLapHD);

        -- Nếu cả 2 lệnh insert đều thành công thì xác nhận giao dịch (lưu thay đổi vào CSDL)
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Nếu có bất kỳ lỗi nào xảy ra ở 1 trong 2 lệnh trên thì hủy bỏ toàn bộ giao dịch (khôi phục trạng thái ban đầu)
        ROLLBACK TRANSACTION;
    END CATCH
END;
GO



--2. Viết thủ tục (có Transaction) để cập nhật giảm giá 10% cho sản phẩm 'Laptop', đồng thời cập nhật lại đơn giá bán trong bảng CTHD cho sản phẩm này. Sử dụng ROLLBACK nếu giá sau khi giảm nhỏ hơn 500.
CREATE PROCEDURE sp_GiamGiaLaptop
AS
BEGIN
    -- Khai báo biến để lưu mã sản phẩm và giá sau khi giảm
    DECLARE @MaSP INT;
    DECLARE @GiaMoi DECIMAL(10,2);

    -- Bắt đầu giao dịch
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Lấy mã sản phẩm của 'Laptop'
        SELECT @MaSP = MaSP FROM SanPham WHERE TenSP = 'Laptop';
        
        -- Cập nhật giảm giá 10% cho sản phẩm 'Laptop' trong bảng SanPham
        UPDATE SanPham
        SET DonGia = DonGia * 0.9
        WHERE MaSP = @MaSP;

        -- Cập nhật lại đơn giá bán trong bảng CTHD cho sản phẩm 'Laptop' tương ứng
        UPDATE CTHD
        SET DonGiaBan = DonGiaBan * 0.9
        WHERE MaSP = @MaSP;

        -- Lấy giá mới của sản phẩm 'Laptop' sau khi đã cập nhật giảm giá
        SELECT @GiaMoi = DonGia FROM SanPham WHERE MaSP = @MaSP;

        -- Kiểm tra điều kiện: nếu giá sau khi giảm nhỏ hơn 500 thì hủy bỏ toàn bộ giao dịch
        IF (@GiaMoi < 500)
        BEGIN
            -- Hủy bỏ giao dịch vì vi phạm điều kiện
            ROLLBACK TRANSACTION;
            -- In ra thông báo lỗi cho người dùng biết
            PRINT N'Lỗi: Giá sau khi giảm nhỏ hơn 500. Giao dịch đã bị hủy.';
        END
        ELSE
        BEGIN
            -- Nếu giá >= 500 thỏa mãn điều kiện thì xác nhận giao dịch (lưu thay đổi vào CSDL)
            COMMIT TRANSACTION;
        END
    END TRY
    BEGIN CATCH
        -- Hủy bỏ giao dịch nếu có bất kỳ lỗi hệ thống nào xảy ra trong quá trình thực thi
        ROLLBACK TRANSACTION;
    END CATCH
END;
GO



--3. Viết thủ tục (có Transaction) thực hiện xóa một hóa đơn: Trước tiên xóa dữ liệu trong CTHD, sau đó xóa trong HoaDon. Đảm bảo tính toàn vẹn dữ liệu.
CREATE PROCEDURE sp_XoaHoaDon
    @MaHD INT
AS
BEGIN
    -- Bắt đầu giao dịch để đảm bảo tính nhất quán giữa 2 bảng
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Trước tiên phải xóa dữ liệu chi tiết hóa đơn trong bảng CTHD (vì bảng này chứa khóa ngoại tham chiếu đến HoaDon)
        DELETE FROM CTHD WHERE MaHD = @MaHD;

        -- Sau khi xóa hết chi tiết, tiến hành xóa hóa đơn trong bảng HoaDon
        DELETE FROM HoaDon WHERE MaHD = @MaHD;

        -- Nếu cả 2 lệnh xóa đều thành công thì xác nhận giao dịch
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Nếu có bất kỳ lỗi nào xảy ra thì hủy bỏ toàn bộ quá trình xóa, tránh trường hợp xóa lỡ dở
        ROLLBACK TRANSACTION;
    END CATCH
END;
GO



--4. Viết thủ tục (có Transaction) thực hiện chuyển một mặt hàng từ hóa đơn 101 sang hóa đơn 102 (Xóa ở 101, Thêm vào 102).
CREATE PROCEDURE sp_ChuyenMatHang
    @MaHD_Cu INT, -- Tham số hóa đơn cũ (vd: 101)
    @MaHD_Moi INT, -- Tham số hóa đơn mới (vd: 102)
    @MaSP INT -- Mã mặt hàng cần chuyển
AS
BEGIN
    -- Khai báo các biến để lưu thông tin mặt hàng chuẩn bị chuyển (số lượng, đơn giá bán)
    DECLARE @SoLuong INT, @DonGiaBan DECIMAL(10,2);
    -- Khai báo biến để lưu mã khách hàng của hóa đơn mới
    DECLARE @MaKH_Moi INT;

    -- Bắt đầu giao dịch
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Lấy thông tin (số lượng, đơn giá bán) của mặt hàng cần chuyển từ hóa đơn cũ
        SELECT @SoLuong = SoLuong, @DonGiaBan = DonGiaBan 
        FROM CTHD 
        WHERE MaHD = @MaHD_Cu AND MaSP = @MaSP;

        -- Lấy mã khách hàng của hóa đơn mới để lưu vào bảng CTHD
        SELECT @MaKH_Moi = MaKH
        FROM HoaDon
        WHERE MaHD = @MaHD_Moi;

        -- Thực hiện thêm mặt hàng đó vào hóa đơn mới với thông tin đã lấy được ở trên
        INSERT INTO CTHD (MaHD, MaKH, MaSP, SoLuong, DonGiaBan)
        VALUES (@MaHD_Moi, @MaKH_Moi, @MaSP, @SoLuong, @DonGiaBan);

        -- Sau khi thêm thành công vào hóa đơn mới, tiến hành xóa mặt hàng đó khỏi hóa đơn cũ
        DELETE FROM CTHD 
        WHERE MaHD = @MaHD_Cu AND MaSP = @MaSP;

        -- Nếu quá trình thêm và xóa đều diễn ra suôn sẻ, không có lỗi thì xác nhận giao dịch
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Nếu có lỗi xảy ra ở bất kỳ bước nào thì hủy bỏ toàn bộ quá trình chuyển, khôi phục lại như cũ
        ROLLBACK TRANSACTION;
    END CATCH
END;
GO
