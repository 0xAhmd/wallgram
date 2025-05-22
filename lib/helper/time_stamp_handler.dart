import 'package:intl/intl.dart';

String formatTimeStamp(DateTime dateTime) {
  return DateFormat('yyyy-MM-dd hh:mm a').format(dateTime);
}
