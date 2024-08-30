import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_api/mala_api.dart';
import 'package:mala_front/protocols/sign_out.dart';
import 'package:mala_front/ui/components/atoms/load_progress_indicator.dart';
import 'package:mala_front/ui/components/molecules/mala_info.dart';
import 'package:mala_front/ui/components/organisms/import_patients.dart';
import 'package:mala_front/ui/components/organisms/settings_pane.dart';
import 'package:mala_front/ui/pages/main_page_controller.dart';
import 'package:provider/provider.dart';

import '../components/atoms/mala_app.dart';
import '../components/organisms/patient_explorer.dart';

class MainPage extends StatelessWidget {
  const MainPage._();

  static Widget create() {
    return ChangeNotifierProvider(
      create: (context) => MainPageController(context),
      child: const MainPage._(),
    );
  }

  @override
  Widget build(BuildContext context) {
    logger.info('Refreshed main page');
    return MalaApp(
      child: LayoutBuilder(
        builder: (context, constraints) {
          var width = constraints.maxWidth;
          return _content(
            context,
            isHorizontal: width > 600,
            explorer: PatientExplorer(
              modalContext: context,
              updateExposer: (updater) {
                var provider = context.read<MainPageController>();
                provider.patientUpdater = updater;
              },
            ),
          );
        },
      ),
    );
  }

  NavigationView _content(
    BuildContext context, {
    required bool isHorizontal,
    required PatientExplorer explorer,
  }) {
    var provider = context.watch<MainPageController>();
    var loadingDescription = provider.loadingDescription;
    var selectedIndex = provider.selectedIndex;
    return NavigationView(
      appBar: NavigationAppBar(
        title: loadingDescription == null ? const Text('Mala') : null,
        leading: Padding(
          padding: const EdgeInsets.all(4),
          child: Center(
            child: Image.asset('assets/logo-icon.png'),
          ),
        ),
        actions: loadingDescription != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(loadingDescription),
                  const SizedBox(width: 10),
                  const LoadProgressIndicator(),
                  const SizedBox(width: 5),
                ],
              )
            : null,
      ),
      pane: NavigationPane(
        displayMode:
            isHorizontal ? PaneDisplayMode.open : PaneDisplayMode.compact,
        size: const NavigationPaneSize(
          openMaxWidth: 200,
        ),
        selected: selectedIndex,
        onChanged: (index) {
          var provider = context.read<MainPageController>();
          provider.selectedIndex = index;
        },
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.user_window),
            title: const Text('Lista de pacientes'),
            body: explorer,
          ),
          PaneItem(
            icon: const Icon(FluentIcons.download),
            title: const Text('Importar pacientes'),
            body: const ImportPatients(),
          ),
        ],
        footerItems: [
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            title: const Text('Configurações'),
            body: const SettingsPane(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.info),
            title: const Text('Info'),
            body: MalaInfo(),
          ),
          PaneItemAction(
            icon: const Icon(FluentIcons.sign_out),
            title: const Text('Sair'),
            onTap: () async {
              await askSignOut(
                context,
                onSignOut: () {
                  var provider = context.read<MainPageController>();
                  provider.didLogOut = true;
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
