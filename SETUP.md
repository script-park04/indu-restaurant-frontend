## Indu Multicuisine Restaurant - Setup Guide

This guide will help you set up and configure the Indu Multicuisine Restaurant app.

### Step 1: Supabase Configuration

1. **Create a Supabase Project**
   - Go to https://supabase.com and create a new project
   - Wait for the project to be fully initialized

2. **Run Database Migration**
   - Navigate to the SQL Editor in your Supabase dashboard
   - Copy the contents of `supabase/migrations/001_initial_schema.sql`
   - Paste and run the SQL script

3. **Get Your Credentials**
   - Go to Project Settings > API
   - Copy the `Project URL` and `anon public` key
   - Update `lib/utils/constants.dart`:
     ```dart
     static const String supabaseUrl = 'https://your-project.supabase.co';
     static const String supabaseAnonKey = 'your-anon-key';
     ```

4. **Configure Authentication Providers**
   - Go to Authentication > Providers in Supabase
   - Enable Email provider
   - Enable Google provider (add Client ID and Secret from Google Cloud Console)
   - Enable Facebook provider (add App ID and Secret from Facebook Developers)

### Step 2: Firebase Configuration (for Phone Auth)

1. **Create Firebase Project**
   - Go to https://console.firebase.google.com
   - Create a new project or use existing one
   - Add Android and Web apps

2. **Configure Android**
   - Download `google-services.json`
   - Place it in `android/app/`
   - Add SHA-1 fingerprint to Firebase Console

3. **Run FlutterFire CLI**
   ```bash
   flutter pub global activate flutterfire_cli
   cd indu_restaurant
   flutterfire configure
   ```

4. **Enable Phone Authentication**
   - In Firebase Console, go to Authentication > Sign-in method
   - Enable Phone authentication

### Step 3: Google Sign-In Setup

1. **Google Cloud Console**
   - Go to https://console.cloud.google.com
   - Create OAuth 2.0 credentials
   - Add authorized redirect URIs

2. **For Android**
   - Add SHA-1 fingerprint
   - Download and add to Firebase

3. **For Web**
   - Add authorized JavaScript origins
   - Add authorized redirect URIs

### Step 4: Facebook Login Setup

1. **Facebook Developers**
   - Go to https://developers.facebook.com
   - Create a new app
   - Add Facebook Login product

2. **Configure OAuth**
   - Add OAuth redirect URIs
   - Get App ID and App Secret
   - Add to Supabase and Firebase

### Step 5: UPI Payment Configuration

Update the UPI details in `lib/utils/constants.dart`:
```dart
static const String upiId = 'your-merchant@upi';
static const String upiName = 'Indu Multicuisine Restaurant';
```

### Step 6: Run the App

```bash
# Install dependencies
flutter pub get

# Run on web
flutter run -d chrome

# Run on Android
flutter run

# Build for production
flutter build apk --release  # Android
flutter build web --release  # Web
```

### Troubleshooting

**Issue: Firebase not initializing**
- Make sure you've run `flutterfire configure`
- Check that `firebase_options.dart` exists in `lib/`

**Issue: Supabase connection failed**
- Verify your Supabase URL and anon key are correct
- Check that your Supabase project is active

**Issue: Google Sign-In not working**
- Verify SHA-1 fingerprint is added to Firebase
- Check OAuth credentials in Google Cloud Console

**Issue: Phone OTP not sending**
- Verify Firebase Phone Auth is enabled
- Check that you've added your phone number for testing in Firebase Console

### Next Steps

1. Add menu items via Supabase dashboard or create admin panel
2. Test the complete user flow
3. Configure production UPI payment gateway
4. Deploy to production

For more information, see the main README.md file.
