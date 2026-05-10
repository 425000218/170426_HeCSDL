/* Xem csdl QLHV */
--Bài tập Thiết lập Table, Khai báo thuộc tính và ràng buộc trực tiếp trong từng bảng

USE [master]
/* Tạo database QLHV_C */
GO
CREATE DATABASE [QLHV_C]
-------------------
GO
use QLHV_C
-------------------
Go 
/*1. Tạo bảng KhoaHoc với các yêu cầu sau:
- MaKH kiểu char, độ dài 10.
- TenKH kiểu nvarchar, độ dài 100.
- BatDau kiểu ngày tháng (smalldatetime).
- KetThuc kiểu ngày tháng (smalldatetime).
Ràng buộc:
- Khóa chính: MaKH
- Khóa ngoại: không.
- Khác: BatDau <= KetThuc. TenKH không được rỗng.
*/
CREATE TABLE [dbo].[KhoaHoc](
	[MaKH] [char](10) PRIMARY KEY,
	[TenKH] [nvarchar](100) NOT NULL,
	[BatDau] [smalldatetime] NULL,
	[KetThuc] [smalldatetime] NULL,
	--CHECK(BatDau < KetThuc)
	CONSTRAINT ck_KH_BDKT CHECK(BatDau < KetThuc)
)
--Kiểm tra ràng buộc đã tạo ở bảng KhoaHoc
select * from information_schema.TABLE_CONSTRAINTS where table_name = 'KhoaHoc'

/*2. Tạo bảng GiaoVien với các yêu cầu sau:
- MaGV kiểu char, độ dài 10.
- HoTen kiểu nvarchar, độ dài 10.
- NgaySinh kiểu ngày tháng năm (smalldatetime).
- Địa chỉ kiểu nvarchar, độ dài 100.
Ràng buộc:
- Khóa chính: MaGV
- Khóa ngoại: không.
- Khác: HoTen không được rỗng.
*/
CREATE TABLE [dbo].[GiaoVien](
	[MaGV] [char](10) PRIMARY KEY,
	[HoTen] [nvarchar](40) NOT NULL,
	[NgaySinh] [smalldatetime] NULL,
	[DiaChi] [nvarchar](100) NULL
) ON [PRIMARY]

/*3. Tạo bảng HocVien với các yêu cầu sau:
- MaHV kiểu char, độ dài 10.
- Ho kiểu nvarchar, độ dài 40.
- Ten kiểu nvarchar, độ dài 20.
- NgaySinh kiểu ngày tháng năm (smalldatetime).
- Địa chỉ kiểu nvarchar, độ dài 100.
- Nghề nghiệp kiểu nvarchar, độ dài 50.
Ràng buộc:
- Khóa chính: MaHV
- Khóa ngoại: không.
- Khác: Ho, Ten không được rỗng.
*/
CREATE TABLE [dbo].[HocVien](
	[MaHV] [char](10) PRIMARY KEY,
	[Ho] [nvarchar](40) NOT NULL,
	[Ten] [nvarchar](20) NOT NULL,
	[NgaySinh] [smalldatetime] NULL,
	[DiaChi] [nvarchar](100) NULL,
	[NgheNghiep] [nvarchar](50) NULL
) ON [PRIMARY]

/*5. Tạo bảng LopHoc với các yêu cầu sau:
- MaLop kiểu char, độ dài 10.
- TenLop kiểu nvarchar, độ dài 100.
- MaKH kiểu char, độ dài 10.
- MaGV kiểu char, độ dài 10.
- SiSoDK kiểu int.
- LopTruong kiểu char, độ dài 10.
- PHoc kiểu char, độ dài 5.
Ràng buộc:
- Khóa chính: MaLop
- Khóa ngoại: MaKH, MaGV, LopTruong
- Khác: SiSoDK > 0. TenLop không được rỗng.
*/
CREATE TABLE [dbo].[LopHoc](
	[MaLop] [char](10) PRIMARY KEY,
	[TenLop] [nvarchar](100) NULL,
	[MaKH] [char](10) NULL REFERENCES dbo.KhoaHoc(MaKH),
	[MaGV] [char](10) NULL REFERENCES dbo.GiaoVien(MaGV),
	[SiSoDK] [int] NULL CHECK(SiSoDK > 0),
	[LopTruong] [char](10) NULL REFERENCES dbo.HocVien(MaHV),
	[PHoc] [char](5) NULL
) ON [PRIMARY]

/*5. Tạo bảng BienLai với các yêu cầu sau:
- MaKH kiểu char, độ dài 10.
- MaLH kiểu char, độ dài 10.
- MaHV kiểu char, độ dài 10.
- SoBL kiểu char, độ dài 10.
- Diem kiểu số thực (2 số lẻ).
- KetQua kiểu nvarchar, độ dài 20.
- XepLoai kiểu nvarchar, độ dài 20.
- TienNop kiểu money.
Ràng buộc:
- Khóa chính: SoBL
- Khóa ngoại: MaKH, MaLH, MaHV
- Khác: Diem > 0. KetQua có giá trị {Đậu, Không đậu}. XepLoai có giá trị {Giỏi, Khá, Trung bình, Yếu}. Tiền nộp >= 0.
*/
CREATE TABLE [dbo].[BienLai](
	[MaKH] [char](10) NULL REFERENCES dbo.KhoaHoc(MaKH),
	[MaLH] [char](10) NULL REFERENCES dbo.LopHoc,
	[MaHV] [char](10) NULL REFERENCES dbo.HocVien,
	[SoBL] INT PRIMARY KEY,
	[Diem] [numeric](4, 2) NULL CHECK(Diem >= 0),
	[KetQua] [nvarchar](20) NULL CHECK(KetQua IN (N'Đậu', N'Không đậu')),
	[XepLoai] [nvarchar](20) NULL CHECK(XepLoai IN (N'Giỏi', N'Khá', N'Trung bình', N'Yếu')),
	[TienNop] [money] NULL CHECK(TienNop >= 0)
) ON [PRIMARY]