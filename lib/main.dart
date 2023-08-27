import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';

import 'ui/pages/patient_explorer.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      home: NavigationView(
        appBar: NavigationAppBar(
          title: const Text('Mala'),
          leading: Transform.rotate(
            angle: pi * 1.75,
            child: const Center(
              child: Text('Logo'),
            ),
          ),
        ),
        pane: NavigationPane(
          displayMode: PaneDisplayMode.open,
          size: const NavigationPaneSize(
            openMaxWidth: 200,
          ),
          selected: 0,
          items: [
            PaneItem(
              icon: const Icon(FluentIcons.user_window),
              title: const Text('Pacientes'),
              body: const PatientExplorer(),
            ),
          ],
        ),
      ),
    );
  }
}
