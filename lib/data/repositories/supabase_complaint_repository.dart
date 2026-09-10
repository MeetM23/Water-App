import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_failure.dart';
import '../../core/errors/result.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/enums/complaint_category.dart';
import '../../domain/enums/complaint_priority.dart';
import '../../domain/enums/complaint_status.dart';
import '../../domain/models/complaint.dart';
import '../../domain/models/complaint_attachment.dart';
import '../../domain/models/complaint_message.dart';
import '../../domain/repositories/complaint_repository.dart';
import '../supabase/supabase_providers.dart';

part 'supabase_complaint_repository.g.dart';

/// Supabase implementation of [ComplaintRepository].
class SupabaseComplaintRepository implements ComplaintRepository {
  /// Creates a repository instance.
  SupabaseComplaintRepository(this._client);

  final SupabaseClient _client;

  static const String _tableComplaints = 'complaints';
  static const String _tableMessages = 'complaint_messages';
  static const String _tableAttachments = 'complaint_attachments';
  static const String _bucketAttachments = 'complaint_attachments';

  @override
  Future<Result<List<Complaint>>> fetchUserComplaints() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return const ResultFailure<List<Complaint>>(
          PermissionFailure(),
        );
      }

      final rows = await _client
          .from(_tableComplaints)
          .select('''
            *,
            product:catalog_view(*)
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final complaints = rows.map((r) => _parseComplaint(r)).toList();
      return Success<List<Complaint>>(complaints);
    } on Object catch (error, stackTrace) {
      return ResultFailure<List<Complaint>>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<List<Complaint>>> fetchAllComplaints({
    ComplaintStatus? status,
    ComplaintPriority? priority,
    ComplaintCategory? category,
    String? searchQuery,
  }) async {
    try {
      var query = _client.from(_tableComplaints).select('''
            *,
            user_profile:profiles(*),
            product:catalog_view(*)
          ''');

      if (status != null) {
        query = query.eq('status', status.value);
      }
      if (priority != null) {
        query = query.eq('priority', priority.value);
      }
      if (category != null) {
        query = query.eq('category', category.value);
      }
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final term = '%${searchQuery.trim()}%';
        query = query.or('ticket_number.ilike.$term,subject.ilike.$term,reference_number.ilike.$term');
      }

      final rows = await query.order('created_at', ascending: false);
      final complaints = rows.map((r) => _parseComplaint(r)).toList();
      return Success<List<Complaint>>(complaints);
    } on Object catch (error, stackTrace) {
      return ResultFailure<List<Complaint>>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<Complaint>> getComplaintById(String complaintId) async {
    try {
      final row = await _client
          .from(_tableComplaints)
          .select('''
            *,
            user_profile:profiles(*),
            product:catalog_view(*)
          ''')
          .eq('id', complaintId)
          .single();

      final messagesRows = await _client
          .from(_tableMessages)
          .select('''
            *,
            sender_profile:profiles(*)
          ''')
          .eq('complaint_id', complaintId)
          .order('created_at', ascending: true);

      final attachmentsRows = await _client
          .from(_tableAttachments)
          .select()
          .eq('complaint_id', complaintId)
          .order('created_at', ascending: true);

      final messages = messagesRows.map((m) {
        final profileJson = m['sender_profile'] as Map<String, dynamic>?;
        return ComplaintMessage.fromJson({
          ...m,
          if (profileJson != null) 'sender_profile': profileJson,
        });
      }).toList();

      final attachments = attachmentsRows
          .map((a) => ComplaintAttachment.fromJson(a))
          .toList();

      final complaint = _parseComplaint(row).copyWith(
        messages: messages,
        attachments: attachments,
      );

      return Success<Complaint>(complaint);
    } on Object catch (error, stackTrace) {
      return ResultFailure<Complaint>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<Complaint>> createComplaint({
    required String subject,
    required ComplaintCategory category,
    required String description,
    required ComplaintPriority priority,
    String? productId,
    String? unitId,
    String? referenceNumber,
    List<({String fileName, Uint8List bytes})>? attachmentFiles,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return const ResultFailure<Complaint>(
          PermissionFailure(),
        );
      }

      final inserted = await _client
          .from(_tableComplaints)
          .insert({
            'user_id': userId,
            'subject': subject,
            'category': category.value,
            'description': description,
            'priority': priority.value,
            if (productId != null && productId.isNotEmpty) 'product_id': productId,
            if (unitId != null && unitId.isNotEmpty) 'unit_id': unitId,
            if (referenceNumber != null && referenceNumber.isNotEmpty)
              'reference_number': referenceNumber,
          })
          .select()
          .single();

      final complaintId = inserted['id'] as String;

      // Upload attachments if provided
      if (attachmentFiles != null && attachmentFiles.isNotEmpty) {
        for (final file in attachmentFiles) {
          final storagePath = '$complaintId/${file.fileName}';
          await _client.storage.from(_bucketAttachments).uploadBinary(
                storagePath,
                file.bytes,
                fileOptions: const FileOptions(upsert: true),
              );

          await _client.from(_tableAttachments).insert({
            'complaint_id': complaintId,
            'storage_path': storagePath,
            'file_name': file.fileName,
            'file_size': file.bytes.length,
          });
        }
      }

      return getComplaintById(complaintId);
    } on Object catch (error, stackTrace) {
      return ResultFailure<Complaint>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<Complaint>> updateComplaintStatusAndPriority({
    required String complaintId,
    ComplaintStatus? status,
    ComplaintPriority? priority,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (status != null) {
        updates['status'] = status.value;
        if (status == ComplaintStatus.resolved || status == ComplaintStatus.closed) {
          updates['resolved_at'] = DateTime.now().toIso8601String();
        }
      }
      if (priority != null) {
        updates['priority'] = priority.value;
      }

      await _client
          .from(_tableComplaints)
          .update(updates)
          .eq('id', complaintId);

      return getComplaintById(complaintId);
    } on Object catch (error, stackTrace) {
      return ResultFailure<Complaint>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<ComplaintMessage>> addMessage({
    required String complaintId,
    required String message,
    bool isInternal = false,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return const ResultFailure<ComplaintMessage>(
          PermissionFailure(),
        );
      }

      final row = await _client
          .from(_tableMessages)
          .insert({
            'complaint_id': complaintId,
            'sender_id': userId,
            'message': message,
            'is_internal': isInternal,
          })
          .select('''
            *,
            sender_profile:profiles(*)
          ''')
          .single();

      final profileJson = row['sender_profile'] as Map<String, dynamic>?;
      final msg = ComplaintMessage.fromJson({
        ...row,
        if (profileJson != null) 'sender_profile': profileJson,
      });

      return Success<ComplaintMessage>(msg);
    } on Object catch (error, stackTrace) {
      return ResultFailure<ComplaintMessage>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<String>> getSignedAttachmentUrl(String storagePath) async {
    try {
      final url = await _client.storage
          .from(_bucketAttachments)
          .createSignedUrl(storagePath, 60 * 60);
      return Success<String>(url);
    } on Object catch (error, stackTrace) {
      return ResultFailure<String>(_map(error, stackTrace));
    }
  }

  Complaint _parseComplaint(Map<String, dynamic> row) {
    final profileJson = row['user_profile'] as Map<String, dynamic>?;
    final productJson = row['product'] as Map<String, dynamic>?;

    return Complaint.fromJson({
      ...row,
      if (profileJson != null) 'user_profile': profileJson,
      if (productJson != null) 'product': productJson,
    });
  }

  AppFailure _map(Object error, StackTrace stackTrace) {
    if (error is SocketException || error is HttpException) {
      return NetworkFailure(cause: error, stackTrace: stackTrace);
    }
    if (error is StorageException) {
      return ServerFailure(cause: error, stackTrace: stackTrace);
    }
    if (error is PostgrestException) {
      if (error.code == '42501') {
        return PermissionFailure(cause: error, stackTrace: stackTrace);
      }
      return ServerFailure(cause: error, stackTrace: stackTrace);
    }
    AppLog.error('Unmapped complaint repository error', error, stackTrace);
    return UnexpectedFailure(cause: error, stackTrace: stackTrace);
  }
}

/// Provider for [ComplaintRepository].
@Riverpod(keepAlive: true)
ComplaintRepository complaintRepository(Ref<ComplaintRepository> ref) =>
    SupabaseComplaintRepository(ref.watch(supabaseClientProvider));
