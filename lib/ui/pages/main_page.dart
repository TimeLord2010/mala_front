import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';

import '../components/atoms/mala_app.dart';
import '../components/organisms/patient_explorer.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MalaApp(
      child: NavigationView(
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
              title: const Text('Lista de pacientes'),
              body: const PatientExplorer(),
            ),
          ],
          footerItems: [
            PaneItem(
              icon: const Icon(FluentIcons.info),
              title: const Text('Info'),
              body: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
