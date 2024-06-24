import 'dart:async';
import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:badges/badges.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_front/factories/logger.dart';
import 'package:mala_front/factories/patients_semaphore.dart';
import 'package:mala_front/models/patient.dart';
import 'package:mala_front/repositories/patient_api.dart';
import 'package:mala_front/repositories/patients_semaphore.dart';
import 'package:mala_front/ui/components/atoms/mala_profile_picker.dart';
import 'package:mala_front/ui/components/molecules/simple_future_builder.dart';
import 'package:mala_front/usecase/error/get_error_message.dart';
import 'package:mala_front/usecase/index.dart';
import 'package:mala_front/usecase/logs/insert_remote_log.dart';
import 'package:vit_dart_extensions/vit_dart_extensions.dart';

class PatientTile extends StatefulWidget {
  const PatientTile({
    super.key,
    required this.patient,
    this.onPressed,
    required this.modalContext,
  });

  final Patient patient;
  final BuildContext modalContext;
  final void Function()? onPressed;

  @override
  State<PatientTile> createState() => _PatientTileState();
}

class _PatientTileState extends State<PatientTile> {
  Future<Uint8List?> pictureData = Future.value(null);

  @override
  void initState() {
    super.initState();
    int patientId = widget.patient.id;
    unawaited(patientsSemaphore
        .lockWhile(
      patientId: patientId,
      task: PatientTask.pictureLoad,
      func: _loadPicture,
    )
        .then((ranTask) {
      if (!ranTask) {
        logger.warn('Picture load and save aborted for $patientId');
      }
    }));
  }

  Future<void> _loadPicture() async {
    try {
      var data = loadProfilePicture(widget.patient.id);
      setState(() {
        pictureData = data;
      });

      // Ensuring there is not picture.

      var resolvedData = await data;

      // If local data is found, then check is aborted.
      if (resolvedData != null) {
        return;
      }

      var patient = widget.patient;
      var mayHavePicture = patient.hasPicture != false;

      // If the record signals there is not picture, then we trust it.
      if (!mayHavePicture) {
        return;
      }

      debugPrint('Loading picture from api. Has picture: ${patient.hasPicture}');

      var rep = PatientApiRepository();
      var remoteId = patient.remoteId;

      // When can only talk to the backend if we have the remoteId.
      if (remoteId == null) {
        return;
      }

      // Loading picture from server
      var apiData = await rep.getPicture(remoteId);

      if (apiData == null) {
        // No data found after all.
        logger.warn('Updating local patient $remoteId to flag no picture');
        patient.hasPicture = false;

        // Fixing the server to flag patient has no picture.
        await upsertPatient(
          patient,
          ignorePicture: true,
          syncWithServer: false,
          context: widget.modalContext,
        );
        return;
      }

      if (mounted) {
        setState(() {
          pictureData = Future.value(apiData);
        });
      }
      await saveOrRemoveProfilePicture(
        patientId: patient.id,
        data: apiData,
      );
    } catch (e, stack) {
      unawaited(insertRemoteLog(
        context: 'Carregando imagem de paciente',
        message: getErrorMessage(e) ?? 'Falha ao carregar imagem de paciente',
        stack: stack.toString(),
        extras: {
          'id': widget.patient.remoteId,
        },
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    var name = widget.patient.name ?? '';
    var phones = widget.patient.phones ?? [];
    int? years = widget.patient.years;
    return ListTile(
      title: Tooltip(
        message: name,
        child: AutoSizeText(
          name,
          maxLines: 1,
          minFontSize: 12,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      leading: Builder(builder: (context) {
        var simpleFutureBuilder = SimpleFutureBuilder(
          future: pictureData,
          builder: (value) {
            return MalaProfilePicker(
              bytes: value,
              onRenderError: () {
                unawaited(saveOrRemoveProfilePicture(
                  patientId: widget.patient.id,
                  data: null,
                ));
              },
            );
          },
          contextMessage: 'Imagem de perfil',
        );
        if (widget.patient.remoteId == null) {
          return Badge(
            badgeContent: const Icon(
              FluentIcons.refresh,
              color: Colors.white,
              size: 10,
            ),
            child: simpleFutureBuilder,
          );
        }
        return simpleFutureBuilder;
      }),
      onPressed: widget.onPressed,
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: (phones.take(2).map((x) {
              return Text(x);
            }).toList())
                .separatedBy(const Text(' | ')),
          ),
          if (years != null)
            Row(
              children: [
                Text('$years anos'),
                const SizedBox(width: 5),
                if (widget.patient.hasBirthDayThisMonth) const Text('🎂'),
                const SizedBox(width: 5),
                if (widget.patient.isBirthdayToday) const Text('🎁'),
              ],
            ),
        ],
      ),
    );
  }
}
