import 'package:get_it/get_it.dart';

final GetIt sl = GetIt.instance;

Future<void> initInjection() async {
  // We will register dependencies here as we build out features
  // e.g., sl.registerLazySingleton<Repository>(() => RepositoryImpl());
}
