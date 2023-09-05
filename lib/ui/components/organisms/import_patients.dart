import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_front/ui/components/atoms/file_system_picker.dart';
import 'package:mala_front/ui/components/molecules/patient_list.dart';
import 'package:mala_front/usecase/patient/import_patients.dart';
import 'package:mala_front/usecase/patient/list_patients_by_creation_dates.dart';
import 'package:vit/vit.dart';

import '../../../models/patient.dart';

class ImportPatients extends StatefulWidget {
  const ImportPatients({super.key});

  @override
  State<ImportPatients> createState() => _ImportPatientsState();
}

class _ImportPatientsState extends State<ImportPatients> {
  String? _path;
  String? get path => _path;
  set path(String? value) {
    setState(() {
      _path = value;
    });
  }

  List<Patient> toAddPatients = [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FileSystemPicker(
            onPick: (picked) {
              path = picked;
            },
            path: path,
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('${toAddPatients.length} Registros'),
              const Spacer(),
              FilledButton(
                onPressed: path == null ? null : _loadPatients,
                child: const Text('Carregar'),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Divider(),
          ),
          Expanded(
            child: PatientList(
              patients: toAddPatients,
              onEdit: null,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              child: const Text('Importar'),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  void _loadPatients() async {
    toAddPatients.clear();
    var patients = await importPatients(
      filename: path!,
    );
    _scanForConflictingPatients(patients);
  }

  void _scanForConflictingPatients(List<Patient> patients) async {
    logInfo('Loaded patients: ${patients.length}');
    var count = 100;
    while (patients.isNotEmpty) {
      var items = patients.take(count).toList();
      patients.removeRange(0, items.length);
      var dates = items.map((x) => x.createdAt).whereType<DateTime>().toList();
      if (dates.isEmpty) continue;
      var foundPatients = await listPatientsByCreation(
        createdAts: dates,
      );
      logInfo('Found patients: ${foundPatients.length}');
      if (foundPatients.isEmpty) continue;
      toAddPatients.addAll(items.where((x) {
        return !foundPatients.any((patient) => patient.createdAt == x.createdAt);
      }));
    }
    logInfo('To add patients ${toAddPatients.length}');
    setState(() {
      toAddPatients = [...toAddPatients];
    });
  }
}
