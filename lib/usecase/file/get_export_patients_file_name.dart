String getExportPatientsFileName() {
  var date = DateTime.now();
  var values = [
    date.year,
    date.month,
    date.day,
    date.hour,
    date.minute,
    date.second,
  ].map((x) => x.toString().padLeft(2, '0')).join();
  var filename = 'Export de pacientes [$values].json';
  return filename;
}
