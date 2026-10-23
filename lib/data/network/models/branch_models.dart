import 'package:json_annotation/json_annotation.dart';

part 'branch_models.g.dart';

@JsonSerializable(createToJson: true) // Bật true để fix lỗi _$BranchToJson
class Branch {
  final int id;
  final String? name;
  final bool isActive;
  final int employeeCount;
  final int publicIpCount;
  final int wifiCount;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final List<BranchWifiDto> wifis = const [];
  @JsonKey(includeFromJson: false, includeToJson: false)
  final List<BranchIpDto> publicIps = const [];

  const Branch({
    required this.id,
    this.name,
    this.isActive = true,
    this.employeeCount = 0,
    this.publicIpCount = 0,
    this.wifiCount = 0,
  });

  factory Branch.fromJson(Map<String, dynamic> json) => _$BranchFromJson(json);
  
  Map<String, dynamic> toJson() => _$BranchToJson(this);

  dynamic operator [](String key) => toJson()[key];
}

typedef BranchListItemResponse = Branch;

@JsonSerializable(createToJson: false)
class BranchListResponse {
  final bool success;
  final List<Branch>? data;

  const BranchListResponse({
    required this.success,
    this.data,
  });

  factory BranchListResponse.fromJson(Map<String, dynamic> json) => _$BranchListResponseFromJson(json);
}

@JsonSerializable(createToJson: true)
class BranchRequest {
  final String name;

  const BranchRequest({required this.name});

  factory BranchRequest.fromJson(Map<String, dynamic> json) => _$BranchRequestFromJson(json);
  Map<String, dynamic> toJson() => _$BranchRequestToJson(this);
}

@JsonSerializable(createToJson: false)
class BranchResponse {
  final int id;
  final String? name;
  final bool isActive;
  final int employeeCount;
  final int publicIpCount;
  final int wifiCount;

  const BranchResponse({
    required this.id,
    this.name,
    required this.isActive,
    required this.employeeCount,
    required this.publicIpCount,
    required this.wifiCount,
  });

  factory BranchResponse.fromJson(Map<String, dynamic> json) => _$BranchResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
class BranchStatusResponse {
  final int id;
  final bool isActive;

  const BranchStatusResponse({
    required this.id,
    required this.isActive,
  });

  factory BranchStatusResponse.fromJson(Map<String, dynamic> json) => _$BranchStatusResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
class BranchWifiStatusResponse {
  final int id;
  final bool isActive;

  const BranchWifiStatusResponse({
    required this.id,
    required this.isActive,
  });

  factory BranchWifiStatusResponse.fromJson(Map<String, dynamic> json) => _$BranchWifiStatusResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
class BranchIpDto {
  final int id;
  final int branchId;
  final String? publicIp;
  final String? description;
  final bool isActive;

  const BranchIpDto({
    required this.id,
    required this.branchId,
    this.publicIp,
    this.description,
    required this.isActive,
  });

  factory BranchIpDto.fromJson(Map<String, dynamic> json) => _$BranchIpDtoFromJson(json);
}

@JsonSerializable(createToJson: true)
class BranchIpRequest {
  final String publicIp;
  final String? description;

  const BranchIpRequest({
    this.publicIp = "",
    this.description,
  });

  factory BranchIpRequest.fromJson(Map<String, dynamic> json) => _$BranchIpRequestFromJson(json);
  Map<String, dynamic> toJson() => _$BranchIpRequestToJson(this);
}

@JsonSerializable(createToJson: false)
class BranchWifiDto {
  final int id;
  final int branchId;
  final String? ssid;
  final String? bssid;
  final String? description;
  final bool isActive;

  const BranchWifiDto({
    required this.id,
    required this.branchId,
    this.ssid,
    this.bssid,
    this.description,
    required this.isActive,
  });

  factory BranchWifiDto.fromJson(Map<String, dynamic> json) => _$BranchWifiDtoFromJson(json);
}

@JsonSerializable(createToJson: true)
class BranchWifiRequest {
  final String ssid;
  final String bssid;
  final String? description;

  const BranchWifiRequest({
    required this.ssid,
    required this.bssid,
    this.description,
  });

  factory BranchWifiRequest.fromJson(Map<String, dynamic> json) => _$BranchWifiRequestFromJson(json);
  Map<String, dynamic> toJson() => _$BranchWifiRequestToJson(this);
}
