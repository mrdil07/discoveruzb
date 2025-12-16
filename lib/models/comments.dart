import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'comments.freezed.dart';
part 'comments.g.dart';

@freezed
class Comments with _$Comments {
  const factory Comments({
    required Map<String, dynamic> users,
    required int dateTime,
    required String comment,
  }) = _Comments;

  factory Comments.fromJson(Map<String, dynamic> json) => _$CommentsFromJson(json);
}
