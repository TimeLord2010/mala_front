import 'package:flutter/foundation.dart';
import 'package:mala_front/factories/logger.dart';
import 'package:mala_front/models/address.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/get_tag_height.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/get_tag_width.dart';
import 'package:mala_front/usecase/number/rount_to_threshold.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:vit_dart_extensions/vit_dart_extensions.dart';

import '../../../../models/patient_tag.dart';

const double _cm = PdfPageFormat.cm;

const double _totalWidth = 21.0 * _cm;
double _totalHeight = roundToThreshold(29.7 * _cm);

const double _horizontalMargin = 0.47 * _cm;
double _verticalMargin = roundToThreshold(0.5 * _cm); // Original was 0.88

const double _contentWidth = _totalWidth - (2 * _horizontalMargin);
// Fixing rounding point precision error that interferes with the tags
// per column calculation
double _contentHeight = roundToThreshold(_totalHeight - (2 * _verticalMargin));

const double _tagHorizontalSpacing = 0.25 * _cm;
const double _tagVerticalSpacing = 0 * _cm;

// const double _tagWidth = (_contentWidth - _tagHorizontalSpacing) / 2;
// double _tagHeight = (_contentHeight - (_tagVerticalSpacing * 10)) / 11;

class _Configuration {
  double tagWidth;
  double tagHeight;

  _Configuration({
    required this.tagHeight,
    required this.tagWidth,
  });
}

Future<Uint8List> createTagsPdf({
  required Iterable<PatientTag> tags,
}) async {
  var configuration = _Configuration(
    tagHeight: getTagHeight(),
    tagWidth: getTagWidth(),
  );
  logger.info('Horinzontal margin: $_horizontalMargin');
  logger.info('Vertical margin: $_verticalMargin');
  logger.info('Tag width: ${configuration.tagWidth}');
  logger.info('Tag height: ${configuration.tagHeight}');
  logger.info('Tag horizontal spacing: $_tagHorizontalSpacing');
  logger.info('Tag vertical spacing: $_tagVerticalSpacing');
  var doc = Document();
  var tagsPerLine = _getTagsPerLine(configuration);
  logger.info('Tags per line: $tagsPerLine');
  var tagsPerColumn = _getTagsPerColumn(configuration);
  logger.info('Tags per column: $tagsPerColumn');
  var tagsPerPage = tagsPerColumn * tagsPerLine;
  logger.info('Tags per page: $tagsPerPage');
  var chuncks = tags.chunck(tagsPerPage);
  for (var chunck in chuncks) {
    var page = _createPage(
      tags: chunck,
      tagsPerColumn: tagsPerColumn,
      tagsPerLine: tagsPerLine,
      config: configuration,
    );
    doc.addPage(page);
  }
  var bytes = await doc.save();
  return bytes;
}

Page _createPage({
  required Iterable<PatientTag> tags,
  required int tagsPerLine,
  required int tagsPerColumn,
  required _Configuration config,
}) {
  var page = Page(
    pageFormat: PdfPageFormat(
      _totalWidth,
      _totalHeight,
      marginBottom: _verticalMargin,
      marginLeft: _horizontalMargin,
      marginRight: _horizontalMargin,
      marginTop: _verticalMargin,
    ),
    // margin: const EdgeInsets.symmetric(
    //   vertical: _verticalMargin,
    //   horizontal: _horizontalMargin,
    // ),
    build: (context) {
      var rows = <Row>[];
      for (var rowIndex = 0; rowIndex < tagsPerColumn; rowIndex++) {
        if (tags.isEmpty) break;
        var tagsInRow = tags.take(tagsPerLine);
        rows.add(Row(
          children: tagsInRow.map((x) => _createTag(x, config)).toList(),
        ));
        tags = tags.skip(tagsPerLine);
      }
      return Column(
        children: rows,
      );
    },
  );
  return page;
}

Container _createTag(PatientTag tag, _Configuration config) {
  var address = tag.address ?? Address();
  return Container(
    width: config.tagWidth,
    height: config.tagHeight,
    // color: PdfColor.fromHex('#FFAAAA'),
    // padding: const EdgeInsets.all(10),
    padding: const EdgeInsets.only(
      left: 0.6 * _cm,
      top: 0.4 * _cm,
      //top: 0.6 * _cm,
    ),
    margin: const EdgeInsets.only(
      right: _tagHorizontalSpacing,
      //bottom: 0.02 * _cm,
      bottom: _tagVerticalSpacing,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        tag.name,
        _street(address),
        _zipCityState(address),
      ].map((x) {
        var text = Text(
          x,
          overflow: TextOverflow.clip,
          maxLines: 1,
          style: const TextStyle(
            fontSize: 9,
          ),
        );
        return FittedBox(
          child: text,
          fit: BoxFit.scaleDown,
        );
      }).toList(),
    ),
  );
}

String _street(Address address) {
  var streetStr = (address.street?.isEmpty ?? true) ? null : address.street;
  var numberStr = (address.number?.isEmpty ?? true) ? null : address.number;
  var districtStr = (address.district?.isEmpty ?? true) ? null : address.district;
  if (streetStr == null && numberStr == null && districtStr == null) {
    return '~';
  }
  var street = streetStr ?? '';
  var number = numberStr ?? '';
  var district = districtStr ?? '';
  return '$street $number - $district';
}

String _zipCityState(Address address) {
  var zipCode = (address.zipCode?.isEmpty ?? true) ? null : address.zipCode;
  var cityStr = (address.city?.isEmpty ?? true) ? null : address.city;
  var stateStr = (address.state?.isEmpty ?? true) ? null : address.state;
  if (zipCode == null && cityStr == null && stateStr == null) {
    return '~';
  }
  var city = cityStr ?? '';
  var state = stateStr ?? '';
  var cityState = '$city-$state'.toUpperCase();
  if (zipCode == null) {
    return cityState;
  }
  String zip = zipCode;
  return "$zip / $cityState";
}

int _getTagsPerLine(
  _Configuration config, [
  double availableWidth = _contentWidth,
]) {
  var tagWidth = config.tagWidth;
  if (availableWidth < tagWidth) return 0;
  var takenWidth = tagWidth + _tagHorizontalSpacing;
  return 1 + _getTagsPerLine(config, availableWidth - takenWidth);
}

int _getTagsPerColumn(
  _Configuration config, [
  double? availableHeight,
]) {
  var tagHeight = config.tagHeight;
  availableHeight ??= _contentHeight;
  debugPrint('AvailableHeight: $availableHeight');
  if (availableHeight < tagHeight) return 0;
  var takenHeight = tagHeight + _tagVerticalSpacing;
  return 1 + _getTagsPerColumn(config, availableHeight - takenHeight);
}
