import '../config/supabase_config.dart';
import '../models/menu_item.dart';
import '../models/category.dart';

class MenuService {
  final _supabase = SupabaseConfig.client;

  Future<void> addMenuItem(Map<String, dynamic> data) async {
  await _supabase.from('menu_items').insert(data);
}

Future<void> updateMenuItem(String id, Map<String, dynamic> data) async {
  await _supabase.from('menu_items').update(data).eq('id', id);
}

Future<void> deleteMenuItem(String id) async {
  await _supabase.from('menu_items').delete().eq('id', id);
}

  Future<void> updateAvailability(String id, bool value) async {
  await _supabase
      .from('menu_items')
      .update({'is_available': value})
      .eq('id', id);
}

Future<void> updateBestseller(String id, bool value) async {
  await _supabase
      .from('menu_items')
      .update({'is_bestseller': value})
      .eq('id', id);
}

  // ─────────────────────────────────────────────
  // Categories
  // ─────────────────────────────────────────────
  Future<List<Category>> getCategories() async {
    final response = await _supabase
        .from('categories')
        .select()
        .eq('is_active', true)
        .order('display_order');

    return (response as List)
        .map((json) => Category.fromJson(json))
        .toList();
  }

  // ─────────────────────────────────────────────
  // Menu Items (list)
  // ─────────────────────────────────────────────
  Future<List<MenuItem>> getMenuItems({
    String? categoryId,
    bool? isAvailable,
    bool? isBestseller,
    bool? isVegetarian,
  }) async {
    var query = _supabase.from('menu_items').select();

    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }
    if (isAvailable != null) {
      query = query.eq('is_available', isAvailable);
    }
    if (isBestseller != null) {
      query = query.eq('is_bestseller', isBestseller);
    }
    if (isVegetarian != null) {
      query = query.eq('is_vegetarian', isVegetarian);
    }

    final response = await query.order('display_order');

    return (response as List)
        .map((json) => MenuItem.fromJson(json))
        .toList();
  }

  // ─────────────────────────────────────────────
  // Bestsellers
  // ─────────────────────────────────────────────
  Future<List<MenuItem>> getBestsellers() async {
    return getMenuItems(isBestseller: true, isAvailable: true);
  }

  // ─────────────────────────────────────────────
  // SINGLE ITEM (used by detail page)
  // ─────────────────────────────────────────────
  Future<MenuItem> getMenuItemById(String id) async {
    final response = await _supabase
        .from('menu_items')
        .select()
        .eq('id', id)
        .single();

    return MenuItem.fromJson(response);
  }

  // (keep old method if used elsewhere)
  Future<MenuItem?> getMenuItem(String id) async {
    try {
      final response = await _supabase
          .from('menu_items')
          .select()
          .eq('id', id)
          .single();

      return MenuItem.fromJson(response);
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // Search
  // ─────────────────────────────────────────────
  Future<List<MenuItem>> searchMenuItems(String query) async {
    final response = await _supabase
        .from('menu_items')
        .select()
        .or('name.ilike.%$query%,description.ilike.%$query%')
        .eq('is_available', true)
        .order('display_order');

    return (response as List)
        .map((json) => MenuItem.fromJson(json))
        .toList();
  }

  // ─────────────────────────────────────────────
  // Sorting
  // ─────────────────────────────────────────────
  List<MenuItem> sortMenuItems(List<MenuItem> items, String sortBy) {
    final sorted = List<MenuItem>.from(items);

    switch (sortBy) {
      case 'price_low':
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'name':
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    return sorted;
  }

  // ─────────────────────────────────────────────
  // Filtering
  // ─────────────────────────────────────────────
  List<MenuItem> filterMenuItems(
    List<MenuItem> items, {
    bool? hasHalfPlate,
    bool? isVegetarian,
    double? maxPrice,
  }) {
    var filtered = items;

    if (hasHalfPlate == true) {
      filtered =
          filtered.where((item) => item.halfPlatePrice != null).toList();
    }

    if (isVegetarian != null) {
      filtered = filtered
          .where((item) => item.isVegetarian == isVegetarian)
          .toList();
    }

    if (maxPrice != null) {
      filtered =
          filtered.where((item) => item.price <= maxPrice).toList();
    }

    return filtered;
  }

  // ─────────────────────────────────────────────
  // Menu Items with Feedback
  // ─────────────────────────────────────────────
  Future<List<MenuItem>> getMenuItemsWithFeedback({
    String? categoryId,
    bool? isVegetarian,
  }) async {
    var query = _supabase.from('menu_items').select();

    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }
    if (isVegetarian != null) {
      query = query.eq('is_vegetarian', isVegetarian);
    }

    query = query.eq('is_available', true);

    final response = await query.order('display_order');

    return (response as List)
        .map((json) => MenuItem.fromJson(json))
        .toList();
  }

  // Filter by dietary preference
  Future<List<MenuItem>> filterByDietaryPreference(bool vegetarianOnly) async {
    return getMenuItems(
      isVegetarian: vegetarianOnly,
      isAvailable: true,
    );
  }

  // Get popular items (based on ratings and tags)
  Future<List<MenuItem>> getPopularItems() async {
    final response = await _supabase
        .from('menu_items')
        .select()
        .eq('is_available', true)
        .gte('average_rating', 4.0)
        .gte('total_reviews', 5)
        .order('average_rating', ascending: false)
        .limit(10);

    return (response as List)
        .map((json) => MenuItem.fromJson(json))
        .toList();
  }

  // Get items by tag
  Future<List<MenuItem>> getItemsByTag(String tag) async {
    final response = await _supabase
        .from('menu_items')
        .select()
        .eq('is_available', true)
        .contains('tags', [tag])
        .order('display_order');

    return (response as List)
        .map((json) => MenuItem.fromJson(json))
        .toList();
  }
}
