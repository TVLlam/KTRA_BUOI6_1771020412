# 🍽️ Restaurant App - Flutter Firebase Project

> **Đồ án môn học:** Lập trình Mobile - Đề số 05
> **Sinh viên:** Trần Văn Lâm
> **Mã SV:** 1771020412
> **Lớp:** [Điền lớp của bạn vào đây]

## 📱 Giới thiệu
Ứng dụng quản lý đặt bàn và gọi món cho nhà hàng, được xây dựng bằng **Flutter** kết hợp với **Firebase (Firestore & Authentication)**. Ứng dụng hỗ trợ quy trình khép kín từ lúc Khách hàng đăng ký, xem menu, đặt bàn cho đến khi Admin duyệt đơn và Khách thanh toán tích điểm.

---

## 🔥 Tính năng nổi bật (Highlights)

### 1. Phía Khách hàng (Customer)
- **🔐 Xác thực:** Đăng ký tài khoản với đầy đủ thông tin (Sở thích ăn uống Multi-select, SĐT, Địa chỉ).
- **📋 Menu thông minh:**
  - Tìm kiếm món ăn theo tên.
  - Lọc theo danh mục (Món chính, Khai vị, Đồ uống...).
  - **Bộ lọc nâng cao:** Lọc món Chay (🥬) / Món Cay (🌶️).
- **🛒 Đặt bàn & Giỏ hàng:** Chọn ngày giờ, số lượng khách và ghi chú đặc biệt.
- **🎁 Hệ thống tích điểm (Loyalty Points):**
  - Tích 1% giá trị hóa đơn sau mỗi lần thanh toán.
  - Sử dụng điểm để giảm giá (1 điểm = 1.000đ).
  - Giới hạn giảm tối đa 50% tổng hóa đơn.
- **📜 Lịch sử đặt bàn:** Theo dõi trạng thái đơn hàng (Chờ duyệt, Đã xác nhận, Đang dùng bữa, Hoàn thành, Hủy).

### 2. Phía Quản trị (Admin)
- **🛠️ Quản lý đơn hàng:**
  - Xem danh sách tất cả đơn đặt bàn.
  - Duyệt đơn (`Pending` → `Confirmed`).
  - Xếp bàn cho khách (`Confirmed` → `Seated`).
- **⚙️ Công cụ hỗ trợ:** Nút "Magic Wand" tự động cập nhật dữ liệu mẫu cho các món ăn (Random thuộc tính Chay/Cay).

---

## 📸 Demo Ứng dụng

| Màn hình chính | Chi tiết món | Giỏ hàng | Lịch sử & Thanh toán |
|:---:|:---:|:---:|:---:|
| <img src="screenshots/home.png" width="200"/> | <img src="screenshots/detail.png" width="200"/> | <img src="screenshots/cart.png" width="200"/> | <img src="screenshots/history.png" width="200"/> |

*(Lưu ý: Bạn cần chụp ảnh màn hình app và lưu vào thư mục `screenshots` trong project để hiển thị ảnh)*

---

## 🛠️ Công nghệ sử dụng

- **Ngôn ngữ:** Dart
- **Framework:** Flutter SDK
- **Backend:** Google Firebase
  - **Firebase Auth:** Quản lý đăng nhập/đăng ký.
  - **Cloud Firestore:** Cơ sở dữ liệu NoSQL thời gian thực (Real-time).
- **Kiến trúc:** Repository Pattern (Tách biệt UI và xử lý dữ liệu).

---

## 🚀 Hướng dẫn cài đặt & Chạy

### 1. Yêu cầu môi trường
- Flutter SDK (phiên bản mới nhất).
- Máy ảo Android/iOS hoặc thiết bị thật.

### 2. Cấu hình Firebase
*Lưu ý: Project này cần file cấu hình của Firebase để chạy.*
1. Tạo project trên [Firebase Console](https://console.firebase.google.com/).
2. Tải file `google-services.json` (cho Android) và đặt vào thư mục `android/app/`.
3. (Tùy chọn) Tải file `GoogleService-Info.plist` (cho iOS) và đặt vào thư mục `ios/Runner/`.

### 3. Chạy ứng dụng
Mở terminal tại thư mục gốc của dự án và chạy các lệnh:

```bash
# Cài đặt các thư viện
flutter pub get

# Chạy ứng dụng
flutter run