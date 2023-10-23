import 'package:flutter/material.dart';
import 'package:mala_front/ui/components/atoms/mala_logo.dart';
import 'package:mala_front/ui/components/molecules/simple_future_builder.dart';
import 'package:mala_front/usecase/platform/get_app_version.dart';

class MalaInfo extends StatelessWidget {
  MalaInfo({super.key});

  final _version = getAppVersion();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          var height = constraints.maxHeight;
          if (height > 400) {
            return _verticalLayout();
          } else {
            return Row(
              children: [
                const Expanded(
                  child: MalaLogo(),
                ),
                _info(),
              ],
            );
          }
        },
      ),
    );
  }

  Column _verticalLayout() {
    return Column(
      children: [
        const MalaLogo(),
        Expanded(
          child: _info(),
        ),
      ],
    );
  }

  Widget _info() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Mala',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Text('Aplicação de gerência de pacientes.'),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SimpleFutureBuilder(
            future: _version,
            builder: (value) {
              return Text(value);
            },
            contextMessage: 'Versão do applicativo',
          ),
        ),
        const Spacer(),
        const Text('2023'),
        const Text('VIT - Desenvolvimento e Tecnologia'),
        const SelectionArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('vinivelloso1997@gmail.com'),
              Text(' - '),
              Text('(85) 9 9700-7440'),
            ],
          ),
        ),
      ],
    );
  }
}
