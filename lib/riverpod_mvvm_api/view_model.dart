import 'package:blog_posting/riverpod_mvvm_api/model.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'view_model.g.dart';

@riverpod
class ViewModel extends _$ViewModel {
  final dio = Dio();

  @override
  AsyncValue<Model> build() {
    getData();
    return const AsyncValue.loading();
  }

  Future<void> getData() async {
    final response =
        await dio.get('https://jsonplaceholder.typicode.com/posts/1');
    state = AsyncValue.data(Model.fromJson(response.data));
  }
}
