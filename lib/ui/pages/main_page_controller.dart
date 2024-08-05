import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_front/data/factories/create_patient_repository.dart';
import 'package:mala_front/data/factories/logger.dart';
import 'package:mala_front/repositories/patient_repository/hybrid_patient_repository.dart';
import 'package:mala_front/usecase/error/get_error_message.dart';
import 'package:mala_front/usecase/error/is_no_internet_error.dart';
import 'package:mala_front/usecase/logs/insert_remote_log.dart';
import 'package:mala_front/usecase/patient/api/background/send_failed_background_operations.dart';
import 'package:mala_front/usecase/patient/count_all_patients.dart';
import 'package:mala_front/usecase/user/refresh_jwt.dart';

class MainPageController extends ChangeNotifier {
  final BuildContext context;
  MainPageController(this.context) {
    _refreshAuthentication(context);
  }

  String? _loadingDescription = 'Atualizando token de autenticação';
  String? get loadingDescription => _loadingDescription;
  set loadingDescription(String? value) {
    _loadingDescription = value;
    notifyListeners();
  }

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;
  set selectedIndex(int value) {
    _selectedIndex = value;
    notifyListeners();
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
        // if (!mounted) {
        //   logger.warn('NOT MOUNTED, CANNOT PROCEED');
        //   return false;
        // }
        logger.info('CAN PROCEED');
        return true;
      }

      try {
        var allCount = await countAllPatients();
        logger.info('All patients count: $allCount');
        await refreshJwt();
        loadingDescription = 'Atualizando pacientes a partir do servidor';
        logger.info('Refreshed JWT');
        var rep = await createPatientRepository();
        if (rep is HybridPatientRepository) {
          await rep.updatePatientsFromServer(
            updater: (dt) {
              loadingDescription = 'Atualizando pacientes: $dt';
              patientUpdater?.call();
            },
            didCancel: () => !canProceed(),
          );
        }
        if (!canProceed()) return;
        logger.info('Updated patients from server');
        loadingDescription = 'Enviando mudanças pendentes para o servidor';
        await sendFailedBackgroundOperations();
        logger.info('Sent failed background operations');
        loadingDescription = 'Enviando pacientes criados enquanto offline';
        if (rep is HybridPatientRepository) {
          await rep.sendAllToApi();
        }
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
    });
  }
}
