import 'package:json_annotation/json_annotation.dart';

part 'overtime_models.g.dart';

@JsonSerializable(createToJson: true)
class OvertimeRequest {
  final DateTime workDate;
  final double hours;
  final double multiplier;

  const OvertimeRequest({
    required this.workDate,
    required this.hours,
    required this.multiplier,
  });

  factory OvertimeRequest.fromJson(Map<String, dynamic> json) => _$OvertimeRequestFromJson(json);

  Map<String, dynamic> toJson() {
    final y = workDate.year.toString().padLeft(4, '0');
    final m = workDate.month.toString().padLeft(2, '0');
    final d = workDate.day.toString().padLeft(2, '0');
    final h = workDate.hour.toString().padLeft(2, '0');
    final min = workDate.minute.toString().padLeft(2, '0');
    final s = workDate.second.toString().padLeft(2, '0');
    final formattedDate = '$y-$m-${d}T$h:$min:${s}Z';

    return {
      'workDate': formattedDate,
      'hours': hours,
      'multiplier': multiplier,
    };
  }
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.pascal)
class OvertimeResponse {
  final int? id;
  final int? employeeId;
  final DateTime? workDate;
  final double? hours;
  final double? multiplier;
  final String? status;

  const OvertimeResponse({
    this.id,
    this.employeeId,
    this.workDate,
    this.hours,
    this.multiplier,
    this.status,
  });

  factory OvertimeResponse.fromJson(Map<String, dynamic> json) => _$OvertimeResponseFromJson(json);

  // Constants for Status (Strictly PascalCase)
  static const String statusPending = 'Pending';
  static const String statusApproved = 'Approved';
  static const String statusRejected = 'Rejected';
  static const String statusCancelled = 'Cancelled';
}

class EmployeeOvertimeDto {
  final int id;
  final DateTime workDate;
  final double hours;
  final double multiplier;
  final String? status;

  const EmployeeOvertimeDto({
    required this.id,
    required this.workDate,
    required this.hours,
    required this.multiplier,
    this.status,
  });

  EmployeeOvertimeDto copyWith({
    int? id,
    DateTime? workDate,
    double? hours,
    double? multiplier,
    String? status,
  }) {
    return EmployeeOvertimeDto(
      id: id ?? this.id,
      workDate: workDate ?? this.workDate,
      hours: hours ?? this.hours,
      multiplier: multiplier ?? this.multiplier,
      status: status ?? this.status,
    );
  }

  factory EmployeeOvertimeDto.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    double parseDouble(dynamic val, [double defaultValue = 0.0]) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? defaultValue;
      return defaultValue;
    }

    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is String && val.isNotEmpty) {
        try {
          return DateTime.parse(val);
        } catch (_) {}
      }
      return null;
    }

    dynamic findKey(List<String> keys) {
      for (final k in keys) {
        if (json.containsKey(k) && json[k] != null) return json[k];
      }
      return null;
    }

    final id = parseInt(findKey(['id', 'Id', 'ID']));
    final workDate = parseDate(findKey(['workDate', 'WorkDate', 'date', 'Date', 'createdAt', 'CreatedAt'])) ?? DateTime.now();
    final hours = parseDouble(findKey(['hours', 'Hours', 'overtimeHours', 'OvertimeHours', 'numHours', 'NumHours']));
    final multiplier = parseDouble(findKey(['multiplier', 'Multiplier', 'rate', 'Rate']), 1.0);
    final status = findKey(['status', 'Status']) as String?;

    return EmployeeOvertimeDto(
      id: id,
      workDate: workDate,
      hours: hours,
      multiplier: multiplier,
      status: status,
    );
  }
}
