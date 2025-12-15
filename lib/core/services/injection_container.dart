import 'package:bill_chillin/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:bill_chillin/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:bill_chillin/features/auth/domain/repositories/auth_repository.dart';
import 'package:bill_chillin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bill_chillin/features/personal_expenses/data/datasources/personal_expenses_remote_data_source.dart';
import 'package:bill_chillin/features/personal_expenses/data/repositories/personal_expenses_repository_impl.dart';
import 'package:bill_chillin/features/personal_expenses/domain/repositories/personal_expenses_repository.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/bloc/personal_expenses_bloc.dart';
import 'package:bill_chillin/features/personal_expenses/data/datasources/category_remote_data_source.dart';
import 'package:bill_chillin/features/personal_expenses/data/repositories/category_repository_impl.dart';
import 'package:bill_chillin/features/personal_expenses/domain/repositories/category_repository.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/bloc/category_bloc.dart';

import 'package:bill_chillin/features/group_expenses/data/datasources/group_remote_data_source.dart';
import 'package:bill_chillin/features/group_expenses/data/repositories/group_repository_impl.dart';
import 'package:bill_chillin/features/group_expenses/domain/repositories/group_repository.dart';
import 'package:bill_chillin/features/group_expenses/domain/usecases/add_group_transaction_usecase.dart';
import 'package:bill_chillin/features/group_expenses/domain/usecases/create_group_usecase.dart';
import 'package:bill_chillin/features/group_expenses/domain/usecases/get_group_debts_usecase.dart';
import 'package:bill_chillin/features/group_expenses/domain/usecases/get_group_transactions_usecase.dart';
import 'package:bill_chillin/features/group_expenses/domain/usecases/join_group_usecase.dart';
import 'package:bill_chillin/features/group_expenses/presentation/bloc/group_list/group_list_bloc.dart';
import 'package:bill_chillin/features/home/presentation/bloc/home_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:isar/isar.dart';
// import 'package:path_provider/path_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! 1. External & Core (Firebase, Google, Local Storage...)
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  await GoogleSignIn.instance.initialize(
    serverClientId: dotenv.env['GOOGLE_OAUTH_WEB_CLIENT_ID']!,
  );
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn.instance);

  //! 2. Feature: Auth
  // Data Source
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
      googleSignIn: sl(),
    ),
  );
  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  // Bloc
  sl.registerFactory<AuthBloc>(() => AuthBloc(authRepository: sl()));

  //! 3. Feature: Personal Expenses
  // Data Source
  sl.registerLazySingleton<PersonalExpensesRemoteDataSource>(
    () => PersonalExpensesRemoteDataSourceImpl(firestore: sl()),
  );
  // Repository
  sl.registerLazySingleton<PersonalExpensesRepository>(
    () => PersonalExpensesRepositoryImpl(remoteDataSource: sl()),
  );
  // Bloc
  sl.registerFactory<PersonalExpensesBloc>(
    () => PersonalExpensesBloc(repository: sl()),
  );

  //! 4. Feature: Categories
  // Data Source
  sl.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(sl()),
  );
  // Repository
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(sl()),
  );
  // Bloc
  sl.registerFactory<CategoryBloc>(() => CategoryBloc(sl()));

  //! 5. Feature: Home
  sl.registerFactory<HomeBloc>(() => HomeBloc(repository: sl()));

  //! 6. Feature: Group Expenses
  // Data Source
  sl.registerLazySingleton<GroupRemoteDataSource>(
    () => GroupRemoteDataSourceImpl(firestore: sl()),
  );
  // Repository
  sl.registerLazySingleton<GroupRepository>(
    () => GroupRepositoryImpl(remoteDataSource: sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => CreateGroupUseCase(sl()));
  sl.registerLazySingleton(() => JoinGroupUseCase(sl()));
  sl.registerLazySingleton(() => AddGroupTransactionUseCase(sl()));
  sl.registerLazySingleton(() => GetGroupTransactionsUseCase(sl()));
  sl.registerLazySingleton(() => GetGroupDebtsUseCase(sl()));

  // Blocs
  sl.registerFactory<GroupListBloc>(
    () => GroupListBloc(repository: sl(), createGroupUseCase: sl()),
  );
}
