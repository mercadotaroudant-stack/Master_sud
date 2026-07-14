import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../models/paint_catalogue_model.dart';
import '../../repositories/paint_catalogue_repository.dart';
import 'catalogue_colors_screen.dart';
import 'widgets/catalogue_app_bar.dart';
import 'widgets/catalogue_card.dart';
import 'widgets/catalogue_card_skeleton.dart';
import 'widgets/catalogue_empty_state.dart';
import 'widgets/catalogue_search_field.dart';

/// Page principale de la section CATALOGUE : grille 2 colonnes de
/// catalogues (couverture 9:16 façon Reels/Stories) + recherche par nom.
/// Toutes les données proviennent de Firestore en temps réel — le
/// Dashboard reste la seule source de vérité.
class CatalogueListScreen extends StatefulWidget {
  const CatalogueListScreen({super.key});

  @override
  State<CatalogueListScreen> createState() => _CatalogueListScreenState();
}

class _CatalogueListScreenState extends State<CatalogueListScreen> {
  final PaintCatalogueRepository _repository = FirebasePaintCatalogueRepository();
  final TextEditingController _searchController = TextEditingController();

  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() => _query = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ctBackground,
      body: SafeArea(
        child: Column(
          children: [
            CatalogueAppBar(title: 'Catalogue', onBack: () => Navigator.of(context).maybePop()),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: CatalogueSearchField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                hintText: 'Rechercher un catalogue...',
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<PaintCatalogueModel>>(
                stream: _repository.streamActiveCatalogues(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildSkeletonGrid();
                  }
                  if (snapshot.hasError) {
                    return const CatalogueEmptyState(
                      icon: Icons.wifi_off_rounded,
                      message: 'Impossible de charger les catalogues pour le moment.',
                    );
                  }

                  final all = snapshot.data ?? [];
                  if (all.isEmpty) {
                    return const CatalogueEmptyState(
                      icon: Icons.menu_book_outlined,
                      message: 'Aucun catalogue disponible pour le moment.',
                    );
                  }

                  final normalized = _query.trim().toLowerCase();
                  final filtered = normalized.isEmpty
                      ? all
                      : all.where((c) => c.name.toLowerCase().contains(normalized)).toList();

                  if (filtered.isEmpty) {
                    return CatalogueEmptyState(
                      icon: Icons.search_off_rounded,
                      message: 'Aucun catalogue ne correspond à "$_query".',
                    );
                  }

                  return _buildGrid(filtered);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(List<PaintCatalogueModel> catalogues) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const horizontalPadding = 32.0; // 16px de chaque côté de la grille
        const crossAxisSpacing = 13.0;
        const mainAxisSpacing = 17.0;
        final columnWidth = (constraints.maxWidth - horizontalPadding - crossAxisSpacing) / 2;
        // Ratio image 9:16 + zone de titre de 60px sous l'image.
        final cardHeight = (columnWidth * 16 / 9) + 60;
        final childAspectRatio = columnWidth / cardHeight;

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          physics: const AlwaysScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: catalogues.length,
          itemBuilder: (context, index) {
            final catalogue = catalogues[index];
            return CatalogueCard(
              catalogue: catalogue,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CatalogueColorsScreen(
                    catalogueId: catalogue.id,
                    initialCatalogue: catalogue,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSkeletonGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const horizontalPadding = 32.0; // 16px de chaque côté de la grille
        const crossAxisSpacing = 13.0;
        const mainAxisSpacing = 17.0;
        final columnWidth = (constraints.maxWidth - horizontalPadding - crossAxisSpacing) / 2;
        final cardHeight = (columnWidth * 16 / 9) + 60;
        final childAspectRatio = columnWidth / cardHeight;

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: 6,
          itemBuilder: (_, __) => const CatalogueCardSkeleton(),
        );
      },
    );
  }
}
