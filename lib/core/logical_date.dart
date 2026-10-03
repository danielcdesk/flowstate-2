import 'package:flowstate/core/local_date.dart';

/// Maps a local wall-clock time to the app's logical day.
LocalDate logicalDate(DateTime localTime, {required int dayStartMinute}) {
  if (dayStartMinute < 0 || dayStartMinute >= 1440) {
    throw ArgumentError.value(dayStartMinute, 'dayStartMinute');
  }
  final int minuteOfDay = localTime.hour * 60 + localTime.minute;
  final LocalDate calendarDate = LocalDate(
    localTime.year,
    localTime.month,
    localTime.day,
  );
  return minuteOfDay < dayStartMinute ? calendarDate.addDays(-1) : calendarDate;
}
