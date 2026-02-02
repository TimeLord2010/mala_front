import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_api/mala_api.dart';
import 'package:mala_front/ui/components/molecules/patient_filter_pane.dart';
import 'package:mala_front/ui/components/molecules/patient_list.dart';
import 'package:mala_front/ui/pages/patient_registration.dart';
import 'package:mala_front/ui/protocols/modal/export_patients_modal.dart';

class PatientExplorer extends StatefulWidget {
  PatientExplorer({
    super.key,
    required this.updateExposer,
    required this.modalContext,
  });

  final nameController = TextEditingController();
  final districtController = TextEditingController();
  final streetController = TextEditingController();
  final BuildContext modalContext;

  final void Function(void Function() updater) updateExposer;

  @override
  State<PatientExplorer> createState() => _PatientExplorerState();
}

class _PatientExplorerState extends State<PatientExplorer> {
  final _logger = createSdkLogger('PatientExplorer');
  final _scrollController = ScrollController();

  List<Patient> _patients = [];
  bool _isLoading = false;
  bool _hasMore = true;
  bool _hasError = false;
  int _searchGeneration = 0;

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

  Set<Activities> activities = {};

  int count = 0;

  int pageSize = 40;

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
    _scrollController.addListener(_onScroll);
    widget.updateExposer(() {
      _search(reset: true);
    });
    _search(reset: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoading || !_hasMore) return;
    var pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              var width = constraints.maxWidth;
              return _commandBar(context, width < 500);
            },
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
                _search(reset: true);
              },
            ),
          ),
        ),
        Expanded(
          child: _hasError && _patients.isEmpty
              ? const Center(child: Text('Falha na listagem de pacientes'))
              : _patients.isEmpty && _isLoading
              ? const Center(child: ProgressRing())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: PatientList(
                        patients: _patients,
                        modalContext: widget.modalContext,
                        controller: _scrollController,
                        onEdit: (patient) {
                          _search(reset: true);
                        },
                        footer: _isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: ProgressRing()),
                              )
                            : null,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('$count resultados'),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  CommandBar _commandBar(BuildContext context, bool compact) {
    return CommandBar(
      mainAxisAlignment: MainAxisAlignment.end,
      overflowBehavior: CommandBarOverflowBehavior.wrap,
      isCompact: compact,
      primaryItems: [
        CommandBarButton(
          icon: const Icon(FluentIcons.add),
          label: const Text('Cadastrar'),
          onPressed: () async {
            await context.navigator.pushMaterial(
              PatientRegistration(
                patient: null,
                modalContext: widget.modalContext,
              ),
            );
            _search(reset: true);
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
          label: const Text('Etiquetas'),
          onPressed: () async {
            var patients = await MalaApi.patient.list(
              query: query,
              limit: 5000,
            );
            var tags = patients.map(PatientTag.fromPatient);
            await MalaApi.pdf.printTags(tags: tags);
          },
        ),
        CommandBarButton(
          icon: const Icon(FluentIcons.print),
          label: const Text('Lista de pacientes'),
          onPressed: () async {
            var patients = await MalaApi.patient.list(
              query: query,
              limit: 5000,
            );
            await MalaApi.pdf.printInfo(patients: patients);
          },
        ),
      ],
    );
  }

  void _search({required bool reset}) async {
    if (reset) {
      _searchGeneration++;
      _currentPage = 0;
      _patients = [];
      _hasMore = true;
      _hasError = false;
    }

    var generation = _searchGeneration;
    setState(() => _isLoading = true);

    try {
      var patientQuery = query;
      if (reset) {
        var c = await MalaApi.patient.count(patientQuery);
        if (generation != _searchGeneration) return;
        count = c;
        _logger.i('Count: $count');
      }
      var result = await MalaApi.patient.list(
        query: patientQuery,
        skip: _currentPage * pageSize,
        limit: pageSize,
      );
      if (generation != _searchGeneration) return;
      setState(() {
        _patients = [..._patients, ...result];
        _hasMore = result.length >= pageSize;
        _isLoading = false;
      });
      _loadMoreIfNeeded();
    } catch (e) {
      if (generation != _searchGeneration) return;
      _logger.e('Search failed: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _loadMoreIfNeeded() {
    if (_isLoading || !_hasMore) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      var pos = _scrollController.position;
      if (pos.maxScrollExtent <= 0 || pos.pixels >= pos.maxScrollExtent - 200) {
        _currentPage++;
        _search(reset: false);
      }
    });
  }

  void _loadMore() {
    _currentPage++;
    _search(reset: false);
  }

  void _clearSearch() {
    widget.nameController.clear();
    widget.districtController.clear();
    widget.streetController.clear();
    _minAge = null;
    _maxAge = null;
    _monthBirthDay = false;
    activities.clear();
    _search(reset: true);
  }
}
