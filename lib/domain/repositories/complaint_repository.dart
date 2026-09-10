import 'dart:typed_data';

import '../../core/errors/result.dart';
import '../enums/complaint_category.dart';
import '../enums/complaint_priority.dart';
import '../enums/complaint_status.dart';
import '../models/complaint.dart';
import '../models/complaint_message.dart';

/// Repository interface for complaint operations.
abstract class ComplaintRepository {
  /// Fetches complaints submitted by the currently logged-in dealer.
  Future<Result<List<Complaint>>> fetchUserComplaints();

  /// Fetches all complaints across all dealers (Owner only).
  Future<Result<List<Complaint>>> fetchAllComplaints({
    ComplaintStatus? status,
    ComplaintPriority? priority,
    ComplaintCategory? category,
    String? searchQuery,
  });

  /// Retrieves full complaint details by ID.
  Future<Result<Complaint>> getComplaintById(String complaintId);

  /// Submits a new complaint.
  Future<Result<Complaint>> createComplaint({
    required String subject,
    required ComplaintCategory category,
    required String description,
    required ComplaintPriority priority,
    String? productId,
    String? unitId,
    String? referenceNumber,
    List<({String fileName, Uint8List bytes})>? attachmentFiles,
  });

  /// Updates complaint status and/or priority (Owner only).
  Future<Result<Complaint>> updateComplaintStatusAndPriority({
    required String complaintId,
    ComplaintStatus? status,
    ComplaintPriority? priority,
  });

  /// Posts a new message or reply to a complaint.
  Future<Result<ComplaintMessage>> addMessage({
    required String complaintId,
    required String message,
    bool isInternal = false,
  });

  /// Generates a signed URL for an attachment file in Supabase Storage.
  Future<Result<String>> getSignedAttachmentUrl(String storagePath);
}
