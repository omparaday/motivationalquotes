
import 'package:intl/intl.dart';

DateTime getPreviousDay(DateTime historyDate) =>
    historyDate.subtract(Duration(days: 1));

DateTime getFirstDayOfMonth(DateTime historyDate) => new DateTime(
    historyDate.year,
    historyDate.month,
    1,
    historyDate.hour,
    historyDate.minute,
    historyDate.second,
    historyDate.millisecond,
    historyDate.microsecond);

DateTime getFirstDayOfYear(DateTime historyDate) => new DateTime(
    historyDate.year,
    1,
    1,
    historyDate.hour,
    historyDate.minute,
    historyDate.second,
    historyDate.millisecond,
    historyDate.microsecond);

DateTime getPreviousMonth(DateTime historyDate) => new DateTime(
    historyDate.year,
    historyDate.month - 1,
    1,
    historyDate.hour,
    historyDate.minute,
    historyDate.second,
    historyDate.millisecond,
    historyDate.microsecond);

DateTime getNextMonth(DateTime historyDate) => new DateTime(
    historyDate.year,
    historyDate.month + 1,
    1,
    historyDate.hour,
    historyDate.minute,
    historyDate.second,
    historyDate.millisecond,
    historyDate.microsecond);

DateTime getPreviousYear(DateTime historyDate) => new DateTime(
    historyDate.year - 1,
    1,
    1,
    historyDate.hour,
    historyDate.minute,
    historyDate.second,
    historyDate.millisecond,
    historyDate.microsecond);

DateTime getNextYear(DateTime historyDate) => new DateTime(
    historyDate.year + 1,
    1,
    1,
    historyDate.hour,
    historyDate.minute,
    historyDate.second,
    historyDate.millisecond,
    historyDate.microsecond);

DateTime getFirstDayOfWeek(DateTime date) {
  while ('Sunday' != getDayOfWeek(date)) {
    date = date.subtract(Duration(days: 1));
  }
  return date;
}

String getDayOfWeek(DateTime date) => DateFormat('EEEE').format(date);

String getDisplayDate(DateTime date) =>
    DateFormat('MMM dd, yyyy EEEE').format(date);

String getDisplayDateWithoutDoW(DateTime date) =>
    DateFormat('MMM dd, yyyy').format(date);

String getDisplayDateWithoutYear(DateTime date) =>
    DateFormat('MMM dd, EEEE').format(date);

DateTime getPreviousWeek(DateTime date) {
  return date.subtract(Duration(days: 7));
}

DateTime getNextWeek(DateTime date) {
  return date.add(Duration(days: 7));
}

String getMonthName(DateTime dateTime) {
  return DateFormat('MMMM yyyy').format(dateTime);
}
