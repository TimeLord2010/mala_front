import 'dart:async';

import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_api/mala_api.dart';
import 'package:mala_front/ui/components/molecules/login_fields.dart';
import 'package:mala_front/ui/pages/main_page.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

import '../components/atoms/mala_app.dart';

const _backgroundColor = Color.fromARGB(255, 253, 253, 253);

const _colors = [
  Color.fromARGB(255, 222, 248, 255),
  Color.fromARGB(255, 148, 176, 185),
  Color.fromARGB(255, 123, 166, 197),
];

var _durations = [
  25,
  20,
  15,
].map((x) => x * 1000).toList();

const _heightPercentages = [
  0.15,
  0.45,
  0.75,
];

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool hasCheckedLogin = false;

  void _checkAuthentication(BuildContext context) {
    if (hasCheckedLogin) return;
    hasCheckedLogin = true;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var authed = isAuthenticated();
      if (authed) {
        unawaited(context.navigator.pushMaterial(MainPage.create()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var height = mediaQuery.size.height;
    var bottomPadding = mediaQuery.viewInsets.bottom;
    return MalaApp(
      child: NavigationView(
        content: Builder(
          builder: (context) {
            _checkAuthentication(context);
            return Stack(
              children: [
                _background(),
                Positioned.fill(
                  child: SingleChildScrollView(
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: height,
                      ),
                      padding: EdgeInsets.only(bottom: bottomPadding),
                      child: LoginFields(
                        onLogin: (email, password) async {
                          logger.info('Login');
                          await loginUser(email, password);
                          await context.navigator
                              .pushMaterial(MainPage.create());
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Positioned _background() {
    return Positioned.fill(
      child: WaveWidget(
        config: CustomConfig(
          colors: _colors,
          durations: _durations,
          heightPercentages: _heightPercentages,
          blur: const MaskFilter.blur(BlurStyle.normal, 10),
        ),
        backgroundColor: _backgroundColor,
        size: const Size(double.infinity, double.infinity),
        waveAmplitude: 50,
      ),
    );
  }
}
