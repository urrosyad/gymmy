import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:gymmy/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:gymmy/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:gymmy/features/auth/domain/repositories/auth_repository.dart';
import 'package:gymmy/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:gymmy/features/auth/domain/usecases/login_usecase.dart';
import 'package:gymmy/features/auth/domain/usecases/logout_usecase.dart';
import 'package:gymmy/features/auth/domain/usecases/register_member_usecase.dart';
import 'package:gymmy/features/auth/domain/usecases/register_owner_usecase.dart';

final GetIt sl = GetIt.instance;

Future<void> initInjection() async {
  // ---------------------------------------------------------------------------
  // Firebase services
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // ---------------------------------------------------------------------------
  // Auth — Data
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasource(
      auth: sl<FirebaseAuth>(),
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDatasource>()),
  );

  // ---------------------------------------------------------------------------
  // Auth — Use Cases
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton(() => LoginUsecase(sl<AuthRepository>()));
  sl.registerLazySingleton(
      () => RegisterMemberUsecase(sl<AuthRepository>()));
  sl.registerLazySingleton(
      () => RegisterOwnerUsecase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUsecase(sl<AuthRepository>()));
  sl.registerLazySingleton(
      () => GetCurrentUserUsecase(sl<AuthRepository>()));
}
