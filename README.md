# Indu Multicuisine Restaurant App

A comprehensive food delivery application built with Flutter and Supabase, featuring multi-platform support (Web & Android), advanced authentication, real-time order tracking, and an admin dashboard.

## Features

### User Features
- ✅ Multi-platform support (Web & Android)
- ✅ Email/Password, Google, Facebook authentication
- ✅ Mandatory phone OTP verification
- ✅ ₹500 signup bonus
- ✅ User onboarding for first-time users
- ✅ Browse menu with categories
- ✅ Filter by price, vegetarian, half/full plate
- ✅ Sort by price
- ✅ Add items to cart
- ✅ Shopping cart management
- ✅ Location selection
- ✅ Checkout with UPI QR code and COD
- ✅ Real-time order tracking
- ✅ Rewards system (5% after 2 orders)
- ✅ Referral system
- ✅ Order history
- ✅ User profile management

### Admin Features (Web Only)
- Admin dashboard
- Menu item management
- Order management
- Reports and analytics

## Setup Instructions

### Prerequisites
- Flutter SDK (>=3.2.0)
- Supabase account
- Firebase account (for phone authentication)
- Google Cloud Console (for Google auth)
- Facebook Developer account (for Facebook auth)

### 1. Supabase Setup

1. Create a new Supabase project at https://supabase.com
2. Run the migration script in `supabase/migrations/001_initial_schema.sql` in the Supabase SQL Editor
3. Copy your Supabase URL and Anon Key
4. Update `lib/utils/constants.dart`:
   ```dart
   static const String supabaseUrl = 'YOUR_SUPABASE_URL';
   static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
   ```

### 2. Firebase Setup (for Phone Auth)

1. Create a Firebase project at https://console.firebase.google.com
2. Add Android and Web apps to your Firebase project
3. Download `google-services.json` (Android) and place in `android/app/`
4. Run FlutterFire CLI to configure:
   ```bash
   flutter pub global activate flutterfire_cli
   flutterfire configure
   ```

### 3. Google Authentication Setup

1. Go to Google Cloud Console
2. Create OAuth 2.0 credentials
3. Add the credentials to your Firebase project
4. For Android, add SHA-1 fingerprint

### 4. Facebook Authentication Setup

1. Create an app at https://developers.facebook.com
2. Add Facebook Login product
3. Configure OAuth redirect URIs
4. Add Facebook App ID to your project

### 5. Install Dependencies

```bash
cd indu_restaurant
flutter pub get
```

### 6. Run the App

For Web:
```bash
flutter run -d chrome
```

For Android:
```bash
flutter run -d <device-id>
```

## Project Structure

```
lib/
├── config/          # Configuration files (Supabase, Firebase, Router)
├── models/          # Data models
├── services/        # Business logic and API calls
├── screens/         # UI screens
│   ├── auth/       # Authentication screens
│   ├── home/       # Home screen
│   ├── menu/       # Menu browsing
│   ├── cart/       # Shopping cart
│   ├── checkout/   # Checkout flow
│   ├── orders/     # Order history
│   ├── profile/    # User profile
│   └── admin/      # Admin dashboard
├── widgets/         # Reusable widgets
├── theme/          # App theme
└── utils/          # Utilities and helpers
```

## Color Scheme (Indo-Chinese Inspired)

- Primary Red: #D32F2F (Chinese lanterns)
- Secondary Gold: #FFA000 (Prosperity)
- Accent Green: #388E3C (Fresh ingredients)
- Background: #FFF8E1 (Warm cream)

## Database Schema

See `supabase/migrations/001_initial_schema.sql` for the complete database schema including:
- User profiles
- Menu items and categories
- Shopping cart
- Orders and order items
- Addresses
- Rewards and referrals

## Payment Integration

### UPI QR Code
Update the UPI details in `lib/utils/constants.dart`:
```dart
static const String upiId = 'your-upi-id@upi';
static const String upiName = 'Indu Multicuisine Restaurant';
```

### Cash on Delivery
COD is automatically enabled after the first successful UPI payment.

## Contributing

This is a complete restaurant food delivery system. Feel free to customize and extend based on your needs.

## License

MIT License
