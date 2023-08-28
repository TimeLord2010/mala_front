import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_front/ui/components/atoms/mala_check_box.dart';
import 'package:mala_front/ui/components/molecules/activities_selector.dart';
import 'package:mala_front/ui/components/molecules/labeled_text_box.dart';
import 'package:mala_front/ui/components/molecules/patient_list.dart';
import 'package:mala_front/ui/components/molecules/simple_future_builder.dart';
import 'package:mala_front/ui/pages/patient_registration.dart';
import 'package:mala_front/usecase/patient/list_patients.dart';

import '../../../models/patient.dart';

class PatientExplorer extends StatefulWidget {
  const PatientExplorer({super.key});

  @override
  State<PatientExplorer> createState() => _PatientExplorerState();
}

class _PatientExplorerState extends State<PatientExplorer> {
  Future<List<Patient>> _patientsFuture = listPatients();
  Future<List<Patient>> get patientsFuture => _patientsFuture;
  set patientsFuture(Future<List<Patient>> value) {
    setState(() {
      _patientsFuture = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: CommandBar(
            mainAxisAlignment: MainAxisAlignment.end,
            overflowBehavior: CommandBarOverflowBehavior.noWrap,
            primaryItems: [
              CommandBarButton(
                icon: const Icon(FluentIcons.add),
                label: const Text('Cadastrar'),
                onPressed: () async {
                  await context.navigator.pushMaterial(PatientRegistration(
                    patient: null,
                  ));
                  patientsFuture = listPatients();
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Expander(
            header: const Text('Filtros'),
            animationCurve: Curves.easeOut,
            animationDuration: const Duration(milliseconds: 300),
            content: Column(
              children: [
                Row(
                  children: [
                    LabeledTextBox(
                      label: 'Nome',
                    ),
                    LabeledTextBox(
                      label: 'Endereço',
                    ),
                    LabeledTextBox(
                      label: 'Bairro',
                    ),
                  ]
                      .map((x) {
                        return Expanded(
                          child: x,
                        );
                      })
                      .toList()
                      .separatedBy(const SizedBox(width: 5)),
                ),
                const SizedBox(height: 15),
                _dateFilter(),
                const SizedBox(height: 15),
                _activityFilter(),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Spacer(),
                    Button(
                      child: const Text('Limpar'),
                      onPressed: () {},
                    ),
                    FilledButton(
                      child: const Text('Pesquisar'),
                      onPressed: () {},
                    ),
                  ].separatedBy(const SizedBox(width: 20)),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: SimpleFutureBuilder(
            future: patientsFuture,
            builder: (patients) {
              return PatientList(
                patients: patients ?? [],
                onEdit: (patient) {
                  patientsFuture = listPatients();
                },
              );
            },
            contextMessage: 'Falha na listagem de pacientes',
          ),
        ),
      ],
    );
  }

  Column _activityFilter() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Atividades'),
        ActivitiesSelector(
          selected: {},
        ),
      ],
    );
  }

  Row _dateFilter() {
    int? minAge, maxAge;
    return Row(
      children: [
        Expanded(
          child: InfoLabel(
            label: 'Idade',
            child: Row(
              children: [
                NumberBox(
                  onChanged: (value) {},
                  value: minAge,
                  min: 0,
                  mode: SpinButtonPlacementMode.none,
                ),
                NumberBox(
                  onChanged: (value) {},
                  value: maxAge,
                  min: 0,
                  mode: SpinButtonPlacementMode.none,
                ),
              ]
                  .map((x) {
                    return Expanded(child: x);
                  })
                  .toList()
                  .separatedBy(const SizedBox(width: 5)),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: MalaCheckBox(
              label: 'Aniversariantes do mês',
              checked: false,
              onCheck: (checked) {},
            ),
          ),
        ),
      ].separatedBy(const SizedBox(width: 10)),
    );
  }
}
