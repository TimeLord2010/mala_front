import 'dart:async';

import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_front/factories/logger.dart';
import 'package:mala_front/ui/components/atoms/load_progress_indicator.dart';
import 'package:mala_front/ui/components/molecules/mala_info.dart';
import 'package:mala_front/ui/components/organisms/import_patients.dart';
import 'package:mala_front/ui/pages/login_page.dart';
import 'package:mala_front/usecase/error/get_error_message.dart';
import 'package:mala_front/usecase/error/is_no_internet_error.dart';
import 'package:mala_front/usecase/logs/insert_remote_log.dart';
import 'package:mala_front/usecase/patient/api/background/send_failed_background_operations.dart';
import 'package:mala_front/usecase/patient/api/send_local_patients_to_server.dart';
import 'package:mala_front/usecase/patient/api/update_patients_from_server.dart';
import 'package:mala_front/usecase/patient/count_all_patients.dart';
import 'package:mala_front/usecase/user/refresh_jwt.dart';
import 'package:mala_front/usecase/user/sign_out.dart';

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
  bool didLogOut = false;
  DateTime? lastAuthCheck;

  void _refreshAuthentication(BuildContext context) {
    if (lastAuthCheck != null) {
      var now = DateTime.now();
      var diff = now.difference(lastAuthCheck!);
      if (diff.inDays < 5) return;
    }
    lastAuthCheck = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      bool canProceed() {
        if (didLogOut) {
          logger.warn('LOGED OUT, CANNOT PROCEED');
          return false;
        }
        if (!mounted) {
          logger.warn('NOT MOUNTED, CANNOT PROCEED');
          return false;
        }
        logger.info('CAN PROCEED');
        return true;
      }

      Future<void> syncronize() async {
        try {
          var allCount = await countAllPatients();
          logger.info('All patients count: $allCount');
          await refreshJwt();
          loadingDescription = 'Atualizando pacientes a partir do servidor';
          logger.info('Refreshed JWT');
          await updatePatientsFromServer(
            updater: (dt) {
              loadingDescription = 'Atualizando pacientes: $dt';
              patientUpdater?.call();
            },
            didCancel: () => !canProceed(),
          );
          if (!canProceed()) return;
          logger.info('Updated patients from server');
          loadingDescription = 'Enviando mudanças pendentes para o servidor';
          await sendFailedBackgroundOperations();
          logger.info('Sent failed background operations');
          loadingDescription = 'Enviando pacientes criados enquanto offline';
          await sendLocalPatientsToServer(
            context: context,
          );
          logger.info('Sent local patients to server');
          patientUpdater?.call();
        } catch (e, stack) {
          var msg = getErrorMessage(e);
          logger.error('Failed to sync data: $msg');
          if (isNoInternetError(e)) {
            logger.warn('No internet detected! Ended error handling');
            return;
          }
          var dialogMsg = msg ?? 'Erro desconhecido';
          var dialogFullMessage = '$dialogMsg\n${stack.toString()}';
          unawaited(insertRemoteLog(
            context: 'Syncronizing data',
            message: dialogMsg,
            stack: stack.toString(),
            level: 'error',
          ));
          if (!canProceed()) {
            return;
          }
          await showDialog<String>(
            context: context,
            builder: (context) {
              return ContentDialog(
                title: const Text('Erro na sincronização de registros'),
                content: Text(dialogFullMessage),
                actions: [
                  Button(
                    child: const Text('Ok'),
                    onPressed: () {
                      Navigator.pop(context, 'Ok');
                    },
                  ),
                ],
              );
            },
          );
        } finally {
          if (canProceed()) {
            loadingDescription = null;
          }
        }
      }

      await syncronize();
    });
  }

  @override
  Widget build(BuildContext context) {
    logger.info('Refreshed main page');
    _refreshAuthentication(context);
    var explorer = PatientExplorer(
      modalContext: context,
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
                          didLogOut = true;
                          context.navigator.pop();
                          if (!context.navigator.canPop()) {
                            await context.navigator.pushMaterial(const LoginPage());
                          }
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
            body: MalaInfo(),
          ),
        ],
      ),
    );
  }
}
