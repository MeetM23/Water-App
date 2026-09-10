import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../domain/models/business_settings.dart';
import '../../../../domain/models/catalog_product.dart';
import '../domain/dealer_experience.dart';

/// Renders a dealer's saved products as a quotation sheet.
///
/// The dealer builds this to send on, not to file: they shortlist products
/// while they are with a buyer and forward the sheet from the share sheet
/// seconds later, so it is laid out as a business document rather than as a
/// dump of the saved list.
///
/// One price column, and it is the one price a [CatalogProduct] carries. There
/// is no second figure on the object for this document to pick the wrong one
/// from, which is what makes generating it on the device safe — and it is why
/// the same builder serves both dealer roles rather than one apiece.
///
/// [QuotationStyle] carries the only words that change between them. The
/// document is English regardless of the app language: the bundled Inter subset
/// is the only face embedded here, so a Gujarati sheet would render as empty
/// boxes rather than as text.
abstract final class QuotationPdfBuilder {
  /// Builds the quotation covering [products].
  static Future<Uint8List> build({
    required List<CatalogProduct> products,
    required BusinessSettings business,
    required QuotationStyle style,
    required DateTime generatedAt,
  }) async {
    final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Inter-Regular.ttf'),
    );
    final semiBold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Inter-SemiBold.ttf'),
    );

    final document = pw.Document(
      theme: pw.ThemeData.withFont(base: regular, bold: semiBold),
    );

    final quotedOn = DateFormat('d MMM yyyy', 'en_IN').format(generatedAt);
    final stamp = DateFormat('d MMM yyyy, HH:mm', 'en_IN').format(generatedAt);

    // Every line is one unit, so the total is the plain sum. The saved list
    // holds no quantities, and inventing a default above one would put a
    // figure on the sheet that nobody agreed to.
    final total = products.fold<double>(
      0,
      (double sum, CatalogProduct product) => sum + product.price,
    );

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(28, 32, 28, 36),
        header: (pw.Context context) => context.pageNumber == 1
            ? pw.SizedBox()
            : _runningHeader(business, style),
        footer: (pw.Context context) => _footer(context, stamp),
        build: (pw.Context context) => <pw.Widget>[
          _letterhead(business),
          pw.SizedBox(height: 14),
          _heading(style.documentTitle, quotedOn),
          pw.SizedBox(height: 10),
          _table(products),
          _total(total),
          pw.SizedBox(height: 12),
          _notes(style.notes),
        ],
      ),
    );

    return document.save();
  }

  /// The letterhead.
  ///
  /// Phone and address take a line each rather than the single joined line a
  /// printed label uses: A4 has the room, and a quotation is read as
  /// correspondence, where a run-on contact line looks like a mistake.
  static pw.Widget _letterhead(BusinessSettings business) {
    final phone = business.phone.trim();
    final address = business.address.trim();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Text(
          business.businessName,
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        if (phone.isNotEmpty) ...<pw.Widget>[
          pw.SizedBox(height: 3),
          pw.Text(
            phone,
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ],
        if (address.isNotEmpty) ...<pw.Widget>[
          pw.SizedBox(height: 2),
          pw.Text(
            address,
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ],
        pw.SizedBox(height: 10),
        pw.Container(height: 1.4, color: PdfColors.blue800),
      ],
    );
  }

  static pw.Widget _heading(String title, String quotedOn) => pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    crossAxisAlignment: pw.CrossAxisAlignment.end,
    children: <pw.Widget>[
      pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 13,
          fontWeight: pw.FontWeight.bold,
          letterSpacing: 0.4,
        ),
      ),
      pw.Text(
        'Date: $quotedOn',
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
      ),
    ],
  );

  static pw.Widget _runningHeader(
    BusinessSettings business,
    QuotationStyle style,
  ) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 10),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: <pw.Widget>[
        pw.Text(
          business.businessName,
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          style.documentTitle,
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
        ),
      ],
    ),
  );

  static pw.Widget _footer(pw.Context context, String stamp) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 8),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: <pw.Widget>[
        pw.Text(
          'Generated $stamp',
          style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
        ),
        pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
        ),
      ],
    ),
  );

  static pw.Widget _table(List<CatalogProduct> products) {
    return pw.TableHelper.fromTextArray(
      cellStyle: const pw.TextStyle(fontSize: 8),
      headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      cellHeight: 18,
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.4),
      columnWidths: <int, pw.TableColumnWidth>{
        0: const pw.FlexColumnWidth(2.4),
        1: const pw.FlexColumnWidth(3.2),
        2: const pw.FlexColumnWidth(1.6),
        3: const pw.FlexColumnWidth(0.7),
        4: const pw.FlexColumnWidth(1.5),
      },
      cellAlignments: <int, pw.Alignment>{
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.center,
        4: pw.Alignment.centerRight,
      },
      headers: <String>['Code', 'Product', 'Model', 'Qty', 'Price (INR)'],
      data: <List<String>>[
        for (final product in products)
          <String>[
            product.productCode,
            product.name,
            product.modelNumber ?? '',
            '1',
            _money(product.price),
          ],
      ],
    );
  }

  static pw.Widget _total(double amount) => pw.Container(
    margin: const pw.EdgeInsets.only(top: 8),
    alignment: pw.Alignment.centerRight,
    child: pw.Container(
      width: 200,
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: <pw.Widget>[
          pw.Text(
            'Total (INR)',
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            _money(amount),
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    ),
  );

  /// The block that keeps this sheet a quotation rather than an invoice.
  ///
  /// The saved list carries no quantities, so the table shows one of each. Both
  /// roles say so plainly, or the total reads as a settled figure and the dealer
  /// spends the next call explaining that it is not. What each says after that
  /// is [QuotationStyle.notes], because a trade buyer and a walk-in customer do
  /// not need the same sentence.
  static pw.Widget _notes(List<String> notes) => pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(5),
    color: PdfColors.grey100,
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        for (var index = 0; index < notes.length; index++) ...<pw.Widget>[
          if (index > 0) pw.SizedBox(height: 4),
          pw.Text(
            notes[index],
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800),
          ),
        ],
      ],
    ),
  );

  /// Formats an amount with Indian digit grouping.
  ///
  /// The rupee glyph is deliberately absent: the bundled Inter subset has no
  /// U+20B9, and a PDF font that cannot render a character draws nothing at
  /// all, which would silently produce a quotation with no prices. The column
  /// header names the currency instead.
  static String _money(double amount) =>
      NumberFormat.decimalPattern('en_IN').format(amount);
}
