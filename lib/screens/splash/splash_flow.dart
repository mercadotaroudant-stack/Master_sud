import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_config.dart';
import '../../config/routes.dart';
import '../../constants/app_assets.dart';
import '../../localization/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/language_switch.dart';

/// تدفّق شاشات الانطلاق الثلاث (Splash 1 → Splash 2 → Splash 3).
/// عند اختيار اللغة في Splash 3 يتم تحديث لغة التطبيق بالكامل فورًا
/// عبر [LocaleProvider]، ثم حفظ الاختيار في SharedPreferences بعد الضغط
/// على زر البدء حتى لا يُطلب اختيار اللغة مرة أخرى.
class SplashFlow extends StatefulWidget {
  const SplashFlow({super.key});

  @override
  State<SplashFlow> createState() => _SplashFlowState();
}

class _SplashFlowState extends State<SplashFlow> {
  // 0 = Splash1, 1 = Splash2, 2 = Splash3
  int _stage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scheduleNextStage();
  }

  void _scheduleNextStage() {
    _timer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (_stage == 0) {
        setState(() => _stage = 1);
        _scheduleNextStage();
      } else if (_stage == 1) {
        setState(() => _stage = 2);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _onStartPressed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConfig.prefHasSeenSplash, true);

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildStage(),
      ),
    );
  }

  Widget _buildStage() {
    switch (_stage) {
      case 0:
        return const _FullScreenImage(key: ValueKey('splash1'), url: AppAssets.splash1Url);
      case 1:
        return const _FullScreenImage(key: ValueKey('splash2'), url: AppAssets.splash2Url);
      default:
        return _Splash3(key: const ValueKey('splash3'), onStartPressed: _onStartPressed);
    }
  }
}

/// عرض صورة كاملة الشاشة دون أي تعديل عليها (Splash 1 / Splash 2)
class _FullScreenImage extends StatelessWidget {
  final String url;
  const _FullScreenImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Image.network(url, fit: BoxFit.cover),
    );
  }
}

/// Splash 3: الصورة + Language Switch + زر البداية (Overlay فقط، الصورة لا تتغير شكلها)
class _Splash3 extends StatelessWidget {
  final VoidCallback onStartPressed;

  const _Splash3({super.key, required this.onStartPressed});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        final isArabic = localeProvider.isArabic;
        final imageUrl = isArabic ? AppAssets.splash3ArUrl : AppAssets.splash3FrUrl;

        return Stack(
          fit: StackFit.expand,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
              child: Image.network(
                imageUrl,
                key: ValueKey(imageUrl),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Positioned(
              top: 55,
              right: 20,
              child: LanguageSwitch(
                isArabic: isArabic,
                onChanged: (arabic) => localeProvider.setLocale(Locale(arabic ? 'ar' : 'fr')),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Center(
                    child: _StartButton(onPressed: onStartPressed),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StartButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _StartButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = screenWidth * 0.90;

    return Container(
      width: buttonWidth,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF1F3265),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F3265).withOpacity(0.10),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onPressed,
          child: Center(
            child: Text(
              context.tr('start'),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
