import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_config.dart';
import '../../config/routes.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimens.dart';
import '../../models/pro_request_model.dart';
import '../../repositories/pro_space_repository.dart';

/// فضاء المحترفين (Espace Pro) : المحترفون (الصباغون) يطلبون الانضمام عبر
/// استمارة بسيطة، ثم يتتبّعون حالة طلبهم لحظيًا (قيد المراجعة / مقبول /
/// مرفوض) بعد أن يعالجه الفريق من لوحة التحكم. لا يوجد حاليًا نظام حسابات
/// كامل (تسجيل دخول) في التطبيق، لذلك يُحفظ معرّف الطلب محليًا على الجهاز.
class ProSpaceScreen extends StatefulWidget {
  const ProSpaceScreen({super.key});

  @override
  State<ProSpaceScreen> createState() => _ProSpaceScreenState();
}

class _ProSpaceScreenState extends State<ProSpaceScreen> {
  final ProSpaceRepository _repository = FirebaseProSpaceRepository();

  bool _checkingPrefs = true;
  String? _requestId;

  @override
  void initState() {
    super.initState();
    _loadStoredRequest();
  }

  Future<void> _loadStoredRequest() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _requestId = prefs.getString(AppConfig.prefProRequestId);
      _checkingPrefs = false;
    });
  }

  Future<void> _onSubmitted(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.prefProRequestId, id);
    if (!mounted) return;
    setState(() => _requestId = id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Espace Pro')),
      body: SafeArea(
        child: _checkingPrefs
            ? const Center(child: CircularProgressIndicator())
            : _requestId == null
                ? _ProSpaceIntro(repository: _repository, onSubmitted: _onSubmitted)
                : _ProSpaceStatus(repository: _repository, requestId: _requestId!),
      ),
    );
  }
}

/// Écran d'accueil de l'Espace Pro : avantages + formulaire de demande.
class _ProSpaceIntro extends StatefulWidget {
  final ProSpaceRepository repository;
  final ValueChanged<String> onSubmitted;

  const _ProSpaceIntro({required this.repository, required this.onSubmitted});

  @override
  State<_ProSpaceIntro> createState() => _ProSpaceIntroState();
}

class _ProSpaceIntroState extends State<_ProSpaceIntro> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final id = await widget.repository.submitRequest(
        name: _nameController.text.trim(),
        company: _companyController.text.trim(),
        phone: _phoneController.text.trim(),
        city: _cityController.text.trim(),
      );
      widget.onSubmitted(id);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible d'envoyer la demande. Réessayez.")),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.paddingMd),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimens.paddingMd),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Réservé aux professionnels de la peinture',
                    style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tarifs de gros, devis prioritaires et accompagnement dédié pour les '
                    "artisans peintres. Remplissez la demande ci-dessous, notre équipe l'étudie "
                    'et valide votre accès Pro.',
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.paddingLg),
            const Text(
              'Votre demande',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: _fieldDecoration('Nom complet'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _companyController,
              decoration: _fieldDecoration('Entreprise / Auto-entrepreneur (optionnel)'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: _fieldDecoration('Téléphone'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _cityController,
              decoration: _fieldDecoration('Ville'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
            ),
            const SizedBox(height: AppDimens.paddingLg),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMd)),
              ),
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Envoyer ma demande', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimens.radiusSm)),
      filled: true,
      fillColor: AppColors.background,
    );
  }
}

/// Suivi en temps réel du statut d'une demande déjà envoyée.
class _ProSpaceStatus extends StatelessWidget {
  final ProSpaceRepository repository;
  final String requestId;

  const _ProSpaceStatus({required this.repository, required this.requestId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProRequestModel?>(
      stream: repository.streamRequestStatus(requestId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final request = snapshot.data;
        if (request == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppDimens.paddingLg),
              child: Text(
                "Votre demande est introuvable. Elle a peut-être été supprimée.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.paddingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StatusBanner(request: request),
              const SizedBox(height: AppDimens.paddingLg),
              if (request.isApproved) _ProPerks(context: context) else _PendingInfo(request: request),
            ],
          ),
        );
      },
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final ProRequestModel request;

  const _StatusBanner({required this.request});

  @override
  Widget build(BuildContext context) {
    late final Color color;
    late final IconData icon;
    late final String label;

    if (request.isApproved) {
      color = AppColors.success;
      icon = Icons.verified_rounded;
      label = 'Compte Pro validé';
    } else if (request.isRejected) {
      color = AppColors.error;
      icon = Icons.cancel_rounded;
      label = 'Demande refusée';
    } else {
      color = AppColors.warning;
      icon = Icons.hourglass_top_rounded;
      label = 'Demande en cours de validation';
    }

    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingMd),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(request.name, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingInfo extends StatelessWidget {
  final ProRequestModel request;

  const _PendingInfo({required this.request});

  @override
  Widget build(BuildContext context) {
    return Text(
      request.isRejected
          ? "Contactez-nous dans l'un de nos showrooms pour plus d'informations sur votre demande."
          : "Votre demande est en cours d'examen par notre équipe. Vous serez notifié automatiquement dès qu'elle sera validée.",
      style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.4),
    );
  }
}

class _ProPerks extends StatelessWidget {
  final BuildContext context;

  const _ProPerks({required this.context});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Vos avantages Pro',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        _PerkTile(
          icon: Icons.request_quote_outlined,
          title: 'Devis prioritaire',
          subtitle: 'Envoyez vos demandes de devis en gros directement.',
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.devis),
        ),
        _PerkTile(
          icon: Icons.storefront_outlined,
          title: 'Nos showrooms',
          subtitle: 'Retrouvez le showroom le plus proche pour vos commandes.',
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.showrooms),
        ),
        _PerkTile(
          icon: Icons.receipt_long_outlined,
          title: 'Historique de commandes',
          subtitle: 'Bientôt disponible avec la création de votre compte complet.',
          onTap: null,
        ),
      ],
    );
  }
}

class _PerkTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _PerkTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.background,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMd)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: onTap != null ? const Icon(Icons.chevron_right_rounded) : null,
        onTap: onTap,
      ),
    );
  }
}
