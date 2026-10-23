import 'package:json_annotation/json_annotation.dart';

class TimeSpanConverter implements JsonConverter<Duration, String> {
  const TimeSpanConverter();

  @override
  Duration fromJson(String json) {
    if (json.isEmpty) return Duration.zero;
    try {
      final parts = json.split(':');
      if (parts.length >= 2) {
        final hours = int.tryParse(parts[0]) ?? 0;
        final minutes = int.tryParse(parts[1]) ?? 0;

        int seconds = 0;
        if (parts.length > 2) {
          // Xử lý cả trường hợp có phần thập phân giây: "00.0000000"
          final secPart = parts[2].split('.')[0];
          seconds = int.tryParse(secPart) ?? 0;
        }
        return Duration(hours: hours, minutes: minutes, seconds: seconds);
      }
    } catch (_) {}
    return Duration.zero;
  }

  @override
  String toJson(Duration object) {
    final hours = object.inHours.toString().padLeft(2, '0');
    final minutes = (object.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (object.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}