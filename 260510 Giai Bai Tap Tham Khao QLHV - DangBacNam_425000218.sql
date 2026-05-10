/*
Họ tên: Đặng Bắc Nam
Mã số sinh viên: 425000218
Ngày thực hiện: 2026-05-10
Bài tập: Giải bài tập tham khảo từ thư mục Tham_Khao (Quản lý Học viên - QLHV)
*/

-- ================================================================
-- PHẦN 1: THIẾT LẬP CSDL (Dựa trên cấu trúc Tham_Khao)
-- ================================================================

USE master;
GO
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'QLHV_Giai')
    DROP DATABASE QLHV_Giai;
GO
CREATE DATABASE QLHV_Giai;
GO
USE QLHV_Giai;
GO

-- 1. Bảng KhoaHoc
CREATE TABLE KhoaHoc (
    MaKH CHAR(10) PRIMARY KEY,
    TenKH NVARCHAR(100) NOT NULL,
    BatDau SMALLDATETIME NULL,
    KetThuc SMALLDATETIME NULL,
    CONSTRAINT ck_KH_BDKT CHECK (BatDau < KetThuc)
);

-- 2. Bảng GiaoVien
CREATE TABLE GiaoVien (
    MaGV CHAR(10) PRIMARY KEY,
    HoTen NVARCHAR(40) NOT NULL,
    NgaySinh SMALLDATETIME NULL,
    DiaChi NVARCHAR(100) NULL
);

-- 3. Bảng HocVien
CREATE TABLE HocVien (
    MaHV CHAR(10) PRIMARY KEY,
    Ho NVARCHAR(40) NOT NULL,
    Ten NVARCHAR(20) NOT NULL,
    NgaySinh SMALLDATETIME NULL,
    DiaChi NVARCHAR(100) NULL,
    NgheNghiep NVARCHAR(50) NULL
);

-- 4. Bảng LopHoc
CREATE TABLE LopHoc (
    MaLop CHAR(10) PRIMARY KEY,
    TenLop NVARCHAR(100) NOT NULL,
    MaKH CHAR(10) REFERENCES KhoaHoc(MaKH),
    MaGV CHAR(10) REFERENCES GiaoVien(MaGV),
    SiSoDK INT CHECK (SiSoDK > 0),
    LopTruong CHAR(10) REFERENCES HocVien(MaHV),
    PHoc CHAR(5) NULL
);

-- 5. Bảng BienLai
CREATE TABLE BienLai (
    MaKH CHAR(10) REFERENCES KhoaHoc(MaKH),
    MaLH CHAR(10) REFERENCES LopHoc(MaLop),
    MaHV CHAR(10) REFERENCES HocVien(MaHV),
    SoBL INT PRIMARY KEY,
    Diem NUMERIC(4, 2) CHECK (Diem >= 0),
    KetQua NVARCHAR(20) CHECK (KetQua IN (N'Đậu', N'Không đậu')),
    XepLoai NVARCHAR(20) CHECK (XepLoai IN (N'Giỏi', N'Khá', N'Trung bình', N'Yếu')),
    TienNop MONEY CHECK (TienNop >= 0)
);
GO

-- ================================================================
-- PHẦN 2: CHÈN DỮ LIỆU MẪU (Để chạy thử nghiệm các câu hỏi)
-- ================================================================

INSERT INTO GiaoVien (MaGV, HoTen, NgaySinh, DiaChi) VALUES
('GV001', N'Nguyễn Văn An', '1970-01-01', N'Hà Nội'),
('GV002', N'Lê Thị Bình', '1980-05-15', N'TP.HCM'),
('GV003', N'Trần Văn Cường', '1960-03-10', N'Đà Nẵng');

INSERT INTO HocVien (MaHV, Ho, Ten, NgaySinh, NgheNghiep) VALUES
('HV001', N'Nguyễn', N'Huong', '2000-01-01', N'Sinh viên'),
('HV002', N'Lê', N'Dũng', '1999-05-20', N'Học sinh'),
('HV003', N'Trần', N'Huong', '2001-11-12', N'Sinh viên');

INSERT INTO KhoaHoc VALUES ('KH001', N'Tiếng Anh Giao Tiếp', '2024-01-01', '2024-06-01');

INSERT INTO LopHoc (MaLop, TenLop, MaKH, MaGV, SiSoDK) VALUES
('LPE0101', N'Lớp Anh Văn 1', 'KH001', 'GV001', 20),
('LPE0102', N'Lớp Anh Văn 2', 'KH001', 'GV002', 15);

INSERT INTO BienLai (SoBL, MaLH, MaHV, Diem, KetQua, XepLoai, TienNop) VALUES
(1001, 'LPE0101', 'HV001', 8.5, N'Đậu', N'Giỏi', 500000),
(1002, 'LPE0101', 'HV002', 7.0, N'Đậu', N'Khá', 500000),
(1003, 'LPE0102', 'HV003', 9.0, N'Đậu', N'Giỏi', 500000);
GO

-- ================================================================
-- PHẦN 3: GIẢI CÁC BÀI TẬP TRONG FILE EXC-6-QUERY-QLHV-QUES
-- ================================================================

/*
Câu 1: Cho biết dữ liệu hiện có trong bảng GiaoVien
Giải thích: Sử dụng SELECT * để lấy tất cả các cột và dòng dữ liệu từ bảng đích.
*/
SELECT * FROM GiaoVien;
GO

/*
Câu 2: Cho biết dữ liệu hiện có trong bảng BienLai
Giải thích: Tương tự câu trên, truy vấn toàn bộ thông tin bảng biên lai.
*/
SELECT * FROM BienLai;
GO

/*
Câu 3: Cho biết thông tin của giáo viên có mã số giáo viên là GV001.
Giải thích: Sử dụng mệnh đề WHERE để lọc dữ liệu theo khóa chính MaGV.
*/
SELECT * 
FROM GiaoVien 
WHERE MaGV = 'GV001';
GO

/*
Câu 4: Cho biết thông tin về các biên lai đã lập cho lớp có mã số LPE0101
Giải thích: Lọc bảng BienLai theo cột MaLH (Mã lớp học).
*/
SELECT * 
FROM BienLai 
WHERE MaLH = 'LPE0101';
GO

/*
Câu 5: Thêm 1 giáo viên mới với dữ liệu gồm ('GV006', N'Lan Ngọc', '20/3/1960', NULL)
Giải thích: Sử dụng lệnh INSERT INTO. Lưu ý dùng N'' trước chuỗi Unicode để không bị lỗi font Tiếng Việt.
Định dạng ngày tháng nên để YYYY-MM-DD để SQL Server nhận diện chính xác.
*/
INSERT INTO GiaoVien (MaGV, HoTen, NgaySinh, DiaChi) 
VALUES ('GV006', N'Lan Ngọc', '1960-03-20', NULL);
-- Kiểm tra lại sau khi thêm
SELECT * FROM GiaoVien WHERE MaGV = 'GV006';
GO

/*
Câu 6: Cho biết thông tin của giáo viên sinh vào tháng 3 năm 1960
Giải thích: Sử dụng hàm MONTH() và YEAR() để tách thông tin từ cột kiểu ngày tháng.
*/
SELECT * 
FROM GiaoVien 
WHERE MONTH(NgaySinh) = 3 AND YEAR(NgaySinh) = 1960;
GO

/*
Câu 7: Cho biết Mã học viên, họ tên và ngày sinh của các học viên tên là Huong
Giải thích: 
- Sử dụng phép nối chuỗi (Ho + ' ' + Ten) để hiển thị đầy đủ họ tên.
- WHERE Ten = N'Huong' để lọc đúng người cần tìm.
*/
SELECT MaHV, (Ho + ' ' + Ten) AS HoTen, NgaySinh
FROM HocVien
WHERE Ten = N'Huong';
GO

/*
Câu 8: Cho biết thông tin của giáo viên có họ Lê
Giải thích: Sử dụng LIKE với ký tự đại diện % để tìm các tên bắt đầu bằng chữ 'Lê'.
*/
SELECT * 
FROM GiaoVien 
WHERE HoTen LIKE N'Lê%';
GO

/*
Câu 9: Cho biết điểm số cao nhất mà học viên đạt được tại trung tâm
Giải thích: Sử dụng hàm gộp (Aggregate Function) MAX() trên cột Diem.
*/
SELECT MAX(Diem) AS DiemCaoNhat
FROM BienLai;
GO

/*
Câu 10: Cho biết mã lớp học và điểm số cao nhất mà học viên đạt được trong từng lớp.
Giải thích: 
- GROUP BY MaLH để gom nhóm các biên lai theo từng lớp.
- MAX(Diem) sẽ tính điểm cao nhất trong phạm vi mỗi nhóm đó.
*/
SELECT MaLH, MAX(Diem) AS DiemCaoNhat_Lop
FROM BienLai
GROUP BY MaLH;
GO

/*
Câu 11: Cho biết tên lớp học, số lượng học viên xếp loại khá giỏi của từng lớp
Giải thích:
- INNER JOIN giữa BienLai và LopHoc để lấy được TenLop (vì BienLai chỉ có MaLH).
- Mệnh đề WHERE để lọc ra những học viên có XepLoai là 'Khá' hoặc 'Giỏi'.
- COUNT(*) dùng để đếm số lượng học viên trong mỗi nhóm (lớp).
*/
SELECT lh.TenLop, COUNT(bl.MaHV) AS SoLuongKhaGioi
FROM BienLai bl
INNER JOIN LopHoc lh ON bl.MaLH = lh.MaLop
WHERE bl.XepLoai IN (N'Khá', N'Giỏi')
GROUP BY lh.TenLop;
GO

-- ================================================================
-- PHẦN 4: NÂNG CAO (Áp dụng kiến thức Stored Procedure, Trigger, Transaction)
-- ================================================================

/*
Kiến thức áp dụng: Trigger
Mục tiêu: Đảm bảo điểm số khi nhập vào bảng BienLai phải nằm trong khoảng từ 0 đến 10.
Nếu sai sẽ báo lỗi và Rollback (giống cách làm trong file trigger của project).
*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'trg_CheckDiemHocVien')
    DROP TRIGGER trg_CheckDiemHocVien;
GO

CREATE TRIGGER trg_CheckDiemHocVien
ON BienLai
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE Diem < 0 OR Diem > 10)
    BEGIN
        RAISERROR(N'Lỗi: Điểm số học viên phải nằm trong khoảng từ 0 đến 10.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

/*
Kiến thức áp dụng: Stored Procedure & Transaction
Mục tiêu: Viết thủ tục thêm học viên mới và tự động lập biên lai đóng tiền ban đầu.
Sử dụng TRANSACTION để đảm bảo nếu một trong hai thao tác lỗi thì sẽ hủy bỏ toàn bộ.
*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'sp_DangKyHocVienMoi')
    DROP PROCEDURE sp_DangKyHocVienMoi;
GO

CREATE PROCEDURE sp_DangKyHocVienMoi
    @MaHV CHAR(10),
    @Ho NVARCHAR(40),
    @Ten NVARCHAR(20),
    @MaLH CHAR(10),
    @SoBL INT,
    @TienNop MONEY
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        -- 1. Thêm học viên vào bảng HocVien
        INSERT INTO HocVien (MaHV, Ho, Ten) 
        VALUES (@MaHV, @Ho, @Ten);

        -- 2. Lập biên lai đóng tiền cho lớp học tương ứng
        -- Giả sử mặc định KetQua và XepLoai ban đầu là NULL
        INSERT INTO BienLai (SoBL, MaLH, MaHV, TienNop)
        VALUES (@SoBL, @MaLH, @MaHV, @TienNop);

        -- Nếu mọi thứ ổn, xác nhận lưu dữ liệu
        COMMIT TRANSACTION;
        PRINT N'Đăng ký học viên và lập biên lai thành công.';
    END TRY
    BEGIN CATCH
        -- Nếu có bất kỳ lỗi nào xảy ra (ví dụ trùng MaHV), hủy bỏ toàn bộ
        ROLLBACK TRANSACTION;
        PRINT N'Lỗi xảy ra trong quá trình đăng ký. Đã hoàn tác (Rollback).';
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

-- Chạy thử thủ tục nâng cao
-- EXEC sp_DangKyHocVienMoi 'HV099', N'Trần', N'Nam', 'LPE0101', 9999, 1000000;
-- SELECT * FROM HocVien WHERE MaHV = 'HV099';
-- SELECT * FROM BienLai WHERE SoBL = 9999;
