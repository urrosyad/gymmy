import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

// Auth
import 'package:gymmy/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:gymmy/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:gymmy/features/auth/domain/repositories/auth_repository.dart';
import 'package:gymmy/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:gymmy/features/auth/domain/usecases/login_usecase.dart';
import 'package:gymmy/features/auth/domain/usecases/logout_usecase.dart';
import 'package:gymmy/features/auth/domain/usecases/register_member_usecase.dart';
import 'package:gymmy/features/auth/domain/usecases/register_owner_usecase.dart';

// Biodata
import 'package:gymmy/features/biodata/data/datasources/biodata_remote_datasource.dart';
import 'package:gymmy/features/biodata/data/repositories/biodata_repository_impl.dart';
import 'package:gymmy/features/biodata/domain/repositories/biodata_repository.dart';
import 'package:gymmy/features/biodata/domain/usecases/save_biodata_usecase.dart';

// Gym Tenant
import 'package:gymmy/features/gym_tenant/data/datasources/gym_tenant_remote_datasource.dart';
import 'package:gymmy/features/gym_tenant/data/repositories/gym_tenant_repository_impl.dart';
import 'package:gymmy/features/gym_tenant/domain/repositories/gym_tenant_repository.dart';
import 'package:gymmy/features/gym_tenant/domain/usecases/create_gym_usecase.dart';
import 'package:gymmy/features/gym_tenant/domain/usecases/get_all_gyms_usecase.dart';
import 'package:gymmy/features/gym_tenant/domain/usecases/get_owner_gym_usecase.dart';

// Membership
import 'package:gymmy/features/membership/data/datasources/membership_remote_datasource.dart';
import 'package:gymmy/features/membership/data/repositories/membership_repository_impl.dart';
import 'package:gymmy/features/membership/domain/repositories/membership_repository.dart';
import 'package:gymmy/features/membership/domain/usecases/get_active_membership_usecase.dart';

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

  // Auth — Use Cases
  sl.registerLazySingleton(() => LoginUsecase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterMemberUsecase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterOwnerUsecase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUsecase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetCurrentUserUsecase(sl<AuthRepository>()));

  // ---------------------------------------------------------------------------
  // Biodata — Data
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<BiodataRemoteDatasource>(
    () => BiodataRemoteDatasource(firestore: sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<BiodataRepository>(
    () => BiodataRepositoryImpl(sl<BiodataRemoteDatasource>()),
  );

  // Biodata — Use Cases
  sl.registerLazySingleton(() => SaveBiodataUsecase(sl<BiodataRepository>()));

  // ---------------------------------------------------------------------------
  // Gym Tenant — Data
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<GymTenantRemoteDatasource>(
    () => GymTenantRemoteDatasource(firestore: sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<GymTenantRepository>(
    () => GymTenantRepositoryImpl(sl<GymTenantRemoteDatasource>()),
  );

  // Gym Tenant — Use Cases
  sl.registerLazySingleton(() => CreateGymUsecase(sl<GymTenantRepository>()));
  sl.registerLazySingleton(() => GetAllGymsUsecase(sl<GymTenantRepository>()));
  sl.registerLazySingleton(() => GetOwnerGymUsecase(sl<GymTenantRepository>()));

  // ---------------------------------------------------------------------------
  // Membership — Data
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<MembershipRemoteDatasource>(
    () => MembershipRemoteDatasource(firestore: sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<MembershipRepository>(
    () => MembershipRepositoryImpl(sl<MembershipRemoteDatasource>()),
  );

  // Membership — Use Cases
  sl.registerLazySingleton(
      () => GetActiveMembershipUsecase(sl<MembershipRepository>()));
}
