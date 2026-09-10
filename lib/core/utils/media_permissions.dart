import 'package:permission_handler/permission_handler.dart';

import 'app_logger.dart';

/// Which media source the owner picked in the chooser sheet.
enum MediaSource {
  /// Take a new photograph.
  camera,

  /// Pick from the device gallery.
  gallery,
}

/// Outcome of asking for access to a media source.
enum MediaPermissionResult {
  /// Access is available; proceed.
  granted,

  /// The user said no this time. Asking again later is reasonable.
  denied,

  /// The user said no permanently, or the OS blocks the prompt. The only way
  /// forward is the system settings screen.
  permanentlyDenied,
}

/// Runtime permission checks for capturing product photography.
///
/// Only the camera needs one. Gallery picking goes through the platform photo
/// picker, which hands back a single user-chosen file and therefore requires no
/// runtime grant on any supported Android version; asking for storage access
/// there would be a prompt the user cannot benefit from refusing.
///
/// `image_picker` alone returns a bare null when the camera is refused, which
/// cannot distinguish "not now" from "never ask again". Those need different
/// interfaces: one offers a retry, the other has to send the user to Settings.
abstract final class MediaPermissions {
  /// Requests access for [source] and reports what happened.
  static Future<MediaPermissionResult> request(MediaSource source) async {
    if (source == MediaSource.gallery) {
      return MediaPermissionResult.granted;
    }

    final status = await Permission.camera.request();

    if (status.isGranted || status.isLimited) {
      return MediaPermissionResult.granted;
    }
    if (status.isPermanentlyDenied || status.isRestricted) {
      return MediaPermissionResult.permanentlyDenied;
    }
    return MediaPermissionResult.denied;
  }

  /// Opens the system settings page for this app.
  ///
  /// Returns false if the settings screen could not be opened, so the caller
  /// can say so rather than appearing to do nothing.
  static Future<bool> openSettings() async {
    try {
      return await openAppSettings();
    } on Object catch (error, stackTrace) {
      AppLog.warn('Could not open app settings', error, stackTrace);
      return false;
    }
  }
}
