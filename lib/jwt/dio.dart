
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'secure_storage.dart';


class DioFactory {
  final SecureStorage storage;

 
  DioFactory(this.storage);

  Dio createDio() {
    BaseOptions options = BaseOptions();
    final dio = Dio(options);
    dio.interceptors.add(TokenInterceptor(
      storage: storage,
    ));
    return dio;
  }
}

class TokenInterceptor extends Interceptor {
  final SecureStorage storage;

  TokenInterceptor({required this.storage});

  ///요청 보내기 전
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    options.headers.remove('accessToken');
    final accessToken = await storage.readAccessToken();
    options.headers.addAll({
      'Content-Type': 'application/json',
      'authorization': 'Bearer $accessToken',
    });
    return handler.next(options);
  }

  ///응답 시
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    return handler.next(response);
  }

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) async {
    if (error.response?.data['statusCode'] == 404) {
      debugPrint('dio 404 에러'); //엑세스 토큰 오류는 아닐 때
      return handler.reject(error);
    } else if (error.response?.data['statusCode'] == 401) {
      debugPrint('dio 401 에러'); //엑세스 토큰 오류
      final refreshToken = await storage.readRefreshToken();
      if (refreshToken != null) {
        Dio dio = Dio();
        try {
          final response = await dio.get(
            '/getAccessToken',
            options: Options(
              headers: {
                'Content-Type': 'application/json',
                'authorization': 'Bearer $refreshToken',
              },
            ),
          );
          debugPrint('리프레시 갱신 ${response.data['data']['accessToken']}');
          final accessToken = response.data['data']['accessToken'];

          final options = error.requestOptions;
          // 요청의 헤더에 새로 발급받은 accessToken으로 변경하기
          options.headers.addAll({
            'authorization': 'Bearer $accessToken',
          });
          // 새롭게 발급 받은 엑세스 토큰으로 갱신
          await storage.saveAccessToken(accessToken);

          // 원래 보내려던 요청 재전송
          final newResponse = await dio.fetch(options);

          return handler.resolve(newResponse);
        } on DioException catch (e) {
          debugPrint('리프레시 토큰으로 토큰 갱신 실패 $e');
          await Future.value([
            storage.deleteToken(),
          ]);
          return handler.reject(e);
        }
      }
      return handler.reject(error);
    }
    debugPrint('dio 에러메시지 ${error.response}'); //데이터 X
    return handler.reject(error);
  }
}