class AppConstants {
  // App Info
  static const String appName = 'Indu Multicuisine Restaurant';
  static const String appVersion = '1.0.0';
  
  // Supabase Configuration
  static const String supabaseUrl = 'https://agukkmffmftbytjckvaj.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_1zkjxProZpPODnmYcUZ-sQ_zv1HUWv9';
  
  // Signup Bonus
  static const double signupBonus = 500.0;
  
  // Discounts
  static const double firstOrderDiscountPercent = 10.0;
  static const double secondOrderDiscountPercent = 10.0;
  static const double subsequentOrderDiscountPercent = 5.0;
  static const double secondOrderMinAmount = 500.0;
  
  // Delivery
  static const double freeDeliveryMinAmount = 500.0;
  static const double deliveryCharge = 20.0;
  
  // Loyalty Points
  static const double firstOrderLoyaltyBonus = 50.0;
  static const double loyaltyPointsPerRupee = 1.0;
  static const int loyaltyWaitingPeriodHours = 72;
  static const double minLoyaltyRedemption = 250.0;
  static const double maxLoyaltyRedemption = 500.0;
  
  // Referral
  static const double referralReward = 50.0;
  
  // Operating Hours
  static const String operatingHoursStart = '14:00';
  static const String operatingHoursEnd = '23:30';
  
  // Service Radius
  static const double minServiceRadiusKm = 3.0;
  static const double maxServiceRadiusKm = 6.0;
  
  // Payment Methods
  static const String paymentCOD = 'COD';
  static const String paymentUPI = 'UPI';
  
  // Order Status
  static const String orderReceived = 'Order Received';
  static const String orderPrepared = 'Order Prepared';
  static const String orderOutForDelivery = 'Out for Delivery';
  static const String orderDelivered = 'Delivered';
  static const String orderCancelled = 'Cancelled';
  
  // UPI Details
  static const String upiId = 'indu@upi';
  static const String upiName = 'Indu Multicuisine Restaurant';
  
  // Pagination
  static const int itemsPerPage = 20;
  
  // Image Constraints
  static const double maxImageSizeMB = 5.0;
  static const int imageQuality = 85;
  
  // Cache Duration
  static const Duration cacheDuration = Duration(hours: 1);
  
  // Validation
  static const int minPasswordLength = 6;
  static const int phoneNumberLength = 10;
  static const int otpLength = 6;
  
  // Admin Role
  static const String adminRole = 'admin';
  
  // Storage Keys
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyThemeMode = 'theme_mode';
  static const String keySelectedAddress = 'selected_address';
}
