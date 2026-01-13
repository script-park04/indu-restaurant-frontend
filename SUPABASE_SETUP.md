# Supabase Setup Checklist for Indu Restaurant

✅ **COMPLETED:**
- Created Supabase project
- Got credentials and updated constants.dart

## 🔧 NEXT STEPS - Follow these in order:

### Step 1: Run Database Migration (CRITICAL - 3 minutes)

1. **Open Supabase Dashboard**
   - Go to: https://supabase.com/dashboard/project/agukkmffmftbytjckvaj
   - Sign in if needed

2. **Open SQL Editor**
   - Click **SQL Editor** in the left sidebar (icon looks like `</>`)
   - Click **New query** button (top right)

3. **Copy the migration SQL**
   - The file is already open: `supabase/migrations/001_initial_schema.sql`
   - Select ALL content (Cmd+A)
   - Copy it (Cmd+C)

4. **Paste and Run**
   - Go back to Supabase SQL Editor
   - Paste the SQL (Cmd+V)
   - Click **RUN** button (or press Cmd+Enter)
   - Wait for "Success. No rows returned" message

5. **Verify Tables Created**
   - Click **Table Editor** in left sidebar (icon looks like a table)
   - You should see these tables:
     - ✓ profiles
     - ✓ categories
     - ✓ menu_items
     - ✓ cart_items
     - ✓ addresses
     - ✓ orders
     - ✓ order_items
     - ✓ rewards
     - ✓ referrals

---

### Step 2: Add Sample Menu Data (OPTIONAL - 2 minutes)

1. **Go back to SQL Editor**
   - Click **SQL Editor** → **New query**

2. **Copy seed data**
   - The file is already open: `supabase/seed.sql`
   - Select ALL (Cmd+A)
   - Copy (Cmd+C)

3. **Paste and Run**
   - Paste in SQL Editor
   - Click **RUN**

4. **Fix Category IDs** (Important!)
   - Go to **Table Editor** → **categories**
   - You'll see 5 categories with UUIDs
   - Copy each category's UUID
   - Go back to **SQL Editor** → **New query**
   - Run this (replace UUIDs with actual ones):

```sql
-- Get category IDs first
SELECT id, name FROM categories ORDER BY display_order;

-- Then update menu items (replace the UUIDs below with actual ones from above)
UPDATE menu_items SET category_id = 'PASTE-STARTERS-UUID-HERE' 
WHERE name IN ('Veg Spring Rolls', 'Chilli Paneer', 'Chicken Lollipop', 'Veg Manchurian', 'Chicken 65');

UPDATE menu_items SET category_id = 'PASTE-MAIN-COURSE-UUID-HERE' 
WHERE name IN ('Veg Hakka Noodles', 'Chicken Hakka Noodles', 'Veg Fried Rice', 'Chicken Fried Rice', 'Schezwan Noodles');

UPDATE menu_items SET category_id = 'PASTE-SOUPS-UUID-HERE' 
WHERE name IN ('Hot & Sour Soup', 'Manchow Soup', 'Chicken Corn Soup', 'Sweet Corn Soup');

UPDATE menu_items SET category_id = 'PASTE-DESSERTS-UUID-HERE' 
WHERE name IN ('Honey Noodles', 'Date Pancake', 'Ice Cream');
```

---

### Step 3: Enable Email Authentication (2 minutes)

1. **Go to Authentication**
   - Click **Authentication** in left sidebar
   - Click **Providers** tab

2. **Enable Email**
   - Find "Email" in the list
   - Toggle it **ON** (should turn green)
   - Click **Save** if prompted

3. **Configure URLs**
   - Scroll down to **URL Configuration** section
   - Set **Site URL**: `http://localhost:52000`
   - Under **Redirect URLs**, add:
     - `http://localhost:52000/**`
     - `http://localhost:3000/**`
   - Click **Save**

---

### Step 4: Disable Email Confirmation (For Testing)

1. **Still in Authentication → Providers**
   - Scroll to **Email** provider settings
   - Find "Confirm email" toggle
   - Turn it **OFF** (for easier testing)
   - Click **Save**

---

### Step 5: Check RLS Policies (Verify - 1 minute)

1. **Go to Authentication → Policies**
   - You should see policies for all tables
   - If you see policies listed, you're good!
   - If not, the migration might not have run correctly

---

## ✅ Verification Checklist

Before running the app, verify:
- [ ] Tables exist in Table Editor (9 tables)
- [ ] Categories table has 5 rows
- [ ] Menu_items table has items (if you ran seed.sql)
- [ ] Email provider is enabled
- [ ] Site URL is set to http://localhost:52000
- [ ] Email confirmation is disabled (for testing)

---

## 🚀 Ready to Run!

Once you've completed the above steps, run:

```bash
cd /Users/shazra/Work/Side/indu_restaurant
flutter run -d chrome
```

---

## 🐛 Troubleshooting

**"Success. No rows returned" - Is this correct?**
- YES! This is the expected message for DDL statements (CREATE TABLE, etc.)

**Can't find SQL Editor**
- Look for `</>` icon in left sidebar
- Or search for "SQL" in the top search bar

**Tables not showing in Table Editor**
- Make sure the migration ran successfully
- Try refreshing the page
- Check for any error messages in SQL Editor

**Need to start over?**
- In SQL Editor, run: `DROP SCHEMA public CASCADE; CREATE SCHEMA public;`
- Then run the migration again

---

**Questions? Let me know which step you're on and I'll help!** 🙂
