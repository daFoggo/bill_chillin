import 'package:bill_chillin/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:bill_chillin/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:bill_chillin/features/auth/domain/repositories/auth_repository.dart';
import 'package:bill_chillin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
// import 'package:isar/isar.dart';
// import 'package:path_provider/path_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // final dir = await getApplicationDocumentsDirectory();
  // final isar = await Isar.open([], directory: dir.path);

  // sl.registerLazySingleton(() => isar);
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl(), firestore: sl()),
  );
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
}
