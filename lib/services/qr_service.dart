import 'dart:typed_data';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import '../config/supabase_config.dart';
import '../models/qr_code.dart' as model;
import '../services/auth_service.dart';

class QRService {
  final _supabase = SupabaseConfig.client;
  final _authService = AuthService();

  // Generate QR code image
  Future<Uint8List> generateQRImage(String content, {double size = 300}) async {
    try {
      final qrValidationResult = QrValidator.validate(
        data: content,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.H,
      );

      if (qrValidationResult.status == QrValidationStatus.valid) {
        final qrCode = qrValidationResult.qrCode!;
        final painter = QrPainter.withQr(
          qr: qrCode,
          gapless: true,
          embeddedImageStyle: null,
          embeddedImage: null,
        );

        final picturRecorder = ui.PictureRecorder();
        final canvas = Canvas(picturRecorder);
        painter.paint(canvas, Size(size, size));
        final picture = picturRecorder.endRecording();
        final image = await picture.toImage(size.toInt(), size.toInt());
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        
        return byteData!.buffer.asUint8List();
      } else {
        throw Exception('Invalid QR code data');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Save QR code to database and storage
  Future<model.QRCode> saveQRCode({
    required String name,
    required String content,
    String? description,
  }) async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Generate QR code image
      final imageBytes = await generateQRImage(content);

      // Upload to Supabase storage
      final fileName = 'qr_${DateTime.now().millisecondsSinceEpoch}.png';
      final uploadPath = 'qr_codes/$fileName';
      
      await _supabase.storage
          .from('public')
          .uploadBinary(uploadPath, imageBytes);

      // Get public URL
      final imageUrl = _supabase.storage
          .from('public')
          .getPublicUrl(uploadPath);

      // Save to database
      final response = await _supabase.from('qr_codes').insert({
        'name': name,
        'content': content,
        'qr_image_url': imageUrl,
        'description': description,
        'is_active': true,
        'created_by': userId,
      }).select().single();

      return model.QRCode.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Get all QR codes
  Future<List<model.QRCode>> getQRCodes({bool activeOnly = false}) async {
    try {
      var query = _supabase
          .from('qr_codes')
          .select();

      if (activeOnly) {
        query = query.eq('is_active', true);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((json) => model.QRCode.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Get single QR code
  Future<model.QRCode?> getQRCode(String id) async {
    try {
      final response = await _supabase
          .from('qr_codes')
          .select()
          .eq('id', id)
          .single();

      return model.QRCode.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Update QR code
  Future<void> updateQRCode(String id, Map<String, dynamic> updates) async {
    try {
      await _supabase
          .from('qr_codes')
          .update(updates)
          .eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  // Delete QR code
  Future<void> deleteQRCode(String id) async {
    try {
      // Get QR code to delete image from storage
      final qrCode = await getQRCode(id);
      
      if (qrCode?.qrImageUrl != null) {
        // Extract file path from URL
        final uri = Uri.parse(qrCode!.qrImageUrl!);
        final path = uri.pathSegments.skip(uri.pathSegments.indexOf('public') + 1).join('/');
        
        // Delete from storage
        await _supabase.storage
            .from('public')
            .remove([path]);
      }

      // Delete from database
      await _supabase
          .from('qr_codes')
          .delete()
          .eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  // Toggle QR code active status
  Future<void> toggleQRCode(String id, bool isActive) async {
    try {
      await _supabase
          .from('qr_codes')
          .update({'is_active': isActive})
          .eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  // Generate promotional QR code with restaurant info
  Future<model.QRCode> generatePromotionalQR({
    required String promoText,
    String? description,
  }) async {
    try {
      // Create content with restaurant info
      final content = '''
Indu Multicuisine Restaurant
$promoText

Download our app or visit our website to order!
''';

      return await saveQRCode(
        name: 'Promotional QR - ${DateTime.now().toString().substring(0, 10)}',
        content: content,
        description: description ?? promoText,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Generate referral QR code
  Future<model.QRCode> generateReferralQR(String referralCode) async {
    try {
      final content = 'INDU_REFERRAL:$referralCode';

      return await saveQRCode(
        name: 'Referral QR - $referralCode',
        content: content,
        description: 'Referral code: $referralCode',
      );
    } catch (e) {
      rethrow;
    }
  }
}
