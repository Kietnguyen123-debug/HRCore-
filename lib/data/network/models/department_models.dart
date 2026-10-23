import 'package:json_annotation/json_annotation.dart';

part 'department_models.g.dart';

@JsonSerializable(createToJson: false)
class DepartmentListItemResponse {
  final int id;
  final String? name;

  const DepartmentListItemResponse({required this.id, this.name});

  factory DepartmentListItemResponse.fromJson(Map<String, dynamic> json) => _$DepartmentListItemResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
class DepartmentListResponse {
  final bool success;
  final List<DepartmentListItemResponse>? data;

  const DepartmentListResponse({required this.success, this.data});

  factory DepartmentListResponse.fromJson(Map<String, dynamic> json) => _$DepartmentListResponseFromJson(json);
}

@JsonSerializable(createToJson: true)
class DepartmentRequest {
  final String name;

  const DepartmentRequest({required this.name});

  Map<String, dynamic> toJson() => _$DepartmentRequestToJson(this);
}

@JsonSerializable(createToJson: false)
class DepartmentResponse {
  final int id;
  final String? name;
  final bool isActive;
  final int employeeCount;

  const DepartmentResponse({
    required this.id,
    this.name,
    required this.isActive,
    required this.employeeCount,
  });

  factory DepartmentResponse.fromJson(Map<String, dynamic> json) => _$DepartmentResponseFromJson(json);
}
