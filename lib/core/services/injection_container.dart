import 'package:bill_chillin/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:bill_chillin/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:bill_chillin/features/auth/domain/repositories/auth_repository.dart';
import 'package:bill_chillin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:isar/isar.dart';
// import 'package:path_provider/path_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  await GoogleSignIn.instance.initialize(
    serverClientId: dotenv.env['GOOGLE_OAUTH_WEB_CLIENT_ID']!,
  );

  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn.instance);

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
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
}
