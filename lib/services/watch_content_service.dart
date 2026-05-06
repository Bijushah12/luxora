import '../models/watch_model.dart';

class WatchContentService {
  static String descriptionFor(Watch watch) {
    return descriptionFromRaw(
      rawDescription: watch.description,
      name: watch.name,
      brand: watch.brand,
      category: watch.category,
    );
  }

  static String descriptionFromRaw({
    required String rawDescription,
    required String name,
    required String brand,
    required String category,
  }) {
    final description = rawDescription.trim();
    if (_isWatchRelated(description)) {
      return description;
    }

    return generatedDescription(name: name, brand: brand, category: category);
  }

  static String generatedDescription({
    required String name,
    required String brand,
    required String category,
  }) {
    final watchName = name.trim().isEmpty ? 'This timepiece' : name.trim();
    final watchBrand = brand.trim().isEmpty ? 'Luxora' : brand.trim();
    final normalizedCategory = category.trim().toLowerCase();

    if (normalizedCategory.contains('women')) {
      return '$watchName by $watchBrand is designed for refined everyday styling, with an elegant wrist presence, a polished dial, and a comfortable fit that moves easily from office hours to evening occasions.';
    }

    if (normalizedCategory.contains('sport')) {
      return '$watchName by $watchBrand is built for active days, pairing a confident case profile with easy readability, dependable comfort, and a durable look made for motion.';
    }

    if (normalizedCategory.contains('smart')) {
      return '$watchName by $watchBrand blends modern smartwatch convenience with a clean wrist-ready design, making it ideal for notifications, daily tracking, and connected routines.';
    }

    if (normalizedCategory.contains('luxury')) {
      return '$watchName by $watchBrand is a statement timepiece with a premium finish, balanced proportions, and sophisticated detailing for occasions where presence matters.';
    }

    if (normalizedCategory.contains('men')) {
      return '$watchName by $watchBrand is a versatile men\'s watch with a strong dial presence, reliable everyday comfort, and styling that works across formal and casual wardrobes.';
    }

    return '$watchName by $watchBrand is a curated Luxora watch selected for balanced design, dependable wearability, and a polished look for everyday ownership.';
  }

  static String generatedName({
    required String brand,
    required String category,
    required int index,
  }) {
    final normalizedCategory = category.trim().toLowerCase();
    final watchBrand = brand.trim().isEmpty ? 'Luxora' : brand.trim();
    final number = (index + 1).toString().padLeft(2, '0');

    if (normalizedCategory.contains('women')) {
      return '$watchBrand Elegance $number';
    }
    if (normalizedCategory.contains('sport')) {
      return '$watchBrand Active Chrono $number';
    }
    if (normalizedCategory.contains('smart')) {
      return '$watchBrand Connect $number';
    }
    if (normalizedCategory.contains('luxury')) {
      return '$watchBrand Signature $number';
    }
    if (normalizedCategory.contains('men')) {
      return '$watchBrand Heritage $number';
    }

    return '$watchBrand Timepiece $number';
  }

  static bool _isWatchRelated(String description) {
    if (description.length < 20) {
      return false;
    }

    final text = description.toLowerCase();
    const watchWords = [
      'watch',
      'timepiece',
      'dial',
      'strap',
      'bracelet',
      'case',
      'wrist',
      'chronograph',
      'movement',
      'bezel',
      'smartwatch',
      'warranty',
    ];
    const unrelatedWords = [
      'shirt',
      'cotton',
      'jacket',
      'backpack',
      'laptop',
      'hard drive',
      'jewelery',
      'clothing',
      'sleeve',
    ];

    return watchWords.any(text.contains) && !unrelatedWords.any(text.contains);
  }
}
