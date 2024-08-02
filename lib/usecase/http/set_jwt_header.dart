import 'package:mala_front/data/factories/http_client.dart';
import 'package:mala_front/data/factories/logger.dart';

void setJwtHeader(String? jwt) {
  var headers = dio.options.headers;
  if (jwt == null) {
    logger.debug('Removing jwt from http headers');
    headers.remove('jwt');
  } else {
    headers['jwt'] = jwt;
  }
}
