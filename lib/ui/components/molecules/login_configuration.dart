import 'package:fluent_ui/fluent_ui.dart';
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
    serverController.text = _serverProvider.ip;
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: LabeledTextBox(
                label: 'Endereço do servidor',
                controller: serverController,
                useMaterial: true,
              ),
            ),
            const SizedBox(width: 5),
            FilledButton(
              child: const Text('Atualizar'),
              onPressed: () {
                var address = serverController.text;
                _serverProvider.updateServer(address);
              },
            ),
          ],
        ),
      ],
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
