# Bill Chillin

Dự án Flutter quản lý chi tiêu.

## Tài Liệu Dự Án

Tài liệu chi tiết về kiến trúc dự án, cấu trúc thư mục và quy trình phát triển (Clean Architecture) có thể được tìm thấy tại đây:

- [Kiến Trúc Dự Án & Quy trình phát triển](docs/PROJECT_ARCHITECTURE.md)

## Cài Đặt & Chạy Dự Án

Để chạy được dự án trên máy local, hãy làm theo các bước sau:

### 1. Yêu cầu tiên quyết

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [VS Code](https://code.visualstudio.com/) hoặc Android Studio
- [Git](https://git-scm.com/)

### 2. Cài đặt dependencies

Mở terminal tại thư mục gốc của dự án và chạy lệnh:

```bash
flutter pub get
```

### 3. Cấu hình biến môi trường (.env)

Dự án sử dụng `flutter_dotenv` để quản lý các biến môi trường (API Keys, Firebase configs).
Bạn cần tạo file `.env` từ file mẫu:

1.  Copy file `.env.example` thành `.env`:

    ```bash
    # Trên Mac/Linux
    cp .env.example .env

    # Trên Windows (CMD)
    copy .env.example .env
    ```

2.  Mở file `.env` vừa tạo và điền các giá trị thực tế (nếu có thay đổi so với mặc định).

### 4. Chạy ứng dụng

Kết nối thiết bị thật hoặc mở máy ảo (Emulator), sau đó chạy:

```bash
flutter run
```

## Tài Nguyên Flutter

Nếu đây là dự án Flutter đầu tiên của bạn, hãy tham khảo:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

Để được hỗ trợ thêm, hãy xem [tài liệu trực tuyến](https://docs.flutter.dev/).
