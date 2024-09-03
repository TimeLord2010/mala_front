import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:mala_api/mala_api.dart';
import 'package:mala_front/ui/components/index.dart';

class PatientRegistration extends StatefulWidget {
  PatientRegistration({
    super.key,
    this.patient,
    required this.modalContext,
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

  /// The context of the calling route.
  ///
  /// This is used to create a modal message if the save or delete operation
  /// fails.
  final BuildContext modalContext;

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
    await MalaApi.patient.loadPicture(
      patient,
      onDataLoad: (data) async {
        pictureData = await data;
      },
    );
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
          title: Text(widget.patient == null
              ? 'Cadastrar novo paciente'
              : 'Editar cadastro'),
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
                _info(),
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
                _addressGroups(),
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
                Align(
                  alignment: Alignment.centerRight,
                  child: _patientIds(),
                ),
              ].separatedBy(const SizedBox(height: 20)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _addressGroups() {
    Widget horizontal() {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _state(),
          _city(),
          _district(),
        ].separatedBy(const SizedBox(width: 20)),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        var width = constraints.maxWidth;
        if (width > 650) {
          return horizontal();
        }
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: _state()),
                const SizedBox(width: 20),
                Expanded(child: _city()),
              ],
            ),
            const SizedBox(height: 10),
            _district(),
          ],
        );
      },
    );
  }

  LabeledTextBox _district() {
    return LabeledTextBox(
      label: 'Bairro',
      controller: widget.districtController,
      placeholder: 'Aldeota',
    );
  }

  LabeledTextBox _city() {
    return LabeledTextBox(
      label: 'Cidade',
      controller: widget.cityController,
      placeholder: 'Fortaleza',
    );
  }

  LabeledTextBox _state() {
    return LabeledTextBox(
      label: 'Estado',
      controller: widget.stateController,
      placeholder: 'Ceará',
    );
  }

  Widget _info() {
    Widget horizontal() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: _phones(),
          ),
          _cpf(),
          _birth(),
          // InfoLabel(
          //   label: 'Data de nascimento',
          //   child: DatePicker(
          //     selected: selectedBirth,
          //     onChanged: (v) {
          //       selectedBirth = v;
          //     },
          //   ),
          // ),
        ].separatedBy(const SizedBox(width: 20)),
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      var width = constraints.maxWidth;
      if (width > 600) {
        return horizontal();
      }
      return Column(
        children: [
          _phones(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _cpf(),
              _birth(),
            ],
          ),
        ],
      );
    });
  }

  Widget _cpf() {
    return SizedBox(
      width: 160,
      child: LabeledTextBox(
        label: 'CPF',
        controller: widget.cpfController,
        placeholder: '999.999.999-99',
      ),
    );
  }

  LabeledTextBox _phones() {
    return LabeledTextBox(
      label: 'Telefones',
      placeholder: '85 999-999-999, 85 999-999-999',
      controller: widget.phonesController,
    );
  }

  MalaDatePicker _birth() {
    return MalaDatePicker(
      label: 'Data de nascimento',
      value: selectedBirth,
      onChanged: (v) {
        selectedBirth = v;
      },
    );
  }

  SelectionArea _patientIds() {
    var style = const TextStyle(
      fontSize: 12,
      color: Color.fromARGB(255, 144, 144, 144),
    );
    return SelectionArea(
      child: Text(
        widget.patient?.remoteId ?? '',
        style: style,
      ),
    );
  }

  void searchByCep() async {
    var cep = widget.zipCodeController.text;
    var found = await MalaApi.patient.searchCep(cep);
    if (found == null) return;
    widget.stateController.text = found.state ?? '';
    widget.cityController.text = found.city ?? '';
    widget.districtController.text = found.district ?? '';
    widget.streetController.text = found.street ?? '';
  }

  void save() async {
    var phonesStr = widget.phonesController.text;
    var phones =
        phonesStr.split(',').map((x) => x.trim()).where((x) => x != '');
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
      remoteId: widget.patient?.remoteId,
      uploadedAt: widget.patient?.uploadedAt,
    );
    if (widget.patient == null && pictureData == null) {
      patient.hasPicture = false;
    }
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
    await MalaApi.patient.upsert(patient, pictureData);
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
              await MalaApi.patient.delete(widget.patient!);
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
