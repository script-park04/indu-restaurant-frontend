import 'package:supabase_flutter/supabase_flutter.dart';

class BackendService {
  BackendService._();

  static final SupabaseClient _client = Supabase.instance.client;

  static Future<Map<String, dynamic>> sendOrderEmail({
    required String name,
  }) async {
    final response = await _client.functions.invoke(
      'send-order-email',
      body: {
        'name': name,
      },
    );

    if (response.error != null) {
      throw response.error!;
    }

    return Map<String, dynamic>.from(response.data);
  }
}
