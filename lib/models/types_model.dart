import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'types_model.freezed.dart';
part 'types_model.g.dart';

@freezed
class Types with _$Types {
  const factory Types({
    required String typeName,
    required String image,
  }) = _Types;

  factory Types.fromJson(Map<String, dynamic> json) => _$TypesFromJson(json);
}
