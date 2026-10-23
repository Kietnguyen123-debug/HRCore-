// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'common_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PagedResponse<T> _$PagedResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => PagedResponse<T>(
  items: (json['items'] as List<dynamic>?)?.map(fromJsonT).toList(),
  data: (json['data'] as List<dynamic>?)?.map(fromJsonT).toList(),
  page: (json['page'] as num?)?.toInt() ?? 1,
  pageSize: (json['pageSize'] as num?)?.toInt() ?? 20,
  totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
  totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$PagedResponseToJson<T>(
  PagedResponse<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'items': instance.items?.map(toJsonT).toList(),
  'data': instance.data?.map(toJsonT).toList(),
  'page': instance.page,
  'pageSize': instance.pageSize,
  'totalItems': instance.totalItems,
  'totalPages': instance.totalPages,
};

CancelRequestResponse _$CancelRequestResponseFromJson(
  Map<String, dynamic> json,
) => CancelRequestResponse(
  id: (json['id'] as num).toInt(),
  status: json['status'] as String?,
);

MessageResponse _$MessageResponseFromJson(Map<String, dynamic> json) =>
    MessageResponse(message: json['message'] as String?);

ApiMessageResponse _$ApiMessageResponseFromJson(Map<String, dynamic> json) =>
    ApiMessageResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
    );
