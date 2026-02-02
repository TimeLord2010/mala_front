import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_api/mala_api.dart';
import 'package:mala_front/ui/pages/login_page.dart';

Future<void> askSignOut(
  BuildContext context, {
  void Function()? onSignOut,
}) async {
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
              await MalaApi.user.logout();
              if (onSignOut != null) onSignOut();
              await context.navigator.pushReplacement(FluentPageRoute(
                builder: (_) => const LoginPage(),
              ));
            },
          ),
        ],
      );
    },
  );
}
