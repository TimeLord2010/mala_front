import 'package:flutter/foundation.dart';
import 'package:mala_front/models/address.dart';
import 'package:mala_front/usecase/number/rount_to_threshold.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:vit/extensions/iterable.dart';
import 'package:vit/vit.dart';

import '../../../../models/patient_tag.dart';

const double _cm = PdfPageFormat.cm;

const double _totalWidth = 21.0 * _cm;
double _totalHeight = roundToThreshold(29.7 * _cm);

const double _horizontalMargin = 0.47 * _cm;
const double _verticalMargin = 0.88 * _cm;

const double _contentWidth = _totalWidth - (2 * _horizontalMargin);
// Fixing rounding point precision error that interferes with the tags
// per column calculation
double _contentHeight = roundToThreshold(_totalHeight - (2 * _verticalMargin));

const double _tagHorizontalSpacing = 0.25 * _cm;
const double _tagVerticalSpacing = 0 * _cm;

const double _tagWidth = 9.9 * _cm;
const double _tagHeight = 2.535 * _cm;
//const double _tagHeight = 2.54 * _cm;

Future<Uint8List> createTagsPdf({
  required Iterable<PatientTag> tags,
}) async {
  var doc = Document();
  var tagsPerLine = _getTagsPerLine();
  logInfo('Tags per line: $tagsPerLine');
  var tagsPerColumn = _getTagsPerColumn();
  logInfo('Tags per column: $tagsPerColumn');
  var tagsPerPage = tagsPerColumn * tagsPerLine;
  logInfo('Tags per page: $tagsPerPage');
  var chuncks = tags.chunck(tagsPerPage);
  for (var chunck in chuncks) {
    var page = _createPage(
      tags: chunck,
      tagsPerColumn: tagsPerColumn,
      tagsPerLine: tagsPerLine,
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
          children: tagsInRow.map((x) => _createTag(x)).toList(),
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

Container _createTag(PatientTag tag) {
  var address = tag.address ?? Address();
  return Container(
    width: _tagWidth,
    height: _tagHeight,
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
      //bottom: _tagVerticalSpacing,
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

int _getTagsPerLine([double availableWidth = _contentWidth]) {
  if (availableWidth < _tagWidth) return 0;
  var takenWidth = _tagWidth + _tagHorizontalSpacing;
  return 1 + _getTagsPerLine(availableWidth - takenWidth);
}

int _getTagsPerColumn([double? availableHeight]) {
  availableHeight ??= _contentHeight;
  if (availableHeight < _tagHeight) return 0;
  var takenHeight = _tagHeight + _tagVerticalSpacing;
  return 1 + _getTagsPerColumn(availableHeight - takenHeight);
}
