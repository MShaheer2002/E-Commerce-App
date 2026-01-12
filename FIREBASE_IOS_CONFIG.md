# Firebase & iOS Configuration Guide for Apple Compliance

## 🔥 Firebase Console Configuration

### 1. Enable Apple Sign-In Provider

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to **Authentication** → **Sign-in method**
4. Click on **Apple** in the providers list
5. Click **Enable**
6. You'll need to configure:
   - **Service ID**: Create this in Apple Developer Console (see below)
   - **Apple Team ID**: Found in Apple Developer Console → Membership
   - **Key ID**: From the Apple Sign-In Key you'll create
   - **Private Key**: Download from Apple Developer Console

### 2. Update Firestore Security Rules

Update your Firestore rules to allow guest browsing while protecting user data:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Products - Allow read for everyone (guest browsing)
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Categories - Allow read for everyone
    match /categories/{categoryId} {
      allow read: if true;
      allow write: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Banners - Allow read for everyone
    match /banners/{bannerId} {
      allow read: if true;
      allow write: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    // App Settings (Promo Codes) - Allow read for everyone
    match /app_settings/{document=**} {
      allow read: if true;
      allow write: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    // Taxes - Allow read for everyone
    match /taxes/{taxId} {
       allow read: if true;
       allow write: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Users - Require authentication
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Carts - Require authentication
    match /carts/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Favorites - Require authentication
    match /favorites/{favoriteId} {
      allow read, write: if request.auth != null && resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
    }
    
    // Orders - Require authentication
    match /orders/{orderId} {
      allow read: if request.auth != null && resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
      allow update: if request.auth != null && (
        resource.data.userId == request.auth.uid ||
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin'
      );
    }
    
    // Analytics - Allow write for everyone (counters), Admin only read
    match /analytics/{document=**} {
      allow write: if true;
      allow read: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

## 🍎 Apple Developer Console Configuration

### 1. Enable Sign in with Apple for Your App ID

1. Go to [Apple Developer Console](https://developer.apple.com/account/)
2. Navigate to **Certificates, Identifiers & Profiles**
3. Select **Identifiers**
4. Find your App ID (e.g., `com.yourcompany.productplug`)
5. Click **Edit**
6. Check **Sign in with Apple**
7. Click **Save**

### 2. Create a Service ID

1. In **Identifiers**, click the **+** button
2. Select **Services IDs** and click **Continue**
3. Enter:
   - **Description**: ProductPlug Sign in with Apple
   - **Identifier**: `com.yourcompany.productplug.signin` (must be different from App ID)
4. Click **Continue** and **Register**
5. Click on your new Service ID
6. Check **Sign in with Apple**
7. Click **Configure**
8. Add your domain and return URLs:
   - **Domains**: Your Firebase project domain (e.g., `productplug-12345.firebaseapp.com`)
   - **Return URLs**: 
     - `https://productplug-12345.firebaseapp.com/__/auth/handler`
     - Replace `productplug-12345` with your Firebase project ID
9. Click **Save** and **Continue**

### 3. Create a Sign in with Apple Key

1. In **Certificates, Identifiers & Profiles**, select **Keys**
2. Click the **+** button
3. Enter a **Key Name**: ProductPlug Apple Sign In Key
4. Check **Sign in with Apple**
5. Click **Configure** next to Sign in with Apple
6. Select your **Primary App ID**
7. Click **Save** and **Continue**
8. Click **Register**
9. **Download the key file** (.p8) - You can only download this ONCE!
10. Note the **Key ID** shown on the page

### 4. Find Your Team ID

1. In Apple Developer Console, click your name in the top right
2. Select **Membership**
3. Your **Team ID** is shown on this page

### 5. Configure Firebase with Apple Credentials

Now go back to Firebase Console:

1. **Authentication** → **Sign-in method** → **Apple**
2. Enter:
   - **Service ID**: `com.yourcompany.productplug.signin`
   - **Apple Team ID**: From step 4
   - **Key ID**: From step 3
   - **Private Key**: Open the .p8 file you downloaded and paste the contents
3. Click **Save**

## 📱 iOS Xcode Configuration

### 1. Enable Sign in with Apple Capability

1. Open your project in Xcode
2. Select your project in the navigator
3. Select the **Runner** target
4. Go to **Signing & Capabilities** tab
5. Click **+ Capability**
6. Search for and add **Sign in with Apple**

### 2. Verify Bundle Identifier

Make sure your Bundle Identifier matches the App ID you configured in Apple Developer Console:

1. In Xcode, select **Runner** target
2. Go to **General** tab
3. Verify **Bundle Identifier** matches (e.g., `com.yourcompany.productplug`)

### 3. Update Info.plist (if needed)

The `Info.plist` file should already have the necessary permissions. Verify it contains:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- REVERSED_CLIENT_ID -->
            <string>com.googleusercontent.apps.217641499247-f1p7jphqv5enkjbr8jr7fg5j565hrqum</string>
        </array>
    </dict>
</array>
```

## ✅ Testing Checklist

### Before Submitting to App Store:

- [ ] Apple Sign-In button appears on iOS devices only
- [ ] Apple Sign-In button follows Apple HIG (white background, black text)
- [ ] Apple Sign-In creates user profile in Firestore
- [ ] Can browse products without login
- [ ] Cannot add to cart without login (shows prompt)
- [ ] Cannot access favorites without login (shows prompt)
- [ ] Cannot checkout without login
- [ ] Delete Account button appears in Profile → Settings
- [ ] Delete Account dialog requires typing "DELETE"
- [ ] Account deletion removes user from Firebase Auth
- [ ] Account deletion removes all user data from Firestore
- [ ] After deletion, cannot log in with deleted account
- [ ] Firestore rules allow guest read access to products
- [ ] Firestore rules block guest write access

## 🚨 Important Notes

### Account Deletion

- Account deletion is **permanent** and cannot be undone
- All user data is deleted from Firestore (profile, cart, favorites, orders)
- The user is deleted from Firebase Authentication
- If a user tries to delete their account shortly after logging in, they may need to re-authenticate first (Firebase security requirement)

### Guest Browsing

- Guests can browse products, view details, and search
- Guests cannot add to cart, checkout, or access favorites
- When a guest tries a restricted action, they see a login prompt
- After successful login, the app should resume the intended action

### Apple Sign-In Requirements

- Must be visible on iOS devices
- Must not be hidden or de-prioritized compared to other sign-in options
- Must follow Apple Human Interface Guidelines
- Button text should be "Continue with Apple" or "Sign in with Apple"

## 📝 Configuration Summary

**When to configure:**

1. **Before Development**: 
   - Enable Apple Sign-In in Apple Developer Console
   - Create Service ID and Key
   - Configure Firebase Authentication

2. **Before Testing**:
   - Update Firestore security rules
   - Enable Sign in with Apple capability in Xcode

3. **Before App Store Submission**:
   - Verify all Apple compliance requirements
   - Test account deletion flow
   - Test guest browsing
   - Ensure Apple Sign-In is visible on iOS

**Required Information:**

- Apple Team ID
- Service ID (created in Apple Developer Console)
- Key ID (from Apple Sign-In Key)
- Private Key (.p8 file contents)
- Firebase Project ID
- App Bundle Identifier

## 🔗 Useful Links

- [Firebase Authentication Docs](https://firebase.google.com/docs/auth)
- [Apple Sign-In Documentation](https://developer.apple.com/sign-in-with-apple/)
- [Apple App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
