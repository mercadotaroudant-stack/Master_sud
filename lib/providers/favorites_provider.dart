import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Architecture de favoris unique et partagée dans toute l'application.
/// Persiste localement (SharedPreferences) une liste de clés "type:id"
/// (ex: "showroom:abc123", "product:xyz789") afin qu'un seul système gère
/// tous les favoris — aucune page ne doit créer son propre mécanisme.
class FavoritesProvider extends ChangeNotifier {
  static const String _storageKey = 'favorite_items';

  final Set<String> _favoriteKeys = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;

  String _keyFor(String type, String id) => '$type:$id';

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _favoriteKeys
      ..clear()
      ..addAll(prefs.getStringList(_storageKey) ?? const []);
    _loaded = true;
    notifyListeners();
  }

  bool isFavorite(String type, String id) => _favoriteKeys.contains(_keyFor(type, id));

  Future<void> toggle(String type, String id) async {
    final key = _keyFor(type, id);
    if (_favoriteKeys.contains(key)) {
      _favoriteKeys.remove(key);
    } else {
      _favoriteKeys.add(key);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, _favoriteKeys.toList());
  }
}
