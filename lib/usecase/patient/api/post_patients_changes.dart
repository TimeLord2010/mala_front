import 'package:flutter/widgets.dart';
import 'package:mala_front/data/factories/create_patient_repository.dart';
import 'package:mala_front/repositories/patient_api.dart';
import 'package:mala_front/repositories/patient_repository/hybrid_patient_repository.dart';
import 'package:mala_front/usecase/patient/api/assign_remote_id_to_patient.dart';
import 'package:mala_front/usecase/patient/api/update_remote_patient_picture.dart';
import 'package:mala_front/usecase/patient/upsert_patient.dart';
import 'package:mala_front/usecase/user/update_last_sync.dart';

import '../../../data/entities/patient.dart';
