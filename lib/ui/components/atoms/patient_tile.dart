import 'dart:async';
import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:badges/badges.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_api/mala_api.dart';
import 'package:mala_front/ui/components/atoms/mala_profile_picker.dart';
import 'package:mala_front/ui/components/molecules/simple_future_builder.dart';

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
  StreamSubscription<Patient>? subscription;

  final _logger = createSdkLogger('PatientTile');

  @override
  void initState() {
    super.initState();
    int patientId = widget.patient.id;
    unawaited(MalaApi.patient.semaphore
        .lockWhile(
      patientId: patientId,
      task: PatientTask.pictureLoad,
      func: () async {
        await MalaApi.patient.loadPicture(
          widget.patient,
          onDataLoad: (data) {
            if (!mounted) return;
            setState(() {
              pictureData = data;
            });
          },
        );
      },
    )
        .then((ranTask) {
      if (!ranTask) {
        _logger.w('Picture load and save aborted for $patientId');
      }
    }));

    if (widget.patient.remoteId == null) {
      var stream =
          PatientModule.patientUploadController.stream.asBroadcastStream();
      subscription = stream.listen(null);
      subscription?.onData((uploadedPatient) async {
        var remoteId = uploadedPatient.remoteId;
        if (remoteId == null) {
          return;
        }
        _logger.i('Received uploaded patient notification');
        if (uploadedPatient.id == widget.patient.id) {
          widget.patient.remoteId = remoteId;
          if (mounted) {
            setState(() {});
          }
          await subscription?.cancel();
        }
      });
    }
  }

  @override
  void dispose() {
    unawaited(subscription?.cancel());
    subscription = null;
    super.dispose();
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
                unawaited(MalaApi.patient.savePicture(widget.patient.id, null));
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
