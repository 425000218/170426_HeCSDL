-- ==================================================
-- DỰ ÁN: SEB_sub - Quản lý mượn trả thiết bị trường học
-- NHÓM THỰC HIỆN: Đặng Bắc Nam (425000218) & Lò Văn Duẩn (525000631)
-- ==================================================

CREATE DATABASE SEB_sub_DB;
GO

USE SEB_sub_DB;
GO

-- ==================================================
-- PHẦN 1: CẤU TRÚC 8 BẢNG (Kèm Ràng buộc toàn vẹn)
-- ==================================================

-- 1. Bảng Phân Quyền (Tách riêng để bảo mật)
CREATE TABLE PhanQuyen (
    MaQuyen INT PRIMARY KEY,
    TenQuyen NVARCHAR(50) NOT NULL -- VD: Admin, Sinh viên
);

-- 2. Bảng Người Dùng (Gốc rễ hệ thống)
CREATE TABLE NguoiDung (
    MaND VARCHAR(20) PRIMARY KEY, -- Chính là MSSV hoặc Mã GV
    HoTen NVARCHAR(100) NOT NULL,
    MaQuyen INT NOT NULL,
    SDT VARCHAR(15),
    Lop VARCHAR(50),
    FOREIGN KEY (MaQuyen) REFERENCES PhanQuyen(MaQuyen)
);

-- 3. Bảng Loại Thiết Bị (Danh mục cha)
CREATE TABLE LoaiThietBi (
    MaLoai INT PRIMARY KEY,
    TenLoai NVARCHAR(100) NOT NULL
);

-- 4. Bảng Thiết Bị (Quản lý kho)
CREATE TABLE ThietBi (
    MaTB VARCHAR(20) PRIMARY KEY,
    TenTB NVARCHAR(100) NOT NULL,
    MaLoai INT NOT NULL,
    SoLuongTon INT NOT NULL CHECK (SoLuongTon >= 0), -- Ràng buộc không cho phép tồn kho âm
    TrangThai NVARCHAR(50) DEFAULT N'Sẵn sàng', 
    FOREIGN KEY (MaLoai) REFERENCES LoaiThietBi(MaLoai)
);

-- 5. Bảng Phiếu Mượn (Giao dịch cốt lõi)
CREATE TABLE PhieuMuon (
    MaPhieu INT IDENTITY(1,1) PRIMARY KEY, -- Tự động tăng
    MaND VARCHAR(20) NOT NULL,
    NgayMuon DATETIME DEFAULT GETDATE(),
    NgayHenTra DATETIME NOT NULL,
    TrangThaiPhieu NVARCHAR(50) DEFAULT N'Đang mượn', -- Đang mượn, Đã trả xong, Quá hạn
    FOREIGN KEY (MaND) REFERENCES NguoiDung(MaND),
    CONSTRAINT CHK_NgayTra_NgayMuon CHECK (CAST(NgayHenTra AS DATE) >= CAST(NgayMuon AS DATE))
);

-- 6. Bảng Chi Tiết Mượn (Một phiếu mượn có thể mượn nhiều món)
CREATE TABLE ChiTietMuon (
    MaPhieu INT NOT NULL,
    MaTB VARCHAR(20) NOT NULL,
    SoLuongMuon INT NOT NULL CHECK (SoLuongMuon > 0),
    TinhTrangTruocMuon NVARCHAR(200),
    PRIMARY KEY (MaPhieu, MaTB),
    FOREIGN KEY (MaPhieu) REFERENCES PhieuMuon(MaPhieu),
    FOREIGN KEY (MaTB) REFERENCES ThietBi(MaTB)
);

-- 7. Bảng Nhật Ký Trả
CREATE TABLE NhatKyTra (
    MaTra INT IDENTITY(1,1) PRIMARY KEY,
    MaPhieu INT NOT NULL,
    NgayTraThucTe DATETIME DEFAULT GETDATE(),
    TienPhat DECIMAL(18,2) DEFAULT 0, -- Tính phí nếu mượn trễ hoặc làm hỏng
    GhiChu NVARCHAR(200),
    FOREIGN KEY (MaPhieu) REFERENCES PhieuMuon(MaPhieu)
);

-- 8. Bảng Nhật Ký Hệ Thống (Audit Log - Dành cho bảo mật và Trigger)
CREATE TABLE NhatKyHeThong (
    MaLog INT IDENTITY(1,1) PRIMARY KEY,
    ThoiGian DATETIME DEFAULT GETDATE(),
    HanhDong VARCHAR(50) NOT NULL, -- INSERT, UPDATE, DELETE
    TenBang VARCHAR(50) NOT NULL,
    ChiTiet NVARCHAR(MAX) -- Mô tả thao tác gì đã diễn ra
);
GO

-- ==================================================
-- PHẦN 2: ĐỔ DỮ LIỆU MẪU (MOCK DATA)
-- ==================================================

INSERT INTO PhanQuyen (MaQuyen, TenQuyen) VALUES 
(1, N'Admin'),
(2, N'Sinh Viên');

INSERT INTO NguoiDung (MaND, HoTen, MaQuyen, SDT, Lop) VALUES 
('ADMIN01', N'Nguyễn Trưởng Phòng', 1, '0969696969', 'Ban Quan Ly'),
('425000218', N'Đặng Bắc Nam', 2, '0378047778', '25CT401'),
('525000631', N'Lò Văn Duẩn', 2, '0366225559', '25CT501');

INSERT INTO LoaiThietBi (MaLoai, TenLoai) VALUES 
(1, N'Máy chiếu'), 
(2, N'Dây cáp kết nối'), 
(3, N'Âm thanh');

INSERT INTO ThietBi (MaTB, TenTB, MaLoai, SoLuongTon, TrangThai) VALUES 
('MC01', N'Máy chiếu Panasonic', 1, 5, N'Sẵn sàng'),
('CAP-HDMI', N'Cáp HDMI 2 mét', 2, 20, N'Sẵn sàng'),
('LOA-01', N'Loa kéo tay Bluetooth', 3, 2, N'Sẵn sàng');
GO

-- ==================================================
-- PHẦN 3: STORED PROCEDURE NÂNG CAO (Có dùng TRANSACTION)
-- Câu hỏi bảo vệ: Tại sao phải dùng BEGIN TRAN?
-- Trả lời: Nếu tạo phiếu xong mà chi tiết mượn bị lỗi (do rớt mạng), 
-- thì hủy phiếu để không bị tạo dữ liệu rác.
-- ==================================================
CREATE PROCEDURE sp_TaoPhieuMuon
    @MaND VARCHAR(20),
    @NgayHenTra DATETIME,
    @MaTB VARCHAR(20),
    @SoLuongMuon INT,
    @TinhTrangTruocMuon NVARCHAR(200)
AS
BEGIN
    -- Bắt đầu giao dịch bảo vệ toàn vẹn dữ liệu
    BEGIN TRANSACTION;
    BEGIN TRY
        -- 1. Lưu hóa đơn (Tạo Phiếu Mượn)
        DECLARE @MaPhieuMoi INT;
        INSERT INTO PhieuMuon (MaND, NgayHenTra)
        VALUES (@MaND, @NgayHenTra);
        
        -- Lấy mã phiếu vừa được tự động sinh ra (IDENTITY)
        SET @MaPhieuMoi = SCOPE_IDENTITY();

        -- 2. Thêm Chi tiết thiết bị mượn vào phiếu
        INSERT INTO ChiTietMuon (MaPhieu, MaTB, SoLuongMuon, TinhTrangTruocMuon)
        VALUES (@MaPhieuMoi, @MaTB, @SoLuongMuon, @TinhTrangTruocMuon);

        -- 3. Trừ đi số lượng tồn kho của thiết bị
        UPDATE ThietBi
        SET SoLuongTon = SoLuongTon - @SoLuongMuon
        WHERE MaTB = @MaTB;

        -- Xác nhận thành công tất cả 3 bước
        COMMIT TRANSACTION;
        PRINT N'Tuyệt vời! Tạo phiếu mượn thành công.';
    END TRY
    BEGIN CATCH
        -- Hủy bỏ nếu có bất kỳ lỗi nào (Ví dụ: trigger bên dưới chặn lại do hết hàng)
        ROLLBACK TRANSACTION;
        PRINT N'LỖI: Giao dịch bị hủy do lỗi logic hoặc hệ thống.';
    END CATCH
END;
GO

-- ==================================================
-- PHẦN 4: TRIGGER BẪY LỖI & BẢO MẬT (Để show off kỹ năng với Cô)
-- ==================================================

-- Trigger 1: Bẫy lỗi logic nghiệp vụ
-- Ngăn chặn sinh viên mượn đồ nếu Số lượng mượn > Số lượng tồn kho đang có
CREATE TRIGGER trg_CheckSoLuongMuon
ON ChiTietMuon
FOR INSERT
AS
BEGIN
    DECLARE @SoLuongTon INT;
    DECLARE @SoLuongMuon INT;
    DECLARE @MaTB VARCHAR(20);

    SELECT @MaTB = MaTB, @SoLuongMuon = SoLuongMuon FROM inserted;
    SELECT @SoLuongTon = SoLuongTon FROM ThietBi WHERE MaTB = @MaTB;

    IF (@SoLuongMuon > @SoLuongTon)
    BEGIN
        -- Quăng lỗi chính thức để nhảy xuống khối CATCH của Procedure
        RAISERROR(N'Số lượng mượn vượt quá số lượng tồn kho hiện tại. Không thể mượn!', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- Trigger 2: Bảo mật hệ thống (Audit Log)
-- Nếu có ai đó cố tình UPDATE thông tin người dùng, hệ thống ngầm ghi lại lịch sử
CREATE TRIGGER trg_LogNguoiDung_Update
ON NguoiDung
AFTER UPDATE
AS
BEGIN
    -- Sử dụng bảng ảo 'deleted' (thông tin cũ) và 'inserted' (thông tin mới)
    DECLARE @MaND VARCHAR(20), @HoTenCu NVARCHAR(100), @HoTenMoi NVARCHAR(100);
    SELECT @MaND = MaND, @HoTenCu = HoTen FROM deleted;
    SELECT @HoTenMoi = HoTen FROM inserted;

    DECLARE @ChiTiet NVARCHAR(MAX);
    SET @ChiTiet = N'Sửa tên người dùng [' + @MaND + '] từ "' + @HoTenCu + N'" thành "' + @HoTenMoi + N'"';

    INSERT INTO NhatKyHeThong (HanhDong, TenBang, ChiTiet)
    VALUES ('UPDATE', 'NguoiDung', @ChiTiet);
END;
GO

-- ==================================================
-- PHẦN 5: STORED PROCEDURE CHUYỂN NHƯỢNG (CASE 3)
-- Minh chứng cho Transaction chuyển dữ liệu 2 bảng nhưng không đổi tồn kho
-- ==================================================
CREATE PROCEDURE sp_ChuyenNhuongThietBi
    @MaPhieuCu INT,
    @MaNDMoi VARCHAR(20)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        -- 1. Đóng phiếu cũ
        UPDATE PhieuMuon
        SET TrangThaiPhieu = N'Đã chuyển nhượng'
        WHERE MaPhieu = @MaPhieuCu;

        -- Lấy thông tin thiết bị và số lượng từ phiếu cũ
        DECLARE @MaTB VARCHAR(20);
        DECLARE @SoLuong INT;
        DECLARE @NgayHenTra DATETIME;
        SELECT TOP 1 @NgayHenTra = NgayHenTra FROM PhieuMuon WHERE MaPhieu = @MaPhieuCu;
        SELECT TOP 1 @MaTB = MaTB, @SoLuong = SoLuongMuon FROM ChiTietMuon WHERE MaPhieu = @MaPhieuCu;

        -- 2. Tạo phiếu mới cho người dùng mới
        DECLARE @MaPhieuMoi INT;
        INSERT INTO PhieuMuon (MaND, NgayHenTra)
        VALUES (@MaNDMoi, @NgayHenTra);
        SET @MaPhieuMoi = SCOPE_IDENTITY();

        -- 3. Thêm chi tiết cho phiếu mới
        INSERT INTO ChiTietMuon (MaPhieu, MaTB, SoLuongMuon)
        VALUES (@MaPhieuMoi, @MaTB, @SoLuong);

        COMMIT TRANSACTION;
        PRINT N'Chuyển nhượng thành công!';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT N'LỖI: Hủy giao dịch chuyển nhượng.';
    END CATCH
END;
GO
