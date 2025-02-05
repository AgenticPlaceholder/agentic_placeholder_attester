// lib/injectable_modules.dart

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@module
abstract class RegisterModule {
  @singleton
  Dio get dio => Dio(BaseOptions(
    baseUrl: 'http://ec2-13-127-246-11.ap-south-1.compute.amazonaws.com:4000',
  ));
}