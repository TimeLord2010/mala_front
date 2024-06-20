import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_front/ui/pages/login_page.dart';
import 'package:mala_front/usecase/user/sign_out.dart';

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
              await signout();
              if (onSignOut != null) onSignOut();
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
}
