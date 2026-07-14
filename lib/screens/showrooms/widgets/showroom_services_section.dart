import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/showroom_service_model.dart';

/// Section "Services disponibles" : rend uniquement les services actifs de
/// [showroom.services] (Firebase). Section masquée si aucun service.
class ShowroomServicesSection extends StatelessWidget {
  final List<ShowroomService> services;

  const ShowroomServicesSection({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Services disponibles',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: AppColors.srNameText),
        ),
        const SizedBox(height: 17),
        SizedBox(
          height: 108,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: services.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) => _ServiceCard(service: services[i]),
          ),
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ShowroomService service;

  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 118,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.srBackground,
        border: Border.all(color: AppColors.srBorder, width: 1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ServiceIcon(service: service),
          const SizedBox(height: 10),
          Text(
            service.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.srNameText),
          ),
        ],
      ),
    );
  }
}

class _ServiceIcon extends StatelessWidget {
  final ShowroomService service;

  const _ServiceIcon({required this.service});

  @override
  Widget build(BuildContext context) {
    if (service.iconUrl != null) {
      return CachedNetworkImage(
        imageUrl: service.iconUrl!,
        width: 36,
        height: 36,
        fit: BoxFit.contain,
        errorWidget: (_, __, ___) => const Icon(Icons.check_circle_outline, size: 32, color: AppColors.srNavy),
      );
    }
    if (service.emoji != null) {
      return Text(service.emoji!, style: const TextStyle(fontSize: 32));
    }
    return const Icon(Icons.check_circle_outline, size: 32, color: AppColors.srNavy);
  }
}
