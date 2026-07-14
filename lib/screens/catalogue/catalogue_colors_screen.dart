import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/app_colors.dart';
import '../../models/catalogue_color_model.dart';
import '../../models/color_tryon_selection.dart';
import '../../models/paint_catalogue_model.dart';
import '../../repositories/paint_catalogue_repository.dart';
import 'tryon/color_tryon_editor_screen.dart';
import 'widgets/catalogue_color_card.dart';
import 'widgets/catalogue_color_card_skeleton.dart';
import 'widgets/catalogue_colors_header.dart';
import 'widgets/catalogue_empty_state.dart';
import 'widgets/catalogue_search_field.dart';
import 'widgets/color_source_bottom_sheet.dart';

/// Page des couleurs d'un catalogue donné. Le catalogue et ses couleurs
/// sont chargés dynamiquement depuis Firebase à partir de `catalogueId` —
/// seules les couleurs actives associées à ce catalogue sont affichées.
///
/// Chaque carte couleur porte son propre bouton caméra qui lance le
/// parcours "Essayer cette couleur" (Color Try-On).
class CatalogueColorsScreen extends StatefulWidget {
  final String catalogueId;

  /// Catalogue déjà connu (venant de la liste) pour afficher immédiatement
  /// le titre sans attendre le premier snapshot Firestore. La page reste
  /// ensuite branchée en temps réel sur Firebase.
  final PaintCatalogueModel? initialCatalogue;

  const CatalogueColorsScreen({super.key, required this.catalogueId, this.initialCatalogue});

  @override
  State<CatalogueColorsScreen> createState() => _CatalogueColorsScreenState();
}

class _CatalogueColorsScreenState extends State<CatalogueColorsScreen> {
  final PaintCatalogueRepository _repository = FirebasePaintCatalogueRepository();
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() => _query = value);
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Lance le parcours Color Try-On pour la couleur d'une carte donnée :
  /// bottom sheet (Caméra / Mes fichiers) -> capture/sélection d'image ->
  /// éditeur, en conservant la couleur choisie tout au long du flux.
  Future<void> _handleCameraTap({
    required String catalogueName,
    required CatalogueColorModel color,
  }) async {
    final selection = ColorTryOnSelection.fromCatalogueColor(
      catalogueId: widget.catalogueId,
      catalogueName: catalogueName,
      color: color,
    );
    if (selection == null) {
      _showSnack('Cette couleur n\'est pas encore disponible pour un essai.');
      return;
    }

    final source = await showColorSourceBottomSheet(context, selection: selection);
    if (source == null || !mounted) return; // annulé par l'utilisateur

    XFile? picked;
    try {
      picked = await _imagePicker.pickImage(source: source, imageQuality: 92);
    } catch (_) {
      final isCamera = source == ImageSource.camera;
      _showSnack(
        isCamera
            ? "Veuillez autoriser l'accès à la caméra dans les réglages pour continuer."
            : "Veuillez autoriser l'accès aux photos dans les réglages pour continuer.",
      );
      return;
    }

    if (picked == null || !mounted) return; // capture/sélection annulée

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ColorTryOnEditorScreen(imageFile: picked!, selection: selection),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ctBackground,
      body: SafeArea(
        child: StreamBuilder<PaintCatalogueModel?>(
          stream: _repository.streamCatalogueById(widget.catalogueId),
          initialData: widget.initialCatalogue,
          builder: (context, catalogueSnapshot) {
            final catalogue = catalogueSnapshot.data ?? widget.initialCatalogue;
            final title = catalogue?.name ?? 'Catalogue';

            return Column(
              children: [
                CatalogueColorsHeader(
                  catalogueName: title,
                  onBack: () => Navigator.of(context).maybePop(),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: CatalogueSearchField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    hintText: 'Rechercher une couleur...',
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<CatalogueColorModel>>(
                    stream: _repository.streamActiveColors(widget.catalogueId),
                    builder: (context, colorsSnapshot) {
                      final loading = colorsSnapshot.connectionState == ConnectionState.waiting;
                      final allColors = colorsSnapshot.data ?? [];

                      final normalized = _query.trim().toLowerCase();
                      final filtered = normalized.isEmpty
                          ? allColors
                          : allColors.where((c) {
                              final byCode = c.code.toLowerCase().contains(normalized);
                              final byName = (c.name ?? '').toLowerCase().contains(normalized);
                              return byCode || byName;
                            }).toList();

                      return _buildColorsArea(
                        title,
                        loading,
                        colorsSnapshot.hasError,
                        allColors,
                        filtered,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildColorsArea(
    String catalogueName,
    bool loading,
    bool hasError,
    List<CatalogueColorModel> allColors,
    List<CatalogueColorModel> filtered,
  ) {
    if (loading) {
      return _buildColorsGrid(catalogueName, itemCount: 6, skeleton: true, colors: const []);
    }
    if (hasError) {
      return const CatalogueEmptyState(
        icon: Icons.wifi_off_rounded,
        message: 'Impossible de charger les couleurs pour le moment.',
      );
    }
    if (allColors.isEmpty) {
      return const CatalogueEmptyState(
        icon: Icons.palette_outlined,
        message: 'Aucune couleur disponible pour ce catalogue.',
      );
    }
    if (filtered.isEmpty) {
      return CatalogueEmptyState(
        icon: Icons.search_off_rounded,
        message: 'Aucune couleur ne correspond à "$_query".',
      );
    }
    return _buildColorsGrid(catalogueName, itemCount: filtered.length, skeleton: false, colors: filtered);
  }

  Widget _buildColorsGrid(
    String catalogueName, {
    required int itemCount,
    required bool skeleton,
    required List<CatalogueColorModel> colors,
  }) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 13,
        mainAxisSpacing: 15,
        childAspectRatio: 0.78,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (skeleton) return const CatalogueColorCardSkeleton();
        final color = colors[index];
        return CatalogueColorCard(
          color: color,
          onCameraTap: () => _handleCameraTap(catalogueName: catalogueName, color: color),
        );
      },
    );
  }
}
