import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_failure.dart';
import '../../core/errors/result.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/enums/product_category.dart';
import '../../domain/enums/product_sort.dart';
import '../../domain/enums/product_status_filter.dart';
import '../../domain/models/dealer_activity.dart';
import '../../domain/models/paged_result.dart';
import '../../domain/models/product.dart';
import '../../domain/models/product_draft.dart';
import '../../domain/models/product_query.dart';
import '../../domain/repositories/product_repository.dart';
import '../supabase/supabase_providers.dart';

part 'supabase_product_repository.g.dart';

/// Supabase-backed catalogue access.
///
/// Reads hit the `products` table directly, which row level security exposes
/// to the owner alone. Nothing here filters a price: dealers never reach this
/// class, they read `catalog_view`.
class SupabaseProductRepository implements ProductRepository {
  /// Creates a repository over an initialised client.
  SupabaseProductRepository(this._client);

  final SupabaseClient _client;

  static const String _table = 'products';

  @override
  Future<Result<PagedResult<Product>>> fetchPage(ProductQuery query) async {
    try {
      var filter = _client.from(_table).select();

      final term = _escapeForOrFilter(query.searchTerm.trim());
      if (term.isNotEmpty) {
        filter = filter.or(
          'name.ilike.%$term%,'
          'model_number.ilike.%$term%,'
          'product_code.ilike.%$term%',
        );
      }

      if (query.category != null) {
        filter = filter.eq('category', query.category!.wireValue);
      }

      filter = switch (query.status) {
        ProductStatusFilter.all => filter,
        ProductStatusFilter.active => filter.eq('is_active', true),
        ProductStatusFilter.inactive => filter.eq('is_active', false),
        ProductStatusFilter.outOfStock =>
          filter.eq('is_active', true).eq('in_stock', false),
      };

      // One row beyond the page is requested so "is there more" needs no
      // separate count query.
      final rows = await filter
          .order(query.sort.column, ascending: query.sort.isAscending)
          .range(query.rangeFrom, query.rangeTo + 1);

      final hasMore = rows.length > query.pageSize;
      final page = rows.take(query.pageSize).map(Product.fromJson).toList();

      return Success<PagedResult<Product>>(
        PagedResult<Product>(items: page, page: query.page, hasMore: hasMore),
      );
    } on Object catch (error, stackTrace) {
      return ResultFailure<PagedResult<Product>>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<Product>> fetchById(String id) async {
    try {
      final row = await _client
          .from(_table)
          .select()
          .eq('id', id)
          .maybeSingle();
      if (row == null) {
        return const ResultFailure<Product>(ServerFailure());
      }
      return Success<Product>(Product.fromJson(row));
    } on Object catch (error, stackTrace) {
      return ResultFailure<Product>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<Product>> create(ProductDraft draft) async {
    try {
      final payload = _payload(draft);
      final hasCustomCode = draft.customCode.trim().isNotEmpty;
      final customCodeUpper = draft.customCode.trim().toUpperCase();

      if (hasCustomCode || draft.isManualCode) {
        payload['product_code'] = customCodeUpper;
      }

      Map<String, dynamic> row;
      try {
        row = await _client
            .from(_table)
            .insert(payload)
            .select()
            .single();
      } on PostgrestException catch (pgErr) {
        if (pgErr.message.contains('stock_quantity') || pgErr.code == '42703' || pgErr.code == 'PGRST204') {
          payload.remove('stock_quantity');
          row = await _client
              .from(_table)
              .insert(payload)
              .select()
              .single();
        } else {
          rethrow;
        }
      }

      // If Postgres DB trigger assigned a random code on BEFORE INSERT, override it with custom code
      if (hasCustomCode) {
        row['product_code'] = customCodeUpper;
        try {
          await _client
              .from(_table)
              .update(<String, dynamic>{'product_code': customCodeUpper})
              .eq('id', row['id'])
              .timeout(const Duration(seconds: 2));
        } catch (overrideErr) {
          AppLog.warn('Failed to override custom product_code: $overrideErr');
        }
      }

      final product = Product.fromJson(row);

      // Seed product units for generated stock serials
      try {
        final serials = draft.generateStockSerials(quantityOverride: product.stockQuantity);
        if (serials.isNotEmpty) {
          final unitsToInsert = <Map<String, dynamic>>[
            for (final serial in serials)
              <String, dynamic>{
                'product_id': product.id,
                'serial_number': serial,
                'manufactured_at': DateTime.now().toIso8601String(),
              }
          ];
          await _client
              .from('product_units')
              .upsert(unitsToInsert)
              .timeout(const Duration(seconds: 2));
        }
      } catch (unitErr) {
        AppLog.warn('Failed to pre-seed product_units: $unitErr');
      }

      return Success<Product>(product);
    } on Object catch (error, stackTrace) {
      return ResultFailure<Product>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<Product>> update(ProductDraft draft) async {
    try {
      final payload = _payload(draft);
      final hasCustomCode = draft.customCode.trim().isNotEmpty;
      final customCodeUpper = draft.customCode.trim().toUpperCase();

      if (hasCustomCode || draft.isManualCode) {
        payload['product_code'] = customCodeUpper;
      }

      Map<String, dynamic> row;
      try {
        row = await _client
            .from(_table)
            .update(payload)
            .eq('id', draft.id!)
            .select()
            .single();
      } on PostgrestException catch (pgErr) {
        if (pgErr.message.contains('stock_quantity') || pgErr.code == '42703' || pgErr.code == 'PGRST204') {
          payload.remove('stock_quantity');
          row = await _client
              .from(_table)
              .update(payload)
              .eq('id', draft.id!)
              .select()
              .single();
        } else {
          rethrow;
        }
      }

      // Override if product_code was modified or replaced
      if (hasCustomCode) {
        row['product_code'] = customCodeUpper;
        try {
          await _client
              .from(_table)
              .update(<String, dynamic>{'product_code': customCodeUpper})
              .eq('id', row['id'])
              .timeout(const Duration(seconds: 2));
        } catch (overrideErr) {
          AppLog.warn('Failed to override custom product_code on update: $overrideErr');
        }
      }

      final product = Product.fromJson(row);

      // Seed product units for generated stock serials
      try {
        final serials = draft.generateStockSerials(quantityOverride: product.stockQuantity);
        if (serials.isNotEmpty) {
          final unitsToInsert = <Map<String, dynamic>>[
            for (final serial in serials)
              <String, dynamic>{
                'product_id': product.id,
                'serial_number': serial,
                'manufactured_at': DateTime.now().toIso8601String(),
              }
          ];
          await _client
              .from('product_units')
              .upsert(unitsToInsert)
              .timeout(const Duration(seconds: 2));
        }
      } catch (unitErr) {
        AppLog.warn('Failed to update product_units: $unitErr');
      }

      return Success<Product>(product);
    } on Object catch (error, stackTrace) {
      return ResultFailure<Product>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _client.from(_table).delete().eq('id', id);
      return const Success<void>(null);
    } on Object catch (error, stackTrace) {
      return ResultFailure<void>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<Product>> setInStock(String id, {required bool inStock}) =>
      _patch(id, <String, dynamic>{'in_stock': inStock});

  @override
  Future<Result<Product>> setActive(String id, {required bool isActive}) =>
      _patch(id, <String, dynamic>{'is_active': isActive});

  @override
  Future<Result<int>> scanCount(String productId) async {
    try {
      final response = await _client
          .from('scan_events')
          .select('id')
          .eq('product_id', productId)
          .count(CountOption.exact);
      return Success<int>(response.count);
    } on Object catch (error, stackTrace) {
      return ResultFailure<int>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<ProductCounts>> counts() async {
    try {
      final total = await _client
          .from(_table)
          .select('id')
          .count(CountOption.exact);
      final outOfStock = await _client
          .from(_table)
          .select('id')
          .eq('is_active', true)
          .eq('in_stock', false)
          .count(CountOption.exact);
      final inactive = await _client
          .from(_table)
          .select('id')
          .eq('is_active', false)
          .count(CountOption.exact);

      return Success<ProductCounts>(
        ProductCounts(
          total: total.count,
          outOfStock: outOfStock.count,
          inactive: inactive.count,
        ),
      );
    } on Object catch (error, stackTrace) {
      return ResultFailure<ProductCounts>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<List<ScannedProduct>>> topScanned({
    int days = 30,
    int limit = 5,
  }) async {
    try {
      final rows = await _client.rpc<List<dynamic>>(
        'top_scanned_products',
        params: <String, dynamic>{'p_days': days, 'p_limit': limit},
      );
      return Success<List<ScannedProduct>>(<ScannedProduct>[
        for (final row in rows.cast<Map<String, dynamic>>())
          ScannedProduct(
            productId: row['product_id'] as String,
            name: row['name'] as String,
            productCode: row['product_code'] as String,
            scanCount: (row['scan_count'] as num?)?.toInt() ?? 0,
          ),
      ]);
    } on Object catch (error, stackTrace) {
      return ResultFailure<List<ScannedProduct>>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<List<Product>>> fetchAllForExport() async {
    try {
      final rows = await _client
          .from(_table)
          .select()
          .eq('is_active', true)
          .order('category')
          .order('name');
      return Success<List<Product>>(rows.map(Product.fromJson).toList());
    } on Object catch (error, stackTrace) {
      return ResultFailure<List<Product>>(_map(error, stackTrace));
    }
  }

  Future<Result<Product>> _patch(String id, Map<String, dynamic> values) async {
    try {
      final row = await _client
          .from(_table)
          .update(values)
          .eq('id', id)
          .select()
          .single();
      return Success<Product>(Product.fromJson(row));
    } on Object catch (error, stackTrace) {
      return ResultFailure<Product>(_map(error, stackTrace));
    }
  }

  Map<String, dynamic> _payload(ProductDraft draft) => <String, dynamic>{
    'name': draft.name.trim(),
    'model_number': _nullIfBlank(draft.modelNumber),
    'category': draft.category!.wireValue,
    'description': _nullIfBlank(draft.description),
    'capacity': _nullIfBlank(draft.capacity),
    'specifications': draft.specificationsMap,
    'mrp': draft.mrpValue,
    'wholesale_price': draft.wholesaleValue,
    'retail_price': draft.retailValue,
    'warranty_months': draft.warrantyMonths,
    'stock_quantity': draft.stockQuantityValue ?? (draft.inStock ? 1 : 0),
    'in_stock': (draft.stockQuantityValue ?? 1) > 0 && draft.inStock,
    'is_active': draft.isActive,
  };

  static String? _nullIfBlank(String value) =>
      value.trim().isEmpty ? null : value.trim();

  /// Strips the characters PostgREST treats as structure inside an `or` filter.
  ///
  /// A product name containing a comma or bracket would otherwise be parsed as
  /// extra filter clauses and the query would fail or, worse, match wrongly.
  static String _escapeForOrFilter(String term) =>
      term.replaceAll(RegExp(r'[,()%\\]'), ' ').trim();

  AppFailure _map(Object error, StackTrace stackTrace) {
    if (error is SocketException || error is HttpException) {
      return NetworkFailure(cause: error, stackTrace: stackTrace);
    }
    if (error is PostgrestException) {
      if (error.code == '42501') {
        return PermissionFailure(cause: error, stackTrace: stackTrace);
      }
      return ServerFailure(cause: error, stackTrace: stackTrace);
    }
    AppLog.error('Unmapped product repository error', error, stackTrace);
    return UnexpectedFailure(cause: error, stackTrace: stackTrace);
  }
}

/// The application-wide [ProductRepository].
@Riverpod(keepAlive: true)
ProductRepository productRepository(Ref<ProductRepository> ref) =>
    SupabaseProductRepository(ref.watch(supabaseClientProvider));
