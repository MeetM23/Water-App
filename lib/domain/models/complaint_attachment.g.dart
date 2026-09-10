// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complaint_attachment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ComplaintAttachmentImpl _$$ComplaintAttachmentImplFromJson(
        Map<String, dynamic> json) =>
    _$ComplaintAttachmentImpl(
      id: json['id'] as String,
      complaintId: json['complaint_id'] as String,
      storagePath: json['storage_path'] as String,
      fileName: json['file_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      fileSize: (json['file_size'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$ComplaintAttachmentImplToJson(
        _$ComplaintAttachmentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'complaint_id': instance.complaintId,
      'storage_path': instance.storagePath,
      'file_name': instance.fileName,
      'created_at': instance.createdAt.toIso8601String(),
      'file_size': instance.fileSize,
    };
