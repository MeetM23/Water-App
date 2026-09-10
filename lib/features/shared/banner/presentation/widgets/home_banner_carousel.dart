import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../domain/models/dashboard_banner.dart';

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

class _HomeBannerCarouselState extends State<HomeBannerCarousel> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  static const Duration _autoSlideInterval = Duration(seconds: 4);
  static const Duration _animDuration = Duration(milliseconds: 450);
  static const Curve _animCurve = Curves.fastOutSlowIn;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
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
                child: PageView.builder(
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
                    return _BannerImageTile(banner: banner, index: index);
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
                (int index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 7,
                  width: _currentPage == index ? 20 : 7,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.primary
                        : AppColors.disabledFill,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
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
  });

  final DashboardBanner banner;
  final int index;

  static const List<List<Color>> _testGradients = <List<Color>>[
    <Color>[Color(0xFF0052D4), Color(0xFF4364F7), Color(0xFF6FB1FC)],
    <Color>[Color(0xFF11998E), Color(0xFF38EF7D)],
    <Color>[Color(0xFF8E2DE2), Color(0xFF4A00E0)],
  ];

  static const List<String> _testTitles = <String>[
    'BANNER 1 — Pure Water Solution',
    'BANNER 2 — Genuine RO Components',
    'BANNER 3 — Premium Quality Filters',
  ];

  @override
  Widget build(BuildContext context) {
    final path = banner.storagePath;

    // 1. Local Test Banner fallback
    if (path.startsWith('test_banner_') || path.isEmpty) {
      return _renderTestBanner(index);
    }

    // 2. Direct File Path
    if (path.startsWith('/') || path.contains('\\') || File(path).existsSync()) {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _renderTestBanner(index),
        );
      }
    }

    // 3. Remote URL
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: AppColors.border,
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => _renderTestBanner(index),
      );
    }

    // Fallback: render test banner
    return _renderTestBanner(index);
  }

  Widget _renderTestBanner(int idx) {
    final colors = _testGradients[idx % _testGradients.length];
    final title = banner.title ?? _testTitles[idx % _testTitles.length];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.water_drop_rounded, color: Colors.white, size: 38),
            const SizedBox(height: Spacing.x2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.x4),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
