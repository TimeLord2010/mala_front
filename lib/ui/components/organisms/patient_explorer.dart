import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_front/models/enums/activities.dart';
import 'package:mala_front/models/patient_query.dart';
import 'package:mala_front/models/patient_tag.dart';
import 'package:mala_front/ui/components/molecules/page_selector.dart';
import 'package:mala_front/ui/components/molecules/patient_filter_pane.dart';
import 'package:mala_front/ui/components/molecules/patient_list.dart';
import 'package:mala_front/ui/components/molecules/simple_future_builder.dart';
import 'package:mala_front/ui/pages/patient_registration.dart';
import 'package:mala_front/ui/protocols/modal/export_patients_modal.dart';
import 'package:mala_front/usecase/file/pdf/create_tags_pdf.dart';
import 'package:mala_front/usecase/patient/count_patients.dart';
import 'package:mala_front/usecase/patient/list_patients.dart';
import 'package:vit/vit.dart';

import '../../../models/patient.dart';

class PatientExplorer extends StatefulWidget {
  PatientExplorer({
    super.key,
    required this.updateExposer,
  });

  final nameController = TextEditingController();
  final districtController = TextEditingController();
  final streetController = TextEditingController();

  final void Function(void Function() updater) updateExposer;

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
    setState(() => _minAge = value);
  }

  int? _maxAge;
  int? get maxAge => _maxAge;
  set maxAge(int? value) {
    setState(() => _maxAge = value);
  }

  bool _monthBirthDay = false;
  bool get monthBirthDay => _monthBirthDay;
  set monthBirthDay(bool value) {
    setState(() => _monthBirthDay = value);
  }

  int _currentPage = 0;
  int get currentPage => _currentPage;
  set currentPage(int value) {
    setState(() => _currentPage = value);
  }

  Set<Activities> activities = {};

  int pages = 1;
  int pageSize = 60;

  PatientQuery get query {
    return PatientQuery(
      name: widget.nameController.text,
      district: widget.districtController.text,
      street: widget.streetController.text,
      minAge: minAge,
      maxAge: maxAge,
      monthBirthday: monthBirthDay,
      activies: activities,
    );
  }

  @override
  void initState() {
    super.initState();
    widget.updateExposer(() {
      _search(0, true);
    });
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
              CommandBarButton(
                icon: const Icon(FluentIcons.save),
                label: const Text('Exportar'),
                onPressed: () async {
                  await exportPatientsModal(context, query);
                },
              ),
              CommandBarButton(
                icon: const Icon(FluentIcons.tag),
                label: const Text('Gerar etiquetas'),
                onPressed: () async {
                  var patients = await patientsFuture;
                  logInfo('Found patients: ${patients.length}');
                  var tags = patients.map((x) {
                    return PatientTag(
                      name: x.name ?? '',
                      address: x.address.value,
                    );
                  });
                  createTagsPdf(
                    tags: tags,
                  );
                },
              ),
              const CommandBarButton(
                icon: Icon(FluentIcons.print),
                label: Text('Gerar lista de pacientes'),
                onPressed: null,
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
            content: PatientFilterPane(
              nameController: widget.nameController,
              streetController: widget.streetController,
              districtController: widget.districtController,
              activities: activities,
              minAge: minAge,
              maxAge: maxAge,
              monthBirthDay: monthBirthDay,
              onMinAgeChange: (value) => minAge = value,
              onMaxAgeChange: (value) => maxAge = value,
              onMonthBirthDayChange: (value) => monthBirthDay = value,
              clear: _clearSearch,
              search: () {
                _search(0, true);
              },
            ),
          ),
        ),
        Expanded(
          child: SimpleFutureBuilder(
            future: patientsFuture,
            builder: (patients) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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

  void _search(int page, bool shouldCount) async {
    currentPage = page;
    var patientQuery = query;
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
