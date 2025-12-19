# Báo Cáo Phân Tích Nghiệp Vụ Dự Án Bill Chillin

## 1. Tổng Quan & Mục Tiêu

**Bill Chillin** là giải pháp số hóa giúp người dùng quản lý tài chính cá nhân và giải quyết bài toán "chia tiền" khi đi ăn chơi theo nhóm. Hệ thống hướng đến sự minh bạch, tiện lợi và tự động hóa cao thông qua tương tác người dùng đơn giản và công nghệ nhận diện thông minh.

## 2. Phân Tích Chức Năng Nghiệp Vụ

### 2.1. Quản Lý Tài Khoản & Người Dùng

- **Mục tiêu**: Định danh người dùng để lưu trữ dữ liệu riêng tư và đồng bộ trên nhiều thiết bị.
- **Các tính năng**:
  - **Đăng nhập đa kênh**: Hỗ trợ đăng nhập nhanh bằng Google hoặc Email/Mật khẩu truyền thống.
  - **Hồ sơ cá nhân**: Quản lý thông tin hiển thị (Tên, Ảnh đại diện) giúp nhận diện dễ dàng trong các giao dịch nhóm.

### 2.2. Quản Lý Chi Tiêu Cá Nhân (Sổ Tài Chính)

- **Mục tiêu**: Giúp người dùng theo dõi dòng tiền hàng ngày, phân loại thu chi để có cái nhìn tổng quan về tình hình tài chính.
- **Quy trình nghiệp vụ (Thêm Giao Dịch)**:
  1.  **Khởi tạo**: Người dùng chọn thêm mới chi tiêu/thu nhập.
  2.  **Nhập liệu**: Cung cấp thông tin: Số tiền, Danh mục (Ăn uống, Di chuyển...), Ghi chú, và Thời gian.
  3.  **Xác nhận**: Hệ thống lưu lại giao dịch vào sổ cái của người dùng.
  4.  **Báo cáo**: Hệ thống tự động tổng hợp số liệu để hiển thị biểu đồ biến động số dư và cơ cấu chi tiêu theo danh mục.

### 2.3. Quản Lý Chi Tiêu Nhóm (Chia Tiền)

- **Mục tiêu**: Tự động hóa việc ghi nợ và tính toán số tiền "ai nợ ai" trong các chuyến đi hoặc nhóm sinh hoạt chung.
- **Quy trình nghiệp vụ**:
  1.  **Tạo Nhóm**: Người dùng tạo một nhóm chi tiêu (ví dụ: "Du lịch Đà Lạt").
  2.  **Mời Thành Viên**: Chia sẻ liên kết hoặc mã QR để bạn bè tham gia nhóm.
  3.  **Ghi Nhận Chi Tiêu Chung**:
      - Một thành viên (người trả tiền) nhập thông tin hóa đơn.
      - Xác định những người thụ hưởng (chia đều hoặc theo tỷ lệ cụ thể).
  4.  **Hệ Thống Phân Bổ**: Tự động tính toán phần nợ của từng thành viên tham gia so với người trả tiền.
  5.  **Theo Dõi Công Nợ**:
      - Hiển thị bảng tổng kết: "Ai cần trả bao nhiêu cho ai".
      - Hỗ trợ tối ưu hóa dòng tiền (ví dụ: A nợ B, B nợ C -> Hệ thống gợi ý A trả trực tiếp cho C nếu phù hợp - _Tính năng nâng cao_).

### 2.4. Dịch Vụ Scan Hóa Đơn (OCR)

- **Mục tiêu**: Giảm thiểu thao tác nhập liệu thủ công, tiết kiệm thời gian cho người dùng.
- **Quy trình nghiệp vụ**:
  1.  **Tiếp nhận**: Người dùng chụp ảnh hóa đơn giấy.
  2.  **Xử lý thông minh**: Hệ thống tự động quét và "đọc" các thông tin quan trọng trên hóa đơn:
      - Tên các mặt hàng.
      - Số tiền từng món.
      - Ngày tháng giao dịch.
  3.  **Đối soát**: Kết quả được hiển thị để người dùng kiểm tra nhanh.
  4.  **Hoàn tất**: Người dùng xác nhận để chuyển các thông tin đã quét thành các giao dịch chi tiêu (Cá nhân hoặc Nhóm) mà không cần gõ phím.

## 3. Bản Đồ Tương Tác Người Dùng (User Flow Map)

    +----------------+       +-------------------+       +-----------------------+
    |  NGƯỜI DÙNG    | ----> |  NHẬP LIỆU        | ----> |  SỔ TÀI CHÍNH         |
    +----------------+       +-------------------+       +-----------------------+
           |                 | - Nhập tay        |       | - Cá Nhân (Riêng tư)  |
           |                 | - Scan Hóa đơn    |       | - Nhóm (Chia sẻ)      |
           |                 +-------------------+       +-----------------------+
           |                                                      |
           |                                                      v
           |                                             +-----------------------+
           +-------------------------------------------> |  HỆ THỐNG XỬ LÝ       |
                                                         +-----------------------+
                                                         | - Phân loại danh mục  |
                                                         | - Tính toán công nợ   |
                                                         | - Tổng hợp báo cáo    |
                                                         +-----------------------+

## 4. Kết Luận

Về mặt nghiệp vụ, **Bill Chillin** tập trung giải quyết trọn vẹn vòng đời của một giao dịch tài chính: từ lúc phát sinh (nhập liệu/scan) -> ghi nhận (lưu trữ) -> xử lý quan hệ tài chính (tính nợ nhóm) -> báo cáo kết quả. Quy trình được thiết kế tinh gọn để tối đa hóa trải nghiệm người dùng.
