rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    /* ============================
       HELPERS
    ============================ */

    function isSignedIn() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }

    // Modernized isAdmin check with hardcoded fallback for dev/admin seed
    function isAdmin() {
      return isSignedIn() && (
        request.auth.token.email == "admin@admin.com" ||
        (
          exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
          get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == "admin"
        )
      );
    }

    /* ============================
       PUBLIC (GUEST READ)
    ============================ */

    match /products/{productId} {
      allow read: if true;
      allow write: if isAdmin();
    }

    match /categories/{categoryId} {
      allow read: if true;
      allow write: if isAdmin();
    }

    match /banners/{bannerId} {
      allow read: if true;
      allow write: if isAdmin();
    }

    /* ============================
       APP SETTINGS & TAXES
    ============================ */

    match /app_settings/{docId} {
      allow read: if true;
      allow write: if isAdmin();
    }

    match /taxes/{taxId} {
      allow read: if true;
      allow write: if isAdmin();
    }

    match /StateSalesTax/{taxId} {
      allow read: if true;
      allow write: if isAdmin();
    }

    /* ============================
       USERS & NOTIFICATIONS
    ============================ */

    match /users/{userId} {
      // Allow creation if it's the user's own doc
      // Enforce role: 'user' ONLY if role is provided
      allow create: if isOwner(userId) && 
        (!('role' in request.resource.data) || request.resource.data.role == 'user');

      allow read: if isOwner(userId) || isAdmin();

      allow update: if
        // ✅ Admin can update any user
        isAdmin() ||
        // ✅ User can update own data (no role escalation)
        (
          isOwner(userId) && (
            (!('role' in request.resource.data)) ||
            (request.resource.data.role == resource.data.role)
          )
        );

      allow delete: if isAdmin();

      // User's own notification subcollection
      match /notifications/{notificationId} {
        allow read, write: if isOwner(userId) || isAdmin();
      }
    }

    /* ============================
       CARTS
    ============================ */

    match /carts/{userId} {
      allow read, write: if isOwner(userId) || isAdmin();
    }

    /* ============================
       FAVORITES
    ============================ */

    match /favorites/{favoriteId} {
      allow create: if isSignedIn() && request.resource.data.userId == request.auth.uid;
      allow read, update, delete: if isSignedIn() && (resource.data.userId == request.auth.uid || isAdmin());
    }

    /* ============================
       ORDERS
    ============================ */

    match /orders/{orderId} {
      allow create: if isSignedIn() && request.resource.data.userId == request.auth.uid;
      allow read: if isSignedIn() && (resource.data.userId == request.auth.uid || isAdmin());
      allow update, delete: if isAdmin();
    }

    /* ============================
       ANALYTICS, LOGS & COUNTERS
    ============================ */

    match /global_analytics/{document=**} {
      // Users need to read/write to update aggregate stats during transactions
      allow read, write: if isSignedIn();
    }

    match /product_analytics/{documentId} {
      // Users need to read (to check existence in transaction) and write
      allow read, write: if isSignedIn();
    }

    match /sales_logs/{logId} {
      allow write: if isSignedIn();
      allow read: if isAdmin();
    }

    match /counters/{counterId} {
      // Users need to read the current count to increment it in a transaction
      allow read, update: if isSignedIn();
      allow create, delete: if isAdmin();
    }

    /* ============================
       CATCH-ALL
    ============================ */

    match /{document=**} {
      allow read, write: if false;
    }
  }
}
