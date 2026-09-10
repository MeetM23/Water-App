// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complaint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ComplaintImpl _$$ComplaintImplFromJson(Map<String, dynamic> json) =>
    _$ComplaintImpl(
      id: json['id'] as String,
      ticketNumber: json['ticket_number'] as String,
      userId: json['user_id'] as String,
      subject: json['subject'] as String,
      category: $enumDecode(_$ComplaintCategoryEnumMap, json['category']),
      description: json['description'] as String,
      priority: $enumDecode(_$ComplaintPriorityEnumMap, json['priority']),
      status: $enumDecode(_$ComplaintStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      productId: json['product_id'] as String?,
      referenceNumber: json['reference_number'] as String?,
      resolvedAt: json['resolved_at'] == null
          ? null
          : DateTime.parse(json['resolved_at'] as String),
      userProfile: json['user_profile'] == null
          ? null
          : Profile.fromJson(json['user_profile'] as Map<String, dynamic>),
      product: json['product'] == null
          ? null
          : CatalogProduct.fromJson(json['product'] as Map<String, dynamic>),
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) => ComplaintMessage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ComplaintMessage>[],
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) =>
                  ComplaintAttachment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ComplaintAttachment>[],
    );

Map<String, dynamic> _$$ComplaintImplToJson(_$ComplaintImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ticket_number': instance.ticketNumber,
      'user_id': instance.userId,
      'subject': instance.subject,
      'category': _$ComplaintCategoryEnumMap[instance.category]!,
      'description': instance.description,
      'priority': _$ComplaintPriorityEnumMap[instance.priority]!,
      'status': _$ComplaintStatusEnumMap[instance.status]!,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'product_id': instance.productId,
      'reference_number': instance.referenceNumber,
      'resolved_at': instance.resolvedAt?.toIso8601String(),
      'user_profile': instance.userProfile,
      'product': instance.product,
      'messages': instance.messages,
      'attachments': instance.attachments,
    };

const _$ComplaintCategoryEnumMap = {
  ComplaintCategory.productIssue: 'product_issue',
  ComplaintCategory.installationIssue: 'installation_issue',
  ComplaintCategory.warrantyIssue: 'warranty_issue',
  ComplaintCategory.deliveryIssue: 'delivery_issue',
  ComplaintCategory.billingIssue: 'billing_issue',
  ComplaintCategory.technicalIssue: 'technical_issue',
  ComplaintCategory.other: 'other',
};

const _$ComplaintPriorityEnumMap = {
  ComplaintPriority.low: 'low',
  ComplaintPriority.medium: 'medium',
  ComplaintPriority.high: 'high',
  ComplaintPriority.urgent: 'urgent',
};

const _$ComplaintStatusEnumMap = {
  ComplaintStatus.open: 'open',
  ComplaintStatus.inProgress: 'in_progress',
  ComplaintStatus.resolved: 'resolved',
  ComplaintStatus.closed: 'closed',
};
