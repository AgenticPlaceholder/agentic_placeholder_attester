// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import 'controllers/barcode_scanner_store.dart' as _i136;
import 'controllers/navigation_controller.dart' as _i894;
import 'controllers/pairings_store.dart' as _i878;
import 'controllers/service_controller.dart' as _i270;
import 'injectable_modules.dart' as _i129;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt $initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  final registerModule = _$RegisterModule();
  gh.singleton<_i361.Dio>(() => registerModule.dio);
  gh.lazySingleton<_i270.ServiceController>(() => _i270.ServiceController());
  gh.lazySingleton<_i894.NavigationController>(
      () => _i894.NavigationController());
  gh.lazySingleton<_i136.BarcodeScannerStore>(
      () => _i136.BarcodeScannerStore());
  gh.lazySingleton<_i878.PairingsStore>(() => _i878.PairingsStore());
  return getIt;
}

class _$RegisterModule extends _i129.RegisterModule {}
