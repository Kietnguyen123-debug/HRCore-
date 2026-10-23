// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoleSummaryResponse _$RoleSummaryResponseFromJson(
  Map<String, dynamic> json,
) => RoleSummaryResponse(
  id: (json['id'] as num?)?.toInt() ?? 0,
  name: json['name'] as String?,
  description: json['description'] as String?,
  isSystemDefault: json['isSystemDefault'] as bool? ?? false,
);

Map<String, dynamic> _$RoleSummaryResponseToJson(
  RoleSummaryResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'isSystemDefault': instance.isSystemDefault,
};

PermissionMatrixItem _$PermissionMatrixItemFromJson(
  Map<String, dynamic> json,
) => PermissionMatrixItem(
  id: (json['id'] as num?)?.toInt() ?? 0,
  module: json['module'] as String?,
  action: json['action'] as String?,
  description: json['description'] as String?,
  enabled: json['enabled'] as bool? ?? false,
);

Map<String, dynamic> _$PermissionMatrixItemToJson(
  PermissionMatrixItem instance,
) => <String, dynamic>{
  'id': instance.id,
  'module': instance.module,
  'action': instance.action,
  'description': instance.description,
  'enabled': instance.enabled,
};

PermissionMatrixResponse _$PermissionMatrixResponseFromJson(
  Map<String, dynamic> json,
) => PermissionMatrixResponse(
  role: RoleSummaryResponse.fromJson(json['role'] as Map<String, dynamic>),
  permissions: (json['permissions'] as List<dynamic>?)
      ?.map((e) => PermissionMatrixItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PermissionMatrixResponseToJson(
  PermissionMatrixResponse instance,
) => <String, dynamic>{
  'role': instance.role,
  'permissions': instance.permissions,
};

CreateRoleRequest _$CreateRoleRequestFromJson(
  Map<String, dynamic> json,
) => CreateRoleRequest(
  name: json['name'] as String?,
  description: json['description'] as String?,
);

Map<String, dynamic> _$CreateRoleRequestToJson(
  CreateRoleRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
};

UpdateRolePermissionsRequest _$UpdateRolePermissionsRequestFromJson(
  Map<String, dynamic> json,
) => UpdateRolePermissionsRequest(
  permissionIds: (json['permissionIds'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$UpdateRolePermissionsRequestToJson(
  UpdateRolePermissionsRequest instance,
) => <String, dynamic>{
  'permissionIds': instance.permissionIds,
};

AssignRoleRequest _$AssignRoleRequestFromJson(
  Map<String, dynamic> json,
) => AssignRoleRequest(
  roleId: (json['roleId'] as num).toInt(),
);

Map<String, dynamic> _$AssignRoleRequestToJson(
  AssignRoleRequest instance,
) => <String, dynamic>{
  'roleId': instance.roleId,
};
