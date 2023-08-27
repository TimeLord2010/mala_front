import 'package:mala_front/models/patient.dart';

class PatientRepository {
  Future<List<Patient>> list() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      Patient(
        name: 'Vinícius Gabriel dos Santos Velloso Amazonas Cotta',
        cpf: '03338095210',
        motherName: 'Edilene',
        phones: [
          '85 997-007-440',
          '85 9 9771-9871',
        ],
        birthDate: DateTime(1997, 3, 5),
      ),
      Patient(
        name: 'João Victor de Sousa Silva',
        cpf: '07209680381',
        motherName: 'Maria',
        phones: [
          '85 9 9663-9598',
        ],
        birthDate: DateTime(1997, 8, 2),
      ),
      Patient(
        name: 'Felipe Cerqueira',
        phones: [
          '85 9 9133-7646',
        ],
      ),
      Patient(
        name: 'Stefano Vacis',
        birthDate: DateTime(1980, 8, 27),
      ),
    ];
  }
}
