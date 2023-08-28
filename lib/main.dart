import 'dart:math';
import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'ui/pages/patient_explorer.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      scrollBehavior: const FluentScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown,
        },
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
      ),
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
