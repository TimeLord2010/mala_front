import 'package:flutter/material.dart';

class MalaInfo extends StatelessWidget {
  const MalaInfo({super.key});

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
                Expanded(
                  child: _logo(),
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
        _logo(),
        Expanded(
          child: _info(),
        ),
      ],
    );
  }

  Column _info() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Mala',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text('Aplicação de gerência de pacientes.'),
        Spacer(),
        Text('2023'),
        Text('VIT - Desenvolvimento e Tecnologia'),
        SelectionArea(
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

  LimitedBox _logo() {
    return LimitedBox(
      maxHeight: 300,
      child: Image.asset('assets/logo.png'),
    );
  }
}
