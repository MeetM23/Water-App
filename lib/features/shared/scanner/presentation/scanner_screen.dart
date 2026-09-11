import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/media_permissions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../domain/models/catalog_product.dart';
import '../../../../domain/models/product_unit.dart';
import '../../../../domain/repositories/scan_repository.dart';
import '../application/scanner_controller.dart';
import 'widgets/manual_entry_sheet.dart';
import 'widgets/scanner_overlay.dart';

/// Controls what the scanner does when a code is decoded.
///
/// [general] — the default tab mode. MWS-DOM opens the product detail,
/// MWS-SN opens the unit detail. All three action tiles are shown.
///
/// [registerProduct] — serial-only mode. Only MWS-SN codes are accepted.
/// A successful scan pushes the Register Product form with the serial
/// pre-filled. MWS-DOM codes show an inline explanation. Action tiles
/// are hidden and the header reads "Scan Physical Unit".
///
/// [warrantyClaim] — identical to [registerProduct] but pushes the
/// Claim/Warranty form instead.
enum ScanMode {
  /// General catalogue + unit scan. Full action tile row shown.
  general,

  /// Physical-unit serial scan for product registration (MWS-SN only).
  registerProduct,

  /// Physical-unit serial scan for warranty claims (MWS-SN only).
  warrantyClaim,
}

/// The barcode scanner.
///
/// Written as a tab first, because that is the hard case. It is the middle tab
/// of the dealer shell, so it stays mounted while the dealer reads the
/// catalogue and must hand the camera back for that whole time; being mounted
/// is not the same as being looked at. It also has to survive the phone being
/// locked mid-scan and come back without a second permission prompt.
///
/// Nothing in here is specific to one dealer role. The route a resolved code
/// opens is the single difference between them, and it is a parameter.
///
/// When [mode] is [ScanMode.registerProduct] or [ScanMode.warrantyClaim] the
/// scanner operates as a serial-capture widget: it only accepts MWS-SN codes,
/// shows a purpose-specific header, hides the action tile row, and pushes the
/// appropriate form screen with the serial pre-filled. This eliminates the
/// need for any nested scanner implementation inside the form screens.
class ScannerScreen extends ConsumerStatefulWidget {
  /// Creates the scanner.
  const ScannerScreen({
    required this.productRoute,
    super.key,
    this.onClose,
    this.mode = ScanMode.general,
  });

  /// Shows a close/back button that calls this.
  ///
  /// Null when the scanner is a tab, which is the default: a tab has nothing
  /// to close back to.
  final VoidCallback? onClose;

  /// Builds the route to push once a code resolves to a product.
  ///
  /// Required rather than defaulted to one role's path: a default would be a
  /// wholesaler route living inside a component both roles mount, and the day
  /// a caller forgot to pass it a retailer would land on the wholesaler screen.
  ///
  /// Ignored when [mode] is not [ScanMode.general].
  final String Function(String productCode) productRoute;

  /// Controls what happens when a code is decoded. Defaults to [ScanMode.general].
  final ScanMode mode;

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen>
    with WidgetsBindingObserver {
  /// Taken once, in [initState], rather than read where each caller needs it.
  ///
  /// [dispose] is one of those callers, and `ref` throws the moment the
  /// element is unmounted — which is precisely when the camera has to be
  /// handed back. Nothing invalidates this provider, so the instance is the
  /// same one a later read would return.
  late final ScannerController _scanner;

  ValueListenable<bool>? _visibility;
  bool _isVisible = true;

  /// Current scan mode — can be changed in-place without pushing a new route.
  late ScanMode _mode;

  @override
  void initState() {
    super.initState();
    _mode = widget.mode;
    _scanner = ref.read(scannerControllerProvider.notifier);
    WidgetsBinding.instance.addObserver(this);
    // Deferred by a frame: asking for the camera during the first build races
    // the route transition, and a permission dialog raised in the middle of
    // one can be dismissed by it before the dealer has read a word.
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      unawaited(_activate());
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // A shell keeps every branch mounted and merely takes the inactive ones
    // off stage, so `mounted` says nothing about whether this tab is on
    // screen. TickerMode is the flag that does flip, and watching it is what
    // releases the camera the moment the dealer switches to the catalogue.
    final notifier = TickerMode.getNotifier(context);
    if (notifier == _visibility) {
      return;
    }
    _visibility?.removeListener(_handleVisibilityChanged);
    _visibility = notifier..addListener(_handleVisibilityChanged);
    _isVisible = notifier.value;
  }

  @override
  void dispose() {
    _visibility?.removeListener(_handleVisibilityChanged);
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_scanner.stopCamera());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // Back through the permission request rather than straight to a
        // start: access can have been withdrawn on the settings screen the
        // dealer has just come back from.
        unawaited(_activate());
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        unawaited(_deactivate());
    }
  }

  void _handleVisibilityChanged() {
    final isVisible = _visibility?.value ?? true;
    if (isVisible == _isVisible) {
      return;
    }
    _isVisible = isVisible;
    unawaited(isVisible ? _activate() : _deactivate());
  }

  Future<void> _activate() async {
    if (!mounted || !_isVisible) {
      return;
    }
    await _scanner.startCamera();
  }

  Future<void> _deactivate() => _scanner.stopCamera();

  Future<void> _handleDetection(BarcodeCapture capture) async {
    final admission = _scanner.admitDetection(capture);

    switch (admission) {
      case null:
        return;
      case ScanRefused(:final reason):
        _reject(reason);
      case ScanAdmitted(:final code):
        // Confirmed the moment the code passes the local check rather than
        // when the lookup answers: the dealer needs to know they can lower the
        // phone, and on a weak connection that is a second or two earlier.
        unawaited(HapticFeedback.mediumImpact());
        unawaited(SystemSound.play(SystemSoundType.click));
        await _resolve(code, ScanSource.camera);
    }
  }

  Future<void> _resolve(String code, ScanSource source) async {
    // Serial-only modes: accept MWS-SN, reject everything else with a
    // clear explanation rather than the generic "invalid code" message.
    if (_mode == ScanMode.registerProduct || _mode == ScanMode.warrantyClaim) {
      await _resolveSerialOnly(code);
      return;
    }

    // General mode: existing product + unit routing.
    final outcome = await _scanner.resolve(code);
    if (!mounted) {
      return;
    }

    switch (outcome) {
      case ScanMatched(:final product):
        await _openProduct(product, source);
      case ScanUnitMatched(:final unit):
        await _openUnit(unit, source);
      case ScanRejected(:final reason):
        _reject(reason);
    }
  }

  /// Handles a detected code when the scanner is in a serial-only mode.
  ///
  /// MWS-SN codes are forwarded to the appropriate form screen.
  /// Handles a detected code when the scanner is in a mode like registerProduct or warrantyClaim.
  ///
  /// Accepts any machine or product code (MWS-SN, MWS-DOM, or custom barcode/serial) and
  /// passes it directly to the target registration/claim form.
  Future<void> _resolveSerialOnly(String code) async {
    final upper = code.trim().toUpperCase();
    if (upper.isEmpty) {
      _scanner.resumeScanning();
      if (!mounted) return;
      AppSnackbar.error(context, 'Invalid code scanned.');
      return;
    }

    // Stop camera and navigate to the appropriate form.
    await _scanner.stopCamera();
    if (!mounted) return;

    final route = _mode == ScanMode.registerProduct
        ? '${AppRoutes.productRegistration}?serialNumber=$upper'
        : '${AppRoutes.warrantyClaim}?serialNumber=$upper';

    context.push(route);

    if (mounted) {
      setState(() => _mode = ScanMode.general);
      _scanner.resumeScanning();
      await _activate();
    }
  }

  void _reject(ScanRejection reason) {
    unawaited(HapticFeedback.heavyImpact());
    // The screen stays on the camera. A dealer working down a shelf catches
    // the wrong box regularly, and being thrown out of the scanner every time
    // would cost far more than the mistake did.
    AppSnackbar.error(context, reason.message(context.l10n));
  }

  Future<void> _openProduct(CatalogProduct product, ScanSource source) async {
    _scanner.recordScan(product, source);

    // The camera is released before the push rather than left running behind
    // the product screen: it is the largest single power draw in the app and
    // nothing on the other side of the push has any use for it.
    await _scanner.stopCamera();
    if (!mounted) {
      return;
    }

    await context.push<void>(widget.productRoute(product.productCode));
    if (!mounted) {
      return;
    }

    _scanner.resumeScanning();
    await _activate();
  }

  Future<void> _openUnit(ProductUnit unit, ScanSource source) async {
    _scanner.recordScanForUnit(unit, source);

    await _scanner.stopCamera();
    if (!mounted) {
      return;
    }

    await context.push<void>('/unit/${unit.serialNumber}');
    if (!mounted) {
      return;
    }

    _scanner.resumeScanning();
    await _activate();
  }

  Future<void> _openManualEntry() async {
    await _deactivate();
    if (!mounted) {
      return;
    }

    // In serial-only modes, the manual entry sheet should accept serial
    // numbers and resolve them directly.
    if (_mode == ScanMode.registerProduct || _mode == ScanMode.warrantyClaim) {
      await _openManualSerialEntry();
      return;
    }

    final product = await ManualEntrySheet.show(context);
    if (!mounted) {
      return;
    }

    if (product == null) {
      _scanner.resumeScanning();
      await _activate();
      return;
    }

    await _openProduct(product, ScanSource.manual);
  }

  /// Shows a text input for the physical unit serial (MWS-SN) in serial modes.
  Future<void> _openManualSerialEntry() async {
    final serial = await showDialog<String>(
      context: context,
      builder: (dialogContext) => _SerialEntryDialog(
        mode: _mode,
      ),
    );
    if (!mounted) return;

    if (serial == null || serial.trim().isEmpty) {
      _scanner.resumeScanning();
      await _activate();
      return;
    }

    await _resolveSerialOnly(serial.trim());
  }

  Future<void> _openGalleryScan() async {
    await _deactivate();
    if (!mounted) return;

    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) {
        _scanner.resumeScanning();
        await _activate();
        return;
      }

      final controller = MobileScannerController();
      try {
        final capture = await controller.analyzeImage(image.path);
        if (capture == null || capture.barcodes.isEmpty) {
          if (mounted) {
            AppSnackbar.error(context, context.l10n.scanNoQrFound);
          }
          return;
        }

        if (capture.barcodes.length > 1) {
          if (mounted) {
            AppSnackbar.error(context, context.l10n.scanMultipleQrFound);
          }
          return;
        }

        final code =
            capture.barcodes.first.rawValue ??
            capture.barcodes.first.displayValue;
        if (code == null || code.trim().isEmpty) {
          if (mounted) {
            AppSnackbar.error(context, context.l10n.scanInvalidCode);
          }
          return;
        }

        await _resolve(code.trim(), ScanSource.manual);
      } finally {
        await controller.dispose();
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, context.l10n.scanNoQrFound);
      }
    } finally {
      if (mounted) {
        _scanner.resumeScanning();
        await _activate();
      }
    }
  }

  /// Switches to Register Product mode in-place (called from action tile).
  void _switchToRegisterMode() {
    setState(() => _mode = ScanMode.registerProduct);
  }

  /// Switches to Claim/Warranty mode in-place (called from action tile).
  void _switchToClaimMode() {
    setState(() => _mode = ScanMode.warrantyClaim);
  }

  /// Returns to general mode (called when the mode banner back arrow is tapped).
  void _resetToGeneralMode() {
    setState(() => _mode = ScanMode.general);
  }

  Future<void> _openSettings() async {
    final opened = await MediaPermissions.openSettings();
    if (!mounted || opened) {
      return;
    }
    AppSnackbar.error(context, context.l10n.permissionSettingsFailed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(scannerControllerProvider);
    final isSerialMode = _mode != ScanMode.general;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isSerialMode ? 'Scan Physical Unit' : l10n.scanTitle,
        ),
        leading: widget.onClose != null
            ? IconButton(
                onPressed: widget.onClose,
                icon: const Icon(Icons.close_rounded),
                tooltip:
                    MaterialLocalizations.of(context).closeButtonTooltip,
              )
            : isSerialMode
                // In-place mode: show back arrow to return to general mode.
                ? IconButton(
                    onPressed: _resetToGeneralMode,
                    icon: const Icon(Icons.arrow_back_rounded),
                    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  )
                : null,
      ),
      body: Column(
        children: <Widget>[
          // Mode banner — shown in serial modes to explain the purpose.
          if (isSerialMode)
            _ModeBanner(mode: _mode)
          else
            // Action tiles — only shown in general mode.
            _ThreeActionHeader(
              onRegisterProduct: _switchToRegisterMode,
              onClaimWarranty: _switchToClaimMode,
              onScanCode: () {}, // already in general mode
            ),
          Expanded(child: _buildViewfinder(state)),
          _BottomControlBar(
            onManualPressed: () => unawaited(_openManualEntry()),
            onGalleryPressed: () => unawaited(_openGalleryScan()),
            isSerialMode: isSerialMode,
          ),
        ],
      ),
    );
  }

  Widget _buildViewfinder(ScannerState state) {
    final l10n = context.l10n;

    switch (state.permission) {
      case ScannerPermission.unknown:
        return const _CameraPlaceholder();
      case ScannerPermission.denied:
        return AppEmptyState(
          icon: Icons.photo_camera_outlined,
          title: l10n.scanPermissionTitle,
          message: l10n.scanPermissionBody,
          actionLabel: l10n.actionRetry,
          onAction: () => unawaited(_activate()),
        );
      case ScannerPermission.permanentlyDenied:
        return AppEmptyState(
          icon: Icons.photo_camera_outlined,
          title: l10n.scanPermissionTitle,
          message: l10n.scanPermissionDeniedBody,
          actionLabel: l10n.permissionOpenSettings,
          onAction: () => unawaited(_openSettings()),
        );
      case ScannerPermission.granted:
        final camera = state.camera;
        if (camera == null) {
          return const _CameraPlaceholder();
        }
        return _Viewfinder(
          camera: camera,
          isResolving: state.isResolving,
          onDetect: (BarcodeCapture capture) =>
              unawaited(_handleDetection(capture)),
          onRetry: () => unawaited(_scanner.retryCamera()),
          onToggleTorch: () => unawaited(_scanner.toggleTorch()),
          onSwitchCamera: () => unawaited(_scanner.switchCamera()),
        );
    }
  }
}

// ---------------------------------------------------------------------------
// Mode banner
// ---------------------------------------------------------------------------

/// Shown in [ScanMode.registerProduct] and [ScanMode.warrantyClaim] to
/// explain what the scanner is looking for.
class _ModeBanner extends StatelessWidget {
  const _ModeBanner({required this.mode});

  final ScanMode mode;

  @override
  Widget build(BuildContext context) {
    final isRegister = mode == ScanMode.registerProduct;
    return Container(
      width: double.infinity,
      color: AppColors.primary.withOpacity(0.08),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.x4,
        vertical: Spacing.x3,
      ),
      child: Row(
        children: <Widget>[
          Icon(
            isRegister
                ? Icons.add_box_outlined
                : Icons.build_circle_outlined,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: Spacing.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  isRegister ? 'Register Product' : 'Claim / Warranty',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Scan the QR label or code on the machine or product box',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary.withOpacity(0.8),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Viewfinder
// ---------------------------------------------------------------------------

class _Viewfinder extends StatelessWidget {
  const _Viewfinder({
    required this.camera,
    required this.isResolving,
    required this.onDetect,
    required this.onRetry,
    required this.onToggleTorch,
    required this.onSwitchCamera,
  });

  /// How far the scan window must resize before the platform is told about it.
  ///
  /// Every layout pass recomputes the rectangle, and the system bars settling
  /// or the shell's bottom bar animating produces a run of them that differ by
  /// a pixel or two. Each one would otherwise cross the platform channel and
  /// reconfigure the decoder mid-scan.
  static const double _scanWindowThreshold = 12;

  final MobileScannerController camera;
  final bool isResolving;
  final void Function(BarcodeCapture capture) onDetect;
  final VoidCallback onRetry;
  final VoidCallback onToggleTorch;
  final VoidCallback onSwitchCamera;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ValueListenableBuilder<MobileScannerState>(
      valueListenable: camera,
      builder: (BuildContext context, MobileScannerState state, Widget? child) {
        if (state.error != null) {
          return AppEmptyState(
            icon: Icons.videocam_off_outlined,
            title: l10n.scanCameraFailed,
            message: l10n.errorGenericBody,
            actionLabel: l10n.actionRetry,
            onAction: onRetry,
          );
        }

        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            // One rectangle drives both the drawing and the decoding, so
            // what the dealer aims at is exactly what gets read and a
            // neighbouring label cannot answer for the one in the frame.
            final window = ScannerOverlay.windowFor(constraints.biggest);

            return Stack(
              fit: StackFit.expand,
              children: <Widget>[
                MobileScanner(
                  // Keyed on the controller so replacing a failed camera
                  // builds a fresh state: the preview binds its barcode
                  // subscription once, to whichever controller it was
                  // first given.
                  key: ValueKey<MobileScannerController>(camera),
                  controller: camera,
                  onDetect: onDetect,
                  scanWindow: window,
                  scanWindowUpdateThreshold: _scanWindowThreshold,
                  // The camera-failure state is handled above, on the same
                  // notifier, so only the pre-initialisation gap reaches
                  // here — it must not flash the package's black error card.
                  placeholderBuilder: (BuildContext context, Widget? child) =>
                      const _CameraPlaceholder(),
                ),
                ScannerOverlay(window: window),
                Positioned(
                  top: window.bottom + Spacing.x5,
                  left: Spacing.x5,
                  right: Spacing.x5,
                  child: isResolving
                      ? _SearchingPill(label: l10n.scanSearching)
                      : _ScanHint(label: l10n.scanHint),
                ),
                Positioned(
                  top: Spacing.x4,
                  right: Spacing.x4,
                  child: _CameraControls(
                    torchState: state.torchState,
                    canSwitchCamera: (state.availableCameras ?? 1) > 1,
                    onToggleTorch: onToggleTorch,
                    onSwitchCamera: onSwitchCamera,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Camera controls
// ---------------------------------------------------------------------------

class _CameraControls extends StatelessWidget {
  const _CameraControls({
    required this.torchState,
    required this.canSwitchCamera,
    required this.onToggleTorch,
    required this.onSwitchCamera,
  });

  final TorchState torchState;
  final bool canSwitchCamera;
  final VoidCallback onToggleTorch;
  final VoidCallback onSwitchCamera;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isTorchOn = torchState == TorchState.on;

    return Column(
      children: <Widget>[
        // A phone with no torch is not a broken phone, so the control simply
        // is not there rather than sitting greyed out asking to be tapped.
        if (torchState != TorchState.unavailable)
          _CameraButton(
            icon: isTorchOn
                ? Icons.flashlight_on_rounded
                : Icons.flashlight_off_rounded,
            tooltip: isTorchOn ? l10n.scanTorchOff : l10n.scanTorchOn,
            isActive: isTorchOn,
            onPressed: onToggleTorch,
          ),
        if (canSwitchCamera) ...<Widget>[
          const SizedBox(height: Spacing.x3),
          _CameraButton(
            icon: Icons.cameraswitch_rounded,
            tooltip: l10n.scanFlipCamera,
            onPressed: onSwitchCamera,
          ),
        ],
      ],
    );
  }
}

class _CameraButton extends StatelessWidget {
  const _CameraButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.isActive = false,
  });

  /// Comfortably past the minimum tap target, on a surface where the finger
  /// is also holding the phone steady against a shelf.
  static const double _size = Spacing.x10 + Spacing.x2;

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: isActive
            ? AppColors.primary
            : AppColors.ink.withOpacity(0.55),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            height: _size,
            width: _size,
            child: Icon(icon, size: 20, color: AppColors.surface),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Scan hint / searching pill
// ---------------------------------------------------------------------------

class _ScanHint extends StatelessWidget {
  const _ScanHint({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: TextAlign.center,
      style: context.textTheme.bodyMedium?.copyWith(color: AppColors.surface),
    );
  }
}

class _SearchingPill extends StatelessWidget {
  const _SearchingPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.pillAll,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.x4,
            vertical: Spacing.x2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(
                height: 14,
                width: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: Spacing.x3),
              // Flexible rather than fixed: the Gujarati string is half again
              // as long as the English one, and at the largest system text
              // size it does not fit a 320dp screen on one line.
              Flexible(
                child: Text(
                  label,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Camera placeholder
// ---------------------------------------------------------------------------

class _CameraPlaceholder extends StatelessWidget {
  const _CameraPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.ink,
      child: Center(
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.surface,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Three-action header (general mode only)
// ---------------------------------------------------------------------------

class _ThreeActionHeader extends StatelessWidget {
  const _ThreeActionHeader({
    required this.onRegisterProduct,
    required this.onClaimWarranty,
    required this.onScanCode,
  });

  final VoidCallback onRegisterProduct;
  final VoidCallback onClaimWarranty;
  final VoidCallback onScanCode;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.x3,
        Spacing.x2,
        Spacing.x3,
        Spacing.x2,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _ActionTile(
              label: l10n.scanOptionRegisterProduct,
              icon: Icons.add_box_outlined,
              onTap: onRegisterProduct,
            ),
          ),
          const SizedBox(width: Spacing.x2),
          Expanded(
            child: _ActionTile(
              label: l10n.scanOptionClaimWarranty,
              icon: Icons.build_circle_outlined,
              onTap: onClaimWarranty,
            ),
          ),
          const SizedBox(width: Spacing.x2),
          Expanded(
            child: _ActionTile(
              label: l10n.scanOptionScanCode,
              icon: Icons.qr_code_scanner_rounded,
              isPrimary: true,
              onTap: onScanCode,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? AppColors.primary : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Spacing.x2),
        side: isPrimary
            ? BorderSide.none
            : const BorderSide(color: AppColors.border),
      ),
      elevation: isPrimary ? 1 : 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.x2,
            vertical: Spacing.x2,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                size: 20,
                color: isPrimary ? Colors.white : AppColors.primary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.labelSmall?.copyWith(
                  color: isPrimary ? Colors.white : AppColors.ink,
                  fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom control bar
// ---------------------------------------------------------------------------

class _BottomControlBar extends StatelessWidget {
  const _BottomControlBar({
    required this.onManualPressed,
    required this.onGalleryPressed,
    required this.isSerialMode,
  });

  final VoidCallback onManualPressed;
  final VoidCallback onGalleryPressed;
  final bool isSerialMode;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.x3),
          child: Row(
            children: <Widget>[
              Expanded(
                child: AppButton(
                  label: isSerialMode
                      ? 'Enter Serial Manually'
                      : l10n.scanManualEntry,
                  icon: Icons.keyboard_outlined,
                  onPressed: onManualPressed,
                  variant: AppButtonVariant.secondary,
                ),
              ),
              const SizedBox(width: Spacing.x3),
              Expanded(
                child: AppButton(
                  label: l10n.scanFromGallery,
                  icon: Icons.photo_library_outlined,
                  onPressed: onGalleryPressed,
                  variant: AppButtonVariant.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Serial entry dialog (for manual entry in serial modes)
// ---------------------------------------------------------------------------

/// A simple dialog for manually entering a physical unit serial number (MWS-SN).
/// Used in [ScanMode.registerProduct] and [ScanMode.warrantyClaim] modes.
class _SerialEntryDialog extends StatefulWidget {
  const _SerialEntryDialog({required this.mode});

  final ScanMode mode;

  @override
  State<_SerialEntryDialog> createState() => _SerialEntryDialogState();
}

class _SerialEntryDialogState extends State<_SerialEntryDialog> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRegister = widget.mode == ScanMode.registerProduct;
    return AlertDialog(
      title: Text(isRegister ? 'Enter Unit Serial' : 'Enter Unit Serial'),
      content: TextField(
        controller: _controller,
        focusNode: _focusNode,
        textCapitalization: TextCapitalization.characters,
        decoration: const InputDecoration(
          labelText: 'Physical Unit Serial (MWS-SN-...)',
          hintText: 'e.g. MWS-SN-DOM-001001-K',
          prefixIcon: Icon(Icons.confirmation_number_outlined),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Look Up'),
        ),
      ],
    );
  }

  void _submit() {
    final serial = _controller.text.trim();
    Navigator.of(context).pop(serial.isEmpty ? null : serial);
  }
}
