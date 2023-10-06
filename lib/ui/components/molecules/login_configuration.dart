import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_front/ui/components/atoms/load_progress_indicator.dart';
import 'package:mala_front/usecase/file/delete_user_files.dart';

class LoginConfiguration extends StatefulWidget {
  const LoginConfiguration({super.key});

  @override
  State<LoginConfiguration> createState() => _LoginConfigurationState();
}

class _LoginConfigurationState extends State<LoginConfiguration> {
  bool _deletingCache = false;
  bool get deletingCache => _deletingCache;
  set deletingCache(bool value) {
    setState(() {
      _deletingCache = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _clearCacheButton(),
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
          await deleteUserFiles();
        } finally {
          deletingCache = false;
        }
      },
    );
  }
}
