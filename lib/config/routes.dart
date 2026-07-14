import 'package:flutter/material.dart';

import '../screens/splash/splash_flow.dart';
import '../screens/home/home_screen.dart';
import '../screens/placeholder/placeholder_screen.dart';
import '../screens/showrooms/showrooms_list_screen.dart';
import '../screens/catalogue/catalogue_list_screen.dart';
import '../screens/formation/formation_screen.dart';
import '../screens/calculator/paint_calculator_screen.dart';
import '../screens/pro_space/pro_space_screen.dart';

/// كل المسارات المسمّاة (Named Routes) للتطبيق.
/// الصفحات الداخلية (غير Home/Splash) مؤقتًا Placeholder فقط بانتظار
/// المرحلة القادمة من التطوير.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String home = '/home';
  static const String produits = '/produits';
  static const String catalogue = '/catalogue';
  static const String showrooms = '/showrooms';
  static const String papierPeint = '/papier-peint';
  static const String formation = '/formation';
  static const String devis = '/devis';
  static const String commande = '/commande';
  static const String calculator = '/calculateur';
  static const String proSpace = '/espace-pro';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashFlow(),
        home: (_) => const HomeScreen(),
        produits: (_) => const PlaceholderScreen(titleKey: 'menu_produits'),
        catalogue: (_) => const CatalogueListScreen(),
        showrooms: (_) => const ShowroomsListScreen(),
        papierPeint: (_) => const PlaceholderScreen(titleKey: 'menu_papier_peint'),
        formation: (_) => const FormationScreen(),
        devis: (_) => const PlaceholderScreen(titleKey: 'devis'),
        commande: (_) => const PlaceholderScreen(titleKey: 'commande'),
        calculator: (_) => const PaintCalculatorScreen(),
        proSpace: (_) => const ProSpaceScreen(),
      };
}
