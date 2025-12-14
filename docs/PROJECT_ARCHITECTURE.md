# Tài Liệu Kiến Trúc Dự Án

Tài liệu này cung cấp hướng dẫn toàn diện về kiến trúc Clean Architecture được sử dụng trong dự án **Bill Chillin**. Nó được thiết kế để giúp các lập trình viên mới hiểu được codebase, các pattern được sử dụng và cách triển khai các tính năng mới một cách hiệu quả.

## 1. Tổng Quan

Dự án tuân theo nguyên lý **Clean Architecture** để đảm bảo sự phân tách trách nhiệm, khả năng mở rộng và kiểm thử.
Dự án sử dụng **Firebase** làm Backend-as-a-Service (BaaS) chính:

- **Authentication**: Dùng Firebase Auth (Email/Password, Google Sign-In).
- **Database**: Dùng Cloud Firestore để lưu trữ dữ liệu người dùng và ứng dụng.

Code được chia thành ba tầng (layer) chính:

1.  **Domain Layer (Nghiệp Vụ)**: Chứa các Entity và Rules nghiệp vụ. Độc lập hoàn toàn với Firebase hay Flutter UI.
2.  **Data Layer (Dữ Liệu)**: Xử lý giao tiếp với Firebase (Auth, Firestore), API và Local Storage.
3.  **Presentation Layer (Giao Diện)**: Xử lý UI và State Management bằng BLoC.

## 2. Cấu Trúc Dự Án

Thư mục `lib` được tổ chức như sau:

```
lib/
├── core/                   # Các chức năng cốt lõi dùng chung (Error, Config, Utils)
├── features/               # Các module tính năng (Feature-based)
│   ├── auth/               # Ví dụ feature: Authentication
│   │   ├── data/           # Data Layer (Models, DataSources, Repositories Impl)
│   │   ├── domain/         # Domain Layer (Entities, Repositories Interface)
│   │   └── presentation/   # Presentation Layer (Bloc, Pages, Widgets)
└── main.dart               # Điểm khởi chạy ứng dụng
```

## 3. Chi Tiết Các Tầng & Ví Dụ Code (Feature Auth)

Dưới đây là chi tiết từng tầng kèm theo minh họa code thực tế từ chức năng **Auth** trong dự án.

### 3.1. Domain Layer (`lib/features/auth/domain`)

Đây là phần lõi, nơi định nghĩa các đối tượng nghiệp vụ và giao diện (hợp đồng) làm việc với dữ liệu.

- **Entities**: Object thuần túy, không chứa logic JSON hay Firebase.
  _Ví dụ `UserEntity` (`lib/features/auth/domain/entities/user_entity.dart`):_

  ```dart
  class UserEntity extends Equatable {
    final String id;
    final String email;
    final String? name;
    final String? avatarUrl;

    const UserEntity({required this.id, required this.email, this.name, this.avatarUrl});

    @override
    List<Object?> get props => [id, email, name, avatarUrl];
  }
  ```

- **Repositories (Interface)**: Định nghĩa các hàm mà Data Layer phải thực hiện.
  _Ví dụ `AuthRepository` (`lib/features/auth/domain/repositories/auth_repository.dart`):_
  ```dart
  abstract class AuthRepository {
    Future<Either<Failure, UserEntity>> signInWithGoogle();
    Future<Either<Failure, void>> signOut();
    // ...
  }
  ```

### 3.2. Data Layer (`lib/features/auth/data`)

Tầng này triển khai các Interface của Domain và làm việc trực tiếp với Firebase.

- **Models**: Kế thừa Entity, bổ sung logic chuyển đổi JSON/Firestore.
  _Ví dụ `UserModel` (`lib/features/auth/data/models/user_model.dart`):_

  ```dart
  class UserModel extends UserEntity {
    // ... constructor ...

    // Chuyển đổi từ Firestore Document sang Object Dart
    factory UserModel.fromFirestore(DocumentSnapshot doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return UserModel(
        id: doc.id,
        email: data['email'],
        name: data['name'],
        avatarUrl: data['avatarUrl'],
      );
    }

    // Chuyển đổi từ Object Dart sang Map để lưu xuống Firestore
    Map<String, dynamic> toDocument() {
      return {'email': email, 'name': name, 'avatarUrl': avatarUrl};
    }
  }
  ```

- **Data Sources**: Nơi thực hiện các cuộc gọi API/Firebase thực sự.
  _Ví dụ `AuthRemoteDataSource` (`lib/features/auth/data/data_sources/auth_remote_data_source.dart`):_

  ```dart
  class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
    final FirebaseAuth firebaseAuth;
    final FirebaseFirestore firestore;
    final GoogleSignIn googleSignIn;

    // ...

    @override
    Future<UserModel> signInWithGoogle() async {
      try {
        // 1. Kích hoạt Google Sign In Flow
        final googleUser = await googleSignIn.signIn();
        final googleAuth = await googleUser!.authentication;

        // 2. Lấy credential và đăng nhập Firebase
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final userCredential = await firebaseAuth.signInWithCredential(credential);

        // 3. Tạo Model và lưu thông tin User vào Firestore
        final userModel = UserModel(/*...*/);
        await firestore.collection('users').doc(user.uid).set(userModel.toDocument());

        return userModel;
      } catch (e) {
        throw ServerException(e.toString());
      }
    }
  }
  ```

- **Repositories (Implementation)**: Kết nối Data Source và trả về kết quả dạng `Either` (Lỗi hoặc Dữ liệu).
  _Ví dụ `AuthRepositoryImpl` (`lib/features/auth/data/repositories/auth_repository_impl.dart`):_

  ```dart
  class AuthRepositoryImpl implements AuthRepository {
    final AuthRemoteDataSource remoteDataSource;

    @override
    Future<Either<Failure, UserEntity>> signInWithGoogle() async {
      try {
        final user = await remoteDataSource.signInWithGoogle();
        return Right(user); // Trả về Success (Phải)
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message)); // Trả về Failure (Trái)
      }
    }
  }
  ```

### 3.3. Presentation Layer (`lib/features/auth/presentation`)

- **Bloc**: Nhận Event từ UI -> Gọi Repository -> Phát ra State mới.
  _Ví dụ `AuthBloc` (`lib/features/auth/presentation/bloc/auth_bloc.dart`):_

  ```dart
  class AuthBloc extends Bloc<AuthEvent, AuthState> {
    final AuthRepository authRepository;

    AuthBloc({required this.authRepository}) : super(AuthInitial()) {
      on<AuthGoogleSignInEvent>((event, emit) async {
        emit(AuthLoading()); // 1. Báo UI đang load

        final result = await authRepository.signInWithGoogle(); // 2. Gọi logic

        result.fold(
          (failure) => emit(AuthFailure(failure.message)), // 3a. Lỗi
          (user) => emit(AuthAuthenticated(user)),         // 3b. Thành công
        );
      });
    }
  }
  ```

## 4. Quy Trình Thêm Feature Mới (Workflow)

Để đảm bảo tính nhất quán, hãy tuân thủ các bước sau khi thêm tính năng mới:

1.  **Domain (Core Logic)**

    - Tạo `Entity`: Xác định dữ liệu (Ví dụ: `BillEntity`).
    - Tạo `Repository Interface`: Xác định xem cần làm gì với dữ liệu (Ví dụ: `getBills()`, `createBill()`).

2.  **Data (Implementation)**

    - Tạo `Model`: Extends Entity, viết `fromJson`/`toJson` khớp với Firestore field.
    - Tạo `RemoteDataSource`: Viết code gọi `firestore.collection('bills')...`.
    - Tạo `Repository Implementation`: Gọi DataSource, `try-catch`, trả về `Right(data)` hoặc `Left(Failure)`.

3.  **Injection**

    - Vào `core/services/injection_container.dart` đăng ký các class mới tạo (Datasource, Repository, Bloc).

4.  **Presentation (UI)**
    - Tạo `Bloc`: Define các `Event` (hành động người dùng) và `State` (trạng thái màn hình).
    - Tạo `Page/Widget`: Dùng `BlocProvider` và `BlocBuilder`, `BlocListener` để kết nối UI với Logic.

## 5. Tài Liệu Tham Khảo

- [Flutter Clean Architecture Proposal](https://youtu.be/zon3WgmcqQw)
- [Official Bloc Library Documentation](https://bloclibrary.dev/#/)
- [Firebase Flutter Documentation](https://firebase.google.com/docs/flutter/setup)
