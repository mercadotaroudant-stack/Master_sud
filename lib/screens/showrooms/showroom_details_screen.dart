import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../models/showroom_model.dart';
import '../../providers/favorites_provider.dart';
import '../../repositories/showroom_repository.dart';
import 'widgets/showroom_about_section.dart';
import 'widgets/showroom_details_app_bar.dart';
import 'widgets/showroom_details_bottom_actions.dart';
import 'widgets/showroom_details_hero.dart';
import 'widgets/showroom_details_skeleton.dart';
import 'widgets/showroom_gallery_section.dart';
import 'widgets/showroom_hours_card.dart';
import 'widgets/showroom_location_card.dart';
import 'widgets/showroom_phone_card.dart';
import 'widgets/showroom_services_section.dart';

/// Page "Détails du showroom", chargée à partir de son ID Firebase réel
/// (showroom.id). Aucune donnée fictive : tout provient de Firestore et est
/// géré depuis le Dashboard.
class ShowroomDetailsScreen extends StatefulWidget {
  final String showroomId;
  final ShowroomModel? initialShowroom;

  const ShowroomDetailsScreen({super.key, required this.showroomId, this.initialShowroom});

  @override
  State<ShowroomDetailsScreen> createState() => _ShowroomDetailsScreenState();
}

enum _LoadState { loading, loaded, unavailable, error }

class _ShowroomDetailsScreenState extends State<ShowroomDetailsScreen> {
  final ShowroomRepository _repository = FirebaseShowroomRepository();

  _LoadState _state = _LoadState.loading;
  ShowroomModel? _showroom;

  @override
  void initState() {
    super.initState();
    if (widget.initialShowroom != null) {
      _applyResult(widget.initialShowroom);
    } else {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() => _state = _LoadState.loading);
    try {
      final showroom = await _repository.getShowroomById(widget.showroomId);
      if (!mounted) return;
      _applyResult(showroom);
    } catch (_) {
      if (!mounted) return;
      setState(() => _state = _LoadState.error);
    }
  }

  void _applyResult(ShowroomModel? showroom) {
    if (showroom == null || !showroom.active) {
      setState(() => _state = _LoadState.unavailable);
      return;
    }
    setState(() {
      _showroom = showroom;
      _state = _LoadState.loaded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isFavorite = _showroom != null && context.watch<FavoritesProvider>().isFavorite('showroom', _showroom!.id);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            ShowroomDetailsAppBar(
              onBack: () => Navigator.of(context).maybePop(),
              isFavorite: isFavorite,
              onFavoritePressed: () {
                if (_showroom != null) context.read<FavoritesProvider>().toggle('showroom', _showroom!.id);
              },
            ),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_state) {
      case _LoadState.loading:
        return const ShowroomDetailsSkeleton();
      case _LoadState.error:
        return _MessageState(message: 'Impossible de charger le showroom.', actionLabel: 'Réessayer', onAction: _load);
      case _LoadState.unavailable:
        return _MessageState(
          message: "Ce showroom n'est pas disponible.",
          actionLabel: 'Retour',
          onAction: () => Navigator.of(context).maybePop(),
        );
      case _LoadState.loaded:
        return _buildContent(context, _showroom!);
    }
  }

  Widget _buildContent(BuildContext context, ShowroomModel showroom) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        ShowroomDetailsHero(imageUrl: showroom.image, title: showroom.city),
        Padding(
          padding: const EdgeInsets.fromLTRB(17, 24, 17, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.location_on, size: 20, color: AppColors.srDetailsRed),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      showroom.displayName,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.srNameText),
                    ),
                  ),
                ],
              ),
              if (showroom.address.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.home_outlined, size: 18, color: AppColors.srTextSecondary),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        showroom.address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 17, color: AppColors.srTextSecondary, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 22),
              ShowroomPhoneCard(showroom: showroom),
              if (showroom.hasPhone) const SizedBox(height: 13),
              ShowroomLocationCard(showroom: showroom),
              if (showroom.hasLocation) const SizedBox(height: 13),
              ShowroomHoursCard(showroom: showroom),
              const SizedBox(height: 28),
              ShowroomServicesSection(services: showroom.activeServices),
              if (showroom.activeServices.isNotEmpty) const SizedBox(height: 30),
              ShowroomAboutSection(description: showroom.description),
              if (showroom.hasDescription) const SizedBox(height: 30),
              ShowroomGallerySection(images: showroom.galleryImages),
              if (showroom.hasGallery) const SizedBox(height: 24),
              ShowroomDetailsBottomActions(showroom: showroom),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}

class _MessageState extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _MessageState({required this.message, required this.actionLabel, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.storefront_outlined, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.srTextSecondary, fontSize: 15)),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
