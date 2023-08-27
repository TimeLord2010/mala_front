import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_front/models/activities.dart';
import 'package:mala_front/ui/components/atoms/mala_check_box.dart';
import 'package:mala_front/ui/components/molecules/labeled_text_box.dart';
import 'package:mala_front/ui/components/molecules/simple_future_builder.dart';
import 'package:mala_front/ui/components/organisms/patient_list.dart';
import 'package:mala_front/usecase/patient/list_patients.dart';

class PatientExplorer extends StatelessWidget {
  const PatientExplorer({super.key});

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
                onPressed: () {},
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
              ],
            ),
          ),
        ),
        Expanded(
          child: SimpleFutureBuilder(
            future: listPatients(),
            builder: (patients) {
              return PatientList(
                patients: patients,
              );
            },
            contextMessage: 'Falha na listagem de pacientes',
          ),
        ),
      ],
    );
  }

  Column _activityFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Atividades'),
        Wrap(
          children: Activities.values.map((x) {
            return Padding(
              padding: const EdgeInsets.all(4),
              child: SizedBox(
                width: 135,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: MalaCheckBox(
                    label: x.toString(),
                    checked: false,
                  ),
                ),
              ),
            );
          }).toList(),
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
        const Expanded(
          child: Center(
            child: MalaCheckBox(
              label: 'Aniversariantes do mês',
              checked: false,
            ),
          ),
        ),
      ].separatedBy(const SizedBox(width: 10)),
    );
  }
}
