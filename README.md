# Ứng Dụng Quản Lý Giảng Viên (Flutter & Firebase)

Hệ thống quản lý giảng viên (ADMIN) đa nền tảng (Web & Android) xây dựng bằng Flutter kết hợp Firebase Authentication và Cloud Firestore.

Tài liệu chi tiết và hướng dẫn nộp bài xem tại: [BAOCAO.md](BAOCAO.md)

---

## 1. Cấu trúc thư mục

```
lib/
├── main.dart                          # Khởi tạo Firebase, runApp
├── firebase_options.dart              # Cấu hình Firebase Web & Android
├── app/
│   ├── app.dart                       # Root MaterialApp, điều hướng theo trạng thái auth
│   └── theme.dart                     # Material 3 theme, tông màu deep navy
├── models/
│   └── lecturer.dart                  # Model Lecturer (IDGV, Fullname, Image, SumClass)
├── data/
│   ├── auth_service.dart              # Xử lý đăng nhập / đăng xuất Firebase Auth
│   ├── lecturer_repository.dart       # Interface repository
│   ├── firestore_lecturer_repository.dart  # Firestore CRUD thật với collection 'GiangVien'
│   ├── in_memory_lecturer_repository.dart  # Repository bộ nhớ tạm phục vụ unit test
│   └── image_service.dart             # Xử lý chọn ảnh (image_picker), nén JPEG và Base64
├── screens/
│   ├── login_screen.dart              # Màn hình đăng nhập quản trị
│   ├── lecturer_list_screen.dart      # Danh sách, dashboard, tìm kiếm, sắp xếp, lọc, xuất JSON
│   ├── lecturer_form_screen.dart      # Form thêm / chỉnh sửa giảng viên, preview ảnh
│   └── lecturer_detail_screen.dart    # Chi tiết giảng viên
└── widgets/
    └── lecturer_avatar.dart           # Widget hiển thị ảnh linh hoạt (URL / Base64 / Placeholder)
```

---

## 2. Các lệnh thực thi

```bash
# Cài đặt thư viện
flutter pub get

# Chạy trên trình duyệt Web (Chrome)
flutter run -d chrome

# Chạy trên Android Emulator
flutter run -d emulator-5554

# Chạy toàn bộ test
flutter test --reporter=expanded

# Kiểm tra phân tích mã nguồn
flutter analyze

# Build bản Web
flutter build web

# Build bản Android debug APK
flutter build apk --debug
```

---

## 3. Schema Firestore (`GiangVien`)

Đảm bảo đúng 4 trường theo yêu cầu của đề bài:

| Tên trường | Kiểu dữ liệu | Mô tả |
|---|---|---|
| `IDGV` | String | Mã giảng viên (khóa chính, trùng với Document ID) |
| `Fullname` | String | Họ và tên giảng viên |
| `Image` | String | URL ảnh hoặc chuỗi Base64 Data URI |
| `SumClass` | Integer | Tổng số lớp giảng dạy (>= 0) |

---

## 4. Bảo mật Firestore (Security Rules)

Quy tắc bảo mật mẫu nằm tại `firestore.rules`.
- Chỉ tài khoản Admin (UID định sẵn) mới có quyền đọc/ghi.
- Bắt buộc kiểm tra chỉ có đúng 4 trường `IDGV`, `Fullname`, `Image`, `SumClass` và kiểm tra kiểu dữ liệu.
- `IDGV` không thể bị sửa đổi sau khi tạo.
