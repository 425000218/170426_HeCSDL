/*
Bài tập ngày 08/05/2026
Mã số sinh viên: 425000218
*/

/* bài tập phần store procedure, trigger */

--Phần 4. Câu hỏi về Trigger

--1. Viết Trigger trg_CheckDonGia trên bảng SanPham để đảm bảo khi thêm mới hoặc cập nhật, đơn giá sản phẩm không được nhỏ hơn 0.
CREATE TRIGGER trg_CheckDonGia
ON SanPham
FOR INSERT, UPDATE -- Kích hoạt trigger khi có thao tác thêm mới hoặc cập nhật dữ liệu
AS
BEGIN
    -- Kiểm tra xem có dữ liệu nào vừa thêm/sửa mà Đơn Giá nhỏ hơn 0 hay không
    IF EXISTS (SELECT 1 FROM inserted WHERE DonGia < 0)
    BEGIN
        -- Nếu có, in ra thông báo lỗi cho người dùng
        RAISERROR(N'Đơn giá sản phẩm không được nhỏ hơn 0.', 16, 1);
        -- Hủy bỏ giao dịch (thao tác thêm/sửa sẽ không được thực hiện)
        ROLLBACK TRANSACTION;
    END
END;
GO

--2. Viết Trigger trên bảng CTHD sao cho khi một chi tiết hóa đơn được thêm vào, đơn giá bán (DonGiaBan) mặc định phải bằng DonGia trong bảng SanPham nếu người dùng để trống hoặc bằng 0.
CREATE TRIGGER trg_DefaultDonGiaBan
ON CTHD
AFTER INSERT -- Kích hoạt trigger sau khi dòng dữ liệu đã được thêm vào bảng CTHD
AS
BEGIN
    -- Cập nhật lại cột DonGiaBan trong bảng CTHD
    UPDATE CTHD
    SET DonGiaBan = sp.DonGia -- Gán bằng đơn giá gốc trong bảng SanPham
    FROM CTHD c
    INNER JOIN inserted i ON c.MaHD = i.MaHD AND c.MaSP = i.MaSP -- Kết nối với dữ liệu vừa được thêm (bảng tạm inserted)
    INNER JOIN SanPham sp ON i.MaSP = sp.MaSP -- Kết nối với bảng SanPham để lấy đơn giá gốc
    WHERE i.DonGiaBan IS NULL OR i.DonGiaBan = 0; -- Chỉ cập nhật nếu đơn giá bán người dùng nhập vào là rỗng hoặc bằng 0
END;
GO

--3. Viết Trigger ngăn chặn việc xóa khách hàng nếu khách hàng đó đã có ít nhất một hóa đơn trong hệ thống.
CREATE TRIGGER trg_PreventDeleteKhachHang
ON KhachHang
FOR DELETE -- Kích hoạt trigger khi có thao tác xóa dữ liệu
AS
BEGIN
    -- Kiểm tra xem khách hàng định xóa (trong bảng tạm deleted) đã có hóa đơn nào chưa
    IF EXISTS (
        SELECT 1
        FROM deleted d
        INNER JOIN HoaDon hd ON d.MaKH = hd.MaKH
    )
    BEGIN
        -- Nếu đã có hóa đơn, báo lỗi không cho phép xóa
        RAISERROR(N'Không thể xóa khách hàng đã có hóa đơn trong hệ thống.', 16, 1);
        -- Hủy bỏ giao dịch xóa
        ROLLBACK TRANSACTION;
    END
END;
GO

--4. Viết Trigger tự động cập nhật lại ngày lập hóa đơn thành ngày hiện tại (GETDATE()) mỗi khi có thao tác chỉnh sửa thông tin hóa đơn.
CREATE TRIGGER trg_UpdateNgayLapHD
ON HoaDon
AFTER UPDATE -- Kích hoạt sau khi người dùng cập nhật dữ liệu bảng HoaDon
AS
BEGIN
    -- Sử dụng hàm UPDATE(tên_cột) để tránh lặp vô tận nếu câu lệnh UPDATE bên dưới lại tự kích hoạt trigger này
    IF NOT UPDATE(NgayLapHD)
    BEGIN
        -- Cập nhật lại ngày lập hóa đơn bằng ngày giờ hiện tại của hệ thống (GETDATE())
        UPDATE HoaDon
        SET NgayLapHD = GETDATE()
        FROM HoaDon hd
        INNER JOIN inserted i ON hd.MaHD = i.MaHD; -- Chỉ cập nhật những hóa đơn vừa được chỉnh sửa
    END
END;
GO

--5. Viết Trigger trên bảng CTHD, khi xóa một sản phẩm khỏi hóa đơn, nếu hóa đơn đó không còn sản phẩm nào thì tự động xóa luôn hóa đơn đó trong bảng
CREATE TRIGGER trg_DeleteEmptyHoaDon
ON CTHD
AFTER DELETE -- Kích hoạt trigger sau khi xóa một dòng trong bảng CTHD
AS
BEGIN
    -- Xóa hóa đơn từ bảng HoaDon
    DELETE FROM HoaDon
    -- Lọc ra những mã hóa đơn nằm trong danh sách các chi tiết hóa đơn vừa bị xóa
    WHERE MaHD IN (SELECT DISTINCT MaHD FROM deleted)
    -- Và kiểm tra đảm bảo rằng mã hóa đơn đó hiện tại không còn bất kỳ dòng dữ liệu nào trong bảng CTHD nữa
    AND MaHD NOT IN (SELECT MaHD FROM CTHD);
END;
GO
