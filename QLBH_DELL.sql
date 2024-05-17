**Tạo CSDL QLBH_NguyenDanhKien
CREATE DATABASE QLBH_NguyenDanhKien
COLLATE utf8_unicode_ci;

USE QLBH_NguyenDanhKien;

1. Tạo 4 bảng và chèn dữ liệu vào các bảng:

**Tạo bảng
CREATE TABLE customer (
    cID INT PRIMARY KEY,
    Name VARCHAR(25),
    cAge TINYINT
);

CREATE TABLE orders (
    oID INT PRIMARY KEY,
    cID INT,
    oDate DATETIME,
    oTotalPrice INT
);

CREATE TABLE product (
    pID INT PRIMARY KEY,
    pName VARCHAR(25),
    pPrice INT
);

CREATE TABLE orderdetail (
    oID INT,
    pID INT,
    odQTY INT
);

**Liên kết bảng
ALTER TABLE `orders`
ADD FOREIGN KEY (`cID`) REFERENCES `customer` (`cID`);

ALTER TABLE `orderdetail`
ADD FOREIGN KEY (`oID`) REFERENCES `orders` (`oID`),
ADD FOREIGN KEY (`pID`) REFERENCES `product` (`pID`);

**Thêm dữ liệu
INSERT INTO `customer` (`cID`, `Name`, `cAge`) VALUES
(1, 'Minh Quan', 10),
(2, 'Ngoc Oanh', 20),
(3, 'Hong Ha', 50);

INSERT INTO `orders` (`oID`, `cID`, `oDate`, `oTotalPrice`) VALUES
(1, 1, '2006-03-21', NULL),
(2, 2, '2006-03-23', NULL),
(3, 1, '2006-03-16', NULL);

INSERT INTO `product` (`pID`, `pName`, `pPrice`) VALUES
(1, 'May Giat', 3),
(2, 'Tu Lanh', 5),
(3, 'Dieu Hoa', 7),
(4, 'Quat', 1),
(5, 'Bep Dien', 2);

INSERT INTO `orderdetail` (`oID`, `pID`, `odQTY`) VALUES
(1, 1, 3),
(1, 3, 7),
(1, 4, 2),
(2, 1, 1),
(3, 1, 8),
(2, 5, 4),
(2, 3, 3);

2. Hiển thị các thông tin gồm oID, oDate, oPrice của tất cả các hóa đơn
trong bảng Order, danh sách phải sắp xếp theo thứ tự ngày tháng, hóa
đơn mới hơn nằm trên:

SELECT oID, cID, oDate, oTotalPrice
FROM orders
ORDER BY oDate DESC;

3. Hiển thị tên và giá của các sản phẩm có giá cao nhất:

SELECT pName, pPrice
FROM product
WHERE pPrice = (SELECT MAX(pPrice) FROM product);

4. Hiển thị danh sách các khách hàng đã mua hàng, và danh sách sản
phẩm được mua bởi các khách đó:

SELECT c.Name, p.pName
FROM customer c
JOIN orders o ON c.cID = o.cID
JOIN orderdetail od ON o.oID = od.oID
JOIN product p ON od.pID = p.pID;

5. Hiển thị tên những khách hàng không mua bất kỳ một sản phẩm nào:

SELECT c.Name
FROM customer c
LEFT JOIN orders o ON c.cID = o.cID
LEFT JOIN orderdetail od ON o.oID = od.oID
WHERE od.pID IS NULL;

6. Hiển thị chi tiết của từng hóa đơn:

SELECT o.oID, o.oDate,  od.odQTY, p.pName, p.pPrice
FROM orders o
JOIN orderdetail od ON o.oID = od.oID
JOIN product p ON od.pID = p.pID;

7. Hiển thị mã hóa đơn, ngày bán và giá tiền của từng hóa đơn (giá một
hóa đơn được tính bằng tổng giá bán của từng loại mặt hàng xuất hiện
trong hóa đơn. Giá bán của từng loại được tính = odQTY*pPrice):

SELECT o.oID, o.oDate, SUM(od.odQTY*p.pPrice) AS oTotalPrice
FROM orders o
JOIN orderdetail od ON o.oID = od.oID
JOIN product p ON od.pID = p.pID
GROUP BY o.oID;

8. Tạo một view tên là Sales để hiển thị tổng doanh thu của siêu thị:

CREATE VIEW Sales AS
SELECT SUM(od.odQTY*p.pPrice) AS Sales
FROM orders o
JOIN orderdetail od ON o.oID = od.oID
JOIN product p ON od.pID = p.pID


SELECT * FROM Sales;

9. Xóa tất cả các ràng buộc khóa ngoại, khóa chính của tất cả các bảng:

ALTER TABLE orderdetail 
DROP FOREIGN KEY orderdetail_ibfk_1,
DROP FOREIGN KEY orderdetail_ibfk_2;

ALTER TABLE orders 
DROP PRIMARY KEY,
DROP FOREIGN KEY orders_ibfk_1;

ALTER TABLE customer DROP PRIMARY KEY;

ALTER TABLE product DROP PRIMARY KEY;

10.Tạo một trigger tên là cusUpdate trên bảng Customer, sao cho khi sửa
mã khách (cID) thì mã khách trong bảng Order cũng được sửa theo:
*tạo trigger
DELIMITER //
CREATE TRIGGER cusUpdate BEFORE UPDATE ON Customer
FOR EACH ROW
BEGIN
    UPDATE Orders SET cID = NEW.cID WHERE cID = OLD.cID;
END;//
DELIMITER ;

*test trigger
UPDATE customer
SET cID = 3
WHERE Name = 'Minh Quan';

11.
Tạo một stored procedure tên là delProduct nhận vào 1 tham số là tên của
một sản phẩm, strored procedure này sẽ xóa sản phẩm có tên được truyên
vào thông qua tham số, và các thông tin liên quan đến sản phẩm đó ở trong
bảng OrderDetail:

DELIMITER //
CREATE PROCEDURE delProduct(IN pName VARCHAR(25))
BEGIN
    DECLARE pID INT;

    SELECT Product.pID INTO pID FROM Product WHERE Product.pName = pName;

    DELETE FROM Product WHERE Product.pID = pID;

    DELETE FROM OrderDetail WHERE OrderDetail.pID = pID;
END;
 // DELIMITER ;