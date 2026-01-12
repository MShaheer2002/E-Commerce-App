---
description: Apple App Store Compliance Implementation Plan
---

# Apple App Store Compliance Implementation

## Overview
Implement Sign in with Apple, Account Deletion, and Guest Browsing to comply with Apple App Store guidelines.

## 1️⃣ Sign in with Apple (iOS Only)

### Implementation Steps:

1. **Update login_screen.dart**
   - Uncomment and fix the Apple Sign-In button (lines 247-283)
   - Add Platform.isIOS check
   - Ensure button follows Apple HIG (white background, black text, Apple logo)
   - Position below Google Sign-In button

2. **Update auth_provider.dart**
   - Fix signInWithApple() method (lines 156-175)
   - Add ProfileSetupProvider parameter to save user data
   - Ensure it creates Firestore profile like Google Sign-In does

3. **iOS Configuration Required**
   - Enable Sign in with Apple capability in Xcode
   - Update Info.plist if needed
   - Firebase Console: Enable Apple as sign-in provider

## 2️⃣ Delete Account Flow

### Implementation Steps:

1. **Create delete_account_dialog.dart**
   - Confirmation dialog with text input
   - User must type "DELETE" exactly
   - Show warning message
   - Confirm/Cancel buttons

2. **Update auth_provider.dart**
   - Add deleteAccount() method
   - Delete from Firebase Authentication
   - Delete from Firestore (users collection)
   - Handle re-authentication if needed
   - Clear local cache

3. **Update profile_screen.dart**
   - Add "Delete Account" menu item in Account section
   - Position after "Order History", before "Logout"
   - Red color to indicate danger

4. **Firestore Cleanup**
   - Delete user document from 'users' collection
   - Delete cart data from 'carts' collection
   - Delete orders from 'orders' collection (or mark as deleted)
   - Delete favorites

## 3️⃣ Guest Browsing + Login-Gated Actions

### Implementation Steps:

1. **Update GoRoute_routing.dart**
   - Remove forced redirect to /login for unauthenticated users
   - Allow access to: /, /home, /products, /single-product, /category-screen, /product-by-category
   - Block access to: /checkout-screen, /order-status, /favorite-screen, profile
   - Create helper function to check if route requires auth

2. **Create auth_gate_helper.dart**
   - Helper to check if user is authenticated
   - Show login prompt dialog
   - Store intended action/route
   - Resume action after login

3. **Update single_product_screen.dart**
   - Check auth before "Add to Cart" (line 246-266)
   - Show login prompt if not authenticated
   - After login, add item to cart

4. **Update cart_provider.dart**
   - Handle guest state gracefully
   - Don't crash if userId is null

5. **Update favorite (fav_provider.dart)**
   - Check auth before toggling favorite
   - Show login prompt if not authenticated

6. **Update checkout flow**
   - Already protected by routing
   - Add additional check at checkout_screen.dart

7. **Update home navigation**
   - Allow bottom nav to show all tabs
   - Show login prompt when accessing profile/favorites/cart as guest

## 4️⃣ Firebase Configuration Requirements

### Firebase Console Changes:
1. **Authentication Providers**
   - Enable Apple Sign-In provider
   - Configure Service ID, Team ID, Key ID, Private Key

2. **Firestore Rules**
   - Allow read access to products for unauthenticated users
   - Require authentication for write operations
   - Require authentication for user-specific data (cart, favorites, orders)

### iOS Configuration:
1. **Xcode**
   - Enable "Sign in with Apple" capability
   - Update Bundle ID if needed

2. **Apple Developer Console**
   - Create App ID with Sign in with Apple capability
   - Create Service ID for Firebase
   - Create Sign in with Apple Key
   - Configure return URLs

3. **Info.plist**
   - May need to add Apple Sign-In configuration

### Android:
- No changes needed (Apple Sign-In won't show on Android)

## Testing Checklist

### Sign in with Apple:
- [ ] Button only shows on iOS
- [ ] Button follows Apple HIG
- [ ] Sign-in flow works correctly
- [ ] User profile created in Firestore
- [ ] Can access app after sign-in

### Delete Account:
- [ ] Dialog shows with correct warning
- [ ] Must type "DELETE" to enable confirm
- [ ] Account deleted from Firebase Auth
- [ ] User data deleted from Firestore
- [ ] Redirected to login screen
- [ ] Cannot log in with deleted account

### Guest Browsing:
- [ ] Can browse products without login
- [ ] Can view product details without login
- [ ] Cannot add to cart without login (shows prompt)
- [ ] Cannot access favorites without login (shows prompt)
- [ ] Cannot checkout without login
- [ ] Cannot access profile without login
- [ ] After login, can perform all actions
- [ ] After login from prompt, original action resumes

## Implementation Order

1. Guest Browsing (Foundation)
2. Sign in with Apple (New login method)
3. Delete Account (Compliance requirement)
4. Firebase Configuration
5. Testing
