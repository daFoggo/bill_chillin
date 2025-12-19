# Báo Cáo Tổng Hợp Dự Án Bill Chillin

## 1. Giới Thiệu Dự Án

**Bill Chillin** là ứng dụng quản lý tài chính toàn diện trên nền tảng di động, được xây dựng bằng công nghệ Flutter tiên tiến. Ứng dụng không chỉ giúp cá nhân theo dõi thu chi hàng ngày mà còn giải quyết bài toán chia sẻ chi phí nhóm phức tạp, kết hợp với công nghệ AI để tự động hóa việc nhập liệu từ hóa đơn.

## 2. Phân Tích Hệ Thống

_(Tham khảo tài liệu chi tiết tại `docs/analysis_report.md` và biểu đồ đi kèm `docs/usecase_diagram.puml`)_

Hệ thống được thiết kế theo kiến trúc **Clean Architecture**, đảm bảo tính ổn định, dễ bảo trì và mở rộng. Các quy trình nghiệp vụ chính bao gồm:

- **Xác thực**: Bảo mật thông tin người dùng.
- **Sổ thu chi cá nhân**: Ghi chép và báo cáo tài chính.
- **Sổ nhóm**: Quản lý quỹ nhóm và tính toán công nợ.
- **OCR Service**: Số hóa hóa đơn giấy thành dữ liệu điện tử.

---

## 3. Kết Quả Xây Dựng & Các Giao Diện Chức Năng

Dưới đây là chi tiết các chức năng đã được hiện thực hóa, tương ứng với các màn hình giao diện của ứng dụng.

### 3.1. Phân Hệ Xác Thực (Authentication)

#### Màn hình Đăng nhập / Chào mừng (`AuthPage`)

Đây là điểm tiếp xúc đầu tiên khi người dùng mở ứng dụng (nếu chưa đăng nhập).

- **Mô tả**: Thiết kế hiện đại, thân thiện với logo thương hiệu Bill Chillin nổi bật.
- **Chức năng chính**:
  - **Đăng nhập Google**: Nút bấm tiện lợi để đăng nhập nhanh 1 chạm.
  - **Đăng nhập Email/Pass**: Mở BottomSheet để nhập tài khoản truyền thống.
  - **Đăng ký**: Chuyển sang form tạo tài khoản mới.
- **Hình ảnh giao diện**:
  > [Ảnh giao diện: Màn hình Chào mừng & Đăng nhập]

### 3.2. Phân Hệ Trang Chủ (Home)

#### Màn hình Dashboard Tổng Quan (`HomePage`)

Trung tâm điều khiển tài chính của người dùng.

- **Mô tả**: Cung cấp cái nhìn toàn cảnh về sức khỏe tài chính ngay lập tức.
- **Chức năng chính**:
  - **Balance Card**: Hiển thị tổng số dư hiện tại và cơ cấu tài sản.
  - **Overview**: Thống kê nhanh Tổng Thu và Tổng Chi trong kỳ.
  - **Biểu đồ thị giác**:
    - _Biểu đồ phân bổ_: Dạng tròn (Pie chart) thể hiện tỷ lệ chi tiêu các danh mục.
    - _Biểu đồ xu hướng_: Dạng cột/đường (Bar/Line chart) so sánh thu chi qua các tháng.
  - **Xin chào**: Hiển thị tên và Avatar người dùng (lấy từ Profile).
- **Hình ảnh giao diện**:
  > [Ảnh giao diện: Dashboard Trang chủ]

### 3.3. Phân Hệ Chi Tiêu Cá Nhân (Personal Expenses)

#### Màn hình Danh sách Giao dịch (`PersonalExpensesPage`)

Nơi người dùng quản lý chi tiết từng khoản thu chi.

- **Mô tả**: Giao diện dạng danh sách cuộn, được tổ chức khoa học theo thời gian.
- **Chức năng chính**:
  - **Bộ lọc thời gian**: Thanh Tab ngang cho phép chuyển đổi nhanh giữa các tháng (Tháng 1 - Tháng 12).
  - **Tìm kiếm & Sắp xếp**: Hỗ trợ tìm kiếm theo từ khóa (ghi chú, danh mục) và sắp xếp danh sách (Mới nhất, Cũ nhất, Theo loại).
  - **Tổng kết tháng**: Hiển thị số dư đầu kỳ/cuối kỳ của tháng đang chọn.
  - **Thao tác nhanh**: Vuốt để xóa, nhấn để xem chi tiết hoặc sửa.
- **Hình ảnh giao diện**:
  > [Ảnh giao diện: Danh sách giao dịch cá nhân]

#### Màn hình Thêm/Sửa Giao dịch (`TransactionBottomSheet`)

- **Mô tả**: Form nhập liệu dạng trượt từ dưới lên (Bottom Sheet), tối ưu cho thao tác một tay.
- **Chức năng chính**:
  - Nhập số tiền, chọn loại (Thu/Chi).
  - Chọn danh mục (có Icon minh họa).
  - Chọn ngày tháng, thêm ghi chú và ảnh đính kèm.
- **Hình ảnh giao diện**:
  > [Ảnh giao diện: Form Thêm giao dịch]

### 3.4. Phân Hệ Chi Tiêu Nhóm (Group Expenses)

#### Màn hình Danh sách Nhóm (`GroupListScreen`)

- **Mô tả**: Liệt kê các nhóm chi tiêu mà người dùng đang tham gia.
- **Chức năng chính**:
  - Xem danh sách nhóm kèm trạng thái (Đang hoạt động, Đã kết thúc).
  - Tạo nhóm mới hoặc Tham gia nhóm bằng mã/link.
- **Hình ảnh giao diện**:
  > [Ảnh giao diện: Danh sách nhóm]

#### Màn hình Chi tiết Nhóm (`GroupDetailScreen`)

- **Mô tả**: Không gian làm việc chung của một nhóm.
- **Chức năng chính**:
  - **Tab Chi tiêu**: Danh sách hóa đơn chung của cả nhóm.
  - **Tab Số dư**: Bảng tính toán "Ai nợ ai" tự động.
  - **Thống kê**: Biểu đồ chi tiêu của nhóm.
- **Hình ảnh giao diện**:
  > [Ảnh giao diện: Chi tiết nhóm & Bảng công nợ]

### 3.5. Phân Hệ Quét Hóa Đơn (AI Scan)

#### Màn hình Chụp Hóa Đơn (`ScanReceiptPage`)

- **Mô tả**: Giao diện Camera đơn giản tích hợp AI.
- **Chức năng chính**:
  - Kích hoạt Camera hoặc chọn ảnh từ thư viện.
  - Gửi ảnh đến Gemini AI để phân tích.
  - Hiển thị trạng thái xử lý (Loading...).
- **Hình ảnh giao diện**:
  > [Ảnh giao diện: Camera Scan]

#### Màn hình Soát lỗi & Kết quả (`ReviewScannedTransactionsPage`)

- **Mô tả**: Hiển thị kết quả AI đọc được trước khi lưu.
- **Chức năng chính**:
  - Danh sách các mục hàng (Item, Giá tiền) đã trích xuất.
  - Cho phép người dùng sửa đổi nếu AI nhận diện sai.
  - Nút xác nhận để lưu hàng loạt vào sổ chi tiêu.
- **Hình ảnh giao diện**:
  > [Ảnh giao diện: Kết quả Scan & Soát lỗi]

---

## 4. Kết Luận

Tính đến thời điểm hiện tại, ứng dụng đã hoàn thiện các chức năng cốt lõi (Core Features) và đáp ứng tốt các yêu cầu nghiệp vụ đề ra. Giao diện được thiết kế đồng bộ, trải nghiệm người dùng mượt mà (đặc biệt là tính năng Scan AI và tính nợ nhóm). Hệ thống sẵn sàng cho các giai đoạn kiểm thử nâng cao và triển khai thực tế.
