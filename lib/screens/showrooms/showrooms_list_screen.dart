import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../models/showroom_model.dart';
import '../../repositories/showroom_repository.dart';
import 'showroom_details_screen.dart';
import 'widgets/showroom_card.dart';
import 'widgets/showroom_card_skeleton.dart';
import 'widgets/showroom_search_field.dart';
import 'widgets/showrooms_app_bar.dart';

/// Page "Nos Showrooms" — liste complète des showrooms actifs, entièrement
/// pilotée par Firebase (Dashboard = source de vérité). Recherche dynamique
/// sur nom / ville / adresse / badge, sans aucune donnée figée.
class ShowroomsListScreen extends StatefulWidget {
  const ShowroomsListScreen({super.key});

  @override
  State<ShowroomsListScreen> createState() => _ShowroomsListScreenState();
}

enum _LoadState { loading, loaded, error }

class _ShowroomsListScreenState extends State<ShowroomsListScreen> {
  final ShowroomRepository _repository = FirebaseShowroomRepository();
  final TextEditingController _searchController = TextEditingController();

  _LoadState _state = _LoadState.loading;
  List<ShowroomModel> _allShowrooms = [];
  List<ShowroomModel> _filtered = [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _state = _LoadState.loading);
    try {
      final showrooms = await _repository.getAllActiveShowrooms();
      if (!mounted) return;
      setState(() {
        _allShowrooms = showrooms;
        _filtered = showrooms;
        _state = _LoadState.loaded;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _state = _LoadState.error);
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _query = query;
      final normalized = query.trim().toLowerCase();
      if (normalized.isEmpty) {
        _filtered = _allShowrooms;
        return;
      }
      _filtered = _allShowrooms.where((s) {
        return s.displayName.toLowerCase().contains(normalized) ||
            s.city.toLowerCase().contains(normalized) ||
            s.address.toLowerCase().contains(normalized) ||
            (s.badgeLabel?.toLowerCase().contains(normalized) ?? false);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.srBackground,
      body: SafeArea(
        child: Column(
          children: [
            ShowroomsAppBar(onBack: () => Navigator.of(context).maybePop()),
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: ShowroomSearchField(controller: _searchController, onChanged: _onSearchChanged),
            ),
            const SizedBox(height: 20),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_state) {
      case _LoadState.loading:
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(height: 18),
          itemBuilder: (_, __) => const ShowroomCardSkeleton(),
        );
      case _LoadState.error:
        return _CenteredMessage(
          icon: Icons.wifi_off_rounded,
          message: "Impossible de charger les showrooms pour le moment.",
          actionLabel: 'Réessayer',
          onAction: _load,
        );
      case _LoadState.loaded:
        if (_allShowrooms.isEmpty) {
          return const _CenteredMessage(
            icon: Icons.storefront_outlined,
            message: 'Aucun showroom disponible pour le moment.',
          );
        }
        if (_filtered.isEmpty) {
          return _CenteredMessage(
            icon: Icons.search_off_rounded,
            message: 'Aucun showroom ne correspond à "$_query".',
          );
        }
        return RefreshIndicator(
          onRefresh: _load,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
            itemCount: _filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 18),
            itemBuilder: (context, index) {
              final showroom = _filtered[index];
              return ShowroomCard(
                showroom: showroom,
                onViewDetails: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ShowroomDetailsScreen(showroomId: showroom.id, initialShowroom: showroom),
                  ),
                ),
              );
            },
          ),
        );
    }
  }
}

class _CenteredMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _CenteredMessage({required this.icon, required this.message, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.srTextSecondary, fontSize: 15)),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
