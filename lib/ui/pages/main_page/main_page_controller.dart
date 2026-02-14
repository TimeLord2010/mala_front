import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_api/mala_api.dart';

class MainPageController extends ChangeNotifier {
  final BuildContext context;
  final _logger = createSdkLogger('MainPageController');
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
          _logger.w('LOGED OUT, CANNOT PROCEED');
          return false;
        }
        _logger.i('CAN PROCEED');
        return true;
      }

      await MalaApi.server.sync(
        uiNotifier: (message) {
          loadingDescription = message;
          patientUpdater?.call();
        },
        shouldAbort: () => !canProceed(),
        errorNotifier: (title, message) async {
          await showDialog<String>(
            context: context,
            builder: (context) {
              const width = 550.0;
              return ContentDialog(
                constraints: const BoxConstraints(
                  minWidth: width,
                  maxWidth: width,
                ),
                title: const Text('Erro na sincronização de registros'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(message),
                  ],
                ),
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
        },
      );

      if (canProceed()) {
        loadingDescription = null;
      }
    });
  }
}
