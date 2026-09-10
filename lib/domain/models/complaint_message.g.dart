// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complaint_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ComplaintMessageImpl _$$ComplaintMessageImplFromJson(
        Map<String, dynamic> json) =>
    _$ComplaintMessageImpl(
      id: json['id'] as String,
      complaintId: json['complaint_id'] as String,
      senderId: json['sender_id'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isInternal: json['is_internal'] as bool? ?? false,
      senderProfile: json['sender_profile'] == null
          ? null
          : Profile.fromJson(json['sender_profile'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ComplaintMessageImplToJson(
        _$ComplaintMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'complaint_id': instance.complaintId,
      'sender_id': instance.senderId,
      'message': instance.message,
      'created_at': instance.createdAt.toIso8601String(),
      'is_internal': instance.isInternal,
      'sender_profile': instance.senderProfile,
    };
