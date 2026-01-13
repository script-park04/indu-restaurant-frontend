# Quick Start Guide - Indu Multicuisine Restaurant

## Step 1: Create Supabase Project (5 minutes)

1. **Go to Supabase**
   - Open https://supabase.com in your browser
   - Click "Start your project" or "Sign In"
   - Create a new account or sign in with GitHub

2. **Create New Project**
   - Click "New Project"
   - Fill in:
     - **Name**: `indu-restaurant` (or any name you prefer)
     - **Database Password**: Create a strong password (SAVE THIS!)
     - **Region**: Choose closest to you (e.g., Mumbai for India)
   - Click "Create new project"
   - Wait 2-3 minutes for project to initialize

3. **Get Your Credentials**
   - Once ready, go to **Project Settings** (gear icon in sidebar)
   - Click **API** in the left menu
   - Copy these two values:
     - **Project URL** (looks like: `https://xxxxx.supabase.co`)
     - **anon public** key (long string starting with `eyJ...`)

## Step 2: Configure App with Supabase Credentials (2 minutes)

1. **Open the constants file**
   ```bash
   open lib/utils/constants.dart
   ```

2. **Replace the placeholder values** (lines 8-9):
   ```dart
   // BEFORE:
   static const String supabaseUrl = 'YOUR_SUPABASE_URL';
   static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
   
   // AFTER (use your actual values):
   static const String supabaseUrl = 'https://xxxxx.supabase.co';
   static const String supabaseAnonKey = 'eyJhbGc...your-actual-key';
   ```

3. **Save the file** (Cmd+S or Ctrl+S)

## Step 3: Set Up Database Schema (5 minutes)

1. **Go to SQL Editor in Supabase**
   - In your Supabase dashboard, click **SQL Editor** in the left sidebar
   - Click **New query**

2. **Copy the database schema**
   ```bash
   # In terminal, display the schema file:
   cat supabase/migrations/001_initial_schema.sql
   ```

3. **Paste and Run**
   - Copy the entire contents
   - Paste into the SQL Editor in Supabase
   - Click **Run** (or press Cmd+Enter)
   - You should see "Success. No rows returned"

4. **Verify Tables Created**
   - Click **Table Editor** in sidebar
   - You should see tables: profiles, menu_items, categories, cart_items, orders, etc.

## Step 4: Add Sample Menu Data (Optional - 3 minutes)

1. **Open SQL Editor again**
   - Click **New query**

2. **Run seed data**
   ```bash
   # Display seed file:
   cat supabase/seed.sql
   ```

3. **Copy and paste** the seed.sql contents into SQL Editor
4. **Click Run**
5. **Update category IDs**:
   - Go to Table Editor → categories
   - Copy the UUID of each category
   - Go back to SQL Editor and run:
   ```sql
   -- Replace 'category-uuid-here' with actual UUIDs from your categories table
   UPDATE menu_items SET category_id = 'starters-uuid' WHERE name IN ('Veg Spring Rolls', 'Chilli Paneer', 'Chicken Lollipop', 'Veg Manchurian', 'Chicken 65');
   UPDATE menu_items SET category_id = 'main-course-uuid' WHERE name IN ('Veg Hakka Noodles', 'Chicken Hakka Noodles', 'Veg Fried Rice', 'Chicken Fried Rice', 'Schezwan Noodles');
   UPDATE menu_items SET category_id = 'soups-uuid' WHERE name IN ('Hot & Sour Soup', 'Manchow Soup', 'Chicken Corn Soup', 'Sweet Corn Soup');
   UPDATE menu_items SET category_id = 'desserts-uuid' WHERE name IN ('Honey Noodles', 'Date Pancake', 'Ice Cream');
   ```

## Step 5: Enable Authentication Providers (5 minutes)

1. **Go to Authentication Settings**
   - In Supabase dashboard, click **Authentication** → **Providers**

2. **Enable Email Provider**
   - Find "Email" in the list
   - Toggle it ON
   - Click "Save"

3. **Configure Site URL** (Important!)
   - Scroll to "Site URL" at the bottom
   - Set to: `http://localhost:3000` (for development)
   - Add redirect URLs:
     - `http://localhost:3000/**`
     - `http://localhost:52000/**` (Flutter web default)

## Step 6: Run the App! (2 minutes)

1. **Open terminal in project directory**
   ```bash
   cd /Users/shazra/Work/Side/indu_restaurant
   ```

2. **Run on Chrome (Web)**
   ```bash
   flutter run -d chrome
   ```

3. **Or run on Android** (if you have device/emulator)
   ```bash
   flutter run
   ```

4. **Wait for app to launch** (30-60 seconds first time)

## Step 7: Test the App

1. **Sign Up**
   - Click "Sign Up"
   - Enter name, email, password
   - Click "Sign Up"

2. **Skip Phone Verification** (for now)
   - Phone verification requires Firebase setup
   - You can skip this for initial testing
   - Click back and go to home

3. **Browse Menu**
   - You should see your sample menu items
   - Try filtering and sorting
   - Add items to cart

## Troubleshooting

### Error: "Supabase not initialized"
- Make sure you updated `lib/utils/constants.dart` with your actual credentials
- Restart the app

### Error: "Failed to load menu"
- Check that you ran the database migration (Step 3)
- Verify tables exist in Supabase Table Editor

### App won't start
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run -d chrome
```

### No menu items showing
- Make sure you ran the seed.sql (Step 4)
- Check Table Editor → menu_items has data
- Verify category_id is set for items

## Next Steps (Optional)

### Set Up Google Sign-In
1. Go to https://console.cloud.google.com
2. Create OAuth credentials
3. Add to Supabase Authentication → Providers → Google

### Set Up Firebase Phone Auth
1. Run: `flutterfire configure`
2. Enable Phone Auth in Firebase Console
3. Add test phone numbers

### Add Your Own Menu Items
1. Go to Supabase → Table Editor → menu_items
2. Click "Insert row"
3. Fill in details and save

## Quick Commands Reference

```bash
# Run on web
flutter run -d chrome

# Run on Android
flutter run

# Clean build
flutter clean && flutter pub get

# Check for issues
flutter doctor

# Build for production
flutter build web --release
flutter build apk --release
```

## Support

If you encounter issues:
1. Check the main [README.md](README.md)
2. See detailed [SETUP.md](SETUP.md)
3. Review [walkthrough.md](walkthrough.md) in the .gemini folder

---

**You're all set! Enjoy your restaurant app! 🎉**
