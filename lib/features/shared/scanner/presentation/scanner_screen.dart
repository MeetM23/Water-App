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
import '../../../../domain/enums/user_role.dart';
import '../../../../domain/models/catalog_product.dart';
import '../../../../domain/models/product_unit.dart';
import '../../../../domain/repositories/scan_repository.dart';
import '../../../auth/application/session_controller.dart';
import '../application/scanner_controller.dart';
import 'widgets/manual_entry_sheet.dart';
import 'widgets/scanner_overlay.dart';

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
class ScannerScreen extends ConsumerStatefulWidget {
  /// Creates the scanner.
  const ScannerScreen({
    required this.productRoute,
    super.key,
    this.onClose,
  });

  /// Shows a close button that calls this.
  ///
  /// Null when the scanner is a tab, which is the default: a tab has nothing
  /// to close back to.
  final VoidCallback? onClose;

  /// Builds the route to push once a code resolves to a product.
  ///
  /// Required rather than defaulted to one role's path: a default would be a
  /// wholesaler route living inside a component both roles mount, and the day
  /// a caller forgot to pass it a retailer would land on the wholesaler screen.
  final String Function(String productCode) productRoute;

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

  @override
  void initState() {
    super.initState();
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

  void _onRegisterProduct() {
    final session = ref.read(sessionControllerProvider).valueOrNull;
    if (session is SessionSignedIn && session.profile.role == UserRole.owner) {
      context.push(AppRoutes.ownerProductNew);
    } else {
      context.push(AppRoutes.productRegistration);
    }
  }

  void _onClaimWarranty() {
    context.push(AppRoutes.warrantyClaim);
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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scanTitle),
        leading: widget.onClose == null
            ? null
            : IconButton(
                onPressed: widget.onClose,
                icon: const Icon(Icons.close_rounded),
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              ),
      ),
      body: Column(
        children: <Widget>[
          _ThreeActionHeader(
            onRegisterProduct: _onRegisterProduct,
            onClaimWarranty: _onClaimWarranty,
            onScanCode: () {},
          ),
          Expanded(child: _buildViewfinder(state)),
          _BottomControlBar(
            onManualPressed: () => unawaited(_openManualEntry()),
            onGalleryPressed: () => unawaited(_openGalleryScan()),
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

class _BottomControlBar extends StatelessWidget {
  const _BottomControlBar({
    required this.onManualPressed,
    required this.onGalleryPressed,
  });

  final VoidCallback onManualPressed;
  final VoidCallback onGalleryPressed;

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
                  label: l10n.scanManualEntry,
                  onPressed: onManualPressed,
                  variant: AppButtonVariant.secondary,
                  icon: Icons.keyboard_rounded,
                ),
              ),
              const SizedBox(width: Spacing.x3),
              Expanded(
                child: AppButton(
                  label: l10n.scanFromGallery,
                  onPressed: onGalleryPressed,
                  variant: AppButtonVariant.secondary,
                  icon: Icons.photo_library_outlined,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
