import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../domain/models/business_settings.dart';
import '../../../../domain/models/product.dart';
import '../domain/label_sheet_spec.dart';

/// One product and its list of unique physical unit serial numbers to print.
class LabelJobItem {
  /// Creates a job line.
  const LabelJobItem({
    required this.product,
    required this.serialNumbers,
  });

  /// The product being labelled.
  final Product product;

  /// The unique physical unit serial numbers generated for this product.
  final List<String> serialNumbers;

  /// How many copies of its label to lay down.
  int get quantity => serialNumbers.length;
}

/// Helper mapping one product model to one unique physical unit serial number.
class UnitLabelEntry {
  /// Creates a unit label entry.
  const UnitLabelEntry({
    required this.product,
    required this.serialNumber,
  });

  /// The product model metadata.
  final Product product;

  /// The unique unit serial number.
  final String serialNumber;
}

/// Pure plain-data DTO passed across isolate boundaries for PDF generation.
class _PlainLabelUnitData {
  const _PlainLabelUnitData({
    required this.productName,
    required this.productCode,
    this.modelNumber,
    required this.serialNumber,
  });

  final String productName;
  final String productCode;
  final String? modelNumber;
  final String serialNumber;
}

class _PlainPdfBuildParams {
  const _PlainPdfBuildParams({
    required this.units,
    required this.pageWidthMm,
    required this.pageHeightMm,
    required this.labelWidthMm,
    required this.labelHeightMm,
    required this.columns,
    required this.rows,
    required this.marginLeftMm,
    required this.marginTopMm,
    required this.columnGapMm,
    required this.rowGapMm,
    required this.businessName,
    this.labelFooter,
    required this.fontRegularBytes,
    required this.fontSemiBoldBytes,
  });

  final List<_PlainLabelUnitData> units;
  final double pageWidthMm;
  final double pageHeightMm;
  final double labelWidthMm;
  final double labelHeightMm;
  final int columns;
  final int rows;
  final double marginLeftMm;
  final double marginTopMm;
  final double columnGapMm;
  final double rowGapMm;
  final String businessName;
  final String? labelFooter;
  final Uint8List fontRegularBytes;
  final Uint8List fontSemiBoldBytes;
}

/// Renders a print-ready label sheet.
abstract final class LabelPdfBuilder {
  /// Builds the PDF bytes for [items] laid out on [spec] in a background isolate.
  static Future<Uint8List> build({
    required List<LabelJobItem> items,
    required LabelSheetSpec spec,
    required BusinessSettings business,
  }) async {
    if (!spec.fitsOnPage) {
      throw ArgumentError.value(
        spec.id,
        'spec',
        'Label grid does not fit inside the declared page size',
      );
    }

    final fontRegularData = await rootBundle.load('assets/fonts/Inter-Regular.ttf');
    final fontSemiBoldData = await rootBundle.load('assets/fonts/Inter-SemiBold.ttf');

    final units = <_PlainLabelUnitData>[
      for (final item in items)
        for (final serial in item.serialNumbers)
          _PlainLabelUnitData(
            productName: item.product.name,
            productCode: item.product.productCode,
            modelNumber: item.product.modelNumber,
            serialNumber: serial,
          ),
    ];

    final params = _PlainPdfBuildParams(
      units: units,
      pageWidthMm: spec.pageWidthMm,
      pageHeightMm: spec.pageHeightMm,
      labelWidthMm: spec.labelWidthMm,
      labelHeightMm: spec.labelHeightMm,
      columns: spec.columns,
      rows: spec.rows,
      marginLeftMm: spec.marginLeftMm,
      marginTopMm: spec.marginTopMm,
      columnGapMm: spec.columnGapMm,
      rowGapMm: spec.rowGapMm,
      businessName: business.businessName,
      labelFooter: business.labelFooter,
      fontRegularBytes: fontRegularData.buffer.asUint8List(
        fontRegularData.offsetInBytes,
        fontRegularData.lengthInBytes,
      ),
      fontSemiBoldBytes: fontSemiBoldData.buffer.asUint8List(
        fontSemiBoldData.offsetInBytes,
        fontSemiBoldData.lengthInBytes,
      ),
    );

    return Isolate.run(() async => await _generatePdfDocumentSync(params));
  }

  static Future<Uint8List> _generatePdfDocumentSync(_PlainPdfBuildParams params) async {
    final regular = pw.Font.ttf(
      ByteData.sublistView(params.fontRegularBytes),
    );
    final semiBold = pw.Font.ttf(
      ByteData.sublistView(params.fontSemiBoldBytes),
    );

    final document = pw.Document(
      theme: pw.ThemeData.withFont(base: regular, bold: semiBold),
    );

    if (params.units.isEmpty) {
      return await document.save();
    }

    final pageFormat = PdfPageFormat(
      params.pageWidthMm * PdfPageFormat.mm,
      params.pageHeightMm * PdfPageFormat.mm,
      marginAll: 0,
    );

    final labelsPerSheet = params.columns * params.rows;

    for (var start = 0; start < params.units.length; start += labelsPerSheet) {
      final sheet = params.units.skip(start).take(labelsPerSheet).toList();

      document.addPage(
        pw.Page(
          pageFormat: pageFormat,
          margin: pw.EdgeInsets.zero,
          build: (pw.Context context) => pw.Stack(
            children: <pw.Widget>[
              for (var index = 0; index < sheet.length; index++)
                pw.Positioned(
                  left: _xForColumn(params, index % params.columns) * PdfPageFormat.mm,
                  top: _yForRow(params, index ~/ params.columns) * PdfPageFormat.mm,
                  child: pw.SizedBox(
                    width: params.labelWidthMm * PdfPageFormat.mm,
                    height: params.labelHeightMm * PdfPageFormat.mm,
                    child: _renderSingleLabel(sheet[index], params),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return await document.save();
  }

  static double _xForColumn(_PlainPdfBuildParams params, int colIndex) {
    final columnPitchMm = params.labelWidthMm + params.columnGapMm;
    return params.marginLeftMm + colIndex * columnPitchMm;
  }

  static double _yForRow(_PlainPdfBuildParams params, int rowIndex) {
    final rowPitchMm = params.labelHeightMm + params.rowGapMm;
    return params.marginTopMm + rowIndex * rowPitchMm;
  }

  static pw.Widget _renderSingleLabel(
    _PlainLabelUnitData entry,
    _PlainPdfBuildParams params,
  ) {
    final padding = (params.labelHeightMm * 0.06).clamp(0.8, 2.5);
    final isCompact = params.labelHeightMm < 25;

    final nameSize = isCompact ? 5.5 : 7.5;
    final metaSize = isCompact ? 4.2 : 5.5;
    final codeSize = isCompact ? 5.0 : 6.5;
    final barcodeHeight =
        (params.labelHeightMm * (isCompact ? 0.34 : 0.38)) * PdfPageFormat.mm;

    return pw.Padding(
      padding: pw.EdgeInsets.all(padding * PdfPageFormat.mm),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: <pw.Widget>[
          pw.Text(
            params.businessName.toUpperCase(),
            maxLines: 1,
            overflow: pw.TextOverflow.clip,
            style: pw.TextStyle(
              fontSize: metaSize,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 0.4,
            ),
          ),
          if (!isCompact && params.labelFooter != null)
            pw.Text(
              params.labelFooter!,
              maxLines: 1,
              overflow: pw.TextOverflow.clip,
              style: pw.TextStyle(fontSize: metaSize * 0.85),
            ),
          pw.Text(
            entry.productName,
            maxLines: 1,
            textAlign: pw.TextAlign.center,
            overflow: pw.TextOverflow.clip,
            style: pw.TextStyle(
              fontSize: nameSize,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          if (!isCompact && (entry.modelNumber?.isNotEmpty ?? false))
            pw.Text(
              entry.modelNumber!,
              maxLines: 1,
              overflow: pw.TextOverflow.clip,
              style: pw.TextStyle(fontSize: metaSize),
            ),
          pw.Expanded(
            child: pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                vertical: 0.4 * PdfPageFormat.mm,
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: <pw.Widget>[
                  pw.Expanded(
                    child: pw.BarcodeWidget(
                      barcode: pw.Barcode.code128(escapes: false),
                      data: entry.serialNumber,
                      drawText: false,
                      height: barcodeHeight,
                      width: double.infinity,
                    ),
                  ),
                  if (!isCompact) ...<pw.Widget>[
                    pw.SizedBox(width: 1.5 * PdfPageFormat.mm),
                    pw.SizedBox(
                      width: barcodeHeight,
                      height: barcodeHeight,
                      child: pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: entry.serialNumber,
                        drawText: false,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          pw.Text(
            entry.serialNumber,
            maxLines: 1,
            style: pw.TextStyle(fontSize: codeSize, letterSpacing: 0.6),
          ),
        ],
      ),
    );
  }
}
