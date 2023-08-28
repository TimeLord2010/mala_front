import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_front/models/activities.dart';
import 'package:mala_front/models/patient.dart';
import 'package:mala_front/ui/components/atoms/mala_title.dart';
import 'package:mala_front/ui/components/molecules/activities_selector.dart';
import 'package:mala_front/ui/components/molecules/labeled_text_box.dart';
import 'package:mala_front/usecase/address/search_address.dart';

import '../components/atoms/mala_app.dart';

class PatientRegistration extends StatefulWidget {
  PatientRegistration({
    super.key,
    this.patient,
  }) {
    if (patient == null) {
      return;
    }
    var p = patient!;
    nameController.text = p.name ?? '';
    phonesController.text = p.phones?.join(', ') ?? '';
    motherController.text = p.motherName ?? '';
    cpfController.text = UtilBrasilFields.obterCpf(p.cpf ?? '');
  }

  final Patient? patient;
  final nameController = TextEditingController();
  final phonesController = TextEditingController();
  final motherController = TextEditingController();
  final cpfController = TextEditingController();
  final cityController = TextEditingController(
    text: 'Fortaleza',
  );
  final stateController = TextEditingController(
    text: 'Ceará',
  );
  final zipCodeController = TextEditingController();
  final streetController = TextEditingController();
  final districtController = TextEditingController();

  @override
  State<PatientRegistration> createState() => _PatientRegistrationState();
}

class _PatientRegistrationState extends State<PatientRegistration> {
  DateTime? selectedBirth;
  Set<Activities> selectedActivities = {};

  @override
  void initState() {
    super.initState();
    selectedBirth = widget.patient?.birthDate;
  }

  @override
  Widget build(BuildContext context) {
    return MalaApp(
      child: NavigationView(
        appBar: NavigationAppBar(
          leading: IconButton(
            icon: const Icon(FluentIcons.back),
            onPressed: () {
              context.navigator.pop();
            },
          ),
          actions: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    FluentIcons.delete,
                    size: 20,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(
                    FluentIcons.save,
                    size: 20,
                  ),
                  onPressed: () {},
                ),
                const SizedBox(width: 5),
              ].separatedBy(const SizedBox(width: 10)),
            ),
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
                  controller: widget.nameController,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: LabeledTextBox(
                        label: 'Telefones',
                        placeholder: '85 999-999-999, 85 999-999-999',
                        controller: widget.phonesController,
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      child: LabeledTextBox(
                        label: 'CPF',
                        controller: widget.cpfController,
                      ),
                    ),
                    InfoLabel(
                      label: 'Data de nascimento',
                      child: DatePicker(
                        selected: selectedBirth,
                      ),
                    ),
                  ].separatedBy(const SizedBox(width: 20)),
                ),
                LabeledTextBox(
                  label: 'Nome da mãe',
                  controller: widget.motherController,
                ),
                const Divider(),
                const MalaTitle('Endereço'),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    LabeledTextBox(
                      label: 'CEP',
                      placeholder: '00000-000',
                      controller: widget.zipCodeController,
                    ),
                    const SizedBox(width: 20),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Button(
                        child: const Text('Pesquisar'),
                        onPressed: () {
                          searchByCep();
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LabeledTextBox(
                      label: 'Estado',
                      controller: widget.stateController,
                      placeholder: 'Ceará',
                    ),
                    LabeledTextBox(
                      label: 'Cidade',
                      controller: widget.cityController,
                      placeholder: 'Fortaleza',
                    ),
                    LabeledTextBox(
                      label: 'Bairro',
                      controller: widget.districtController,
                      placeholder: 'Aldeota',
                    ),
                  ].separatedBy(const SizedBox(width: 20)),
                ),
                Row(
                  children: [
                    Expanded(
                      child: LabeledTextBox(
                        label: 'Logradouro',
                        placeholder: 'Av. Dom Luis',
                        controller: widget.streetController,
                      ),
                    ),
                    SizedBox(
                      width: 110,
                      child: LabeledTextBox(
                        label: 'Número',
                        placeholder: '17B',
                      ),
                    ),
                    SizedBox(
                      width: 110,
                      child: LabeledTextBox(
                        label: 'Complemento',
                        placeholder: 'apto 201',
                      ),
                    ),
                  ].separatedBy(const SizedBox(width: 20)),
                ),
                const Divider(),
                const MalaTitle('Atividades'),
                ActivitiesSelector(
                  selected: selectedActivities,
                ),
              ].separatedBy(const SizedBox(height: 20)),
            ),
          ),
        ),
      ),
    );
  }

  void searchByCep() async {
    var found = await searchAddress(widget.zipCodeController.text);
    if (found == null) return;
    widget.stateController.text = found.state ?? '';
    widget.cityController.text = found.city ?? '';
    widget.districtController.text = found.district ?? '';
    widget.streetController.text = found.street ?? '';
  }
}
