# Tài Liệu Phân Tích & Thiết Kế Kiến Trúc Hệ Thống - Bill Chillin

## 1. Tổng Quan Dự Án

**Bill Chillin** là ứng dụng di động đa nền tảng (Mobile App) được thiết kế để giải quyết bài toán quản lý tài chính cá nhân và chia sẻ chi phí nhóm một cách minh bạch, tiện lợi và thú vị.

- **Mục tiêu chính**: Đơn giản hóa việc ghi chép chi tiêu, tự động tính toán nợ nhóm, và hỗ trợ nhập liệu nhanh thông qua công nghệ OCR.
- **Phong cách**: Trẻ trung, năng động, kết hợp yếu tố Gamification (dự kiến).

## 2. Kiến Trúc Tổng Thể (Architectural Pattern)

Dự án áp dụng mô hình **Clean Architecture** kết hợp với **Bloc Pattern** để quản lý trạng thái. Kiến trúc này chia hệ thống thành các tầng độc lập, đảm bảo nguyên lý "Separation of Concerns" (Phân tách trách nhiệm).

### Lợi ích của kiến trúc này:

- **Độc lập với Framework**: Logic nghiệp vụ (Core Business) không phụ thuộc vào Flutter hay thư viện UI cụ thể.
- **Dễ kiểm thử (Testable)**: Business Rules có thể được test độc lập mà không cần UI hay Database.
- **Dễ bảo trì & Mở rộng**: Việc thay đổi Database (ví dụ từ Firebase sang SQL) hoặc thay đổi UI không ảnh hưởng đến logic cốt lõi.

---

## 3. Chi Tiết Các Tầng (Layered Architecture)

Hệ thống được chia thành 3 tầng chính, giao tiếp với nhau theo nguyên tắc phụ thuộc hướng vào trong (Dependency Rule) hoặc thông qua Dependency Inversion.

### 3.1. Presentation Layer (Tầng Giao Diện)

Lớp ngoài cùng, nơi tương tác trực tiếp với người dùng.

- **Thành phần**:
  - **Pages/Widgets**: Các màn hình và component UI (được xây dựng bằng Flutter Widgets).
  - **Bloc/Cubit**: Quản lý State của ứng dụng. Nhận sự kiện (Events) từ UI, gọi xuống Domain Layer để xử lý, và phát ra trạng thái (States) mới để UI cập nhật.
- **Trách nhiệm**: Hiển thị dữ liệu và thu thập hành động của người dùng. Không chứa logic nghiệp vụ phức tạp.

### 3.2. Domain Layer (Tầng Nghiệp Vụ - Core)

Lớp lõi của ứng dụng, chứa toàn bộ logic nghiệp vụ thuần túy. Tầng này **KHÔNG** phụ thuộc vào bất kỳ tầng nào khác (Pure Dart).

- **Thành phần**:
  - **Entities**: Các đối tượng dữ liệu nghiệp vụ cốt lõi (ví dụ: `User`, `Expense`, `Group`).
  - **Use Cases (Logic nghiệp vụ)**: Các quy trình nghiệp vụ cụ thể (ví dụ: `CalculateDebt`, `ScanReceipt`). _Lưu ý: Trong dự án hiện tại, Use Case có thể được tích hợp trực tiếp vào Interface Repository hoặc tách riêng tùy độ phức tạp._
  - **Repository Interfaces**: Định nghĩa các hợp đồng (contracts) để truy xuất dữ liệu.
- **Trách nhiệm**: Đảm bảo tính đúng đắn của logic nghiệp vụ.

### 3.3. Data Layer (Tầng Dữ Liệu)

Lớp chịu trách nhiệm làm việc với nguồn dữ liệu ngoài.

- **Thành phần**:
  - **Models**: Các đối tượng dữ liệu dùng để chuyển đổi (mapping) giữa Entity và định dạng lưu trữ (JSON, Firestore Document).
  - **Data Sources (Remote/Local)**: Thực hiện các kết nối thực tế (gọi API, truy vấn Firebase, đọc ghi Local DB).
  - **Repositories Implementation**: Triển khai các Interface đã định nghĩa ở Domain Layer. Quyết định nguồn dữ liệu nào sẽ được sử dụng (ví dụ: lấy từ Cache hay Server).
- **Trách nhiệm**: Cung cấp dữ liệu cho Domain Layer.

---

## 4. Giải Pháp Công Nghệ (Technology Stack)

| Hạng mục               | Công nghệ                      | Vai trò trong kiến trúc                                                                         |
| :--------------------- | :----------------------------- | :---------------------------------------------------------------------------------------------- |
| **Mobile Framework**   | **Flutter**                    | Xây dựng Presentation Layer (UI đa nền tảng).                                                   |
| **Ngôn ngữ**           | **Dart**                       | Ngôn ngữ duy nhất xuyên suốt 3 tầng.                                                            |
| **State Management**   | **Bloc**                       | Cầu nối giữa Presentation và Domain (Logic điều phối).                                          |
| **Backend / Database** | **Firebase** (Firestore, Auth) | Đóng vai trò Technology Service, cung cấp Authentication và Database thời gian thực.            |
| **AI / OCR**           | **Gemini AI**                  | Technology Service xử lý nhận diện văn bản (tính năng Scan) và trích xuất thông tin thông minh. |

_Lưu ý: Local Storage (Isar/Hive) đã được loại bỏ khỏi kiến trúc cốt lõi ban đầu để tập trung vào Cloud-first._

---

## 5. Mô Hình Archimate (Mô tả sơ đồ UML)

Dựa trên sơ đồ Archimate đã thiết kế, hệ thống vận hành như sau:

1.  **Business Layer (User & Services)**: Người dùng (`User`) sử dụng các dịch vụ nghiệp vụ như _Quản lý chi tiêu cá nhân_, _Quản lý nhóm_, và _Quét hóa đơn_.
2.  **Application Layer (App Structure)**:
    - Ứng dụng Bill Chillin cung cấp các **Application Services** tương ứng để hiện thực hóa các dịch vụ nghiệp vụ trên.
    - Bên trong, các module (Auth, Expense) được tổ chức phân tầng rõ ràng (Presentation -> Domain <- Data).
    - Presentation Layer "được gán" (assigned to) nhiệm vụ thực thi các Application Services này.
3.  **Technology Layer (Infrastructure)**:
    - Data Layer kết nối xuống hạ tầng kỹ thuật bên dưới như Firebase Auth (xác thực), Firestore (lưu trữ cloud), và Gemini AI (xử lý ảnh & trích xuất).

---

## 6. Luồng Dữ Liệu Điển Hình (Workflow Example)

**Ví dụ: Tính năng "Thêm chi tiêu mới"**

1.  **UI**: Người dùng nhập số tiền và nhấn "Lưu". `ExpensePage` gửi event `AddExpenseEvent` đến `ExpenseBloc`.
2.  **Presentation**: `ExpenseBloc` nhận event, gọi hàm `createExpense()` từ `ExpenseRepository` (thuộc Domain).
3.  **Domain**: `CreateExpense` usecase (hoặc repository logic) kiểm tra tính hợp lệ của dữ liệu (validate).
4.  **Data**: `ExpenseRepositoryImpl` chuyển gọi xuống `ExpenseRemoteDataSource`.
5.  **Infra**: `ExpenseRemoteDataSource` gọi Firebase SDK để đẩy dữ liệu lên Firestore.
6.  **Phản hồi**: Kết quả (Thành công/Lỗi) được trả ngược lại theo chuỗi: Data -> Domain -> Presentation. `ExpenseBloc` phát ra state `AddExpenseSuccess`, UI hiển thị thông báo thành công.
