import 'package:flutter/material.dart';

/// جميع ألوان التطبيق في مكان واحد لتسهيل التعديل مستقبلاً (بما فيها دعم Dark Mode لاحقًا).
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1F3265); // كحلي - اللون الرئيسي للعلامة
  static const Color primaryLight = Color(0xFF33477F);
  static const Color accent = Color(0xFFE8A33D);

  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Colors.white;

  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFEDEDED);

  static const Color success = Color(0xFF2E9E5B);
  static const Color error = Color(0xFFE5484D);
  static const Color warning = Color(0xFFF5A623);

  static const Color promo = Color(0xFFFF3B30);
  static const Color priceRed = Color(0xFFD62828);

  static const Color shimmerBase = Color(0xFFEAEAEA);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // ===== MASTER SUD — Product Details page palette =====
  // (Voir spécification "Détails du produit" fournie par le client)
  static const Color pdNavy = Color(0xFF10264B);
  static const Color pdDarkNavy = Color(0xFF071B3B);
  static const Color pdPriceRed = Color(0xFFE33131);
  static const Color pdPromoRed = Color(0xFFF0202A);
  static const Color pdSuccessGreen = Color(0xFF20A83A);
  static const Color pdTextPrimary = Color(0xFF11182C);
  static const Color pdTextSecondary = Color(0xFF6F7480);
  static const Color pdCardBackground = Color(0xFFFFFFFF);
  static const Color pdPageBackground = Color(0xFFF7F8FC);
  static const Color pdBorder = Color(0xFFE8EBF2);
  static const Color pdLightBlue = Color(0xFFEDF5FF);
  static const Color pdInactiveDot = Color(0xFFD5D9E2);
  static const Color pdVariantBorder = Color(0xFFDDE2EC);
  static const Color pdOldPrice = Color(0xFF8B909A);
  static const Color pdDiscountBg = Color(0xFFFFE3E5);
  static const Color pdDescriptionText = Color(0xFF31394A);

  // ===== MASTER SUD — "Nos Showrooms" page palette =====
  static const Color srBackground = Color(0xFFF7F8FC);
  static const Color srNavy = Color(0xFF192D50);
  static const Color srGold = Color(0xFFE5B83F);
  static const Color srTextPrimary = Color(0xFF171C2D);
  static const Color srTextSecondary = Color(0xFF858995);
  static const Color srOpenGreen = Color(0xFF18A957);
  static const Color srClosedRed = Color(0xFFD93B3B);
  static const Color srCard = Color(0xFFFFFFFF);
  static const Color srBorder = Color(0xFFE4E6EC);
  static const Color srSearchBorder = Color(0xFFE1E3E8);
  static const Color srBadgeText = Color(0xFF26314A);
  static const Color srNameText = Color(0xFF20283B);
  static const Color srDetailsRed = Color(0xFFD95353);

  // ===== MASTER SUD — "Catalogue" section palette =====
  static const Color ctBackground = Color(0xFFFFFFFF);
  static const Color ctNavy = Color(0xFF192E52);
  static const Color ctTextPrimary = Color(0xFF171B2E);
  static const Color ctTextSecondary = Color(0xFF7A7F8C);
  static const Color ctCardLight = Color(0xFFF5F7FB);
  static const Color ctGold = Color(0xFFE4B63F);
  static const Color ctSearchBackground = Color(0xFFF7F8FC);

  // ===== MASTER SUD — "Formation" (vidéos) section palette =====
  static const Color fmBackground = Color(0xFFFFFFFF);
  static const Color fmBackButtonBg = Color(0xFFF7F8FC);
  static const Color fmIconNavy = Color(0xFF192E52);
  static const Color fmTitle = Color(0xFF171B2E);
  static const Color fmTextSecondary = Color(0xFF7A7F8C);
  static const Color fmCardBg = Color(0xFFFFFFFF);
  static const Color fmDurationBg = Color(0xFF080C16);
  static const Color fmGold = Color(0xFFE5B83F);
}
