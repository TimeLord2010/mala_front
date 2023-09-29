import 'dart:io';

import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_front/ui/components/atoms/load_progress_indicator.dart';
import 'package:mala_front/ui/components/molecules/mala_info.dart';
import 'package:mala_front/ui/components/organisms/import_patients.dart';
import 'package:mala_front/usecase/error/get_error_message.dart';
import 'package:mala_front/usecase/patient/api/background/send_failed_background_operations.dart';
import 'package:mala_front/usecase/patient/api/send_local_patients_to_server.dart';
import 'package:mala_front/usecase/patient/api/update_patients_from_server.dart';
import 'package:mala_front/usecase/user/refresh_jwt.dart';
import 'package:mala_front/usecase/user/sign_out.dart';
import 'package:vit/vit.dart';

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

  String? _loadingDescription = 'Atualizando token de autenticação';
  String? get loadingDescription => _loadingDescription;
  set loadingDescription(String? value) {
    setState(() {
      _loadingDescription = value;
    });
  }

  void Function()? patientUpdater;

  DateTime? lastAuthCheck;

  void _refreshAuthentication(BuildContext context) {
    if (lastAuthCheck != null) {
      var now = DateTime.now();
      var diff = now.difference(lastAuthCheck!);
      if (diff.inDays < 5) return;
    }
    lastAuthCheck = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      try {
        await refreshJwt();
        loadingDescription = 'Atualizando pacientes a partir do servidor';
        logInfo('Refreshed JWT');
        await updatePatientsFromServer(
          updater: patientUpdater,
        );
        logInfo('Updated patients from server');
        loadingDescription = 'Enviando mudanças pendentes para o servidor';
        await sendFailedBackgroundOperations();
        logInfo('Sent failed background operations');
        loadingDescription = 'Enviando pacientes criados enquanto offline';
        await sendLocalPatientsToServer();
        logInfo('Sent local patients to server');
        patientUpdater?.call();
        loadingDescription = null;
      } catch (e) {
        if (e is DioException) {
          var innerError = e.error;
          if (innerError is SocketException) {
            // NO INTERNET CONNECTION
            return;
          }
        }
        logError('Failed to refresh jwt: ${getErrorMessage(e)}');
        context.navigator.pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    logInfo('Refreshed main page');
    _refreshAuthentication(context);
    var explorer = PatientExplorer(
      updateExposer: (updater) {
        patientUpdater = updater;
      },
    );
    return MalaApp(
      child: LayoutBuilder(
        builder: (context, constraints) {
          var width = constraints.maxWidth;
          return _content(
            context,
            isHorizontal: width > 600,
            explorer: explorer,
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
                  Text(loadingDescription!),
                  const SizedBox(width: 10),
                  const LoadProgressIndicator(),
                  const SizedBox(width: 5),
                ],
              )
            : null,
      ),
      pane: NavigationPane(
        displayMode: isHorizontal ? PaneDisplayMode.open : PaneDisplayMode.compact,
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
            body: explorer,
          ),
          PaneItem(
            icon: const Icon(FluentIcons.download),
            title: const Text('Importar pacientes'),
            body: const ImportPatients(),
          ),
        ],
        footerItems: [
          PaneItemAction(
            icon: const Icon(FluentIcons.sign_out),
            title: const Text('Sair'),
            onTap: () async {
              await showDialog<String>(
                context: context,
                builder: (con) {
                  return ContentDialog(
                    title: const Text('Sair?'),
                    actions: [
                      Button(
                        child: const Text('Cancelar'),
                        onPressed: () {
                          Navigator.pop(con, 'User canceled dialog');
                        },
                      ),
                      FilledButton(
                        child: const Text('Sair'),
                        onPressed: () async {
                          Navigator.pop(con, 'User deleted file');
                          await signout();
                          context.navigator.pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          PaneItem(
            icon: const Icon(FluentIcons.info),
            title: const Text('Info'),
            body: const MalaInfo(),
          ),
        ],
      ),
    );
  }
}
