import 'dart:convert';
import 'dart:typed_data';

import 'package:intl/intl.dart';

import '../../../../domain/models/profile.dart';

/// Renders the dealer list as a CSV the client can open in Excel.
///
/// Written by hand rather than through a package because the whole format is
/// four rules and the escaping is the only part that matters.
abstract final class DealerCsvBuilder {
  /// Columns, in the order the client reads them.
  static const List<String> headers = <String>[
    'Firm name',
    'Contact name',
    'Phone',
    'City',
    'State',
    'GST number',
    'Role',
    'Status',
    'Registered on',
    'Approved on',
  ];

  /// Builds the CSV bytes for [dealers].
  static Uint8List build(List<Profile> dealers) {
    final date = DateFormat('yyyy-MM-dd');

    final rows = <String>[
      _row(headers),
      for (final dealer in dealers)
        _row(<String>[
          dealer.firmName,
          dealer.fullName,
          dealer.phone,
          dealer.city,
          dealer.state,
          dealer.gstNumber ?? '',
          dealer.role.name,
          dealer.status.name,
          date.format(dealer.createdAt),
          dealer.approvedAt == null ? '' : date.format(dealer.approvedAt!),
        ]),
    ];

    // A UTF-8 BOM. Excel on Windows assumes the system codepage without it and
    // renders any Gujarati firm name as mojibake, which is precisely the case
    // this file exists for.
    const bom = <int>[0xEF, 0xBB, 0xBF];

    return Uint8List.fromList(<int>[...bom, ...utf8.encode(rows.join('\r\n'))]);
  }

  static String _row(List<String> values) => values.map(_escape).join(',');

  /// Quotes a field when it contains a comma, a quote or a line break.
  ///
  /// An address is the field that breaks a naive CSV: it routinely contains
  /// both a comma and a newline.
  static String _escape(String value) {
    final needsQuotes =
        value.contains(',') ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r');

    if (!needsQuotes) {
      return value;
    }
    return '"${value.replaceAll('"', '""')}"';
  }
}
