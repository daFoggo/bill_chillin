# 1. Giới thiệu dự án

- **Ý nghĩa tên**: Bill + Chilling, and the most important thing...
  ![[Pasted image 20251204024806.png]]
- Mascot đại diện dự án: Capybara, Sloth ( Con lười á ),...
- Mô tả dự án: BillChillin là ứng dụng giúp giải quyết nỗi đau mỗi khi chia tiền hoán đơn nhóm và quản lý tài chính cá nhân chỉ trong một ứng dụng duy nhất, với phong cách năng động và giải trí. Kết hợp với các tính năng đổi mới như OCR để quét text từ hoá đơn hay **kiểm soát tài chính với việc nuôi pet dựa trên tích luỹ tiền ( cái này chém gió :v** ).
- Techstack ( Cái này Gemini recommend nhưng về cơ bản là chuẩn):

| **Hạng mục**             | **Công nghệ Đã Chọn**          | **Chi tiết và Mục đích**                                                                                         |
| ------------------------ | ------------------------------ | ---------------------------------------------------------------------------------------------------------------- |
| **Core Framework**       | **Flutter**                    | Nền tảng phát triển ứng dụng di động đa nền tảng (Android, iOS) từ một mã nguồn duy nhất.                        |
| **Ngôn ngữ**             | **Dart**                       | Ngôn ngữ lập trình chính được sử dụng trong Flutter.                                                             |
| **State Management**     | **Bloc / Cubit**               | Quản lý trạng thái ứng dụng một cách mạnh mẽ, rõ ràng, giúp tách biệt Logic nghiệp vụ (BL) khỏi giao diện (UI).  |
| **UI Library**           | **Material Design (Built-in)** | Sử dụng các thành phần giao diện người dùng tiêu chuẩn của Google, dễ dàng tùy chỉnh màu sắc và phong cách.      |
| **Biểu đồ/Đồ thị**       | **fl_chart**                   | Thư viện tạo biểu đồ linh hoạt, dùng để hiển thị báo cáo thống kê thu chi cá nhân và nhóm.                       |
| **Database (Cloud)**     | **Firebase Firestore**         | Cơ sở dữ liệu NoSQL, cung cấp tính năng đồng bộ hóa real-time để quản lý giao dịch và dữ liệu nhóm.              |
| **Database (Local)**     | **Hive / Isar**                | Cơ sở dữ liệu cục bộ, tốc độ cao, dùng để lưu trữ dữ liệu ngoại tuyến hoặc cache.                                |
| **AI/OCR**               | **Google ML Kit**              | Dùng cho tính năng nhận dạng văn bản (Text Recognition) từ hóa đơn, hỗ trợ thêm nhanh giao dịch cá nhân và nhóm. |
| **Định tuyến (Routing)** | **GoRouter**                   | Quản lý việc điều hướng (navigation) giữa các màn hình, hỗ trợ cấu trúc app phức tạp và Deep Linking.            |

# 2. Chức năng cốt lõi (Bắt buộc phải có)

## 2.1. Quản lý sổ tài chính cá nhân

- CRUD giao dịch thu chi cá nhân
- Phân loại danh mục cho các giao dịch
- Xem báo cáo thống kê hàng tháng

## 2.2. Quản lý tài chính nhóm

- Tạo nhóm mới
- Mời thành viên qua link / QR
- Thêm chi tiêu cho nhóm:
  - Thêm chi tiêu với thông tin những người được chia tiền
  - Xử lý thông tin và tối ưu ra thông tin nợ cuối cùng giữa các người tham gia. Ví dụ: A nợ B 50k, B nợ C 50k -> A trả cho C 50k.
- Tự động thêm cả tiền mà người dùng đã chi trong nhóm về sổ tài chính cá nhân (Như vậy có thể link giữa 2 loại sổ, các app khác chưa có)

# 3. Chức năng sáng tạo / chém gió

## 3.1. OCR hoá đơn (Tính năng này khá cần thiết nếu muốn điểm cao và nổi trội hơn so với các app khác)

- Có 2 phiên bản:
  - Cho cá nhân: OCR hoá đơn -> thêm nhanh luôn được vào sổ chi tiêu cá nhân
  - Cho nhóm: OCR hoá đơn -> Cần chuyển ngay sang màn danh sách hàng hoá, và cho phép check box để đánh dấu nhanh của những ai.

## 3.2.... Anh em có thể chém gió thêm, cái pet thì cần resources nên cũng hơi khó

# 4. Luồng hoạt động

- Thanh điều hướng gồm: Trang chủ, Chi tiêu cá nhân, Nút Action (+) Thêm chi tiêu, Chi tiêu nhóm, Hồ sơ.
- Các màn:
  - Trang chủ:
    - Chào tương tác với user, các thông tin tiện ích khác như lịch,...
    - Biểu đồ thống kê
    - Các danh mục chi tiêu
    - Các chi tiêu gần đây
  - Chi tiêu cá nhân:
    - Các thông số tiền
    - Nút thêm mới
    - Một list theo chiều ngang các danh mục ( Không làm phần này quá dài )
    - Danh sách các chi tiêu đi kèm các nút thao tác chỉnh sửa. Các chi tiêu dù hiển thị list nhưng cũng sẽ được nhóm thành từng phần của các danh mục chi tiêu (Như trong ảnh).
    - ![[Pasted image 20251204031710.png]]
    - Bấm vào 1 danh mục thì lại show ra danh sách tiếp nhưng chỉ thuộc danh mục đó (Trong này cũng sẽ có thống kê riêng của mục đó )
  - Chi tiêu nhóm:
    - Hiển thị danh sách nhóm
    - Khi vào 1 nhóm thì khá tương tự sẽ có danh sách chi tiêu, nhưng cần thay đổi giao diện để dành cho nhóm, vì có nợ nần các thứ.
    - Các giao diện khi tạo 1 chi tiêu cũng sẽ khác biệt hơn
  - Hồ sơ:
    - Các thông tin của user
    - Setting
    - Đăng nhập / Đăng xuất
