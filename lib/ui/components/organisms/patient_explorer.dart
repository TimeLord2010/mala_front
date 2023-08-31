import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_front/models/activities.dart';
import 'package:mala_front/models/patient_query.dart';
import 'package:mala_front/ui/components/atoms/mala_check_box.dart';
import 'package:mala_front/ui/components/molecules/activities_selector.dart';
import 'package:mala_front/ui/components/molecules/labeled_text_box.dart';
import 'package:mala_front/ui/components/molecules/page_selector.dart';
import 'package:mala_front/ui/components/molecules/patient_list.dart';
import 'package:mala_front/ui/components/molecules/simple_future_builder.dart';
import 'package:mala_front/ui/pages/patient_registration.dart';
import 'package:mala_front/usecase/patient/count_patients.dart';
import 'package:mala_front/usecase/patient/list_patients.dart';

import '../../../models/patient.dart';

class PatientExplorer extends StatefulWidget {
  PatientExplorer({super.key});

  final nameController = TextEditingController();
  final districtController = TextEditingController();
  final streetController = TextEditingController();

  @override
  State<PatientExplorer> createState() => _PatientExplorerState();
}

class _PatientExplorerState extends State<PatientExplorer> {
  Future<List<Patient>> _patientsFuture = Future.value([]);
  Future<List<Patient>> get patientsFuture => _patientsFuture;
  set patientsFuture(Future<List<Patient>> value) {
    setState(() {
      _patientsFuture = value;
    });
  }

  int? _minAge;
  int? get minAge => _minAge;
  set minAge(int? value) {
    setState(() {
      _minAge = value;
    });
  }

  int? _maxAge;
  int? get maxAge => _maxAge;
  set maxAge(int? value) {
    setState(() {
      _maxAge = value;
    });
  }

  bool _monthBirthDay = false;
  bool get monthBirthDay => _monthBirthDay;
  set monthBirthDay(bool value) {
    setState(() {
      _monthBirthDay = value;
    });
  }

  int _currentPage = 0;
  int get currentPage => _currentPage;
  set currentPage(int value) {
    setState(() {
      _currentPage = value;
    });
  }

  Set<Activities> activities = {};

  int pages = 1;
  int pageSize = 60;

  @override
  void initState() {
    super.initState();
    _search(currentPage, true);
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
                  _search(currentPage, true);
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
                      controller: widget.nameController,
                    ),
                    LabeledTextBox(
                      label: 'Endereço',
                      controller: widget.streetController,
                    ),
                    LabeledTextBox(
                      label: 'Bairro',
                      controller: widget.districtController,
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
                      onPressed: () {
                        _clearSearch();
                      },
                    ),
                    FilledButton(
                      child: const Text('Pesquisar'),
                      onPressed: () {
                        _search(0, true);
                      },
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
              return Column(
                children: [
                  Expanded(
                    child: PatientList(
                      patients: patients ?? [],
                      onEdit: (patient) {
                        _search(currentPage, true);
                      },
                    ),
                  ),
                  PageSelector(
                    index: currentPage,
                    pages: pages,
                    onSelected: (index) {
                      _search(index, false);
                    },
                  ),
                ],
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
        ActivitiesSelector(
          selected: activities,
        ),
      ],
    );
  }

  Row _dateFilter() {
    return Row(
      children: [
        Expanded(
          child: InfoLabel(
            label: 'Idade',
            child: Row(
              children: [
                NumberBox(
                  onChanged: (value) {
                    minAge = value;
                  },
                  value: minAge,
                  min: 0,
                  mode: SpinButtonPlacementMode.none,
                ),
                NumberBox(
                  onChanged: (value) {
                    maxAge = value;
                  },
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
              checked: monthBirthDay,
              onCheck: (checked) {
                monthBirthDay = checked;
              },
            ),
          ),
        ),
      ].separatedBy(const SizedBox(width: 10)),
    );
  }

  void _search(int page, bool shouldCount) async {
    currentPage = page;
    var patientQuery = PatientQuery(
      name: widget.nameController.text,
      district: widget.districtController.text,
      street: widget.streetController.text,
      minAge: minAge,
      maxAge: maxAge,
      monthBirthday: monthBirthDay,
      activies: activities,
    );
    if (shouldCount) {
      var count = await countPatients(patientQuery);
      pages = count ~/ pageSize;
    }
    patientsFuture = listPatients(
      patientQuery: patientQuery,
      skip: currentPage * pageSize,
      limit: pageSize,
    );
  }

  void _clearSearch() {
    widget.nameController.clear();
    widget.districtController.clear();
    widget.streetController.clear();
    _minAge = null;
    _maxAge = null;
    _monthBirthDay = false;
    activities.clear();
    _search(0, false);
  }
}
