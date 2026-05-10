SQL 1 TABLE
•	Danh sách tất cả hóa đơn cùng với ngày lập hóa đơn
SELECT MaHD, NgayLapHD 
FROM hoadon;
•	Danh sách tất cả sản phẩm và giá của chúng
•	Danh sách tất cả khách hàng cùng với số điện thoại và email
•	Danh sách tất cả các chi tiết hóa đơn cùng với số lượng và đơn giá
•	Danh sách tất cả khách hàng có tên chứa từ 'Nguyễn'
•	Danh sách tất cả sản phẩm có mã sản phẩm lớn hơn 1002
•	Tìm hóa đơn với mã hóa đơn là 103
•	Danh sách các hóa đơn mà chưa có bất kỳ chi tiết nào (trong bảng hóa đơn nhưng không có trong bảng chi tiết hóa đơn)

SQL INNER JOIN
•	Danh sách các khách hàng cùng với thông tin hóa đơn của họ
SELECT kh.MaKH, kh.HoTenKH, h.MaHD, h.NgayLapHD 
FROM KhachHang kh INNER JOIN hoadon h ON kh.MaKH = h.MaKH;

•	Danh sách sản phẩm cùng với các hóa đơn mà sản phẩm đó xuất hiện
•	Danh sách khách hàng cùng với các sản phẩm mà họ đã mua
•	Danh sách hóa đơn và tên sản phẩm cùng với số lượng và đơn giá
•	Danh sách hóa đơn và thông tin khách hàng của hóa đơn đó
•	Danh sách các sản phẩm và số lượng chúng đã xuất hiện trong hóa đơn
•	Danh sách các hóa đơn và sản phẩm liên quan đến hóa đơn đó
•	Danh sách khách hàng và sản phẩm họ đã mua, bao gồm cả số lượng

