SQL GROUP BY
Lưu ý: Thay đổi tên bảng, tên thuộc tính phù hợp với csdl sinh viên đã tạo.
•	Danh sách các hóa đơn và số lượng sản phẩm đã mua trong mỗi hóa đơn
SELECT MaHD, SUM(SoLuong) AS TongSoLuong 
FROM dbo.hoadonchitiet 
GROUP BY MaHD;

•	Danh sách các sản phẩm và số lượng mà mỗi sản phẩm xuất hiện trong hóa đơn
SELECT MaSP, SUM(SoLuong) AS TongSoLuong
FROM dbo.hoadonchitiet
GROUP BY MaSP;
•	Danh sách khách hàng và tổng giá trị hóa đơn mà họ đã thực hiện
SELECT kh.HoTenKH, SUM(hct.SoLuong * hct.DonGia) AS TongGiaTri
FROM dbo.hoadon h
INNER JOIN dbo.MaKhachHang kh ON h.MaKH = kh.MaKH
INNER JOIN dbo.hoadonchitiet hct ON h.MaHD = hct.MaHD
GROUP BY kh.HoTenKH;
•	Danh sách sản phẩm và số lượng đã bán, chỉ bao gồm các sản phẩm đã bán
SELECT sp.TenSP, SUM(hct.SoLuong) AS TongSoLuong
FROM dbo.hoadonchitiet hct
INNER JOIN dbo.sanpham sp ON hct.MaSP = sp.MaSP
GROUP BY sp.TenSP;
•	Danh sách hóa đơn và số lượng sản phẩm của từng loại sản phẩm trong mỗi hóa đơn
SELECT h.MaHD, sp.TenSP, SUM(hct.SoLuong) AS TongSoLuong
FROM dbo.hoadonchitiet hct
INNER JOIN dbo.hoadon h ON hct.MaHD = h.MaHD
INNER JOIN dbo.sanpham sp ON hct.MaSP = sp.MaSP
GROUP BY h.MaHD, sp.TenSP;
•	Danh sách các hóa đơn có giá trị tổng cộng lớn hơn 1000, bao gồm thông tin chi tiết sản phẩm
SELECT h.MaHD, SUM(hct.SoLuong * hct.DonGia) AS TongGiaTri
FROM dbo.hoadon h
INNER JOIN dbo.hoadonchitiet hct ON h.MaHD = hct.MaHD
GROUP BY h.MaHD
HAVING SUM(hct.SoLuong * hct.DonGia) > 1000;
•	Danh sách sản phẩm và số lượng đã bán, chỉ bao gồm các sản phẩm có tên chứa từ 'Smartphone'
SELECT sp.TenSP, SUM(hct.SoLuong) AS TongSoLuong
FROM dbo.hoadonchitiet hct
INNER JOIN dbo.sanpham sp ON hct.MaSP = sp.MaSP
WHERE sp.TenSP LIKE '%Smartphone%'
GROUP BY sp.TenSP;
