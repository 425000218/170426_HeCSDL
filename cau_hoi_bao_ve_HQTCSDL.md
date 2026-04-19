# TÀI LIỆU ÔN TẬP BẢO VỆ MÔN HỆ QUẢN TRỊ CƠ SỞ DỮ LIỆU (HQTCSDL)

Tài liệu này tổng hợp các câu hỏi "bắt bí", móc nối logic mà Giảng viên thường dùng để kiểm tra mức độ hiểu bản chất của sinh viên.

---

## PHẦN 1: CÁC KHÁI NIỆM LÝ THUYẾT CỐT LÕI

### 1. Stored Procedure (Thủ tục lưu trữ)
**Câu hỏi:** Tại sao phải dùng Procedure mà không viết thẳng câu lệnh SQL trên ứng dụng (C#/Java) rồi truyền xuống database?
**Trả lời (Từ khóa ăn điểm):**
*   **Kế hoạch thực thi (Execution Plan) & Cache:** Khi chạy procedure lần đầu, SQL Server phân tích đường dẫn tối ưu nhất và lưu vào bộ nhớ đệm (cache). Các lần gọi sau lấy ra chạy luôn nên tốc độ rất nhanh, tối ưu tài nguyên server. Nếu ghép string SQL từ app truyền xuống thì máy chủ phải dịch lại từ đầu mỗi lần chạy.
*   **Giảm băng thông mạng (Network Traffic):** Thay vì gửi đoạn code SQL vài chục dòng qua mạng, ta chỉ cần gửi lệnh `EXEC ten_proc`.
*   **Bảo mật:** Ngăn chặn tuyệt đối tình trạng tiêm rác mã độc (SQL Injection).

### 2. Trigger (Trình kích hoạt)
**Câu hỏi:** Khi nào dùng `Check Constraint` ở Table, khi nào **hết cách** buộc phải dùng `Trigger`?
**Trả lời (Từ khóa ăn điểm):**
*   **Ràng buộc toàn vẹn phức tạp:** `Check constraint` chỉ kiểm tra được dữ liệu trên **cùng 1 dòng/1 bảng** (VD: Ràng buộc Tuổi > 18). Nếu yêu cầu nghiệp vụ liên quan đến việc **kiểm tra chéo sang bảng khác** (VD: Không cho bán nếu Tồn kho bên bảng Sản phẩm = 0), thì bắt buộc phải dùng Trigger.
*   **Bảng ảo (Magic Tables):** Cần nắm rõ bảng `inserted` (chứa dữ liệu mới chèn/sau khi sửa) và `deleted` (chứa dữ liệu vừa xoá/trước khi sửa). Đặc biệt update là quá trình: xoá dòng cũ (đưa vào `deleted`) + thêm dòng mới (đưa vào `inserted`).

### 3. Transaction (Giao dịch)
**Câu hỏi:** Transaction dùng để làm gì? Nêu đặc tính cơ bản của Transaction?
**Trả lời (Từ khóa ăn điểm):**
*   Transaction gom nhiều thao tác thành 1 khối duy nhất theo nguyên tắc **"Tất cả cùng thành công hoặc tất cả cùng thất bại (All or Nothing)"**. Ngăn chặn việc dữ liệu bị cập nhật lửng lơ do cúp điện hoặc đứt kết nối.
*   **Đặc tính ACID:**
    *   **A (Atomicity - Tính nguyên tử):** Không thể tách rời (All or Nothing).
    *   **C (Consistency - Tính nhất quán):** Dữ liệu trước và sau giao dịch không được vi phạm các ràng buộc hiện có.
    *   **I (Isolation - Tính cô lập):** Rất nhiều người dùng đồng thời (Concurrency) thì các giao dịch phải bị khoá (Lock) độc lập, không dẫm chân lên nhau.
    *   **D (Durability - Tính bền bỉ):** Dữ liệu đã `COMMIT` thì lưu cứng vào ổ đĩa, cúp điện cũng không mất.

---

## PHẦN 2:  PHÂN TÍCH CODE VÀ BẪY LOGIC

### Dạng 1: Viết Procedure tính toán có tham số OUTPUT
*(Ví dụ tham chiếu: `sp_DoanhThu_Thang` tính tổng tiền hàng)*

**1. Tại sao dùng ISNULL() khi thiết lập công thức SUM()?**
> `SELECT @DoanhThu = ISNULL(SUM(SoLuong * DonGiaBan), 0)`

*   **Câu hỏi vặn:** Lệnh `SUM` là đủ rồi, thêm hàm `ISNULL(..., 0)` vào làm gì, bỏ đi có lỗi cú pháp không?
*   **Hướng dẫn trả lời:** Dạ không lỗi cú pháp nhưng sẽ **lỗi logic chạy thực tế**. Nếu tháng đó (vd tháng cô hồn) **không bán được bất kỳ đơn nào**, thì lệnh `SUM()` sẽ trả về kết quả rỗng là `NULL`. Nếu truyền `NULL` ra ngoài lập trình C#/Java, phần mềm sẽ không nhận diện được và có khả năng bị Crash. Thêm `ISNULL(..., 0)` để chặn đứng lỗi này: Bán không được thì quy định @DoanhThu bằng `0` đồng.

**2. Lý do phải thực hiện lệnh JOIN các bảng?**
*   **Câu hỏi vặn:** Tính doanh thu hóa đơn theo ngày tháng, tại sao phải phiền phức đi JOIN 2 bảng Hóa Đơn (`HoaDon`) và Chi Tiết Hóa Đơn (`CTHD`) lại với nhau?
*   **Hướng dẫn trả lời:** Tại vì bảng `HoaDon` có lưu "Ngày Lập" nhưng lại **không hề** lưu "Số lượng" và "Đơn giá". Đơn ráp chắp vá: Bảng `HoaDon` cung cấp dữ liệu điều kiện lọc thời gian, còn phải `JOIN` chui vào bảng `CTHD` mới lấy được số lượng, đơn giá để nhân lên ra tiền.

**3. Tại sao chạy Code EXEC nhưng không thấy in ra kết quả?**
*   **Bẫy thao tác phòng máy:** Sinh viên viết code gọi Output xong chạy quét riêng dòng `EXEC ...`, máy báo "Command completed successfully" nhưng không thấy giá trị đâu.
*   **Cách xử lý chuẩn:** Với Procedure có Output, **bắt buộc phải bôi đen quét chạy cùng lúc cả 3 dòng lệnh**: Khai báo biến `DECLARE` -> Thực thi đổ dữ liệu vô biến `EXEC` -> Dùng `SELECT` móc dữ liệu từ biến in ra màn hình.

---

### Dạng 2: Sử dụng Transaction xử lý đồng bộ nhiều bảng (Cập nhật giá)
*(Ví dụ tham chiếu: Giảm giá Laptop)*

**1. "Tại sao em phải nhét 2 câu UPDATE vào trong khối BEGIN TRANSACTION?"**
*   **Câu hỏi vặn:** Rút gọn code, bỏ chữ `BEGIN TRAN` và `COMMIT` đi, chỉ chừa lại đúng 2 câu lệnh `UPDATE` Sản Phẩm và `UPDATE` Chi Tiết Hóa Đơn thì có lỗi không? Tại sao thầy thấy nó vẫn chạy bình thường ra kết quả?
*   **Hướng dẫn trả lời:** Dạ thưa thầy/cô, nếu chạy bình thường (không có sự cố) thì không sao. Nhưng HQTCSDL được thiết kế để đoán trước rủi ro rớt mạng/cúp điện. Giả sử máy chủ bị cúp điện HOẶC đứt kết nối mạng ĐÚNG LÚC vừa chạy xong lệnh `UPDATE` bảng SanPham nhưng CHƯA KỊP `UPDATE` bảng CTHD. Hậu quả là: Giá ở kệ hàng (`SanPham`) thì đã giảm, nhưng hóa đơn khách mua (`CTHD`) vẫn neo ở giá cũ cắt cổ -> **Dữ liệu 2 bảng bị "vênh" nhau nghiêm trọng rách nát**. Đưa vào `BEGIN TRAN` để ép quy tắc "All or nothing": Nếu đứt gánh giữa chừng, toàn bộ tự động lùi về trạng thái cũ như chưa bao giờ giảm giá.

**2. Lệnh RAISERROR kết hợp với IF khác gì lệnh PRINT bình thường?**
> `RAISERROR(N'Giá sau khi giảm nhỏ hơn 500. Hủy giao dịch.', 16, 1);`
*   **Câu hỏi vặn:** Để thông báo lỗi giá nhỏ hơn 500, em dùng hàm `PRINT N'Lỗi giá...'` được không? Sao viết `RAISERROR` phức tạp thế?
*   **Hướng dẫn trả lời:** Lệnh `PRINT` chỉ đơn thuần là thảy dòng chữ ra màn hình để con người đọc, hệ thống SQL Server vẫn cho rằng "À, in chữ xong rồi, code chạy ngon lành" -> Không kích hoạt lỗi -> Không nhảy xuống được khối `CATCH`. Ngược lại, hàm `RAISERROR` (cụ thể với mức độ 16) sẽ chính thức báo động cho hệ thống SQL Server biết: "Đây là một lỗi chí mạng do ý đồ nghiệp vụ của lập trình viên!". Máy chủ lập tức ngưng khối `TRY`, ôm lỗi quăng thẳng xuống khối `CATCH` bên dưới để `ROLLBACK`.

**3. ROLLBACK TRANSACTION hoạt động thế nào trong CATCH?**
*   **Câu hỏi logic:** Nếu trong CATCH không có lệnh `ROLLBACK` thì hậu quả là gì?
*   **Hướng dẫn trả lời:** Khối CATCH là nơi đón lỗi. Nếu không có `ROLLBACK` ở đây, tiến trình `Transaction` bị "treo" lửng lơ trên RAM của máy chủ (gọi là trạng thái Uncommited). Các user khác khi vào xem giá Laptop sẽ bị màn hình xoay vòng vòng vô tận (trạng thái chờ giải phóng Lock dữ liệu). `ROLLBACK` giống như cây chổi, gặp lỗi là lập tức lấy ra quét sạch rác, đưa Database về trạng thái an toàn. Trang bị `TRY...CATCH...ROLLBACK` là tiêu chuẩn cao nhất của người thao tác DB.

---

### Dạng 3: Viết Trigger quản lý toàn vẹn dữ liệu (Dọn rác tự động)
*(Ví dụ tham chiếu: Tự động xóa Hóa Đơn khi không còn Chi Tiết Hóa Đơn nào)*

**1. Phân biệt AFTER DELETE và INSTEAD OF DELETE**
*   **Câu hỏi vặn:** Đoạn mã này khai báo `AFTER DELETE`, nếu thầy đổi lệnh thành `INSTEAD OF DELETE` thì Trigger có chạy mục đích như cũ không? Em hãy giải thích hai sự kiện này khác gì nhau?
*   **Hướng dẫn trả lời:** Dạ thưa thầy/cô, nếu đổi sang `INSTEAD OF DELETE` thì **Trigger sẽ bị sai logic**. 
    *   `AFTER DELETE`: Cho phép lệnh SQL cứ thực thi việc xóa cái món hàng (trong CTHD) đó đi đã. Xóa rớt khỏi giỏ hàng xong, Trigger mới ngầm chạy để kiểm tra xem "Cái giỏ (Hóa Đơn) bây giờ có bị rỗng sạch trơn không?". Rỗng thì nó vứt luôn cái giỏ. Rất mượt mà.
    *   `INSTEAD OF DELETE`: Trigger sẽ "chặn cửa" lệnh xóa. Món hàng (CTHD) đó bị giam lại không cho xóa. Hệ thống nhường toàn quyền quyết định cho Trigger. Nếu dùng cách này, lập trình viên phải tự gánh trách nhiệm viết thêm lệnh `DELETE CTHD` vào bên trong Trigger thì món hàng mới bay đi được. Làm code rườm rà, chạy chậm mà không cần thiết.

**2. Bảng ảo DELETED và bài toán tối ưu "Khoanh vùng mục tiêu"**
> `AND hd.MaHD IN (SELECT DISTINCT MaHD FROM deleted);`
*   **Câu hỏi vặn:** Trong câu lệnh `DELETE HoaDon` ở phần body, thầy thấy các điều kiện lệnh `LEFT JOIN` và lọc `IS NULL` là đủ lọc ra hóa đơn bị rỗng rồi, em kẹp thêm điều kiện `IN` nguyên cái bảng `deleted` này vào đây để làm cục mịch code làm gì? Bỏ được không?
*   **Hướng dẫn trả lời:** Dạ thưa BỎ LÀ SẬP MÁY CHỦ ạ! Đây là điểm cốt tử để đánh giá Triger dở hay Trigger chuyên nghiệp.
    *   **Bảng `deleted`** là "bảng ma" (bảng ảo tạm trên RAM) do SQL cấp tự động, chứa chính xác các dòng lệnh CTHD *vừa bị người dùng bôi đen bấm xóa*.
    *   **Nếu bỏ điều kiện này:** Cứ mỗi lần có ai đó xóa 1 CTHD trên app, Trigger sẽ đè máy chủ ra quét duyệt **TOÀN BỘ BẢNG HOÁ ĐƠN TỪ ĐỜI TÁM HOÁNH** xem có cái vỏ HĐ nào trống không rồi nó giết hết. Nó sẽ làm tê liệt Server nếu Database có vài triệu dòng.
    *   **Có điều kiện định hướng này:** Trigger sẽ lấy `MaHD` từ "bảng ma" `deleted` để khoanh vùng: "Người dùng vừa táy máy xóa CTHD của cái Mã Hóa Đơn số 005. Tôi chỉ Focus vào đúng duy nhất cái giỏ số 005 xem nó có trống không để đập luôn, các giỏ rỗng khác mặc kệ". Suy ra, tính toán rất nhẹ nhe và an toàn tuyệt đối.

---

## PHẦN 3: TƯ DUY KIẾN TRÚC THỰC TẾ TRONG DOANH NGHIỆP

**Câu hỏi nâng cao:** *"Chốt lại, khi em đi làm dự án phần mềm thực tế, có phải mọi câu lệnh `INSERT`, `UPDATE`, `DELETE` đều bắt buộc phải nhét hết vào Stored Procedure, Trigger và Transaction không?"*

**Hướng dẫn trả lời rành mạch, chuẩn tư duy hệ thống:**
Dạ thưa thầy/cô, câu trả lời là **KHÔNG BẮT BUỘC**, mà nó phụ thuộc vào quy mô và tiêu chuẩn kiến trúc của dự án. Áp dụng thực tế sẽ đi theo ranh giới sau:

*   **1. Nhóm Stored Procedure (Được yêu thích và ưu tiên nhất):** Ở các dự án lớn doanh nghiệp (Ngân hàng, Tài chính), 100% các câu lệnh tương tác đều bị cất giấu sau Procedure. Yếu tố sống còn ở đây là **bảo mật**. Coder viết giao diện Frontend/Backend API bên ngoài sẽ hoàn toàn mù tịt về cấu trúc và tên các bảng vật lý dưới Database, bẻ gãy ý tưởng tấn công SQL Injection. Ngoài ra, việc dồn logic nghiệp vụ phức tạp xuống Procedure giúp tối ưu hiệu năng tốc độ thông qua đặc tính Execution Plan Caching của SQL Server.
*   **2. Nhóm Transaction (Chỉ đánh trận lớn đa bảng):** Đặt trường hợp em chỉ Update thay đổi cái "Tên khách hàng" (1 thao tác trên 1 bảng đơn lập), em hoàn toàn không cần gọi `BEGIN TRAN` làm rườm rà. Bản chất lệnh SQL đơn luôn có cơ chế ngầm tự auto-commit an toàn. Em CHỈ BẮT BUỘC thiết quân luật bằng `Transaction` khi một hành động nghiệp vụ lan truyền sửa đổi từ **2 bảng trở lên** (Kinh điển nhất là: Lưu Hóa đơn + Xóa Tồn kho Sản phẩm phải thành công một lượt).
*   **3. Nhóm Trigger (Con dao hai lưỡi - Rất hạn chế đụng tới):** Trái ngược với trường học, đi làm thực tế dân chuyên ngành không thích lạm dụng Trigger. Do bản chất Trigger là cơ chế **"Chạy Ngầm"**. Khi code nhiều Trigger ở rải rác các bảng, việc gỡ lỗi (Debug / Fix bug) trở thành ác mộng. Lập trình viên lưu data thành công trên Web nhưng dữ liệu tự dưng bốc hơi do bị một cái Trigger "mệnh lệnh ngầm" rà quét và tự động tàn phá. Thay vì dùng Trigger, Developer dạn dày kinh nghiệm sẽ mang toàn bộ logic liên đới đó viết thẳng phơi bày vào Body của 1 **Stored Procedure lớn** cho minh bạch. Trigger chỉ nên dành chuyên trị cho vị trí bảo mẫu: Âm thầm ghi lại dấu vết (Auditing logs) ai vửa sửa trộm data lúc mấy giờ.
