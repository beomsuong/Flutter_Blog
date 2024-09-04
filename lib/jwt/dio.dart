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

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    return handler.next(response);
  }

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) async {
    if (error.response?.data['statusCode'] == 404) {
      debugPrint('dio 404 에러'); //데이터 X
      return handler.reject(error);
    } else if (error.response?.data['statusCode'] == 401) {
      debugPrint('dio 401 에러'); //엑세스 토큰 오류
      final refreshToken = await storage.readRefreshToken();
      if (refreshToken != null) {
        Dio dio = Dio();
        try {
          final response = await dio.get(
            '${Config.instance.apiBaseUrl}/auth',
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

          // secure storage도 update
          await storage.saveAccessToken(accessToken);

          // 원래 보내려던 요청 재전송
          final newResponse = await dio.fetch(options);

          return handler.resolve(newResponse);
        } on DioException catch (e) {
          debugPrint('리프레시 토큰으로 토큰 갱신 실패 $e');
          await Future.value([
            storage.deleteId(),
            storage.deleteToken(),
          ]);
          //로그인 화면으로 이동 처리
          // 이 부분에서 로그인 화면으로의 전환을 직접 구현해야 합니다.
          // 예: Navigator.pushReplacementNamed(context, '/login');

          return handler.reject(e);
        }
      }
      return handler.reject(error);
    }
    debugPrint('dio 에러메시지 ${error.response}'); //데이터 X
    return handler.reject(error);
  }
}

void main() {
  final secureStorage = SecureStorage(); // SecureStorage 인스턴스 생성
  final dioFactory = DioFactory(secureStorage);
  final dio = dioFactory.createDio(); // Dio 인스턴스 생성

  runApp(MyApp(dio: dio)); // dio 인스턴스를 MyApp에 전달
}

class MyApp extends StatelessWidget {
  final Dio dio;

  MyApp({required this.dio});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dio without Riverpod',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(dio: dio),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final Dio dio;

  MyHomePage({required this.dio});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dio without Riverpod'),
      ),
      body: Center(
        child: Text('My Home Page'),
      ),
    );
  }
}
