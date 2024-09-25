import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_api/mala_api.dart';

import '../atoms/mala_check_box.dart';
import 'activities_selector.dart';
import 'labeled_text_box.dart';

class PatientFilterPane extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var width = constraints.maxWidth;
        return _content(width);
      },
    );
  }

  Column _content(double maxWidth) {
    return Column(
      children: [
        _nameAndAddressFilter(maxWidth),
        const SizedBox(height: 15),
        _dateFilter(maxWidth),
        const SizedBox(height: 15),
        _activityFilter(),
        const SizedBox(height: 10),
        Row(
          children: [
            const Spacer(),
            Button(
              onPressed: clear,
              child: const Text('Limpar'),
            ),
            FilledButton(
              onPressed: search,
              child: const Text('Pesquisar'),
            ),
          ].separatedBy(const SizedBox(width: 20)),
        ),
      ],
    );
  }

  Widget _nameAndAddressFilter(double width) {
    if (width < 400) {
      return Column(
        children: [
          _nameFilter(),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _addressFilter(),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _districtFilter(),
              ),
            ],
          ),
        ],
      );
    }
    return Row(
      children: [
        _nameFilter(),
        _addressFilter(),
        _districtFilter(),
      ]
          .map((x) {
            return Expanded(
              child: x,
            );
          })
          .toList()
          .separatedBy(const SizedBox(width: 5)),
    );
  }

  LabeledTextBox _districtFilter() {
    return LabeledTextBox(
      label: 'Bairro',
      controller: districtController,
    );
  }

  LabeledTextBox _addressFilter() {
    return LabeledTextBox(
      label: 'Endereço',
      controller: streetController,
    );
  }

  LabeledTextBox _nameFilter() {
    return LabeledTextBox(
      label: 'Nome',
      controller: nameController,
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
        Expanded(
          child: _ageFilter(),
        ),
        Expanded(
          child: _birthDatesFilter(),
        ),
      ].separatedBy(const SizedBox(width: 10)),
    );
  }

  Center _birthDatesFilter() {
    return Center(
      child: MalaCheckBox(
        label: 'Aniversariantes do mês',
        checked: monthBirthDay,
        onCheck: onMonthBirthDayChange,
      ),
    );
  }

  InfoLabel _ageFilter() {
    return InfoLabel(
      label: 'Idade',
      child: Row(
        children: [
          NumberBox(
            onChanged: onMinAgeChange,
            value: minAge,
            min: 0,
            mode: SpinButtonPlacementMode.none,
          ),
          NumberBox(
            onChanged: onMaxAgeChange,
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
    );
  }
}
