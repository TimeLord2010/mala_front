import 'package:mala_front/models/patient.dart';

class PatientRepository {
  Future<List<Patient>> list() async {
    return [
      Patient(
        name: 'Vinícius Gabriel dos Santos Velloso Amazonas Cotta',
        cpf: '03338095210',
        motherName: 'Edilene',
        phones: [
          '85 997-007-440',
          '85 9 9771-9871',
        ],
      ),
      Patient(
        name: 'João Victor de Sousa Silva',
        cpf: '07209680381',
        motherName: 'Maria',
        phones: [
          '85 9 9663-9598',
        ],
      ),
    ];
  }
}
