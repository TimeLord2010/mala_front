import 'dart:typed_data';

import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_front/models/activities.dart';
import 'package:mala_front/models/address.dart';
import 'package:mala_front/models/patient.dart';
import 'package:mala_front/ui/components/atoms/mala_profile_picker.dart';
import 'package:mala_front/ui/components/atoms/mala_title.dart';
import 'package:mala_front/ui/components/molecules/activities_selector.dart';
import 'package:mala_front/ui/components/molecules/labeled_text_box.dart';
import 'package:mala_front/usecase/address/search_address.dart';
import 'package:mala_front/usecase/patient/delete_patient.dart';
import 'package:mala_front/usecase/patient/profile_picture/load_profile_picture.dart';
import 'package:mala_front/usecase/patient/upsert_patient.dart';

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
    observationController.text = p.observation ?? '';
    var cpf = p.cpf ?? '';
    var isValid = UtilBrasilFields.isCPFValido(cpf);
    if (isValid) {
      cpfController.text = UtilBrasilFields.obterCpf(p.cpf ?? '');
    } else {
      cpfController.text = p.cpf ?? '';
    }
    var address = p.address.value;
    if (address == null) {
      debugPrint('Address was null');
      return;
    }
    zipCodeController.text = address.zipCode ?? '';
    stateController.text = address.state ?? '';
    cityController.text = address.city ?? '';
    districtController.text = address.district ?? '';
    streetController.text = address.street ?? '';
    numberController.text = address.number ?? '';
    complementController.text = address.complement ?? '';
  }

  final Patient? patient;
  final nameController = TextEditingController();
  final phonesController = TextEditingController();
  final motherController = TextEditingController();
  final cpfController = TextEditingController();
  final zipCodeController = TextEditingController();
  final stateController = TextEditingController(
    text: 'Ceará',
  );
  final cityController = TextEditingController(
    text: 'Fortaleza',
  );
  final districtController = TextEditingController();
  final streetController = TextEditingController();
  final numberController = TextEditingController();
  final complementController = TextEditingController();
  final observationController = TextEditingController();

  @override
  State<PatientRegistration> createState() => _PatientRegistrationState();
}

class _PatientRegistrationState extends State<PatientRegistration> {
  DateTime? _selectedBirth;
  DateTime? get selectedBirth => _selectedBirth;
  set selectedBirth(DateTime? value) {
    setState(() {
      _selectedBirth = value;
    });
  }

  Set<Activities> selectedActivities = {};

  Uint8List? _pictureData;
  Uint8List? get pictureData => _pictureData;
  set pictureData(Uint8List? value) {
    setState(() {
      _pictureData = value;
    });
  }

  @override
  void initState() {
    super.initState();
    var patient = widget.patient;
    if (patient == null) return;
    selectedBirth = patient.birthDate;
    selectedActivities = patient.activitiesId?.map((x) {
          return Activities.values[x];
        }).toSet() ??
        {};
    _loadPic();
  }

  void _loadPic() async {
    var patient = widget.patient;
    if (patient == null) return;
    pictureData = await loadProfilePicture(patient.id);
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
                if (widget.patient != null)
                  IconButton(
                    icon: const Icon(
                      FluentIcons.delete,
                      size: 20,
                    ),
                    onPressed: () async {
                      await _delete(context);
                    },
                  ),
                IconButton(
                  icon: const Icon(
                    FluentIcons.save,
                    size: 20,
                  ),
                  onPressed: () {
                    save();
                  },
                ),
                const SizedBox(width: 5),
              ].separatedBy(const SizedBox(width: 10)),
            ),
          ),
          title: const Text('Cadastrar novo paciente'),
        ),
        content: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const MalaTitle('Informações pessoais'),
                Row(
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: MalaProfilePicker(
                              bytes: pictureData,
                              onPick: (data) {
                                if (data != null) {
                                  pictureData = data;
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          Button(
                            onPressed: pictureData == null
                                ? null
                                : () {
                                    pictureData = null;
                                  },
                            child: const Text('Remover'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        children: [
                          LabeledTextBox(
                            label: 'Nome',
                            controller: widget.nameController,
                          ),
                          LabeledTextBox(
                            label: 'Nome da mãe',
                            controller: widget.motherController,
                          ),
                        ].separatedBy(const SizedBox(height: 20)),
                      ),
                    ),
                  ],
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
                        placeholder: '999.999.999-99',
                      ),
                    ),
                    InfoLabel(
                      label: 'Data de nascimento',
                      child: DatePicker(
                        selected: selectedBirth,
                        onChanged: (v) {
                          selectedBirth = v;
                        },
                      ),
                    ),
                  ].separatedBy(const SizedBox(width: 20)),
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
                        controller: widget.numberController,
                      ),
                    ),
                    SizedBox(
                      width: 110,
                      child: LabeledTextBox(
                        label: 'Complemento',
                        placeholder: 'apto 201',
                        controller: widget.complementController,
                      ),
                    ),
                  ].separatedBy(const SizedBox(width: 20)),
                ),
                const Divider(),
                const MalaTitle('Atividades'),
                ActivitiesSelector(
                  selected: selectedActivities,
                ),
                const Divider(),
                const MalaTitle('Observações'),
                TextBox(
                  maxLines: 6,
                  placeholder: 'Observações',
                  controller: widget.observationController,
                  placeholderStyle: TextStyle(
                    color: Colors.grey[80],
                  ),
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

  void save() async {
    var phones = widget.phonesController.text.split(',').map((x) => x.trim()).where((x) => x != '');
    var patient = Patient(
      name: widget.nameController.text,
      cpf: widget.cpfController.text,
      motherName: widget.motherController.text,
      yearOfBirth: selectedBirth?.year,
      monthOfBirth: selectedBirth?.month,
      dayOfBirth: selectedBirth?.day,
      phones: phones.toList(),
      observation: widget.observationController.text,
      activitiesId: selectedActivities.map((x) => x.index).toList(),
      createdAt: widget.patient?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
    patient.address.value = Address(
      zipCode: widget.zipCodeController.text,
      state: widget.stateController.text,
      city: widget.cityController.text,
      district: widget.districtController.text,
      street: widget.streetController.text,
      number: widget.numberController.text,
      complement: widget.complementController.text,
    );
    if (widget.patient != null) {
      patient.id = widget.patient!.id;
    }
    await upsertPatient(
      patient,
      pictureData: pictureData,
    );
    context.navigator.pop();
  }

  Future<void> _delete(BuildContext context) async {
    var result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Deletar paciente?'),
        content: const Text(
          'Essa ação não pode ser revertida',
        ),
        actions: [
          Button(
            child: const Text('Deletar'),
            onPressed: () async {
              await deletePatient(widget.patient!.id);
              Navigator.pop(context, "DEL");
            },
          ),
          FilledButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
    if (result == 'DEL') {
      context.navigator.pop();
    }
  }
}
