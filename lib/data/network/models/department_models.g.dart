// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'department_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DepartmentListItemResponse _$DepartmentListItemResponseFromJson(
  Map<String, dynamic> json,
) => DepartmentListItemResponse(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String?,
);

DepartmentListResponse _$DepartmentListResponseFromJson(
  Map<String, dynamic> json,
) => DepartmentListResponse(
  success: json['success'] as bool,
  data: (json['data'] as List<dynamic>?)
      ?.map(
        (e) => DepartmentListItemResponse.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
);

DepartmentRequest _$DepartmentRequestFromJson(Map<String, dynamic> json) =>
    DepartmentRequest(name: json['name'] as String);

Map<String, dynamic> _$DepartmentRequestToJson(DepartmentRequest instance) =>
    <String, dynamic>{'name': instance.name};

DepartmentResponse _$DepartmentResponseFromJson(Map<String, dynamic> json) =>
    DepartmentResponse(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
      isActive: json['isActive'] as bool,
      employeeCount: (json['employeeCount'] as num).toInt(),
    );
