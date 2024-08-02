import 'package:flutter/foundation.dart';
import 'package:mala_front/data/entities/address.dart';
import 'package:mala_front/data/factories/logger.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/dimensions/get_tag_height.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/dimensions/get_tag_width.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/margins/bottom/get_tag_bottom_margin.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/margins/left/get_tag_left_margin.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/margins/right/get_tag_right_margin.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/margins/top/get_tag_top_margin.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/spacings/get_tag_horizontal_spacing.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/spacings/get_tag_vertical_spacing.dart';
import 'package:mala_front/usecase/number/rount_to_threshold.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:vit_dart_extensions/vit_dart_extensions.dart';

import '../../../../data/entities/patient_tag.dart';

const double _cm = PdfPageFormat.cm;

const double _totalWidth = 21.0 * _cm;
double _totalHeight = roundToThreshold(29.7 * _cm);

// const double _horizontalMargin = 0.47 * _cm;
// double _verticalMargin = roundToThreshold(0.5 * _cm); // Original was 0.88

//const double _contentWidth = _totalWidth - (2 * _horizontalMargin);
// Fixing rounding point precision error that interferes with the tags
// per column calculation
//double _contentHeight = roundToThreshold(_totalHeight - (2 * _verticalMargin));

// const double _tagHorizontalSpacing = 0.25 * _cm;
// const double _tagVerticalSpacing = 0 * _cm;

// const double _tagWidth = (_contentWidth - _tagHorizontalSpacing) / 2;
// double _tagHeight = (_contentHeight - (_tagVerticalSpacing * 10)) / 11;

class _Configuration {
  double width;
  double height;

  double horizontalSpacing;
  double verticalSpacing;

  EdgeInsets margin;

  _Configuration({
    required this.height,
    required this.width,
    required this.horizontalSpacing,
    required this.verticalSpacing,
    required this.margin,
  }) {
    logger.info('Horizontal margin: ${margin.toString()}');
    logger.info('Tag width: $width');
    logger.info('Tag height: $height');
    logger.info('Tag horizontal spacing: $horizontalSpacing');
    logger.info('Tag vertical spacing: $verticalSpacing');
  }

  double get horizontalMargin => margin.left + margin.right;

  double get verticalMargin => margin.top + margin.bottom;

  double get contentWidth => _totalWidth - horizontalMargin;

  double get contentHeight {
    return roundToThreshold(_totalHeight - verticalMargin);
  }
}

Future<Uint8List> createTagsPdf({
  required Iterable<PatientTag> tags,
}) async {
  var configuration = _Configuration(
    height: getTagHeight(),
    width: getTagWidth(),
    horizontalSpacing: getTagHorizontalSpacing(),
    verticalSpacing: getTagVerticalSpacing(),
    margin: EdgeInsets.only(
      left: getTagLeftMargin(),
      bottom: getTagBottomMargin(),
      right: getTagRightMargin(),
      top: getTagTopMargin(),
    ),
  );

  var tagsPerLine = _getTagsPerLine(configuration);
  if (tagsPerLine != 2) {
    logger.warn('Tags per line: $tagsPerLine');
  } else {
    logger.info('Tags per line: $tagsPerLine');
  }
  var tagsPerColumn = _getTagsPerColumn(configuration);
  if (tagsPerColumn != 11) {
    logger.warn('Tags per column: $tagsPerColumn');
  } else {
    logger.info('Tags per column: $tagsPerColumn');
  }

  var tagsPerPage = tagsPerColumn * tagsPerLine;
  logger.info('Tags per page: $tagsPerPage');

  var doc = Document();
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
      marginTop: config.margin.top,
      marginBottom: config.margin.bottom,
      marginLeft: config.margin.left,
      marginRight: config.margin.right,
    ),
    build: (context) {
      var rows = <Row>[];
      for (var rowIndex = 0; rowIndex < tagsPerColumn; rowIndex++) {
        if (tags.isEmpty) break;

        // Popping required row tags
        var tagsInRow = tags.take(tagsPerLine);
        tags = tags.skip(tagsPerLine);

        var isLastRow = rowIndex == tagsPerColumn - 1;

        rows.add(Row(
          children: tagsInRow.map((x) {
            return _createTag(x, config, isLastRow);
          }).toList(),
        ));
      }
      return Column(
        children: rows,
      );
    },
  );
  return page;
}

Container _createTag(PatientTag tag, _Configuration config, bool isLastRow) {
  var address = tag.address ?? Address();
  return Container(
    width: config.width,
    height: config.height,
    // color: PdfColor.fromHex('#FFAAAA'),
    padding: const EdgeInsets.only(
      left: 0.6 * _cm,
      top: 0.4 * _cm,
    ),
    margin: EdgeInsets.only(
      right: config.horizontalSpacing,
      bottom: isLastRow ? 0 : config.verticalSpacing,
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

int _getTagsPerLine(_Configuration config, [double? availableWidth]) {
  var tagWidth = config.width;
  availableWidth ??= config.contentWidth;
  if (availableWidth < tagWidth) return 0;
  var takenWidth = tagWidth + config.horizontalSpacing;
  return 1 + _getTagsPerLine(config, availableWidth - takenWidth);
}

int _getTagsPerColumn(_Configuration config, [double? availableHeight]) {
  var tagHeight = config.height;
  availableHeight ??= config.contentHeight;
  debugPrint('AvailableHeight: $availableHeight');
  if (availableHeight < tagHeight) return 0;
  var takenHeight = tagHeight + config.verticalSpacing;
  return 1 + _getTagsPerColumn(config, availableHeight - takenHeight);
}
