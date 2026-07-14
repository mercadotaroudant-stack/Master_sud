import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/routes.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimens.dart';
import '../../constants/app_strings_keys.dart';
import '../../localization/app_localizations.dart';
import '../../providers/home_provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/banner_slider.dart';
import '../../widgets/categories_grid.dart';
import '../../widgets/horizontal_menu.dart';
import '../../widgets/products_section.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/showrooms_section.dart';
import '../../widgets/stories_bar.dart';
import '../showrooms/showroom_details_screen.dart';
import '../showrooms/showrooms_list_screen.dart';
import '../../widgets/skeleton_loading.dart';
import '../../widgets/videos_section.dart';
import '../category_products/category_products_screen.dart';
import '../formation/formation_screen.dart';
import '../formation/player/video_player_screen.dart';
import '../placeholder/placeholder_screen.dart';
import '../product_details/product_details_screen.dart';

/// الصفحة الرئيسية: Header + Search + القائمة الأفقية + Banner Slider + Categories Grid.
/// كل البيانات (Banners/Categories) تُجلب من Firebase عبر [HomeProvider].
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeProvider _homeProvider;

  @override
  void initState() {
    super.initState();
    _homeProvider = HomeProvider();
    _homeProvider.load();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _homeProvider,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Consumer<HomeProvider>(
          builder: (context, provider, _) {
            return SafeArea(
              child: Column(
                children: [
                  AppHeader(
                    onMenuTap: () => Scaffold.of(context).openDrawer(),
                    onDevisTap: () => Navigator.of(context).pushNamed(AppRoutes.devis),
                    onCommandeTap: () => Navigator.of(context).pushNamed(AppRoutes.commande),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: provider.refresh,
                      child: _buildBody(context, provider),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        drawer: _HomeDrawer(),
      ),
    );
  }

  Widget _buildBody(BuildContext context, HomeProvider provider) {
    if (provider.state == HomeLoadState.loading || provider.state == HomeLoadState.initial) {
      return const HomeSkeleton();
    }

    if (provider.state == HomeLoadState.error) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.textMuted),
          const SizedBox(height: AppDimens.paddingMd),
          Center(
            child: Text(
              context.tr(K.errorLoad),
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: AppDimens.paddingMd),
          Center(
            child: OutlinedButton(
              onPressed: provider.load,
              child: Text(context.tr(K.retry)),
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppDimens.paddingLg),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMd, vertical: AppDimens.paddingSm),
          child: AppSearchBar(onTap: () {}),
        ),
        const SizedBox(height: AppDimens.paddingSm),
        HorizontalMenu(items: _menuItems(context)),
        const SizedBox(height: AppDimens.paddingLg),
        BannerSlider(banners: provider.banners),
        const StoriesBar(),
        const SizedBox(height: AppDimens.paddingSm),
        CategoriesSection(
          categories: provider.categories,
          onTap: (category) => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => CategoryProductsScreen(category: category)),
          ),
        ),
        ProductsSection(
          products: provider.popularProducts,
          onAddPressed: (_) {
            // بنية الاستدعاء جاهزة للربط لاحقًا بمنطق السلة/الطلبية الحقيقي.
          },
          onViewDetails: (product) => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProductDetailsScreen(productId: product.id, initialProduct: product),
            ),
          ),
          onSeeAllTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PlaceholderScreen(titleKey: 'popular_products')),
          ),
        ),
        ShowroomsSection(
          showrooms: provider.showrooms,
          onShowroomTap: (showroom) => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ShowroomDetailsScreen(showroomId: showroom.id, initialShowroom: showroom),
            ),
          ),
          onSeeAllTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ShowroomsListScreen()),
          ),
        ),
        VideosSection(
          videos: provider.trainingVideos,
          onVideoTap: (video) => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => VideoPlayerScreen(video: video)),
          ),
          onSeeAllTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const FormationScreen()),
          ),
        ),
      ],
    );
  }

  List<MenuItemData> _menuItems(BuildContext context) => [
        MenuItemData(labelKey: K.menuPeinture, icon: Icons.format_paint_rounded, onTap: () {}),
        MenuItemData(
          labelKey: K.menuProduits,
          icon: Icons.inventory_2_outlined,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.produits),
        ),
        MenuItemData(
          labelKey: K.menuCatalogue,
          icon: Icons.menu_book_outlined,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.catalogue),
        ),
        MenuItemData(
          labelKey: K.menuShowrooms,
          icon: Icons.storefront_outlined,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.showrooms),
        ),
        MenuItemData(
          labelKey: K.menuPapierPeint,
          icon: Icons.wallpaper_rounded,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.papierPeint),
        ),
        MenuItemData(
          labelKey: K.menuFormation,
          icon: Icons.school_outlined,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.formation),
        ),
        MenuItemData(
          labelKey: K.menuCalculator,
          icon: Icons.calculate_outlined,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.calculator),
        ),
        MenuItemData(
          labelKey: K.menuProSpace,
          icon: Icons.badge_outlined,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.proSpace),
        ),
      ];
}

class _HomeDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppColors.primary),
              child: Text(
                context.tr(K.appName),
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: Text(context.tr(K.menuProduits)),
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.produits),
            ),
            ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: Text(context.tr(K.menuCatalogue)),
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.catalogue),
            ),
            ListTile(
              leading: const Icon(Icons.storefront_outlined),
              title: Text(context.tr(K.menuShowrooms)),
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.showrooms),
            ),
            ListTile(
              leading: const Icon(Icons.wallpaper_rounded),
              title: Text(context.tr(K.menuPapierPeint)),
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.papierPeint),
            ),
            ListTile(
              leading: const Icon(Icons.school_outlined),
              title: Text(context.tr(K.menuFormation)),
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.formation),
            ),
            ListTile(
              leading: const Icon(Icons.calculate_outlined),
              title: Text(context.tr(K.menuCalculator)),
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.calculator),
            ),
            ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: Text(context.tr(K.menuProSpace)),
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.proSpace),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.request_quote_outlined),
              title: Text(context.tr(K.devis)),
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.devis),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag_outlined),
              title: Text(context.tr(K.commande)),
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.commande),
            ),
          ],
        ),
      ),
    );
  }
}
