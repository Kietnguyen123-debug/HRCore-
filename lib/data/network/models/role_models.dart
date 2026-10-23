import 'package:json_annotation/json_annotation.dart';

part 'role_models.g.dart';

@JsonSerializable(createToJson: true)
class RoleSummaryResponse {
  final int id;
  final String? name;
  final String? description;
  final bool isSystemDefault;

  const RoleSummaryResponse({
    required this.id,
    this.name,
    this.description,
    this.isSystemDefault = false,
  });

  factory RoleSummaryResponse.fromJson(Map<String, dynamic> json) => _$RoleSummaryResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RoleSummaryResponseToJson(this);
}

@JsonSerializable(createToJson: true)
class PermissionMatrixItem {
  final int id;
  final String? module;
  final String? action;
  final String? description;
  final bool enabled;

  const PermissionMatrixItem({
    required this.id,
    this.module,
    this.action,
    this.description,
    this.enabled = false,
  });

  factory PermissionMatrixItem.fromJson(Map<String, dynamic> json) => _$PermissionMatrixItemFromJson(json);
  Map<String, dynamic> toJson() => _$PermissionMatrixItemToJson(this);
}

@JsonSerializable(createToJson: true)
class PermissionMatrixResponse {
  final RoleSummaryResponse role;
  final List<PermissionMatrixItem>? permissions;

  const PermissionMatrixResponse({
    required this.role,
    this.permissions,
  });

  factory PermissionMatrixResponse.fromJson(Map<String, dynamic> json) => _$PermissionMatrixResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PermissionMatrixResponseToJson(this);
}

@JsonSerializable(createToJson: true)
class CreateRoleRequest {
  final String? name;
  final String? description;

  const CreateRoleRequest({this.name, this.description});

  factory CreateRoleRequest.fromJson(Map<String, dynamic> json) => _$CreateRoleRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateRoleRequestToJson(this);
}

@JsonSerializable(createToJson: true)
class UpdateRolePermissionsRequest {
  final List<int>? permissionIds;

  const UpdateRolePermissionsRequest({this.permissionIds});

  factory UpdateRolePermissionsRequest.fromJson(Map<String, dynamic> json) => _$UpdateRolePermissionsRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateRolePermissionsRequestToJson(this);
}

@JsonSerializable(createToJson: true)
class AssignRoleRequest {
  final int roleId;

  const AssignRoleRequest({required this.roleId});

  factory AssignRoleRequest.fromJson(Map<String, dynamic> json) => _$AssignRoleRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AssignRoleRequestToJson(this);
}
