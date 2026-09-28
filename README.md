# HƯỚNG DẪN THỰC HÀNH BÀI TẬP VỀ NHÀ MÔN LẬP TRÌNH WEB (LỚP 59KMT)
**Đề tài**: Triển khai hệ thống Web Fullstack đa dịch vụ với Docker Compose trên Fedora Linux, Nginx đa tên miền, Node-RED Backend kết nối MariaDB, quản trị phpMyAdmin, Cloudflare Tunnel và Web Frontend HTML/JS bảo mật thông tin.

---

## MỤC LỤC
1. [Kiến trúc hệ thống & Luồng hoạt động](#1-kien-truc-he-thong)
2. [Chuẩn bị môi trường trên Fedora Linux](#2-chuan-bi-fedora)
3. [Cấu trúc thư mục dự án](#3-cau-truc-thu-muc)
4. [File docker-compose.yml hoàn chỉnh (5 dịch vụ)](#4-docker-compose)
5. [Cấu hình Nginx chạy 2 Website 2 Domain & Proxy sang Node-RED](#5-cau-hinh-nginx)
6. [Quản trị cơ sở dữ liệu MariaDB với phpMyAdmin](#6-mariadb-phpmyadmin)
7. [Cấu hình Node-RED & Cài đặt thư viện MySQL](#7-nodered-config)
8. [Code Frontend Web (HTML + JS) Bảo Mật & Duy Trì Đăng Nhập](#8-frontend-code)
9. [Cấu hình Cloudflare Tunnel với Tên miền riêng (Domain xịn)](#9-cloudflare-tunnel)
10. [Kiểm thử kết quả theo yêu cầu bài tập](#10-kiem-thu)

---

## 1. Kiến trúc hệ thống & Luồng hoạt động
Hệ thống gồm 5 thành phần chính phối hợp trong mạng nội bộ Docker:
- **Cloudflare Edge (HTTPS)**: Nhận truy cập từ internet qua tên miền riêng, chuyển tiếp bảo mật qua Cloudflare Tunnel mà không cần mở port modem.
- **NGINX (Port 80/443)**: Reverse proxy định tuyến 2 tên miền độc lập (Virtual Hosts). Điều hướng trang tĩnh từ thư mục `./html` và chuyển tiếp yêu cầu `/api/*` sang Node-RED.
- **Node-RED (Port 1880)**: Đóng vai trò Backend API xử lý logic xác thực đăng nhập `/api/login` và trả danh sách bí mật `/api/remu`. Có giao diện Editor được bảo mật bằng `adminAuth` mật khẩu băm bcrypt.
- **MariaDB (Port 3306)**: Lưu trữ bảng `users` (tài khoản đăng nhập) và bảng `dssv` (danh sách sinh viên kèm tiền quỹ mật).
- **phpMyAdmin (Port 8080)**: Giao diện trực quan để sinh viên quản trị DB, tạo bảng, nhập dữ liệu.

---

## 2. Chuẩn bị môi trường trên Fedora Linux
Kiểm tra Docker và Docker Compose trên Fedora:
```bash
docker --version
docker compose version
```
Nếu chưa phân quyền cho user hiện tại:
```bash
sudo usermod -aG docker $USER
newgrp docker
```
![[Pasted image 20260928102352.png]]


---

## 3. Cấu trúc thư mục dự án
```
baitap_59kmt/
├── docker-compose.yml
├── nginx/
│   └── nginx.conf
├── nodered/
│   ├── settings.js
│   └── flows.json
├── mariadb/
│   └── init.sql
├── html/
│   ├── site1/
│   │   └── index.html        <-- Web chính (Đăng nhập, xem thông tin mật 59KMT)
│   └── site2/
│       └── index.html        <-- Website thứ 2 chạy trên domain khác
└── cloudflared/
    └── config.yml
```

---

## 4. File docker-compose.yml hoàn chỉnh
Được config tại thư mục gốc của đề tài. 5 dịch vụ được cấu hình kết nối qua network `remu_net`.

---

## 5. Cấu hình Nginx 2 Domain & Proxy API
Nginx sử dụng 2 khối `server` riêng:
- `server_name remuk235480106063.id.vn`: Root tới `site1`, location `/api/` proxy sang `http://nodered:1880/api/` kèm CORS headers.
- `server_name site2.remuk235480106063.id.vn`: Root tới `site2` độc lập.

---

## 6. Quản trị cơ sở dữ liệu MariaDB với phpMyAdmin
Truy cập `http://localhost:8080`, đăng nhập bằng user `root` và pass `05012005`.
Cơ sở dữ liệu `Remu_db` được khởi tạo tự động từ file `mariadb/init.sql`.
![[Pasted image 20260928115122.png]]

---

## 7. Cấu hình Node-RED & Cài đặt thư viện MySQL
### 7.1. Cài đặt thư viện node-red-node-mysql:
- **Cách 1 (Giao diện)**: Vào menu ☰ -> Manage palette -> tab Install -> tìm `node-red-node-mysql` -> Install.
- **Cách 2 (Terminal)**: `docker exec -it remu_nodered npm install node-red-node-mysql && docker restart remu_nodered`
Kiểm tra kết quả:
![[Pasted image 20260928101735.png]]

### 7.2. Bắt buộc đăng nhập tại settings.js:
Cấu hình `adminAuth` với chuỗi bcrypt hash tạo từ công cụ tại tab **"Tạo Hash Mật Khẩu"**.

### 7.3. Tạo API Flow:
Import file `flows.json` bao gồm:
- `POST /api/login`: Xác thực `uid` và `pwd` trong MariaDB, tạo session token.
- `GET /api/remu`: Kiểm tra token, truy vấn bảng `dssv` và trả về đúng định dạng:
`{"ok":1,"msg":"thành công","dssv":[{"name":"Remu","money":123},{"name":"TrongTan","money":456}]}`

---

## 8. Code Frontend Web (HTML + JS)
- Lưu trữ token vào `localStorage.setItem('remu_auth_token', token)`.
- Tự động kiểm tra token khi tải trang để **Duy trì đăng nhập**.
- Nếu mở bằng **trình duyệt ẩn danh (Incognito)**, `localStorage` trống rỗng nên lập tức bị chặn xem dữ liệu mật.
- Nút **Đăng xuất** xóa token và đưa về màn hình đăng nhập.

---

## 9. Cấu hình Cloudflare Tunnel với Domain cá nhân
1. Đăng nhập Cloudflare Zero Trust -> Networks -> Tunnels -> Create tunnel.
2. Sao chép `TUNNEL_TOKEN` dán vào biến môi trường trong `docker-compose.yml`.
3. Thêm 2 Public Hostname trỏ tới `http://nginx:80`.
![[Pasted image 20260928101904.png]]

---

## 10. Kiểm thử & Nghiệm thu
Chạy `docker compose up -d`, kiểm tra logs bằng `docker compose logs -f` và nghiệm thu tất cả tiêu chí của đề bài!
Sử dụng Docker Desktop để kiểm tra Images và Containers sau khi sử dụng lệnh `docker compose up -d`. Có thể xem logs bằng HUD thay vì sử dụng lệnh.
![[Pasted image 20260928101506.png]]
Chạy web thông qua một thiết bị khác không chung đường mạng ví dụ như điện thoại sử dụng 4G/5G.
![[Pasted image 20260928115916.png]]
![[Pasted image 20260928115953.png]]