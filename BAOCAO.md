# Báo cáo Đồ án: Ứng dụng Quản lý Giảng Viên

## 1. Môi trường phát triển

| Mục | Phiên bản |
|---|---|
| Hệ điều hành | Windows 11 |
| Flutter | 3.47.9 stable |
| Dart | 3.13.7 |
| Firebase CLI | ≥ 13.x |
| IDE | VS Code / Android Studio |
| Trình duyệt | Google Chrome |
| Thiết bị kiểm thử | Android Emulator (API 34) |

---

## 2. Thư viện và lệnh cài đặt

Tất cả phụ thuộc đã khai báo trong `pubspec.yaml`. Chạy lệnh sau để cài:

```bash
flutter pub get
```

| Thư viện | Phiên bản | Mục đích |
|---|---|---|
| `firebase_core` | ^5.1.0 | Khởi tạo Firebase |
| `cloud_firestore` | ^7.1.0 | Cơ sở dữ liệu Firestore |
| `firebase_auth` | ^7.0.1 | Xác thực email/password |
| `image_picker` | ^1.2.4 | Chọn ảnh từ thiết bị |

> Không dùng Firebase Storage (Spark plan). Ảnh được lưu dưới dạng Base64 trong trường `Image` (giới hạn 80 kB sau khi nén).

---

## 3. Kiến trúc ứng dụng

```
lib/
├── main.dart                        ← Khởi tạo Firebase, runApp
├── firebase_options.dart            ← Cấu hình tự động bởi FlutterFire CLI
├── app/
│   ├── app.dart                     ← Root widget, auth-state router
│   └── theme.dart                   ← Material 3, bảng màu deep navy
├── models/
│   └── lecturer.dart                ← Model Lecturer (4 trường Firestore)
├── data/
│   ├── auth_service.dart            ← Wrapper Firebase Auth
│   ├── lecturer_repository.dart     ← Interface repository (abstract)
│   ├── firestore_lecturer_repository.dart ← Triển khai Firestore thực
│   ├── in_memory_lecturer_repository.dart ← Triển khai trong bộ nhớ (test)
│   └── image_service.dart           ← Chọn & nén ảnh, mã hóa Base64
├── screens/
│   ├── login_screen.dart            ← Đăng nhập email/password
│   ├── lecturer_list_screen.dart    ← Danh sách, dashboard, tìm kiếm, sắp xếp
│   ├── lecturer_form_screen.dart    ← Thêm / chỉnh sửa giảng viên
│   └── lecturer_detail_screen.dart  ← Chi tiết giảng viên
└── widgets/
    └── lecturer_avatar.dart         ← Hiển thị ảnh (URL, Base64 hoặc placeholder)
```

**Luồng xác thực:**  
`Firebase.authStateChanges` → nếu `user == null` hiển thị `LoginScreen`, ngược lại `LecturerListScreen`.

---

## 4. Cơ sở dữ liệu

**Collection:** `GiangVien`  
**Document ID:** Giá trị `IDGV` của giảng viên

| Trường | Kiểu Firestore | Ý nghĩa |
|---|---|---|
| `IDGV` | String | Mã giảng viên duy nhất |
| `Fullname` | String | Họ và tên |
| `Image` | String | URL ảnh hoặc chuỗi Base64 data URI |
| `SumClass` | Integer | Số lớp đang dạy (≥ 0) |

> **Bất biến:** Không thêm bất kỳ trường nào khác ngoài 4 trường trên.

---

## 5. Màn hình và chức năng

| Màn hình | Chức năng |
|---|---|
| Đăng nhập | Email/password, hiển thị lỗi tiếng Việt, duy trì phiên |
| Danh sách giảng viên | Dashboard (tổng GV, tổng lớp), bảng (Web)/thẻ (mobile), tìm kiếm, sắp xếp |
| Thêm/Sửa | Validation đầy đủ, chọn ảnh, preview ảnh, lỗi IDGV trùng |
| Chi tiết | Hiển thị ảnh lớn, nút sửa/xóa |
| Xuất JSON | Dữ liệu Firestore → chuỗi JSON với 4 trường chính xác |

---

## 6. Chạy ứng dụng

### Web (Chrome)
```bash
flutter run -d chrome
```

### Android Emulator
```bash
flutter run -d emulator-5554
```

### Build Web (production)
```bash
flutter build web
```

### Build APK debug
```bash
flutter build apk --debug
```

---

## 7. Xác minh dữ liệu Firebase

1. Mở [Firebase Console](https://console.firebase.google.com)
2. Chọn project **flutter-midterm-practice**
3. Vào **Firestore Database → GiangVien**
4. Kiểm tra document có đúng 4 trường: IDGV, Fullname, Image, SumClass

---

## 8. Security Rules

File: `firestore.rules`

Quy tắc bảo mật yêu cầu:
- Chỉ admin UID được phép đọc/ghi collection `GiangVien`
- Document phải có đúng 4 trường, đúng kiểu
- `IDGV` không được thay đổi khi cập nhật
- Mọi collection khác bị từ chối

**Để triển khai (cần approval của người dùng):**
```bash
firebase deploy --only firestore:rules
```

**Để lấy Admin UID:**  
Firebase Console → Authentication → Users → Copy UID

---

## 9. Xuất dữ liệu JSON

Trong ứng dụng: nhấn nút **Xuất JSON** trên thanh công cụ.  
Dữ liệu hiển thị dạng có thể sao chép, mỗi document gồm đúng 4 trường.

Ví dụ:
```json
[
  {
    "IDGV": "GV001",
    "Fullname": "Nguyễn Văn A",
    "Image": "https://example.com/avatar.jpg",
    "SumClass": 3
  }
]
```

---

## 10. Checklist ảnh chụp màn hình

- [ ] Màn hình đăng nhập
- [ ] Thông báo lỗi đăng nhập
- [ ] Dashboard (tổng giảng viên + tổng lớp)
- [ ] Bảng danh sách giảng viên (Web)
- [ ] Danh sách thẻ (Android)
- [ ] Form thêm giảng viên (validation)
- [ ] Chọn ảnh từ thiết bị
- [ ] Preview ảnh trong form
- [ ] Form chỉnh sửa (IDGV bị khóa)
- [ ] Hộp thoại xác nhận xóa
- [ ] Thông báo thành công (SnackBar)
- [ ] Dữ liệu JSON xuất ra
- [ ] Firebase Console — collection GiangVien
- [ ] Đăng xuất

---

## 11. Script demo (2–3 phút)

1. **Mở Chrome** → `flutter run -d chrome` → hiển thị màn hình đăng nhập
2. **Đăng nhập** bằng tài khoản admin → chuyển sang màn hình quản lý
3. **Dashboard** hiển thị tổng giảng viên và tổng lớp từ Firestore
4. **Thêm giảng viên**: nhấn "+", nhập GV001, Nguyễn Văn A, chọn ảnh, 3 lớp → Lưu
5. **Kiểm tra Firestore**: mở Console → GiangVien → thấy document GV001
6. **Chỉnh sửa**: mở GV001 → thay đổi SumClass → Lưu → xác nhận update trên Console
7. **Thử IDGV trùng**: thêm GV001 lại → thấy thông báo lỗi tiếng Việt
8. **Tìm kiếm**: nhập "Nguyễn" → lọc kết quả
9. **Sắp xếp**: nhấn "Họ tên" → danh sách sắp xếp theo tên
10. **Xuất JSON**: nhấn "Xuất JSON" → thấy dữ liệu với 4 trường
11. **Trên Android**: mở emulator → đăng nhập → chọn ảnh từ gallery → xem ảnh hiển thị
12. **Xóa**: xác nhận xóa giảng viên → SnackBar thông báo
13. **Đăng xuất**: nhấn biểu tượng đăng xuất → quay lại màn hình đăng nhập

---

## 12. Những gì đã kiểm thử tự động

| Kiểm thử | Kết quả | Chi tiết |
|---|---|---|
| `dart format lib/ test/` | ✅ Thành công | 25 files được format chuẩn quy cách |
| `flutter analyze` | ✅ 0 lỗi / cảnh báo | Không có warning, không có error |
| `flutter test` | ✅ 41 / 41 test pass | Bao quát Model, Repository, Image/Base64 và Widget validation |
| `flutter build web` | ✅ Thành công | Tạo thư mục `build\web` production |
| `flutter build apk --debug` | ✅ Thành công | Tạo file `build\app\outputs\flutter-apk\app-debug.apk` |
| Cài đặt & khởi chạy trên Android Emulator | ✅ Thành công | `adb install -r` và khởi chạy MainActivity thành công, Impeller backend chạy ổn định |

## 13. Những gì cần kiểm thử thủ công

- Đăng nhập thực tế với Firebase Auth
- Thao tác CRUD trên Firestore thực
- Chọn ảnh trên Chrome và Android
- Xác minh dữ liệu tồn tại sau khi tải lại trang
- Kiểm tra Security Rules sau khi triển khai

---

## 14. Hạn chế đã biết

| Hạn chế | Nguyên nhân | Giải pháp tương lai |
|---|---|---|
| Ảnh tối đa 80 kB | Spark plan — không có Storage | Nâng Blaze, dùng Firebase Storage |
| Không tải file JSON | Web API hạn chế | Thêm `universal_html` hoặc `dart:html` |
| Không có multi-admin | Đề bài không yêu cầu | Thêm Firestore role field |
