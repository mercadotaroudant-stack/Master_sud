import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../models/banner_model.dart';

/// Banner Slider مع Auto Slide + Indicator، البيانات قادمة من Firebase.
class BannerSlider extends StatefulWidget {
  final List<BannerModel> banners;
  final ValueChanged<BannerModel>? onTap;

  const BannerSlider({super.key, required this.banners, this.onTap});

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  late final PageController _controller;
  int _currentPage = 0;
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    if (widget.banners.length <= 1) return;
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_currentPage + 1) % widget.banners.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: AppDimens.bannerHeight,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.banners.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMd),
                child: GestureDetector(
                  onTap: () => widget.onTap?.call(banner),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                    child: CachedNetworkImage(
                      imageUrl: banner.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (_, __) => Container(color: AppColors.shimmerBase),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.shimmerBase,
                        child: const Icon(Icons.image_not_supported_outlined, color: AppColors.textMuted),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppDimens.paddingSm),
        if (widget.banners.length > 1)
          SmoothPageIndicator(
            controller: _controller,
            count: widget.banners.length,
            effect: const WormEffect(
              dotHeight: 6,
              dotWidth: 6,
              activeDotColor: AppColors.primary,
              dotColor: AppColors.border,
            ),
          ),
      ],
    );
  }
}
