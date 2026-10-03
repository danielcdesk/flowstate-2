/// Calendar date without a time zone or time of day.
final class LocalDate implements Comparable<LocalDate> {
  LocalDate(this.year, this.month, this.day) {
    final DateTime normalized = DateTime.utc(year, month, day);
    if (normalized.year != year ||
        normalized.month != month ||
        normalized.day != day) {
      throw ArgumentError('Invalid calendar date.');
    }
  }

  final int year;
  final int month;
  final int day;

  int get weekday => DateTime.utc(year, month, day).weekday;

  LocalDate get startOfIsoWeek => addDays(1 - weekday);

  LocalDate addDays(int days) {
    final DateTime value = DateTime.utc(
      year,
      month,
      day,
    ).add(Duration(days: days));
    return LocalDate(value.year, value.month, value.day);
  }

  int differenceInDays(LocalDate other) {
    return DateTime.utc(
      year,
      month,
      day,
    ).difference(DateTime.utc(other.year, other.month, other.day)).inDays;
  }

  @override
  int compareTo(LocalDate other) {
    final int yearComparison = year.compareTo(other.year);
    if (yearComparison != 0) return yearComparison;
    final int monthComparison = month.compareTo(other.month);
    if (monthComparison != 0) return monthComparison;
    return day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) {
    return other is LocalDate &&
        other.year == year &&
        other.month == month &&
        other.day == day;
  }

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() {
    final String yearText = year.toString().padLeft(4, '0');
    final String monthText = month.toString().padLeft(2, '0');
    final String dayText = day.toString().padLeft(2, '0');
    return '$yearText-$monthText-$dayText';
  }
}
