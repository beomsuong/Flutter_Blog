import 'package:freezed_annotation/freezed_annotation.dart';

part "model.freezed.dart";
part 'model.g.dart';

@freezed
class Model with _$Model {
  factory Model(
      {required int userId,
      required int id,
      required String title,
      required String body}) = _Model;
  factory Model.fromJson(Map<String, dynamic> json) => _$ModelFromJson(json);
}
