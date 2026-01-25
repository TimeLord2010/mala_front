import 'package:fluent_ui/fluent_ui.dart';
import 'package:gap/gap.dart';
import 'package:mala_front/ui/components/atoms/load_progress_indicator.dart';
import 'package:mala_front/ui/components/molecules/labeled_text_box.dart';
import 'package:mala_front/ui/providers/server_provider.dart';

var _serverProvider = ServerProvider();

class LoginConfiguration extends StatefulWidget {
  const LoginConfiguration({super.key});

  @override
  State<LoginConfiguration> createState() => _LoginConfigurationState();
}

class _LoginConfigurationState extends State<LoginConfiguration> {
  final serverController = TextEditingController();

  String? currentAddress;

  bool _deletingCache = false;
  bool get deletingCache => _deletingCache;
  set deletingCache(bool value) {
    setState(() {
      _deletingCache = value;
    });
  }

  @override
  void initState() {
    super.initState();
    currentAddress = _serverProvider.address;
    serverController.text = _serverProvider.address;
  }

  @override
  void dispose() {
    super.dispose();
    serverController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _clearCacheButton(),
        const SizedBox(height: 10),
        LabeledTextBox(
          label: 'Endereço do servidor',
          controller: serverController,
        ),
        const Gap(10),
        Row(
          children: [
            Expanded(
              child: Row(
                spacing: 10,
                children: [
                  FilledButton(
                    onPressed: () {
                      serverController.text = ApiAddreess.dev.address;
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.orange),
                    ),
                    child: const Text('Dev'),
                  ),
                  FilledButton(
                    onPressed: () {
                      serverController.text = ApiAddreess.prod.address;
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.green),
                    ),
                    child: const Text('Prod'),
                  ),
                ],
              ),
            ),
            _updateServerButton(),
          ],
        ),
      ],
    );
  }

  Widget _updateServerButton() {
    return ValueListenableBuilder(
      valueListenable: serverController,
      builder: (context, value, child) {
        return FilledButton(
          onPressed: value.text != currentAddress
              ? () {
                  var address = serverController.text;
                  _serverProvider.updateServer(address);
                  currentAddress = address;
                  setState(() {});
                }
              : null,
          child: const Text('Atualizar'),
        );
      },
    );
  }

  Widget _clearCacheButton() {
    if (deletingCache) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Deletando cache...'),
          SizedBox(width: 10),
          LoadProgressIndicator(),
        ],
      );
    }
    return Button(
      child: const Text('Limpar cache'),
      onPressed: () async {
        if (deletingCache) return;
        deletingCache = true;
        try {
          //await deleteUserFiles();
        } finally {
          deletingCache = false;
        }
      },
    );
  }
}
