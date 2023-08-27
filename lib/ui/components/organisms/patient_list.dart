import 'package:flutter/material.dart';
import 'package:mala_front/models/patient.dart';
import 'package:mala_front/ui/components/molecules/patient_tile.dart';

class PatientList extends StatelessWidget {
  const PatientList({
    super.key,
    required this.patients,
  });

  final List<Patient> patients;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: patients.map((x) {
        return SizedBox(
          width: 350,
          child: PatientTile(patient: x),
        );
      }).toList(),
    );
  }
}
