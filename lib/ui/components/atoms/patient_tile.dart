import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:badges/badges.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_front/models/patient.dart';
import 'package:mala_front/repositories/patient_api.dart';
import 'package:mala_front/ui/components/atoms/mala_profile_picker.dart';
import 'package:mala_front/ui/components/molecules/simple_future_builder.dart';
import 'package:mala_front/usecase/index.dart';
import 'package:vit/extensions/iterable.dart';
import 'package:vit/vit.dart';

class PatientTile extends StatefulWidget {
  const PatientTile({
    super.key,
    required this.patient,
    this.onPressed,
  });

  final Patient patient;
  final void Function()? onPressed;

  @override
  State<PatientTile> createState() => _PatientTileState();
}

class _PatientTileState extends State<PatientTile> {
  Future<Uint8List?> pictureData = Future.value(null);

  @override
  void initState() {
    super.initState();
    _loadPicture();
  }

  Future<void> _loadPicture() async {
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
    var apiData = await rep.getPicture(remoteId);

    // No data found after all.
    if (apiData == null) {
      logWarn('Updating local patient $remoteId to flag no picture');
      patient.hasPicture = false;
      await upsertPatient(
        patient,
        ignorePicture: true,
        syncWithServer: false,
      );
      return;
    }

    setState(() {
      pictureData = Future.value(apiData);
    });
    await saveOrRemoveProfilePicture(
      patientId: patient.id,
      data: apiData,
    );
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
                saveOrRemoveProfilePicture(
                    patientId: widget.patient.id, data: null);
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
