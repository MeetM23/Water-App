import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../domain/enums/product_category.dart';
import '../../../../domain/models/business_settings.dart';
import '../../../../domain/models/product.dart';

/// Renders the owner's copy of the catalogue.
///
/// This is the OWNER version and it prints both price columns side by side.
/// It must never be handed to a dealer: a retailer who sees the wholesale
/// column learns exactly what their competitor pays. The dealer-facing export
/// is a separate document in a later phase, resolving one entitled price.
abstract final class CataloguePdfBuilder {
  /// Builds the catalogue PDF for [products].
  static Future<Uint8List> build({
    required List<Product> products,
    required BusinessSettings business,
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

    // Grouped by category because that is how the owner reads a price list and
    // how the products sit on a shelf, not by the insertion order of the table.
    final grouped = <ProductCategory, List<Product>>{};
    for (final product in products) {
      grouped.putIfAbsent(product.category, () => <Product>[]).add(product);
    }

    final stamp = DateFormat('d MMM yyyy, HH:mm', 'en_IN').format(generatedAt);

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(28, 32, 28, 36),
        header: (pw.Context context) =>
            context.pageNumber == 1 ? pw.SizedBox() : _runningHeader(business),
        footer: (pw.Context context) => _footer(context, stamp),
        build: (pw.Context context) => <pw.Widget>[
          _title(business, stamp, products.length),
          pw.SizedBox(height: 18),
          for (final category in ProductCategory.values)
            if (grouped[category]?.isNotEmpty ?? false) ...<pw.Widget>[
              _categoryHeading(category),
              _table(grouped[category]!),
              pw.SizedBox(height: 14),
            ],
          if (products.isEmpty)
            pw.Text(
              'No active products in the catalogue.',
              style: const pw.TextStyle(fontSize: 10),
            ),
        ],
      ),
    );

    return document.save();
  }

  static pw.Widget _title(BusinessSettings business, String stamp, int count) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Text(
          business.businessName,
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 2),
        if (business.labelFooter != null)
          pw.Text(
            business.labelFooter!,
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        pw.SizedBox(height: 10),
        pw.Container(height: 1.4, color: PdfColors.blue800),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: <pw.Widget>[
            pw.Text(
              'Catalogue price list — owner copy',
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              '$count active products · $stamp',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            ),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(5),
          color: PdfColors.amber50,
          child: pw.Text(
            'CONFIDENTIAL — contains wholesale pricing. Do not share with '
            'dealers.',
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.orange900,
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _runningHeader(BusinessSettings business) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 10),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: <pw.Widget>[
        pw.Text(
          business.businessName,
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          'Owner copy — confidential',
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

  static pw.Widget _categoryHeading(ProductCategory category) => pw.Container(
    width: double.infinity,
    margin: const pw.EdgeInsets.only(top: 6, bottom: 4),
    padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3),
    color: PdfColors.blue50,
    child: pw.Text(
      _categoryName(category).toUpperCase(),
      style: pw.TextStyle(
        fontSize: 9,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blue900,
        letterSpacing: 0.6,
      ),
    ),
  );

  static pw.Widget _table(List<Product> products) {
    return pw.TableHelper.fromTextArray(
      cellStyle: const pw.TextStyle(fontSize: 8),
      headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      cellHeight: 16,
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.4),
      columnWidths: <int, pw.TableColumnWidth>{
        0: const pw.FlexColumnWidth(2.4),
        1: const pw.FlexColumnWidth(2.6),
        2: const pw.FlexColumnWidth(1.4),
        3: const pw.FlexColumnWidth(1.2),
        4: const pw.FlexColumnWidth(1.2),
        5: const pw.FlexColumnWidth(1.2),
        6: const pw.FlexColumnWidth(1),
      },
      cellAlignments: <int, pw.Alignment>{
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerRight,
        6: pw.Alignment.center,
      },
      headers: <String>[
        'Code',
        'Product',
        'Model',
        'MRP',
        'Wholesale',
        'Retail',
        'Stock',
      ],
      data: <List<String>>[
        for (final product in products)
          <String>[
            product.productCode,
            product.name,
            product.modelNumber ?? '',
            product.mrp == null ? '' : _money(product.mrp!),
            _money(product.wholesalePrice),
            _money(product.retailPrice),
            product.inStock ? 'Yes' : 'No',
          ],
      ],
    );
  }

  /// Formats an amount with Indian digit grouping.
  ///
  /// The rupee glyph is deliberately absent: the bundled Inter subset has no
  /// U+20B9, and a PDF font that cannot render a character draws nothing at
  /// all, which would silently produce a price list with no prices.
  static String _money(double amount) =>
      NumberFormat.decimalPattern('en_IN').format(amount);

  static String _categoryName(ProductCategory category) => switch (category) {
    ProductCategory.domestic => 'Domestic',
    ProductCategory.commercial => 'Commercial',
    ProductCategory.industrial => 'Industrial',
    ProductCategory.sparePart => 'Spare parts',
    ProductCategory.accessory => 'Accessories',
  };
}
