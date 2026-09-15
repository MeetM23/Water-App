import 'dart:async';

import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/media_permissions.dart';
import '../../../../core/utils/product_code.dart';
import '../../../../data/repositories/supabase_scan_repository.dart';
import '../../../../domain/enums/user_role.dart';
import '../../../../domain/models/catalog_product.dart';
import '../../../../domain/models/product_lookup.dart';
import '../../../../domain/repositories/scan_repository.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/application/session_controller.dart';
import '../../../owner/products/application/product_list_controller.dart';
import '../../dealer/application/catalogue_controller.dart';
import '../../dealer/application/product_lookup_controller.dart';

part 'scanner_controller.g.dart';

/// Whether the operating system will let the camera run.
enum ScannerPermission {
  /// Access has not been asked for yet.
  unknown,

  /// The camera may be started.
  granted,

  /// Refused this time. Asking again is allowed and may work.
  denied,

  /// Refused for good, or blocked by policy. Only Settings can undo it.
  permanentlyDenied,
}

/// Why a code could not be turned into a product.
enum ScanRejection {
  /// The shape or the check character is wrong, so it is not one of ours.
  invalidCode,

  /// Well formed, but no product carries it.
  unknownCode,

  /// The lookup itself could not be completed.
  lookupFailed,
}

/// The line shown to the dealer when a code is refused.
///
/// It lives beside [ScanRejection] rather than in the widget that shows it
/// because two callers render it, the camera path and the manual-entry sheet,
/// and the two must not drift apart on what a rejection means.
extension ScanRejectionMessage on ScanRejection {
  /// Localised explanation of why the code was refused.
  String message(AppLocalizations l10n) => switch (this) {
    ScanRejection.invalidCode => l10n.scanInvalidCode,
    ScanRejection.unknownCode => l10n.scanUnknownCode,
    ScanRejection.lookupFailed => l10n.scanLookupFailed,
  };
}

/// The synchronous verdict on one camera detection.
sealed class ScanAdmission {
  /// Creates an admission.
  const ScanAdmission();
}

/// The code is well formed and worth looking up.
final class ScanAdmitted extends ScanAdmission {
  /// Creates an admitted detection.
  const ScanAdmitted(this.code);

  /// The code in its canonical form.
  final String code;
}

/// The code was rejected without asking anybody.
final class ScanRefused extends ScanAdmission {
  /// Creates a refused detection.
  const ScanRefused(this.reason);

  /// Why it was refused.
  final ScanRejection reason;
}

/// The result of resolving an admitted code.
sealed class ScanOutcome {
  /// Creates an outcome.
  const ScanOutcome();
}

/// The code resolved to a product the dealer may open.
final class ScanMatched extends ScanOutcome {
  /// Creates a matched outcome.
  const ScanMatched(this.product);

  /// The product behind the code.
  final CatalogProduct product;
}

/// The code resolved to an individual physical RO unit.
final class ScanUnitMatched extends ScanOutcome {
  /// Creates a unit matched outcome.
  const ScanUnitMatched(this.unit);

  /// The product lookup result.
  final ProductLookup unit;
}

/// The code resolved to nothing usable.
final class ScanRejected extends ScanOutcome {
  /// Creates a rejected outcome.
  const ScanRejected(this.reason);

  /// Why it was rejected.
  final ScanRejection reason;
}

/// Everything the scanner screen needs that the camera does not publish.
class ScannerState {
  /// Creates a scanner state.
  const ScannerState({
    this.permission = ScannerPermission.unknown,
    this.camera,
    this.isResolving = false,
  });

  /// What the operating system currently allows.
  final ScannerPermission permission;

  /// The live camera, or null until access has been granted once.
  ///
  /// A mutable object inside an immutable state, deliberately: the widget has
  /// to hand this exact instance to the preview, and a rebuild is the only way
  /// it learns the instance was replaced after a hardware failure.
  final MobileScannerController? camera;

  /// Whether a scan is being resolved, or a resolved one is being opened.
  final bool isResolving;

  /// Copies with selected fields replaced.
  ///
  /// [camera] is deliberately not settable here. It is replaced only by the
  /// controller, which rebuilds the whole state when it does, so a stray copy
  /// can never leave a disposed camera behind in the state.
  ScannerState copyWith({ScannerPermission? permission, bool? isResolving}) =>
      ScannerState(
        permission: permission ?? this.permission,
        camera: camera,
        isResolving: isResolving ?? this.isResolving,
      );
}

/// Camera lifecycle, scan debouncing and code resolution.
///
/// The camera lives here rather than in the screen because the screen is a
/// tab: it stays mounted while the dealer is reading the catalogue, and the
/// camera must not stay powered while it is. Routing every start and stop
/// through one object means there is a single answer to "is the camera
/// running", which is what makes backgrounding mid-scan survivable.
///
/// Nothing here knows which role is scanning. Everything role-shaped, the
/// route to open and the price on the other side of it, is decided above.
@riverpod
class ScannerController extends _$ScannerController {
  /// How long the same code stays suppressed after it was last seen.
  ///
  /// The camera reports a barcode it can still see several times a second, so
  /// measuring from the last *sighting* rather than from the last acceptance
  /// makes the suppression last as long as the label is in frame, plus two
  /// seconds. That is what stops the product screen re-opening the instant the
  /// dealer returns to a scanner still pointed at the label they just scanned,
  /// without needing a second, longer timer for that one case.
  static const Duration _duplicateWindow = Duration(seconds: 2);

  /// The barcode symbologies the printed labels actually carry.
  ///
  /// Restricting the decoder is a speed decision as much as a correctness one:
  /// every extra format is another pass over every frame.
  static const List<BarcodeFormat> _formats = <BarcodeFormat>[
    BarcodeFormat.code128,
    BarcodeFormat.ean13,
    BarcodeFormat.qrCode,
  ];

  /// Monotonic on purpose. A wall clock can jump backwards when the network
  /// corrects it, and a debounce that unlocks early because of that would show
  /// up as a double-opened product screen nobody could reproduce.
  final Stopwatch _sinceLastSeen = Stopwatch();

  MobileScannerController? _camera;
  String? _lastRawValue;
  bool _isStarting = false;

  /// Whether this provider has been torn down.
  ///
  /// Writing [state] after disposal throws, and every write here sits behind
  /// an await that a sign-out can outlive: the permission dialog, and the
  /// lookup. A revoked session redirects to the sign-in screen, which unmounts
  /// the scanner, and the answer arrives afterwards with nobody to give it to.
  bool _isDisposed = false;

  @override
  ScannerState build() {
    _isDisposed = false;
    ref.onDispose(() {
      _isDisposed = true;
      _releaseCamera();
    });
    return const ScannerState();
  }

  /// Asks for camera access and starts the preview if it is granted.
  ///
  /// Safe to call whenever the screen becomes visible: an already-running
  /// camera is left alone, and an already-granted permission does not prompt.
  Future<void> startCamera() async {
    // Two activations can arrive together, the tab becoming visible at the
    // same moment the app resumes, and a second permission request while the
    // first dialog is still up is how you get a prompt the user cannot answer.
    if (_isStarting) {
      return;
    }
    _isStarting = true;
    try {
      await _start();
    } finally {
      _isStarting = false;
    }
  }

  /// Stops the preview and hands the camera back to the system.
  ///
  /// The last-seen code is kept on purpose: coming back from the product
  /// screen must not count as never having seen that label.
  Future<void> stopCamera() async {
    final camera = _camera;
    if (camera == null) {
      return;
    }
    try {
      await camera.stop();
    } on Object catch (error, stackTrace) {
      // Every caller is fire and forget, so an exception raised here would
      // land as an unhandled error rather than anywhere a dealer could act on
      // it. Failing to release the camera costs battery, nothing more.
      AppLog.warn('Camera could not be stopped', error, stackTrace);
    }
  }

  /// Re-enables scanning after the screen comes back to the front.
  void resumeScanning() {
    _sinceLastSeen
      ..reset()
      ..start();
    if (state.isResolving) {
      state = state.copyWith(isResolving: false);
    }
  }

  /// Throws a failed camera away and starts a fresh one.
  ///
  /// A retry cannot be another start: the controller latches the failure that
  /// stopped it, and a latched permission refusal makes every later start a
  /// silent no-op.
  Future<void> retryCamera() async {
    final failed = _camera;
    _camera = null;
    state = const ScannerState();
    await failed?.dispose();
    await startCamera();
  }

  /// Turns the torch on or off, ignoring the request when it cannot apply.
  Future<void> toggleTorch() async {
    final camera = _camera;
    if (camera == null || !camera.value.isRunning) {
      return;
    }
    try {
      await camera.toggleTorch();
    } on MobileScannerException catch (error, stackTrace) {
      // A torch that will not light is not worth an error dialog over a live
      // camera: the dealer can already see whether the scene got brighter.
      AppLog.warn('Torch could not be toggled', error, stackTrace);
    }
  }

  /// Swaps to the other camera, ignoring the request when it cannot apply.
  Future<void> switchCamera() async {
    final camera = _camera;
    if (camera == null || !camera.value.isRunning) {
      return;
    }
    try {
      await camera.switchCamera();
    } on MobileScannerException catch (error, stackTrace) {
      AppLog.warn('Camera could not be switched', error, stackTrace);
    }
  }

  /// Decides, synchronously, what to do with one detection.
  ///
  /// Returns null when the detection is swallowed, which is the common case: a
  /// single physical scan produces a detection several times a second for as
  /// long as the label is in frame, and all but the first are noise.
  ///
  /// Two guards do that work. [ScannerState.isResolving] covers the window in
  /// which a lookup and a navigation are running, and [_duplicateWindow]
  /// covers the frames on either side of it.
  ScanAdmission? admitDetection(BarcodeCapture capture) {
    if (state.isResolving) {
      return null;
    }

    final raw = _firstUsableValue(capture);
    if (raw == null) {
      return null;
    }

    if (raw == _lastRawValue && _sinceLastSeen.elapsed < _duplicateWindow) {
      _sinceLastSeen.reset();
      return null;
    }
    _lastRawValue = raw;
    _sinceLastSeen
      ..reset()
      ..start();

    final code = ProductCode.normalise(raw);
    if (code == null) {
      // Refused here, before any network call: a shop is full of other
      // manufacturers' barcodes and not one of them deserves a round trip.
      return const ScanRefused(ScanRejection.invalidCode);
    }

    state = state.copyWith(isResolving: true);
    return ScanAdmitted(code);
  }

  /// Resolves [rawCode] to a product, or explains why it could not.
  ///
  /// The manual-entry sheet uses this too, so it repeats the format check
  /// rather than trusting its caller to have done it.
  Future<ScanOutcome> resolve(String rawCode) async {
    final code = ProductCode.normalise(rawCode);
    if (code == null) {
      return const ScanRejected(ScanRejection.invalidCode);
    }

    state = state.copyWith(isResolving: true);
    final outcome = await ref
        .read(productLookupControllerProvider.notifier)
        .lookup(code);

    switch (outcome) {
      case LookupFound(:final product):
        // Scanning stays off until the screen calls [resumeScanning]. The
        // product route is pushed next, and a detection arriving while it
        // opens would push a second copy of the same screen behind it.
        return ScanMatched(product);
      case LookupUnitFound(:final unit):
        return ScanUnitMatched(unit);
      case LookupInvalidCode():
        return _reject(ScanRejection.invalidCode);
      case LookupNotFound():
        return _reject(ScanRejection.unknownCode);
      case LookupFailed():
        return _reject(ScanRejection.lookupFailed);
    }
  }

  /// Records that this dealer looked [product] up.
  ///
  /// Fire and forget by contract. The dealer is already on their way to the
  /// product screen, and an insert that fails, offline or refused by the row
  /// policy on a suspended account, must never surface as a failed scan.
  void recordScan(CatalogProduct product, ScanSource source) {
    final session = ref.read(sessionControllerProvider).valueOrNull;
    if (session is! SessionSignedIn) {
      return;
    }

    // The repository is resolved before the async gap so the write cannot
    // reach for a ref this notifier has since disposed.
    final repo = ref.read(scanRepositoryProvider);
    unawaited(
      _write(
        repo,
        productId: product.id,
        role: session.profile.role,
        source: source,
      ).then((_) {
        try {
          ref.invalidate(productListControllerProvider);
          ref.invalidate(catalogueControllerProvider);
        } catch (_) {}
      }),
    );
  }

  /// Records telemetry when a product is scanned.
  void recordScanForUnit(ProductLookup unit, ScanSource source) {
    final session = ref.read(sessionControllerProvider).valueOrNull;
    if (session is! SessionSignedIn) {
      return;
    }

    final repo = ref.read(scanRepositoryProvider);
    unawaited(
      _write(
        repo,
        productId: unit.productId,
        role: session.profile.role,
        source: source,
      ).then((_) {
        try {
          ref.invalidate(productListControllerProvider);
          ref.invalidate(catalogueControllerProvider);
        } catch (_) {}
      }),
    );
  }

  Future<void> _start() async {
    final permission = switch (await MediaPermissions.request(
      MediaSource.camera,
    )) {
      MediaPermissionResult.granted => ScannerPermission.granted,
      MediaPermissionResult.denied => ScannerPermission.denied,
      MediaPermissionResult.permanentlyDenied =>
        ScannerPermission.permanentlyDenied,
    };

    if (_isDisposed) {
      return;
    }

    if (permission != ScannerPermission.granted) {
      state = state.copyWith(permission: permission);
      // Access can be withdrawn from the settings screen while the app sits in
      // the background, so a refusal has to take a running camera down too.
      // The state goes first: the explanation should be on screen before the
      // hardware round trip, not after it.
      await stopCamera();
      return;
    }

    final camera = _camera ??= MobileScannerController(
      // The preview is started here, after the permission answer, rather
      // than by the widget on mount: a start that races the OS dialog
      // fails, latches its error, and leaves a dead black rectangle.
      autoStart: false,
      detectionTimeoutMs: 250,
      formats: _formats,
    );

    state = ScannerState(permission: ScannerPermission.granted, camera: camera);
    resumeScanning();

    try {
      await camera.start();
    } on MobileScannerException catch (error, stackTrace) {
      // A start that fails for a camera reason is recorded on the controller's
      // own value and drawn by the viewfinder. The one case that throws
      // instead is a controller disposed while the permission dialog was up,
      // which is the dealer leaving the tab: there is nobody left to tell.
      AppLog.warn('Camera could not be started', error, stackTrace);
    }
  }

  ScanOutcome _reject(ScanRejection reason) {
    if (!_isDisposed) {
      state = state.copyWith(isResolving: false);
    }
    return ScanRejected(reason);
  }

  void _releaseCamera() {
    final camera = _camera;
    _camera = null;
    unawaited(camera?.dispose());
  }

  /// The first barcode in [capture] that carries anything at all.
  ///
  /// One frame can hold several codes, and an empty payload is a decode that
  /// only half worked, which is not worth an error message.
  static String? _firstUsableValue(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue?.trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  static Future<void> _write(
    ScanRepository repository, {
    required String productId,
    required UserRole role,
    required ScanSource source,
  }) async {
    try {
      await repository.logScan(
        productId: productId,
        source: source,
        role: role,
      );
    } on Object catch (error, stackTrace) {
      AppLog.warn('Scan could not be logged', error, stackTrace);
    }
  }
}
