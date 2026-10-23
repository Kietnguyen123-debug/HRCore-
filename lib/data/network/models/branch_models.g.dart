// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branch_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Branch _$BranchFromJson(Map<String, dynamic> json) => Branch(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  employeeCount: (json['employeeCount'] as num?)?.toInt() ?? 0,
  publicIpCount: (json['publicIpCount'] as num?)?.toInt() ?? 0,
  wifiCount: (json['wifiCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$BranchToJson(Branch instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'isActive': instance.isActive,
  'employeeCount': instance.employeeCount,
  'publicIpCount': instance.publicIpCount,
  'wifiCount': instance.wifiCount,
};

BranchListResponse _$BranchListResponseFromJson(Map<String, dynamic> json) =>
    BranchListResponse(
      success: json['success'] as bool,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => Branch.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

BranchRequest _$BranchRequestFromJson(Map<String, dynamic> json) =>
    BranchRequest(name: json['name'] as String);

Map<String, dynamic> _$BranchRequestToJson(BranchRequest instance) =>
    <String, dynamic>{'name': instance.name};

BranchResponse _$BranchResponseFromJson(Map<String, dynamic> json) =>
    BranchResponse(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
      isActive: json['isActive'] as bool,
      employeeCount: (json['employeeCount'] as num).toInt(),
      publicIpCount: (json['publicIpCount'] as num).toInt(),
      wifiCount: (json['wifiCount'] as num).toInt(),
    );

BranchStatusResponse _$BranchStatusResponseFromJson(
  Map<String, dynamic> json,
) => BranchStatusResponse(
  id: (json['id'] as num).toInt(),
  isActive: json['isActive'] as bool,
);

BranchWifiStatusResponse _$BranchWifiStatusResponseFromJson(
  Map<String, dynamic> json,
) => BranchWifiStatusResponse(
  id: (json['id'] as num).toInt(),
  isActive: json['isActive'] as bool,
);

BranchIpDto _$BranchIpDtoFromJson(Map<String, dynamic> json) => BranchIpDto(
  id: (json['id'] as num).toInt(),
  branchId: (json['branchId'] as num).toInt(),
  publicIp: json['publicIp'] as String?,
  description: json['description'] as String?,
  isActive: json['isActive'] as bool,
);

BranchIpRequest _$BranchIpRequestFromJson(Map<String, dynamic> json) =>
    BranchIpRequest(
      publicIp: json['publicIp'] as String? ?? "",
      description: json['description'] as String?,
    );

Map<String, dynamic> _$BranchIpRequestToJson(BranchIpRequest instance) =>
    <String, dynamic>{
      'publicIp': instance.publicIp,
      'description': instance.description,
    };

BranchWifiDto _$BranchWifiDtoFromJson(Map<String, dynamic> json) =>
    BranchWifiDto(
      id: (json['id'] as num).toInt(),
      branchId: (json['branchId'] as num).toInt(),
      ssid: json['ssid'] as String?,
      bssid: json['bssid'] as String?,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool,
    );

BranchWifiRequest _$BranchWifiRequestFromJson(Map<String, dynamic> json) =>
    BranchWifiRequest(
      ssid: json['ssid'] as String,
      bssid: json['bssid'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$BranchWifiRequestToJson(BranchWifiRequest instance) =>
    <String, dynamic>{
      'ssid': instance.ssid,
      'bssid': instance.bssid,
      'description': instance.description,
    };
