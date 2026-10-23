import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'interceptors/auth_interceptor.dart';

/// Centralized singleton manager for the [Dio] HTTP network client,
/// pre-configured with precise timeouts, SSL bypass for development,
/// and the thread-safe [AuthInterceptor].
class DioClient {
  static const String baseUrl = 'https://quantrinhansu.runasp.net/api/';

  late final Dio dio;

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 120),
        sendTimeout: const Duration(seconds: 30),
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    // Bỏ qua lỗi SSL Certificate trên Android/iOS để đảm bảo kết nối ổn định
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );

    // Register our sequential queued authorization interceptor
    dio.interceptors.add(AuthInterceptor());
  }

  static final DioClient _instance = DioClient._internal();

  /// Retrieves the initialized single instance of [DioClient].
  factory DioClient() => _instance;
}
