CREATE DATABASE IF NOT EXISTS Remu_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE Remu_db;

-- 1. Bảng lưu tài khoản đăng nhập (uid, pwd)
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    uid VARCHAR(50) NOT NULL UNIQUE,
    pwd VARCHAR(100) NOT NULL,
    fullname VARCHAR(100),
    role VARCHAR(20) DEFAULT 'student'
);

-- 2. Bảng lưu danh sách sinh viên & tiền quỹ mật
CREATE TABLE IF NOT EXISTS dssv (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    money INT DEFAULT 0,
    secret_note VARCHAR(255)
);

-- Thêm dữ liệu tài khoản mẫu
INSERT INTO users (uid, pwd, fullname, role) VALUES 
('admin', '123456', 'Quản Trị Viên 59KMT', 'admin'),
('remu25', '05012005', 'Remu', 'student'),
('tan25', '23112013', 'TrongTan', 'student');

-- Thêm dữ liệu mẫu danh sách sinh viên
INSERT INTO dssv (name, money, secret_note) VALUES 
('Remu', 123, 'Học bổng loại A - Đã nộp quỹ lớp'),
('TrongTan', 456, 'Học bổng xuất sắc - Quỹ thừa 456k'),
('Ram', 789, 'Thành viên ban cán sự 59KMT');
