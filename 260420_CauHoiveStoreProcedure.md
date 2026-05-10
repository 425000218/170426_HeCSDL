Store Procedure

Phản hồi nội dung tìm hiểu trong quá trình làm bài tập về thủ tục (store procedure - SP)

Phần 1. Giải câu hỏi trực tiếp trong file bài tập về SP
Phần 2. Phản hồi/ report
2.1 Stored Procedure giải quyết vấn đề gì?
2.2 Giải thích cấu trúc câu lệnh SP: từ khoá, tham số, cách thực thi SP
2.3 Giải thích cấu trúc các câu lệnh khác được sử dụng trong file bài tập

Ví dụ: 
IF NOT EXISTS (SELECT 1 FROM KhachHang WHERE MaKH = @MaKH)
Sinh viên cần giải thích:
●	IF là gì?
●	EXISTS hoạt động thế nào?
●	Tại sao dùng câu lệnh này? 

---

## Phần 1. Lời giải bài tập Stored Procedure

Lời giải đầy đủ đã được viết trong file [260420 bt SQL thongtinbanhang4table - store procedure.sql](260420%20bt%20SQL%20thongtinbanhang4table%20-%20store%20procedure.sql). Các thủ tục được viết theo đúng dữ liệu mẫu cũ của bộ 4 bảng:

- `SanPham(MaSP INT, TenSP NVARCHAR(100), DonGia DECIMAL(10,2))`
- `KhachHang(MaKH INT, HoTenKH NVARCHAR(100), SoDTKH VARCHAR(20), EmailKH VARCHAR(100))`
- `HoaDon(MaHD INT, MaKH INT, NgayLapHD DATE)`
- `CTHD(MaHD INT, MaKH INT, MaSP INT, SoLuong INT, DonGiaBan DECIMAL(10,2))`

Các thủ tục đã làm đúng yêu cầu bài:

- `sp_TatCaSanPham`: hiển thị toàn bộ sản phẩm.
- `sp_TimKhachHang`: tìm khách hàng theo `MaKH`.
- `sp_HoaDonTheoNgay`: lọc hóa đơn theo ngày lập.
- `sp_SanPhamGiaCao`: lọc sản phẩm có đơn giá lớn hơn ngưỡng truyền vào.
- `sp_ChiTietMuaHang`: lấy tên sản phẩm và số lượng theo `MaHD`.
- `sp_TongHoaDon_KH`: trả về tổng số hóa đơn của khách hàng.
- `sp_TongThanhTien_HD`: trả về tổng tiền của một hóa đơn.
- `sp_TongSoLuongBan_SP`: trả về tổng số lượng đã bán của một sản phẩm.
- `sp_TenSanPhamGiaCaoNhat`: trả về tên sản phẩm có đơn giá cao nhất.
- `sp_DoanhThu_Thang`: trả về tổng doanh thu theo tháng/năm.

---

## Phần 2. Phản hồi / Report

### 2.1 Stored Procedure giải quyết vấn đề gì?

Stored Procedure là một khối lệnh SQL được lưu sẵn trong cơ sở dữ liệu để tái sử dụng nhiều lần. Nó giải quyết các vấn đề sau:

1. Tái sử dụng logic: thay vì viết lại cùng một đoạn `SELECT`, `JOIN`, `SUM`, `COUNT` nhiều lần ở nhiều nơi, ta gọi một thủ tục duy nhất.
2. Dễ bảo trì: nếu nghiệp vụ thay đổi, chỉ cần sửa trong một nơi thay vì sửa nhiều câu lệnh rải rác.
3. Tăng tính nhất quán: dữ liệu được xử lý theo cùng một quy tắc, giảm sai khác giữa các màn hình hoặc ứng dụng.
4. Tăng bảo mật và kiểm soát: có thể cấp quyền chạy procedure mà không cần cấp trực tiếp quyền vào bảng.
5. Tối ưu vận hành: SQL Server có thể lưu kế hoạch thực thi, nên nhiều trường hợp chạy procedure ổn định hơn so với gửi nhiều câu lệnh lẻ tẻ.

Ví dụ trong bài:

- `sp_TimKhachHang` chỉ cần nhập mã khách hàng là lấy ra đúng thông tin cần xem.
- `sp_DoanhThu_Thang` gom toàn bộ logic doanh thu vào một thủ tục, không phải viết lại công thức `SUM(SoLuong * DonGiaBan)` ở nhiều nơi.

### 2.2 Giải thích cấu trúc câu lệnh SP: từ khoá, tham số, cách thực thi SP

#### a. Cấu trúc cơ bản

Một Stored Procedure thường có dạng:

```sql
CREATE OR ALTER PROCEDURE TenThuTuc
	@ThamSo1 KieuDuLieu,
	@ThamSo2 KieuDuLieu OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	-- Câu lệnh xử lý
END;
GO
```

Giải thích từng phần:

- `CREATE PROCEDURE` hoặc `CREATE OR ALTER PROCEDURE`: tạo mới hoặc cập nhật procedure nếu đã tồn tại.
- `TenThuTuc`: tên thủ tục, nên đặt theo mục đích rõ ràng như `sp_TimKhachHang`.
- `@ThamSo`: tham số đầu vào hoặc đầu ra của procedure.
- `OUTPUT`: đánh dấu tham số đó có thể trả kết quả ra ngoài cho biến bên gọi.
- `AS`: bắt đầu phần thân của procedure.
- `BEGIN ... END`: khối lệnh bao quanh phần xử lý.
- `GO`: kết thúc một batch để SQL Server biên dịch và lưu procedure.

#### b. Tham số đầu vào và đầu ra

- Tham số đầu vào dùng để truyền dữ liệu vào thủ tục, ví dụ `@MaKH INT`.
- Tham số đầu ra dùng để nhận kết quả sau khi thủ tục chạy xong, ví dụ `@TongHoaDon INT OUTPUT`.

Trong file bài tập:

- `sp_TimKhachHang @MaKH INT` là tham số đầu vào.
- `sp_TongHoaDon_KH @TongHoaDon INT OUTPUT` là tham số đầu ra.

Khi gọi procedure có OUTPUT, phải khai báo biến ngoài rồi truyền biến đó vào:

```sql
DECLARE @SoHD INT;
EXEC sp_TongHoaDon_KH @MaKH = 1, @TongHoaDon = @SoHD OUTPUT;
SELECT @SoHD;
```

Nếu thiếu `OUTPUT` ở lúc gọi thì giá trị có thể không được trả ra biến bên ngoài đúng cách.

#### c. Cách thực thi SP

Procedure thường được chạy bằng `EXEC` hoặc `EXECUTE`:

```sql
EXEC sp_TatCaSanPham;
EXEC sp_TimKhachHang @MaKH = 1;
```

Nếu là procedure có OUTPUT thì cần thêm biến nhận kết quả như ví dụ ở trên.

#### d. Vì sao dùng `SET NOCOUNT ON`

`SET NOCOUNT ON` làm cho SQL Server không in ra thông báo kiểu `X row(s) affected` sau mỗi câu lệnh `INSERT`, `UPDATE`, `DELETE`.

Lý do nên dùng:

- Giảm nhiễu khi xem kết quả procedure.
- Tránh một số ứng dụng đọc nhầm thông báo số dòng ảnh hưởng thành một result set phụ.

Nếu bỏ dòng này thì procedure vẫn chạy, nhưng sẽ xuất hiện thêm thông báo không cần thiết.

### 2.3 Giải thích các câu lệnh khác được sử dụng trong file bài tập

#### a. `SELECT`

`SELECT` dùng để truy vấn dữ liệu từ bảng hoặc gán kết quả vào biến.

Trong bài:

- `SELECT MaSP, TenSP, DonGia FROM SanPham` là lấy dữ liệu sản phẩm.
- `SELECT @TongHoaDon = COUNT(*) FROM HoaDon WHERE MaKH = @MaKH` là gán số lượng hóa đơn vào biến output.

Nếu thiếu `SELECT` thì procedure không trả dữ liệu gì ra ngoài.

#### b. `FROM`

`FROM` chỉ nguồn dữ liệu sẽ đọc, ví dụ bảng `SanPham`, `HoaDon`, `CTHD`.

Nếu thiếu `FROM` thì SQL không biết lấy dữ liệu từ đâu.

#### c. `WHERE`

`WHERE` dùng để lọc dữ liệu theo điều kiện.

Trong bài:

- `WHERE MaKH = @MaKH` chỉ lấy đúng khách hàng cần tìm.
- `WHERE NgayLapHD = @Ngay` chỉ lấy hóa đơn trong một ngày.
- `WHERE DonGia > @GiaX` chỉ lấy sản phẩm đắt hơn ngưỡng.

Nếu bỏ `WHERE` thì procedure thường trả về toàn bộ dữ liệu, sai yêu cầu bài.

#### d. `INNER JOIN`

`INNER JOIN` dùng để ghép dữ liệu giữa các bảng có liên quan.

Trong bài:

- `CTHD` giữ `MaSP`, nhưng không có `TenSP`.
- `SanPham` giữ `TenSP`, nên phải `JOIN` hai bảng mới hiển thị được tên sản phẩm.

Nếu bỏ `JOIN` ở `sp_ChiTietMuaHang` thì chỉ còn mã sản phẩm, không lấy được tên.

#### e. `COUNT(*)`

`COUNT(*)` đếm số dòng thỏa điều kiện.

Trong bài dùng để đếm số hóa đơn của khách hàng.

Nếu khách hàng không có hóa đơn nào, `COUNT(*)` vẫn trả về `0`, nên rất phù hợp cho bài toán đếm.

#### f. `SUM(...)`

`SUM` tính tổng các giá trị số.

Trong bài:

- Tổng tiền hóa đơn = `SUM(SoLuong * DonGiaBan)`.
- Tổng số lượng đã bán = `SUM(SoLuong)`.

Nếu không có dòng nào phù hợp, `SUM` sẽ trả `NULL`, vì vậy cần bọc thêm `ISNULL(..., 0)`.

#### g. `ISNULL(..., 0)`

`ISNULL` thay giá trị `NULL` bằng giá trị khác, ở đây là `0`.

Trong bài:

- Nếu hóa đơn chưa có chi tiết, `SUM(...)` trả `NULL`.
- Nếu sản phẩm chưa từng bán, `SUM(SoLuong)` cũng có thể `NULL`.

Khi đó `ISNULL(..., 0)` giúp kết quả trả về là `0` thay vì `NULL`, dễ xử lý hơn ở ứng dụng bên ngoài.

Nếu bỏ `ISNULL` thì có thể gây lỗi logic khi màn hình hoặc chương trình mong đợi một con số cụ thể.

#### h. `TOP 1` và `ORDER BY`

`TOP 1` lấy đúng 1 dòng đầu tiên trong kết quả.

`ORDER BY DonGia DESC` sắp xếp giảm dần theo đơn giá để dòng đầu tiên là sản phẩm có giá cao nhất.

Trong bài:

- `TOP 1` giúp gán được một giá trị duy nhất vào biến output.
- `ORDER BY` bảo đảm không lấy ngẫu nhiên.

Nếu thiếu `TOP 1`, procedure có thể lỗi vì đang gán nhiều dòng cho một biến.
Nếu thiếu `ORDER BY`, `TOP 1` sẽ lấy ngẫu nhiên một sản phẩm, không chắc là đắt nhất.

#### i. `MONTH()` và `YEAR()`

Hai hàm này lấy phần tháng và năm từ cột ngày.

Trong bài `sp_DoanhThu_Thang`, dùng:

- `MONTH(hd.NgayLapHD) = @Thang`
- `YEAR(hd.NgayLapHD) = @Nam`

để lọc đúng các hóa đơn thuộc tháng/năm cần tính doanh thu.

Nếu bỏ hai điều kiện này thì doanh thu sẽ bị tính cho toàn bộ dữ liệu, không còn đúng yêu cầu.

#### j. `DECLARE`

`DECLARE` dùng để khai báo biến cục bộ trong SQL.

Trong ví dụ gọi output procedure:

```sql
DECLARE @SoHD INT;
```

Nếu không khai báo biến thì không có chỗ để nhận kết quả output.

#### k. `IF NOT EXISTS (SELECT 1 FROM KhachHang WHERE MaKH = @MaKH)`

Đây là câu kiểm tra điều kiện tồn tại trước khi chèn hoặc cập nhật dữ liệu.

Giải thích:

- `IF` là câu lệnh rẽ nhánh: đúng thì chạy khối lệnh bên trong, sai thì bỏ qua.
- `EXISTS` trả về đúng/sai dựa trên việc truy vấn con có trả về ít nhất một dòng hay không.
- `SELECT 1` chỉ là cách viết gọn để kiểm tra tồn tại, không cần lấy toàn bộ cột.

Tại sao dùng câu này:

- Tránh chèn trùng khóa chính.
- Tránh cập nhật/xóa nhầm khi đối tượng không tồn tại.
- Giúp báo lỗi nghiệp vụ rõ ràng hơn thay vì để SQL Server ném lỗi kỹ thuật khó hiểu.

Ví dụ logic:

```sql
IF NOT EXISTS (SELECT 1 FROM KhachHang WHERE MaKH = @MaKH)
BEGIN
	RAISERROR(N'Khách hàng không tồn tại.', 16, 1);
	RETURN;
END;
```

Nếu không có khối kiểm tra này, câu lệnh phía dưới có thể vẫn chạy nhưng xử lý sai dữ liệu hoặc trả kết quả rỗng mà người dùng không biết nguyên nhân.

---

## Kết luận ngắn

Stored Procedure trong bài này giúp gom các thao tác truy vấn, đếm, tính tổng và lọc dữ liệu của 4 bảng `SanPham`, `KhachHang`, `HoaDon`, `CTHD` vào các thủ tục có thể tái sử dụng. Phần giải thích trong file SQL đã nêu rõ vì sao từng dòng cần thiết và nếu bỏ đi thì sẽ dẫn tới trả dữ liệu sai, thiếu dữ liệu, hoặc phát sinh lỗi logic.
