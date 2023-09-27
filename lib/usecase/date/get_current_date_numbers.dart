/// Generates a string containing the current date numbers in a string.
///
/// For example, if the current date is 2020-12-31 15:13:33, then the
/// function will produce: "20201231151333"
String getCurrentDateNumbers() {
  var date = DateTime.now();
  var values = [
    date.year,
    date.month,
    date.day,
    date.hour,
    date.minute,
    date.second,
  ].map((x) => x.toString().padLeft(2, '0')).join();
  return values;
}
