# Tài Liệu Thiết Kế Cơ Sở Dữ Liệu (Database Design) - Bill Chillin

## 1. Tổng Quan về Chiến Lược Dữ Liệu

Dự án sử dụng **Cloud Firestore** - một cơ sở dữ liệu NoSQL linh hoạt, thời gian thực từ Firebase.

- **Mô hình**: Document-oriented (Hướng tài liệu).
- **Cấu trúc**: Phẳng hóa (Flatten structure) các Collection chính để tối ưu hóa việc truy vấn và mở rộng, thay vì lồng nhau quá sâu (Sub-collections).

## 2. Chi Tiết Các Collection

### 2.1. Collection `users`

Lưu trữ thông tin hồ sơ người dùng.

- **Path**: `/users/{uid}`
- **Document Structure**:
  | Field | Type | Required | Description |
  | :--- | :--- | :--- | :--- |
  | `id` | String | Yes | Primary Key (UID từ Auth). |
  | `email` | String | Yes | Email đăng nhập. |
  | `name` | String | No | Tên hiển thị người dùng. |
  | `avatarUrl` | String | No | URL ảnh đại diện. |

### 2.2. Collection `groups`

Lưu trữ thông tin các nhóm chi tiêu chung.

- **Path**: `/groups/{groupId}`
- **Document Structure**:
  | Field | Type | Required | Description |
  | :--- | :--- | :--- | :--- |
  | `id` | String | Yes | Unique Group ID. |
  | `name` | String | Yes | Tên nhóm. |
  | `members` | Array<String> | Yes | Danh sách UID của các thành viên `['uid1', 'uid2']`. Dùng để query `array-contains`. |
  | `createdBy` | String | Yes | UID người tạo nhóm. |
  | `createdAt` | Timestamp | Yes | Thời gian tạo. |
  | `currency` | String | Yes | Đơn vị tiền tệ mặc định (VND). |
  | `imageUrl` | String | No | Ảnh đại diện nhóm. |
  | `searchKeywords`| Array<String> | No | Hỗ trợ tìm kiếm full-text đơn giản. |

### 2.3. Collection `transactions`

Lưu trữ **TẤT CẢ** các giao dịch (Chi tiêu cá nhân & Chi tiêu nhóm).

- **Path**: `/transactions/{transactionId}`
- **Mô hình Single Collection**: Thay vì tách `personal_transactions` và `group_transactions`, ta gộp chung để dễ dàng thống kê tổng chi tiêu của một user. Phân biệt bằng trường `groupId`.
- **Document Structure**:

  **Core Fields (Thông tin chung):**
  | Field | Type | Description |
  | :--- | :--- | :--- |
  | `id` | String | Transaction ID. |
  | `userId` | String | UID người tạo giao dịch (Owner). |
  | `type` | String | `income` (Thu) hoặc `expense` (Chi). |
  | `amount` | Double | Số tiền. |
  | `currency` | String | Đơn vị tiền (VND, USD). |
  | `date` | Timestamp | Ngày phát sinh giao dịch. |
  | `status` | String | `confirmed` (Đã lưu) hoặc `draft` (Bản nháp từ OCR/Scan). |
  | `note` | String | Ghi chú thêm. |
  | `imageUrl` | String | Ảnh hóa đơn đính kèm. |

  **Category Info (Denormalized):**
  _Lưu trực tiếp thông tin Category để tránh phải join/read thêm document khi hiển thị list._
  | Field | Type | Description |
  | :--- | :--- | :--- |
  | `categoryId` | String | ID danh mục. |
  | `categoryName` | String | Tên danh mục tại thời điểm giao dịch. |
  | `categoryIcon` | String | Icon danh mục. |

  **Group Expense Specifics (Chỉ có nếu là chi tiêu nhóm):**
  | Field | Type | Description |
  | :--- | :--- | :--- |
  | `groupId` | String | Null nếu là chi tiêu cá nhân. Có giá trị nếu thuộc nhóm. |
  | `groupName` | String | Tên nhóm (Denormalized). |
  | `payerId` | String | UID người trả tiền thực tế (có thể khác người tạo). |
  | `participants` | Array<String> | Danh sách UID những người tham gia thụ hưởng (Share bill). |
  | `splitDetails` | Map<String, Double> | Chi tiết chia tiền. Key là UID, Value là số tiền nợ/đóng góp. Ví dụ: `{'uid1': 50000, 'uid2': 50000}`. |

### 2.4. Collection `categories`

Lưu trữ danh mục thu chi.

- **Path**: `/categories/{categoryId}`
- **Document Structure**:
  | Field | Type | Required | Description |
  | :--- | :--- | :--- | :--- |
  | `id` | String | Yes | Category ID. |
  | `name` | String | Yes | Tên danh mục (Ăn uống, Di chuyển...). |
  | `icon` | String | Yes | Mã hoặc tên File icon. |
  | `type` | String | Yes | `income` hoặc `expense`. |
  | `userId` | String | Yes | UID của người sở hữu danh mục này. |

## 3. Các Mối Quan Hệ & Truy Vấn (Relationships & Queries)

### 3.1. User - Group (Many-to-Many)

- **Quan hệ**: Một User tham gia nhiều Group, một Group có nhiều User.
- **Cách lưu**: Field `members` (Array) trong `groups`.
- **Query**: Lấy danh sách nhóm của tôi:
  ```dart
  firestore.collection('groups').where('members', arrayContains: myUid);
  ```

### 3.2. User - Transaction (One-to-Many)

- **Quan hệ**: Một User có nhiều Transaction.
- **Query**: Lấy sổ chi tiêu cá nhân:
  ```dart
  firestore.collection('transactions')
    .where('userId', isEqualTo: myUid)
    .where('groupId', isNull: true) // Chỉ lấy cá nhân
    .orderBy('date', descending: true);
  ```

### 3.3. Group - Transaction (One-to-Many)

- **Quan hệ**: Một Group có nhiều Transaction.
- **Query**: Lấy lịch sử chi tiêu của nhóm:
  ```dart
  firestore.collection('transactions')
    .where('groupId', isEqualTo: currentGroupId)
    .orderBy('date', descending: true);
  ```
