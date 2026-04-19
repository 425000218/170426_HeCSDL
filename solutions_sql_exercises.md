# SQL Exercises – Solutions with Detailed Comments

> **File:** `bt SQL thongtinbanhang4table - query store procedure trigger_.sql`
>
> This document contains full implementations for all stored procedures, transactions, and triggers requested in the original exercise file. Each statement is annotated line‑by‑line, and after each block a **NOTE** explains what would happen if a particular line were omitted or written incorrectly.

---

## Part 1 – Stored Procedures (No Parameters / Input Parameters)

### 1️⃣ `sp_TatCaSanPham` – List all products
```sql
CREATE PROCEDURE sp_TatCaSanPham
AS
BEGIN
    -- 1. Set NOCOUNT ON to suppress the "X rows affected" messages.
    SET NOCOUNT ON;

    -- 2. Select all columns from the SanPham table.
    SELECT *
    FROM   SanPham;
END;
GO
```
**NOTE:**
- If `SET NOCOUNT ON` is omitted, client applications that expect a single result set may receive extra “X rows affected” messages, potentially causing parsing errors.
- Missing the `SELECT *` line would result in an empty procedure that returns nothing, leading to “no result set” errors when the procedure is called.

---

### 2️⃣ `sp_TimKhachHang` – Find a customer by `MaKH`
```sql
CREATE PROCEDURE sp_TimKhachHang
    @MaKH CHAR(5)   -- Input parameter: customer code
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM   KhachHang
    WHERE  MaKH = @MaKH;   -- Filter by the supplied customer code
END;
GO
```
**NOTE:**
- Forgetting the `WHERE` clause would return *all* customers, not the intended single record.
- Declaring the parameter with the wrong datatype (e.g., `INT`) would cause conversion errors when a string code is passed.

---

### 3️⃣ `sp_HoaDonTheoNgay` – List invoices for a given date
```sql
CREATE PROCEDURE sp_HoaDonTheoNgay
    @Ngay DATE   -- Input parameter: the target date
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM   HoaDon
    WHERE  CAST(NgayLap AS DATE) = @Ngay;   -- Compare only the date part
END;
GO
```
**NOTE:**
- Using `= @Ngay` directly on a `DATETIME` column could miss rows where the time part is non‑midnight. Casting to `DATE` ensures a proper match.
- If the `@Ngay` parameter is omitted, the procedure will not compile.

---

### 4️⃣ `sp_SanPhamGiaCao` – Products with price > X
```sql
CREATE PROCEDURE sp_SanPhamGiaCao
    @GiaMin MONEY   -- Input parameter: minimum price threshold
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM   SanPham
    WHERE  DonGia > @GiaMin;   -- Return products priced higher than @GiaMin
END;
GO
```
**NOTE:**
- Using `>=` instead of `>` would include products priced exactly at the threshold, which may not meet the “greater than X” requirement.
- If `@GiaMin` is `NULL`, the `WHERE` clause evaluates to UNKNOWN and returns no rows.

---

### 5️⃣ `sp_ChiTietMuaHang` – Details of a specific invoice
```sql
CREATE PROCEDURE sp_ChiTietMuaHang
    @MaHD CHAR(5)   -- Input parameter: invoice code
AS
BEGIN
    SET NOCOUNT ON;

    SELECT sp.TenSP, cthd.SoLuong
    FROM   CTHD cthd
           INNER JOIN SanPham sp ON cthd.MaSP = sp.MaSP
    WHERE  cthd.MaHD = @MaHD;   -- Show product name and quantity for the invoice
END;
GO
```
**NOTE:**
- Omitting the `INNER JOIN` would leave you with only product IDs, not readable names.
- Forgetting the `WHERE` clause would list *all* invoice details, potentially exposing unrelated data.

---

## Part 2 – Stored Procedures with OUTPUT Parameters

### 1️⃣ Total number of invoices for a customer
```sql
CREATE PROCEDURE sp_TongHoaDon_KH
    @MaKH CHAR(5),
    @TongHoaDon INT OUTPUT   -- Output: count of invoices
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @TongHoaDon = COUNT(*)
    FROM   HoaDon
    WHERE  MaKH = @MaKH;
END;
GO
```
**NOTE:**
- If the `OUTPUT` keyword is omitted, the caller cannot retrieve the value.
- Not initializing `@TongHoaDon` may leave it `NULL` when the customer has no invoices.

---

### 2️⃣ Total amount of a specific invoice
```sql
CREATE PROCEDURE sp_TongThanhTien_HD
    @MaHD CHAR(5),
    @TongTien MONEY OUTPUT   -- Output: total amount (Qty * UnitPrice)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @TongTien = SUM(cthd.SoLuong * sp.DonGia)
    FROM   CTHD cthd
           INNER JOIN SanPham sp ON cthd.MaSP = sp.MaSP
    WHERE  cthd.MaHD = @MaHD;
END;
GO
```
**NOTE:**
- Using `SUM` without handling `NULL` may return `NULL` for an empty invoice; you can coalesce to `0` if desired.
- Forgetting the `INNER JOIN` would cause `DonGia` to be undefined.

---

### 3️⃣ Total quantity sold for a product across all invoices
```sql
CREATE PROCEDURE sp_TongSoLuongBan_SP
    @MaSP CHAR(5),
    @TongSoLuong INT OUTPUT   -- Output: total quantity sold
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @TongSoLuong = ISNULL(SUM(cthd.SoLuong),0)
    FROM   CTHD cthd
    WHERE  cthd.MaSP = @MaSP;
END;
GO
```
**NOTE:**
- Without `ISNULL`, the output would be `NULL` when the product has never been sold, which may break client logic expecting a numeric value.

---

### 4️⃣ Product with the highest price
```sql
CREATE PROCEDURE sp_SanPhamGiaCaoNhat
    @MaSPMax CHAR(5) OUTPUT   -- Output: product code of the most expensive product
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 1 @MaSPMax = MaSP
    FROM   SanPham
    ORDER BY DonGia DESC;   -- Highest price first
END;
GO
```
**NOTE:**
- Using `TOP 1` without `ORDER BY` would return an arbitrary product, not necessarily the most expensive.
- If there are ties, this returns the first encountered; you may need additional logic to handle multiple max‑price products.

---

### 5️⃣ Total revenue for a given month/year
```sql
CREATE PROCEDURE sp_DoanhThu_Thang
    @Thang INT,          -- 1‑12
    @Nam   INT,          -- e.g., 2024
    @DoanhThu MONEY OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @DoanhThu = ISNULL(SUM(cthd.SoLuong * sp.DonGia),0)
    FROM   HoaDon hd
           INNER JOIN CTHD cthd ON hd.MaHD = cthd.MaHD
           INNER JOIN SanPham sp ON cthd.MaSP = sp.MaSP
    WHERE  MONTH(hd.NgayLap) = @Thang
       AND YEAR(hd.NgayLap)   = @Nam;
END;
GO
```
**NOTE:**
- Forgetting `MONTH`/`YEAR` filters would sum *all* revenue, not just the specified month.
- Using `DATEPART` instead of `MONTH`/`YEAR` works as well; just be consistent.

---

## Part 3 – Transactions

### 1️⃣ Insert a new customer and its first invoice (all‑or‑nothing)
```sql
BEGIN TRANSACTION Tran_ThemKH_Va_HoaDon;
    BEGIN TRY
        -- 1. Insert new customer
        INSERT INTO KhachHang (MaKH, TenKH, DiaChi, DienThoai)
        VALUES ('KH999', N'Nguyễn Văn A', N'123 Đường ABC', '0900123456');

        -- 2. Insert first invoice for that customer
        INSERT INTO HoaDon (MaHD, MaKH, NgayLap)
        VALUES ('HD999', 'KH999', GETDATE());

        COMMIT TRANSACTION Tran_ThemKH_Va_HoaDon;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION Tran_ThemKH_Va_HoaDon;
        THROW;  -- Propagate the error
    END CATCH;
GO
```
**NOTE:**
- If `COMMIT` is omitted, the transaction stays open and locks rows, potentially causing deadlocks.
- If `ROLLBACK` is omitted in the `CATCH` block, the transaction remains uncommitted after an error, again leading to locks.

---

### 2️⃣ Reduce price of *Laptop* by 10 % and update `DonGiaBan` in `CTHD`; rollback if new price < 500
```sql
BEGIN TRANSACTION Tran_GiamGia_Laptop;
    BEGIN TRY
        -- 1. Compute new price
        DECLARE @NewPrice MONEY;
        SELECT @NewPrice = DonGia * 0.9
        FROM   SanPham
        WHERE  TenSP = N'Laptop';

        -- 2. Guard clause – abort if price would drop below 500
        IF @NewPrice < 500
        BEGIN
            RAISERROR('Giá giảm xuống dưới 500, rollback transaction.', 16, 1);
        END;

        -- 3. Update product price
        UPDATE SanPham
        SET    DonGia = @NewPrice
        WHERE  TenSP = N'Laptop';

        -- 4. Propagate new price to existing invoice details (if any)
        UPDATE cthd
        SET    DonGiaBan = @NewPrice
        FROM   CTHD cthd
               INNER JOIN SanPham sp ON cthd.MaSP = sp.MaSP
        WHERE  sp.TenSP = N'Laptop';

        COMMIT TRANSACTION Tran_GiamGia_Laptop;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION Tran_GiamGia_Laptop;
        THROW;
    END CATCH;
GO
```
**NOTE:**
- Omitting the `RAISERROR` guard would allow the price to go below 500, violating the business rule.
- Forgetting the `UPDATE CTHD` step would leave historic invoice lines with the old price, causing inconsistency.

---

### 3️⃣ Delete an invoice safely (remove details first)
```sql
BEGIN TRANSACTION Tran_XoaHoaDon;
    BEGIN TRY
        -- 1. Delete child rows in CTHD
        DELETE FROM CTHD
        WHERE  MaHD = @MaHD;   -- @MaHD should be supplied before running

        -- 2. Delete the parent invoice
        DELETE FROM HoaDon
        WHERE  MaHD = @MaHD;

        COMMIT TRANSACTION Tran_XoaHoaDon;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION Tran_XoaHoaDon;
        THROW;
    END CATCH;
GO
```
**NOTE:**
- If the `DELETE FROM CTHD` step is skipped, the foreign‑key constraint (if defined) will raise an error and the transaction will roll back automatically.
- Not wrapping in a transaction could leave the child rows deleted while the parent remains, breaking referential integrity.

---

### 4️⃣ Move a line‑item from invoice 101 to invoice 102
```sql
BEGIN TRANSACTION Tran_ChuyenHangHoa;
    BEGIN TRY
        DECLARE @MaSP CHAR(5), @SoLuong INT;

        -- 1. Capture the line‑item to be moved (assume a single product per line)
        SELECT @MaSP = MaSP, @SoLuong = SoLuong
        FROM   CTHD
        WHERE  MaHD = 'HD101'   -- source invoice
               AND MaSP = @TargetMaSP;   -- set @TargetMaSP before execution

        -- 2. Remove it from the source invoice
        DELETE FROM CTHD
        WHERE  MaHD = 'HD101'
               AND MaSP = @TargetMaSP;

        -- 3. Insert (or update) it into the destination invoice
        IF EXISTS (SELECT 1 FROM CTHD WHERE MaHD = 'HD102' AND MaSP = @TargetMaSP)
        BEGIN
            UPDATE CTHD
            SET    SoLuong = SoLuong + @SoLuong
            WHERE  MaHD = 'HD102' AND MaSP = @TargetMaSP;
        END
        ELSE
        BEGIN
            INSERT INTO CTHD (MaHD, MaSP, SoLuong, DonGiaBan)
            SELECT 'HD102', @MaSP, @SoLuong, sp.DonGia
            FROM   SanPham sp
            WHERE  sp.MaSP = @MaSP;
        END

        COMMIT TRANSACTION Tran_ChuyenHangHoa;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION Tran_ChuyenHangHoa;
        THROW;
    END CATCH;
GO
```
**NOTE:**
- Forgetting the `IF EXISTS` check could create duplicate rows for the same product in the destination invoice.
- Not wrapping the whole operation in a transaction could leave the line‑item deleted from the source but not inserted into the destination if an error occurs.

---

## Part 4 – Triggers

### 1️⃣ `trg_CheckDonGia` on **SanPham** – Prevent negative price
```sql
CREATE TRIGGER trg_CheckDonGia
ON   SanPham
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Raise an error if any inserted/updated row has DonGia < 0
    IF EXISTS (SELECT 1 FROM inserted WHERE DonGia < 0)
    BEGIN
        RAISERROR('DonGia không được nhỏ hơn 0.', 16, 1);
        ROLLBACK TRANSACTION;   -- Abort the DML statement
    END
END;
GO
```
**NOTE:**
- Using `AFTER` ensures the check runs *after* the row is written but before the transaction commits. If you used `INSTEAD OF`, you would need to manually perform the insert/update.
- Omitting `ROLLBACK` would allow the row with a negative price to be persisted despite the error message.

---

### 2️⃣ Default `DonGiaBan` in **CTHD** when omitted or zero
```sql
CREATE TRIGGER trg_DefaultDonGiaBan
ON   CTHD
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO CTHD (MaHD, MaSP, SoLuong, DonGiaBan)
    SELECT
        i.MaHD,
        i.MaSP,
        i.SoLuong,
        CASE
            WHEN i.DonGiaBan IS NULL OR i.DonGiaBan = 0
                THEN sp.DonGia   -- fetch price from SanPham
            ELSE i.DonGiaBan
        END AS DonGiaBan
    FROM inserted i
    LEFT JOIN SanPham sp ON i.MaSP = sp.MaSP;
END;
GO
```
**NOTE:**
- An `INSTEAD OF INSERT` trigger replaces the original insert, allowing us to supply a default value.
- If you used an `AFTER INSERT` trigger, you would need an additional `UPDATE` statement, which could cause a second write‑lock and is less efficient.
- Forgetting the `LEFT JOIN` would cause `NULL` for `DonGiaBan` when the product does not exist, leading to a constraint violation.

---

### 3️⃣ Prevent deletion of a customer that has invoices
```sql
CREATE TRIGGER trg_PreventDeleteKhachHang
ON   KhachHang
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM HoaDon hd JOIN deleted d ON hd.MaKH = d.MaKH)
    BEGIN
        RAISERROR('Không được xóa khách hàng đã có hóa đơn.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- If no invoices, allow the delete to proceed
    DELETE FROM KhachHang
    WHERE MaKH IN (SELECT MaKH FROM deleted);
END;
GO
```
**NOTE:**
- Using `INSTEAD OF DELETE` gives us the chance to abort before any row is removed. An `AFTER DELETE` trigger would be too late—the row would already be gone.
- Omitting the `JOIN` check would allow deletion regardless of existing invoices, violating business rules.

---

### 4️⃣ Auto‑update `NgayLap` to current date on invoice edit
```sql
CREATE TRIGGER trg_UpdateNgayLap_OnHoaDon
ON   HoaDon
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE hd
    SET    NgayLap = GETDATE()
    FROM   HoaDon hd
           JOIN inserted i ON hd.MaHD = i.MaHD;
END;
GO
```
**NOTE:**
- `AFTER UPDATE` ensures the trigger fires only when an actual update occurs (not on insert).
- If you used `GETUTCDATE()` instead of `GETDATE()`, the stored time would be UTC, which may not match the local business timezone.

---

### 5️⃣ Delete an invoice automatically when its last line‑item is removed
```sql
CREATE TRIGGER trg_DeleteHoaDon_WhenEmpty
ON   CTHD
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Find invoices that now have zero detail rows
    DELETE hd
    FROM   HoaDon hd
           LEFT JOIN CTHD cthd ON hd.MaHD = cthd.MaHD
    WHERE  cthd.MaHD IS NULL   -- no remaining child rows
       AND hd.MaHD IN (SELECT DISTINCT MaHD FROM deleted);
END;
GO
```
**NOTE:**
- The `LEFT JOIN … WHERE cthd.MaHD IS NULL` pattern finds parent rows without children.
- If the trigger were `INSTEAD OF DELETE`, the original delete would never happen, and the cascade logic would break.
- Forgetting to filter by `hd.MaHD IN (SELECT … FROM deleted)` could delete *all* empty invoices in the database, not just those affected by the current operation.

---

## How to Test
1. **Create sample data** (tables `SanPham`, `KhachHang`, `HoaDon`, `CTHD`).
2. Run each stored procedure with valid and edge‑case parameters to verify output.
3. Intentionally violate trigger rules (e.g., insert a product with `DonGia = -10`) and observe the error messages.
4. Use `BEGIN TRAN … ROLLBACK` blocks around test calls to keep the demo data clean.

---

*End of solution file.*
