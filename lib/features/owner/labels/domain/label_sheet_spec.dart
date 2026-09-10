/// Physical geometry of a label sheet, in millimetres.
///
/// Every dimension here is real-world stock, not an approximation. A sheet
/// whose pitch is even a millimetre out walks progressively off the die-cuts
/// down the page, so these numbers are the whole feature working or not.
///
/// PDF user space is 1/72 inch ("points"), so millimetres are converted at
/// 72/25.4. Barcodes are drawn as vectors rather than rasterised, which makes
/// them resolution-independent: there is no DPI to set, and the printer renders
/// them at whatever its native resolution is.
class LabelSheetSpec {
  /// Creates a sheet specification.
  const LabelSheetSpec({
    required this.id,
    required this.displayName,
    required this.reference,
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
  });

  /// Stable identifier used in state and preferences.
  final String id;

  /// Name shown in the layout picker.
  final String displayName;

  /// The commercial stock this matches, shown so the client can buy the right
  /// paper.
  final String reference;

  /// Page width in millimetres.
  final double pageWidthMm;

  /// Page height in millimetres.
  final double pageHeightMm;

  /// Single label width in millimetres.
  final double labelWidthMm;

  /// Single label height in millimetres.
  final double labelHeightMm;

  /// Labels across the page.
  final int columns;

  /// Labels down the page.
  final int rows;

  /// Distance from the page edge to the first column.
  final double marginLeftMm;

  /// Distance from the page top to the first row.
  final double marginTopMm;

  /// Horizontal gap between columns.
  final double columnGapMm;

  /// Vertical gap between rows.
  final double rowGapMm;

  /// Labels on one sheet.
  int get labelsPerSheet => columns * rows;

  /// Padding the renderer reserves on every side of a label, in millimetres.
  ///
  /// Scales with the die so a 21 mm label is not squeezed by the margin that
  /// suits a 37 mm one. Lives here rather than in the builder because the
  /// scannability check below has to reason about the same number.
  double get contentPaddingMm => (labelHeightMm * 0.06).clamp(0.8, 2.5);

  /// Width left for the barcode once padding is taken off, in millimetres.
  double get barcodeWidthMm => labelWidthMm - 2 * contentPaddingMm;

  /// Width of the narrowest bar for a [characters]-long Code 128 payload.
  ///
  /// Code 128 spends 11 modules on each symbol, plus a start symbol, a
  /// checksum symbol and a 13-module stop pattern: `11 * (n + 2) + 13`. The
  /// encoder may compact a digit run into Code C and do better than this, so
  /// treating every character as Code B is the safe direction to be wrong in.
  double moduleWidthMm(int characters) =>
      barcodeWidthMm / (11 * (characters + 2) + 13);

  /// Whether a [characters]-long code prints wide enough bars to scan.
  bool isScannerSafeFor(int characters) =>
      moduleWidthMm(characters) >= LabelSheets.minimumModuleWidthMm;

  /// Horizontal distance between the left edges of adjacent labels.
  double get columnPitchMm => labelWidthMm + columnGapMm;

  /// Vertical distance between the top edges of adjacent labels.
  double get rowPitchMm => labelHeightMm + rowGapMm;

  /// Left offset of the column at [index], in millimetres.
  double xForColumn(int index) => marginLeftMm + index * columnPitchMm;

  /// Top offset of the row at [index], in millimetres.
  double yForRow(int index) => marginTopMm + index * rowPitchMm;

  /// Whether the declared grid actually fits inside the declared page.
  ///
  /// Asserted in the PDF builder so a bad edit to these constants fails loudly
  /// instead of quietly printing skewed sheets.
  bool get fitsOnPage {
    final usedWidth =
        marginLeftMm + columns * labelWidthMm + (columns - 1) * columnGapMm;
    final usedHeight =
        marginTopMm + rows * labelHeightMm + (rows - 1) * rowGapMm;
    // Half a millimetre of slack absorbs the rounding in published stock specs.
    return usedWidth <= pageWidthMm + 0.5 && usedHeight <= pageHeightMm + 0.5;
  }
}

/// The sheet layouts offered on the label screen.
abstract final class LabelSheets {
  /// Millimetres to PDF points.
  static const double mmToPoints = 72 / 25.4;

  /// Narrowest Code 128 bar a handheld laser scanner reliably resolves.
  ///
  /// 0.19 mm is 7.5 mil, the finest most cheap CCD and laser guns manage.
  /// GS1 asks for 0.25 mm in general distribution; this is the floor below
  /// which a printed label stops being worth the paper, not a target.
  static const double minimumModuleWidthMm = 0.19;

  /// A4, 24 labels of 70 x 37 mm, three across and eight down.
  ///
  /// Avery L7871 / 3474. The grid consumes the full 210 mm width with no side
  /// margin and no gaps; the 1 mm left over vertically is split top and bottom.
  static const LabelSheetSpec a4TwentyFourUp = LabelSheetSpec(
    id: 'a4-24up-70x37',
    displayName: 'A4 sheet, 24 labels (70 x 37 mm)',
    reference: 'Avery L7871 / 3474',
    pageWidthMm: 210,
    pageHeightMm: 297,
    labelWidthMm: 70,
    labelHeightMm: 37,
    columns: 3,
    rows: 8,
    marginLeftMm: 0,
    marginTopMm: 0.5,
    columnGapMm: 0,
    rowGapMm: 0,
  );

  /// A4, 65 labels of 38.1 x 21.2 mm, five across and thirteen down.
  ///
  /// Avery L7651. The true die size is 38.1 x 21.2 mm, not the rounded 38 x 21:
  /// using the rounded figure with no column gap would drift about 10 mm across
  /// the page by the fifth column.
  static const LabelSheetSpec a4SixtyFiveUp = LabelSheetSpec(
    id: 'a4-65up-38x21',
    displayName: 'A4 sheet, 65 labels (38.1 x 21.2 mm)',
    reference: 'Avery L7651',
    pageWidthMm: 210,
    pageHeightMm: 297,
    labelWidthMm: 38.1,
    labelHeightMm: 21.2,
    columns: 5,
    rows: 13,
    marginLeftMm: 4.75,
    marginTopMm: 10.7,
    columnGapMm: 2.5,
    rowGapMm: 0,
  );

  /// Continuous thermal roll, one 50 x 25 mm label per page.
  ///
  /// The page is the label: no margins, no grid.
  static const LabelSheetSpec thermalFiftyByTwentyFive = LabelSheetSpec(
    id: 'thermal-50x25',
    displayName: 'Thermal label, 50 x 25 mm',
    reference: 'Continuous roll, one per page',
    pageWidthMm: 50,
    pageHeightMm: 25,
    labelWidthMm: 50,
    labelHeightMm: 25,
    columns: 1,
    rows: 1,
    marginLeftMm: 0,
    marginTopMm: 0,
    columnGapMm: 0,
    rowGapMm: 0,
  );

  /// What a single freshly created product prints on.
  ///
  /// A4, deliberately. Sending the 50 x 25 mm thermal page to an A4 printer --
  /// or to "Save as PDF", which is A4 -- makes Android scale it up to fill the
  /// sheet, and the label arrives four times its intended size. Anyone with an
  /// actual roll printer picks the thermal spec on the Labels screen.
  static const LabelSheetSpec newProductDefault = a4TwentyFourUp;

  /// Every layout offered, in the order shown to the owner.
  static const List<LabelSheetSpec> all = <LabelSheetSpec>[
    a4TwentyFourUp,
    a4SixtyFiveUp,
    thermalFiftyByTwentyFive,
  ];
}
