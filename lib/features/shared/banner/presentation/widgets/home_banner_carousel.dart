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

  static const List<List<Color>> _testGradients = <List<Color>>[
    <Color>[Color(0xFF0052D4), Color(0xFF4364F7), Color(0xFF6FB1FC)],
    <Color>[Color(0xFF11998E), Color(0xFF38EF7D)],
    <Color>[Color(0xFF8E2DE2), Color(0xFF4A00E0)],
  ];

  static const List<String> _testTitles = <String>[
    'Maruti Water Solution',
    'Genuine RO Components',
    'Premium Quality Filters',
  ];

  @override
  Widget build(BuildContext context) {
    final path = banner.storagePath;

    if (path.isEmpty) {
      return _renderTestBanner(index);
    }

    return BannerImage(
      storagePath: path,
      fit: BoxFit.cover,
      errorBuilder: (_) => _renderTestBanner(index),
    );
  }

  Widget _renderTestBanner(int idx) {
    final colors = _testGradients[idx % _testGradients.length];
    final title = banner.title ?? _testTitles[idx % _testTitles.length];
    final subtitles = <String>[
      'Advanced Multi-Stage Filtration',
      'Original Spare Parts & Systems',
      'ISO Certified RO Technology',
    ];
    final subtitle = subtitles[idx % subtitles.length];

    final badges = <String>[
      'PREMIUM RANGE',
      'SPECIAL OFFER',
      'GENUINE PARTS',
    ];
    final badge = badges[idx % badges.length];

    // Calculate motion offset based on pulseValue (0.0 to 1.0)
    final shift = pulseValue * 12.0;
    final scale = 1.0 + (pulseValue * 0.05);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment(-1.0 + (pulseValue * 0.4), -1.0),
          end: Alignment(1.0, 1.0 - (pulseValue * 0.4)),
        ),
      ),
      child: Stack(
        children: <Widget>[
          // Animated Background decorative glow shapes
          Positioned(
            right: -20 + shift,
            top: -20 - (shift * 0.5),
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.14),
                ),
              ),
            ),
          ),
          Positioned(
            left: -40 - shift,
            bottom: -30 + (shift * 0.5),
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.09),
                ),
              ),
            ),
          ),
          // Content Overlay
          Padding(
            padding: const EdgeInsets.all(Spacing.x4),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Dynamic Animated Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25 + (pulseValue * 0.1)),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4 + (pulseValue * 0.2)),
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: Spacing.x2),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                          shadows: <Shadow>[
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Spacing.x3),
                Transform.scale(
                  scale: 0.95 + (pulseValue * 0.1),
                  child: Container(
                    padding: const EdgeInsets.all(Spacing.x3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.white.withOpacity(0.15 * pulseValue),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.water_drop_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
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
