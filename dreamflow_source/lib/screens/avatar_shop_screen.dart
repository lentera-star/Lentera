import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lentera/models/avatar.dart';
import 'package:lentera/services/avatar_service.dart';
import 'package:lentera/services/gamification_service.dart';
import 'package:lentera/auth/supabase_auth_manager.dart';
import 'package:lentera/services/user_service.dart';
import 'package:lentera/theme.dart';

class AvatarShopScreen extends StatefulWidget {
  const AvatarShopScreen({super.key});

  @override
  State<AvatarShopScreen> createState() => _AvatarShopScreenState();
}

class _AvatarShopScreenState extends State<AvatarShopScreen> {
  final _avatarSvc = AvatarService();
  final _gf = GamificationService();

  late Future<void> _init;
  Set<String> _owned = {};
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _init = _load();
  }

  Future<void> _load() async {
    _owned = await _avatarSvc.getOwnedIds();
    _selectedId = await _avatarSvc.getSelectedId();
    if (mounted) setState(() {});
  }

  Future<void> _buy(AvatarItem item) async {
    final ok = await _avatarSvc.purchase(item.id);
    if (!mounted) return;
    if (ok) {
      setState(() => _owned.add(item.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Berhasil membeli ${item.name}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Koin tidak cukup')),
      );
    }
  }

  Future<void> _select(AvatarItem item) async {
    await _avatarSvc.select(item.id);
    setState(() => _selectedId = item.id);

    // Also persist to Supabase user.avatar_url so profile uses it
    try {
      final auth = SupabaseAuthManager();
      final user = await auth.getCurrentUser();
      if (user != null) {
        final saved = await UserService().updateUser(user.copyWith(avatarUrl: item.assetPath));
        if (saved != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Avatar dipilih: ${item.name}')),
          );
          context.pop();
        }
      }
    } catch (e) {
      debugPrint('Avatar select save error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final branding = theme.extension<BrandingColors>() ?? BrandingColors.light;
    final items = AvatarCatalog.all;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Avatar & Toko'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<void>(
          future: _init,
          builder: (context, _) {
            return Column(
              children: [
                // Coin balance header
                ValueListenableBuilder<int>(
                  valueListenable: _gf.tick,
                  builder: (context, __, ___) {
                    return FutureBuilder<GamificationSummary>(
                      future: _gf.getSummary(),
                      builder: (context, snapshot) {
                        final koin = snapshot.data?.koin ?? 0;
                        return Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.18)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.monetization_on, color: (Theme.of(context).extension<AppColors>() ?? kAppColorsLight).amber),
                              const SizedBox(width: 8),
                              Text('$koin koin', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                              const Spacer(),
                              Text('Beli avatar untuk profil', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),

                // Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final owned = _owned.contains(item.id);
                      final selected = _selectedId == item.id;
                      return _AvatarCard(
                        item: item,
                        owned: owned,
                        selected: selected,
                        onBuy: () => _buy(item),
                        onSelect: () => _select(item),
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
}

class _AvatarCard extends StatelessWidget {
  final AvatarItem item;
  final bool owned;
  final bool selected;
  final VoidCallback onBuy;
  final VoidCallback onSelect;
  const _AvatarCard({
    required this.item,
    required this.owned,
    required this.selected,
    required this.onBuy,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? kAppColorsLight;
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(48),
            child: Image.asset(
              item.assetPath,
              width: 96,
              height: 96,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Text(item.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          if (!owned)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.monetization_on, size: 16, color: appColors.amber),
                const SizedBox(width: 4),
                Text('${item.price}', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            )
          else
            Text(selected ? 'Dipakai' : 'Dimiliki', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary)),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: owned ? theme.colorScheme.primary : appColors.amber,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: owned ? onSelect : onBuy,
                icon: Icon(owned ? (selected ? Icons.check : Icons.person) : Icons.shopping_cart),
                label: Text(owned ? (selected ? 'Dipakai' : 'Pilih') : 'Beli'),
              ),
            ),
          )
        ],
      ),
    );
  }
}
