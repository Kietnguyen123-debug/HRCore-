import 'package:json_annotation/json_annotation.dart';
import '../converters/time_span_converter.dart';

part 'shift_models.g.dart';

@JsonSerializable(createToJson: true)
@TimeSpanConverter()
class ShiftDto {
  final int? id;
  final String? shiftCode;
  final String? shiftName;
  final Duration startTime;
  final Duration endTime;
  final bool isActive;

  const ShiftDto({
    this.id,
    this.shiftCode,
    this.shiftName,
    required this.startTime,
    required this.endTime,
    required this.isActive,
  });

  factory ShiftDto.fromJson(Map<String, dynamic> json) => _$ShiftDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ShiftDtoToJson(this);

  dynamic operator [](String key) {
    if (key == 'startTime') return startTime.toString();
    if (key == 'endTime') return endTime.toString();
    return toJson()[key];
  }
}

/// Request DTO chuẩn cho POST/PUT /api/Shift (Không chứa trường id)
@JsonSerializable(createToJson: true)
@TimeSpanConverter()
class CreateShiftRequest {
  final String shiftCode;
  final String shiftName;
  final Duration startTime;
  final Duration endTime;
  final bool isActive;

  const CreateShiftRequest({
    required this.shiftCode,
    required this.shiftName,
    required this.startTime,
    required this.endTime,
    this.isActive = true,
  });

  factory CreateShiftRequest.fromJson(Map<String, dynamic> json) => _$CreateShiftRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateShiftRequestToJson(this);
}

@JsonSerializable(createToJson: true)
class EmployeeShiftScheduleDto {
  final int? assignmentId;
  final DateTime effectiveFromDate;
  final DateTime? effectiveToDate;
  final ShiftDto? shift;

  const EmployeeShiftScheduleDto({
    this.assignmentId,
    required this.effectiveFromDate,
    this.effectiveToDate,
    this.shift,
  });

  factory EmployeeShiftScheduleDto.fromJson(Map<String, dynamic> json) => _$EmployeeShiftScheduleDtoFromJson(json);
  Map<String, dynamic> toJson() => _$EmployeeShiftScheduleDtoToJson(this);

  dynamic operator [](String key) => toJson()[key];
}