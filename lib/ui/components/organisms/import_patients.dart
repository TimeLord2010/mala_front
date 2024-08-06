import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_front/data/factories/create_patient_repository.dart';
import 'package:mala_front/repositories/patient_repository/hybrid_patient_repository.dart';
import 'package:mala_front/repositories/patient_repository/local_patient_repository.dart';
import 'package:mala_front/ui/components/atoms/file_system_picker.dart';
import 'package:mala_front/ui/components/molecules/patient_list.dart';

import '../../../data/entities/patient.dart';

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

  List<Patient> addedPatients = [];

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
              Text('${addedPatients.length} Registros adicionados'),
              const Spacer(),
              FilledButton(
                onPressed: path == null ? null : _loadPatients,
                child: const Text('Importar'),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Divider(),
          ),
          Expanded(
            child: PatientList(
              modalContext: context,
              patients: addedPatients,
              onEdit: null,
            ),
          ),
        ],
      ),
    );
  }

  void _loadPatients() async {
    addedPatients.clear();
    var rep = await createPatientRepository();
    var localRep = switch (rep) {
      LocalPatientRepository l => l,
      HybridPatientRepository h => h.localRepository,
      _ => null,
    };
    if (localRep == null) {
      return;
    }
    var added = await localRep.importPatients(
      zipFileName: path!,
    );
    setState(() {
      addedPatients = added;
    });
  }
}
