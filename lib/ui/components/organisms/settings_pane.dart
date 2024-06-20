import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:mala_front/ui/components/index.dart';

class SettingsPane extends StatelessWidget {
  SettingsPane({super.key});

  final widthController = TextEditingController();
  final heightController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          SizedBox(
            height: 210,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 157, 157, 157),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    const Text(
                                      'Dimensões',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    LabeledTextBox(
                                      label: 'Largura',
                                      controller: widthController,
                                    ),
                                    const SizedBox(height: 8),
                                    LabeledTextBox(
                                      label: 'Altura',
                                      controller: heightController,
                                    )
                                  ],
                                ),
                              ),
                              const material.VerticalDivider(),
                              Expanded(
                                child: Column(
                                  children: [
                                    const Text(
                                      'Espaçamentos',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    LabeledTextBox(label: 'Horizontal'),
                                    const SizedBox(height: 8),
                                    LabeledTextBox(label: 'Vertical'),
                                  ],
                                ),
                              ),
                              const material.VerticalDivider(),
                              Expanded(
                                child: Column(
                                  children: [
                                    const Text(
                                      'Margens da página',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    LabeledTextBox(label: 'Horizontal'),
                                    const SizedBox(height: 8),
                                    LabeledTextBox(label: 'Vertical'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Spacer(),
                            Button(
                              child: const Text('Restaurar para padrão'),
                              onPressed: () {},
                            ),
                            const SizedBox(width: 10),
                            FilledButton(
                              onPressed: () {},
                              child: const Text('Salvar'),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 245, 245, 245),
                    ),
                    child: const Text('Etiquetas'),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
