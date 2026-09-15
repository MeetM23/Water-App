import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../domain/models/dashboard_banner.dart';
import 'banner_image.dart';

/// A stable, production-grade promotional banner carousel for the User Dashboard.
///
/// Lifecycle Rules:
/// - [PageController] created once in [initState] and disposed in [dispose].
/// - [Timer] created once in [initState] (4s interval) and cancelled in [dispose].
/// - Zero network/provider requests inside [build].
/// - Zero timers/controllers created in [build].
class HomeBannerCarousel extends StatefulWidget {
  /// Creates the home banner carousel.
  const HomeBannerCarousel({
    required this.banners,
    super.key,
  });

  /// The list of active banners to display.
  final List<DashboardBanner> banners;

  @override
  State<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<HomeBannerCarousel>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _animController;
  Timer? _timer;
  int _currentPage = 0;

  static const Duration _autoSlideInterval = Duration(milliseconds: 3500);
  static const Duration _animDuration = Duration(milliseconds: 550);
  static const Curve _animCurve = Curves.easeOutCubic;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _startTimer();
  }

  @override
  void didUpdateWidget(covariant HomeBannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.banners.length != oldWidget.banners.length) {
      _resetTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _animController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.banners.length <= 1) return;

    _timer = Timer.periodic(_autoSlideInterval, (_) {
      if (!mounted || !_pageController.hasClients) return;
      final nextPage = (_currentPage + 1) % widget.banners.length;
      _pageController.animateToPage(
        nextPage,
        duration: _animDuration,
        curve: _animCurve,
      );
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.x4,
        vertical: Spacing.x2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Listener(
            onPointerDown: (_) => _resetTimer(),
            child: AspectRatio(
              aspectRatio: 16 / 7,
              child: ClipRRect(
                borderRadius: AppRadius.cardAll,
                child: AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return PageView.builder(
                      controller: _pageController,
                      itemCount: widget.banners.length,
                      onPageChanged: (int index) {
                        if (!mounted) return;
                        setState(() {
                          _currentPage = index;
                        });
                        _resetTimer();
                      },
                      itemBuilder: (BuildContext context, int index) {
                        final banner = widget.banners[index];
                        return _BannerImageTile(
                          banner: banner,
                          index: index,
                          pulseValue: _animController.value,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
          if (widget.banners.length > 1) ...<Widget>[
            const SizedBox(height: Spacing.x2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.banners.length,
                (int index) {
                  final isSelected = _currentPage == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 8,
                    width: isSelected ? 24 : 8,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.disabledFill,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: isSelected
                          ? <BoxShadow>[
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ]
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BannerImageTile extends StatelessWidget {
  const _BannerImageTile({
    required this.banner,
    required this.index,
    this.pulseValue = 0.0,
  });

  final DashboardBanner banner;
  final int index;
  final double pulseValue;

  @override
  Widget build(BuildContext context) {
    final path = banner.storagePath;

    if (path.isEmpty) {
      return const SizedBox.shrink();
    }

    return BannerImage(
      storagePath: path,
      fit: BoxFit.cover,
    );
  }
}
