import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:gap/gap.dart';
import 'package:mala_api/mala_api.dart';

import '../atoms/mala_check_box.dart';
import 'activities_selector.dart';
import 'labeled_text_box.dart';

class PatientFilterPane extends StatefulWidget {
  const PatientFilterPane({
    super.key,
    required this.nameController,
    required this.streetController,
    required this.districtController,
    required this.clear,
    required this.search,
    required this.activities,
    required this.minAge,
    required this.maxAge,
    required this.onMinAgeChange,
    required this.onMaxAgeChange,
    required this.monthBirthDay,
    required this.onMonthBirthDayChange,
  });

  final TextEditingController nameController;
  final TextEditingController streetController;
  final TextEditingController districtController;

  final void Function() clear;
  final void Function() search;

  final Set<Activities> activities;

  final int? minAge;
  final int? maxAge;
  final void Function(int? value) onMinAgeChange;
  final void Function(int? value) onMaxAgeChange;

  final bool monthBirthDay;
  final void Function(bool value) onMonthBirthDayChange;

  @override
  State<PatientFilterPane> createState() => _PatientFilterPaneState();
}

class _PatientFilterPaneState extends State<PatientFilterPane> {
  int tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var maxWidth = constraints.maxWidth;
        var bgColor = WidgetStateColor.resolveWith((states) {
          debugPrint('states: $states');
          if (states.isEmpty) return const .fromARGB(255, 235, 235, 235);
          return switch (states.first) {
            .selected => const .fromARGB(255, 169, 205, 255),
            .hovered => const .fromARGB(255, 222, 222, 222),
            _ => Colors.red,
          };
        });
        return Column(
          children: [
            SizedBox(
              height: 210,
              child: TabView(
                currentIndex: tabIndex,
                onChanged: (index) => setState(() => tabIndex = index),

                tabs: [
                  Tab(
                    text: const Text('Pessoal'),
                    icon: const WindowsIcon(FluentIcons.profile_search),
                    backgroundColor: bgColor,
                    body: Column(
                      children: [
                        const Gap(8),
                        _nameFilter(),
                        const Gap(10),
                        _dateFilter(maxWidth),
                      ],
                    ),
                  ),
                  Tab(
                    text: const Text('Local'),
                    icon: const WindowsIcon(FluentIcons.map_pin),
                    backgroundColor: bgColor,
                    body: Column(
                      children: [
                        const Gap(8),
                        _addressFilter(),
                        const Gap(10),
                        _districtFilter(),
                      ],
                    ),
                  ),
                  Tab(
                    text: const Text('Atividades'),
                    icon: const WindowsIcon(FluentIcons.health),
                    backgroundColor: bgColor,
                    body: _activityFilter(),
                  ),
                ],
              ),
            ),
            _buttons(),
          ],
        );
      },
    );
  }

  Row _buttons() {
    return Row(
      children: [
        const Spacer(),
        Button(onPressed: widget.clear, child: const Text('Limpar')),
        FilledButton(onPressed: widget.search, child: const Text('Pesquisar')),
      ].separatedBy(const SizedBox(width: 20)),
    );
  }

  LabeledTextBox _districtFilter() {
    return LabeledTextBox(
      label: 'Bairro',
      controller: widget.districtController,
    );
  }

  LabeledTextBox _addressFilter() {
    return LabeledTextBox(
      label: 'Endereço',
      controller: widget.streetController,
    );
  }

  LabeledTextBox _nameFilter() {
    return LabeledTextBox(label: 'Nome', controller: widget.nameController);
  }

  Widget _activityFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Gap(10),
        ActivitiesSelector(selected: widget.activities),
      ],
    );
  }

  Widget _dateFilter(double width) {
    if (width < 400) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ageFilter(),
          const SizedBox(height: 15),
          _birthDatesFilter(),
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: _ageFilter()),
        Expanded(child: _birthDatesFilter()),
      ].separatedBy(const SizedBox(width: 10)),
    );
  }

  Center _birthDatesFilter() {
    return Center(
      child: MalaCheckBox(
        label: 'Aniversariantes do mês',
        checked: widget.monthBirthDay,
        onCheck: widget.onMonthBirthDayChange,
      ),
    );
  }

  InfoLabel _ageFilter() {
    return InfoLabel(
      label: 'Idade',
      child: Row(
        children:
            [
                  NumberBox(
                    onChanged: widget.onMinAgeChange,
                    value: widget.minAge,
                    min: 0,
                    mode: SpinButtonPlacementMode.none,
                  ),
                  NumberBox(
                    onChanged: widget.onMaxAgeChange,
                    value: widget.maxAge,
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
    );
  }
}
