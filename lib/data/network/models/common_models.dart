import 'package:json_annotation/json_annotation.dart';
import 'admin_models.dart';
import 'shift_admin_models.dart';

part 'common_models.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class PagedResponse<T> {
  final List<T>? items;
  final List<T>? data;
  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  PagedResponse({
    this.items,
    this.data,
    this.page = 1,
    this.pageSize = 20,
    this.totalItems = 0,
    this.totalPages = 0,
  });

  factory PagedResponse.fromJson(
      Map<String, dynamic> json, T Function(Object? json) fromJsonT) =>
      _$PagedResponseFromJson(json, fromJsonT);

  List<T> get list => items ?? data ?? [];
}

@JsonSerializable(createToJson: false)
class CancelRequestResponse {
  final int id;
  final String? status;

  const CancelRequestResponse({
    required this.id,
    this.status,
  });

  factory CancelRequestResponse.fromJson(Map<String, dynamic> json) => _$CancelRequestResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
class MessageResponse {
  final String? message;
  const MessageResponse({this.message});
  factory MessageResponse.fromJson(Map<String, dynamic> json) => _$MessageResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
class ApiMessageResponse {
  final bool success;
  final String? message;
  const ApiMessageResponse({required this.success, this.message});
  factory ApiMessageResponse.fromJson(Map<String, dynamic> json) => _$ApiMessageResponseFromJson(json);
}

// Aliases for Retrofit
typedef AdminAttendanceDtoPagedResponse = PagedResponse<AdminAttendanceDto>;
typedef AdminLeaveDtoPagedResponse = PagedResponse<AdminLeaveDto>;
typedef AdminOvertimeDtoPagedResponse = PagedResponse<AdminOvertimeDto>;
typedef AdminSalaryAdvanceDtoPagedResponse = PagedResponse<AdminSalaryAdvanceDto>;
typedef AdminShiftAssignmentDtoPagedResponse = PagedResponse<AdminShiftAssignmentDto>;
