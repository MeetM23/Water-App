import '../../../../domain/models/product.dart';

/// Persistent sequential label tracker for a product.
///
/// Ensures deterministic, non-repeating sequence generation independent of
/// stock decrement or scanning events.
class ProductLabelTracker {
  const ProductLabelTracker({
    required this.productId,
    required this.prefix,
    this.startNumber = 1,
    this.padLength = 3,
    this.lastSequence = 0,
    this.totalCapacity = 0,
    this.totalGenerated = 0,
  });

  /// The product ID this tracker belongs to.
  final String productId;

  /// Series prefix, e.g. "MWS-DOM-" or "MWS-COM-".
  final String prefix;

  /// Starting sequence number (default: 1).
  final int startNumber;

  /// Padding width for digits (default: 3 -> 001).
  final int padLength;

  /// Number of sequence increments allocated so far (e.g. 5 means 001..005 allocated).
  final int lastSequence;

  /// Cumulative stock capacity added to this product over time.
  final int totalCapacity;

  /// Total count of labels generated/printed throughout lifecycle.
  final int totalGenerated;

  /// The count of already allocated/existing labels.
  int get existingLabelsCount => lastSequence;

  /// The next sequence number that will be assigned on next new allocation.
  int get nextSequenceNumber => startNumber + lastSequence;

  /// Number of new labels available to allocate based on stock capacity.
  int get newLabelsAvailable => (totalCapacity - lastSequence).clamp(0, totalCapacity);

  /// Formats a single sequential number with prefix and zero-padding.
  String formatLabel(int number) {
    final numStr = number.toString().padLeft(padLength, '0');
    return '$prefix$numStr';
  }

  /// Adds stock capacity (e.g. when Admin adds stock) without immediately advancing sequence numbers.
  ProductLabelTracker addStockCapacity(int addedStock) {
    if (addedStock <= 0) return this;
    final updatedCapacity = (totalCapacity < lastSequence ? lastSequence : totalCapacity) + addedStock;
    return copyWith(totalCapacity: updatedCapacity);
  }

  /// Allocates [quantity] new sequential label numbers from the available capacity.
  ///
  /// Advances [lastSequence] by [quantity] (clamped to [newLabelsAvailable]).
  ({ProductLabelTracker tracker, List<String> newLabels}) allocateLabels(int quantity) {
    final available = newLabelsAvailable;
    final toAllocate = quantity.clamp(0, available > 0 ? available : quantity);
    if (toAllocate <= 0) {
      return (tracker: this, newLabels: <String>[]);
    }

    final newLabels = <String>[];
    for (var i = 0; i < toAllocate; i++) {
      final seqNum = startNumber + lastSequence + i;
      newLabels.add(formatLabel(seqNum));
    }

    final newLastSequence = lastSequence + toAllocate;
    final newCapacity = totalCapacity < newLastSequence ? newLastSequence : totalCapacity;

    final updated = copyWith(
      lastSequence: newLastSequence,
      totalCapacity: newCapacity,
      totalGenerated: totalGenerated + toAllocate,
    );

    return (tracker: updated, newLabels: newLabels);
  }

  /// Returns preview of the next [quantity] new labels that would be allocated.
  List<String> previewNewLabels(int quantity) {
    final count = quantity.clamp(0, newLabelsAvailable);
    if (count <= 0) return <String>[];
    final labels = <String>[];
    for (var i = 0; i < count; i++) {
      final seqNum = startNumber + lastSequence + i;
      labels.add(formatLabel(seqNum));
    }
    return labels;
  }

  /// Returns the complete existing label series for this product (e.g. 001 -> 010).
  ///
  /// This intentionally does NOT generate new sequence numbers.
  List<String> getAllLabels() {
    if (lastSequence <= 0) {
      return <String>[formatLabel(startNumber)];
    }
    final labels = <String>[];
    for (var i = 0; i < lastSequence; i++) {
      final seqNum = startNumber + i;
      labels.add(formatLabel(seqNum));
    }
    return labels;
  }

  /// Returns a custom count of labels from the sequence without altering state.
  List<String> getCustomLabels(int count) {
    if (count <= 0) return <String>[];
    final labels = <String>[];
    for (var i = 0; i < count; i++) {
      final seqNum = startNumber + i;
      labels.add(formatLabel(seqNum));
    }
    return labels;
  }

  /// Serializes to JSON map for database persistence in `specifications['_label_tracker']`.
  Map<String, dynamic> toJson() => <String, dynamic>{
    'prefix': prefix,
    'start_number': startNumber,
    'pad_length': padLength,
    'last_sequence': lastSequence,
    'total_capacity': totalCapacity,
    'total_generated': totalGenerated,
  };

  /// Deserializes from JSON map.
  factory ProductLabelTracker.fromJson(
    Map<String, dynamic> json, {
    required String productId,
    required String productCode,
  }) {
    final parsed = _parseCode(productCode);
    final prefix = json['prefix'] as String? ?? parsed.prefix;
    final startNumber = (json['start_number'] as num?)?.toInt() ?? parsed.startNumber;
    final padLength = (json['pad_length'] as num?)?.toInt() ?? parsed.padLength;
    final lastSequence = (json['last_sequence'] as num?)?.toInt() ?? 0;
    final totalCapacity = (json['total_capacity'] as num?)?.toInt() ??
        (json['unprinted_count'] != null
            ? lastSequence + (json['unprinted_count'] as num).toInt()
            : lastSequence);
    final totalGenerated = (json['total_generated'] as num?)?.toInt() ?? lastSequence;

    return ProductLabelTracker(
      productId: productId,
      prefix: prefix,
      startNumber: startNumber,
      padLength: padLength,
      lastSequence: lastSequence,
      totalCapacity: totalCapacity,
      totalGenerated: totalGenerated,
    );
  }

  /// Creates a tracker from a [Product] entity.
  factory ProductLabelTracker.fromProduct(Product product) {
    final raw = product.specifications['_label_tracker'];
    if (raw is Map) {
      return ProductLabelTracker.fromJson(
        Map<String, dynamic>.from(raw),
        productId: product.id,
        productCode: product.productCode,
      );
    }

    final parsed = _parseCode(product.productCode);
    final stock = product.stockQuantity ?? (product.inStock ? 1 : 0);

    return ProductLabelTracker(
      productId: product.id,
      prefix: parsed.prefix,
      startNumber: parsed.startNumber,
      padLength: parsed.padLength,
      lastSequence: stock,
      totalCapacity: stock,
      totalGenerated: stock,
    );
  }

  /// Creates a tracker for a new product being created.
  factory ProductLabelTracker.forNewProduct({
    required String productId,
    required String productCode,
    required int initialStock,
    String? customPrefix,
    int? customStartNumber,
  }) {
    final parsed = _parseCode(productCode);
    final prefix = customPrefix?.trim().isNotEmpty == true ? customPrefix!.trim() : parsed.prefix;
    final startNum = customStartNumber ?? parsed.startNumber;
    final padLen = parsed.padLength;
    final initialQty = initialStock > 0 ? initialStock : 1;

    return ProductLabelTracker(
      productId: productId,
      prefix: prefix,
      startNumber: startNum,
      padLength: padLen,
      lastSequence: 0,
      totalCapacity: initialQty,
      totalGenerated: 0,
    );
  }

  /// Helper to extract prefix, startNumber, and padLength from a productCode string.
  static ({String prefix, int startNumber, int padLength}) _parseCode(String code) {
    final trimmed = code.trim();
    if (trimmed.isEmpty) {
      return (prefix: 'PROD-', startNumber: 1, padLength: 3);
    }

    final formattedPrefix = trimmed.endsWith('-') ? trimmed : '$trimmed-';
    return (prefix: formattedPrefix, startNumber: 1, padLength: 3);
  }

  ProductLabelTracker copyWith({
    String? productId,
    String? prefix,
    int? startNumber,
    int? padLength,
    int? lastSequence,
    int? totalCapacity,
    int? totalGenerated,
  }) {
    return ProductLabelTracker(
      productId: productId ?? this.productId,
      prefix: prefix ?? this.prefix,
      startNumber: startNumber ?? this.startNumber,
      padLength: padLength ?? this.padLength,
      lastSequence: lastSequence ?? this.lastSequence,
      totalCapacity: totalCapacity ?? this.totalCapacity,
      totalGenerated: totalGenerated ?? this.totalGenerated,
    );
  }
}
