class AvatarItem {
  final String id;
  final String name;
  final String assetPath;
  final int price; // koin

  const AvatarItem({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.price,
  });
}

/// Static catalog of available avatars.
class AvatarCatalog {
  static const List<AvatarItem> all = [
    AvatarItem(
      id: 'ava_blue_flat',
      name: 'Wave Blue',
      assetPath: 'assets/images/flat_character_avatar_portrait_colorful_blue_1765788628712.png',
      price: 60,
    ),
    AvatarItem(
      id: 'ava_female_min',
      name: 'Rose Girl',
      assetPath: 'assets/images/minimalist_avatar_female_flat_portrait_pink_1765788630118.png',
      price: 80,
    ),
    AvatarItem(
      id: 'ava_male_min',
      name: 'Leaf Boy',
      assetPath: 'assets/images/minimalist_avatar_male_flat_portrait_green_1765788631488.png',
      price: 80,
    ),
    AvatarItem(
      id: 'ava_orange_round',
      name: 'Sun Pop',
      assetPath: 'assets/images/avatar_cartoon_profile_circle_orange_1765788633035.png',
      price: 50,
    ),
    AvatarItem(
      id: 'ava_turq_geo',
      name: 'Turquoise Geo',
      assetPath: 'assets/images/flat_geometric_avatar_person_turquoise_1765788634189.png',
      price: 70,
    ),
    AvatarItem(
      id: 'ava_cute_lilac',
      name: 'Lilac Cute',
      assetPath: 'assets/images/cute_avatar_illustration_profile_lilac_1765788635093.jpg',
      price: 90,
    ),
    AvatarItem(
      id: 'ava_pro_gray',
      name: 'Pro Gray',
      assetPath: 'assets/images/professional_avatar_illustration_profile_gray_1765788636158.png',
      price: 90,
    ),
    AvatarItem(
      id: 'ava_youth_yellow',
      name: 'Youth Yellow',
      assetPath: 'assets/images/youth_avatar_illustration_profile_yellow_1765788637308.jpg',
      price: 70,
    ),
  ];

  static AvatarItem? byId(String id) {
    try {
      return all.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
