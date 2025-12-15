import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lentera/models/avatar.dart';
import 'package:lentera/services/gamification_service.dart';

class AvatarService {
  static const _ownedKey = 'avatar_owned_ids_v1';
  static const _selectedKey = 'avatar_selected_id_v1';

  Future<Set<String>> getOwnedIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_ownedKey) ?? const [];
      return list.toSet();
    } catch (e) {
      debugPrint('AvatarService.getOwnedIds error: $e');
      return {};
    }
  }

  Future<void> _saveOwnedIds(Set<String> ids) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_ownedKey, ids.toList());
    } catch (e) {
      debugPrint('AvatarService._saveOwnedIds error: $e');
    }
  }

  Future<String?> getSelectedId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_selectedKey);
    } catch (e) {
      debugPrint('AvatarService.getSelectedId error: $e');
      return null;
    }
  }

  Future<void> select(String avatarId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_selectedKey, avatarId);
    } catch (e) {
      debugPrint('AvatarService.select error: $e');
    }
  }

  Future<bool> purchase(String avatarId) async {
    try {
      final owned = await getOwnedIds();
      if (owned.contains(avatarId)) return true; // already owned

      final item = AvatarCatalog.byId(avatarId);
      if (item == null) return false;

      final gf = GamificationService();
      final summary = await gf.getSummary();
      if (summary.koin < item.price) return false;

      // Deduct coins locally
      await gf.addKoin(-item.price);

      // Save ownership
      owned.add(avatarId);
      await _saveOwnedIds(owned);
      return true;
    } catch (e) {
      debugPrint('AvatarService.purchase error: $e');
      return false;
    }
  }

  /// Returns the selected avatar asset path, if any.
  Future<String?> getSelectedAssetPath() async {
    final id = await getSelectedId();
    if (id == null) return null;
    return AvatarCatalog.byId(id)?.assetPath;
  }
}
