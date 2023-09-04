import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';

import '../components/atoms/mala_app.dart';
import '../components/organisms/patient_explorer.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;
  set selectedIndex(int value) {
    setState(() {
      _selectedIndex = value;
    });
  }

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
          selected: selectedIndex,
          onChanged: (index) {
            selectedIndex = index;
          },
          items: [
            PaneItem(
              icon: const Icon(FluentIcons.user_window),
              title: const Text('Lista de pacientes'),
              body: PatientExplorer(),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.download),
              title: const Text('Importar pacientes'),
              body: const SizedBox.shrink(),
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
