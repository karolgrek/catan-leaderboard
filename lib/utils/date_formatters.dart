class DateFormatter {
  static String toReadableDate(DateTime date) {
    // Basic date formatting: DD.MM.YYYY
    // If intl package was added, we would use DateFormat('dd.MM.yyyy').format(date);
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
