import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/banner_controller.dart';
import 'home_banner_carousel.dart';

/// User Dashboard promotional image carousel widget.
///
/// Wraps [HomeBannerCarousel] and connects it to the fail-safe [activeBannersProvider].
class BannerCarouselWidget extends ConsumerWidget {
  /// Creates the banner carousel widget.
  const BannerCarouselWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final banners = ref.watch(activeBannersProvider);
    return HomeBannerCarousel(banners: banners);
  }
}
