import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_front/models/patient.dart';
import 'package:mala_front/ui/components/atoms/mala_title.dart';
import 'package:mala_front/ui/components/molecules/labeled_text_box.dart';

class PatientRegistration extends StatelessWidget {
  PatientRegistration({
    super.key,
    this.patient,
  }) {
    if (patient == null) {
      return;
    }
    var p = patient!;
    nameController.text = p.name ?? '';
    motherController.text = p.motherName ?? '';
    cpfController.text = UtilBrasilFields.obterCpf(p.cpf ?? '');
  }

  final Patient? patient;
  final nameController = TextEditingController();
  final motherController = TextEditingController();
  final cpfController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      home: NavigationView(
        appBar: NavigationAppBar(
          leading: IconButton(
            icon: const Icon(FluentIcons.back),
            onPressed: () {
              context.navigator.pop();
            },
          ),
          title: const Text('Cadastrar novo paciente'),
        ),
        content: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const MalaTitle('Informações pessoais'),
                LabeledTextBox(
                  label: 'Nome',
                  controller: nameController,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: LabeledTextBox(
                        label: 'Telefones',
                        placeholder: '85 999-999-999, 85 999-999-999',
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      child: LabeledTextBox(
                        label: 'CPF',
                        controller: cpfController,
                      ),
                    ),
                    _birthFields(),
                  ].separatedBy(const SizedBox(width: 20)),
                ),
                LabeledTextBox(
                  label: 'Nome da mãe',
                  controller: motherController,
                ),
                const Divider(),
                const MalaTitle('Endereço'),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    LabeledTextBox(
                      label: 'CEP',
                    ),
                    const SizedBox(width: 20),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Button(
                        child: const Text('Pesquisar'),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LabeledTextBox(
                      label: 'Estado',
                    ),
                    LabeledTextBox(
                      label: 'Cidade',
                    ),
                  ].separatedBy(const SizedBox(width: 20)),
                ),
                Row(
                  children: [
                    Expanded(
                      child: LabeledTextBox(
                        label: 'Logradouro',
                      ),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(
                      width: 100,
                      child: LabeledTextBox(
                        label: 'Número',
                      ),
                    ),
                  ],
                ),
                const Divider(),
                const MalaTitle('Atividades'),
              ].separatedBy(const SizedBox(height: 20)),
            ),
          ),
        ),
      ),
    );
  }

  InfoLabel _birthFields() {
    int? day, month, year;
    return InfoLabel(
      label: 'Data de nascimento',
      child: Row(
        children: [
          NumberBox(
            value: day,
            onChanged: (int? value) {},
            mode: SpinButtonPlacementMode.none,
            clearButton: false,
            placeholder: '30',
            placeholderStyle: TextStyle(
              color: Colors.grey[80],
            ),
          ),
          NumberBox(
            value: month,
            onChanged: (int? value) {},
            mode: SpinButtonPlacementMode.none,
            clearButton: false,
            placeholder: '06',
            placeholderStyle: TextStyle(
              color: Colors.grey[80],
            ),
          ),
          NumberBox(
            value: year,
            onChanged: (int? value) {},
            mode: SpinButtonPlacementMode.none,
            clearButton: false,
            placeholder: '1992',
            placeholderStyle: TextStyle(
              color: Colors.grey[80],
            ),
          ),
        ]
            .map((x) {
              return SizedBox(
                width: 60,
                child: x,
              );
            })
            .toList()
            .separatedBy(const Padding(
              padding: EdgeInsets.symmetric(horizontal: 3),
              child: Text('/'),
            )),
      ),
    );
  }
}
