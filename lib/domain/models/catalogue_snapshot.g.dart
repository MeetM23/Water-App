// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalogue_snapshot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CatalogueSnapshotImpl _$$CatalogueSnapshotImplFromJson(
        Map<String, dynamic> json) =>
    _$CatalogueSnapshotImpl(
      products: (json['products'] as List<dynamic>)
          .map((e) => CatalogProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
      fetchedAt: DateTime.parse(json['fetched_at'] as String),
    );

Map<String, dynamic> _$$CatalogueSnapshotImplToJson(
        _$CatalogueSnapshotImpl instance) =>
    <String, dynamic>{
      'products': instance.products,
      'fetched_at': instance.fetchedAt.toIso8601String(),
    };
