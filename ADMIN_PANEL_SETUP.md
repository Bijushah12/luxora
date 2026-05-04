# Luxora Admin Panel Setup

The Flutter admin panel is available at the `/admin` route and uses Provider,
Firebase Auth, Cloud Firestore, and Firebase Storage.

## 1. Install Packages

Run:

```bash
flutter pub get
```

The admin panel adds `firebase_storage` for product image uploads. The app
already includes Firebase Auth, Firestore, Provider, and Image Picker.

## 2. Enable Firebase Products

In Firebase Console for project `luxora-watch`:

1. Enable Authentication with Email/Password.
2. Enable Cloud Firestore.
3. Enable Firebase Storage.
4. Deploy `firestore.rules` and `storage.rules`.

Deploy from the repo root:

```bash
firebase deploy --only firestore:rules,storage
```

## 3. Create an Admin Account

Create an Email/Password user in Firebase Authentication, then mark that user
as admin using one of these supported options:

```text
users/{uid}
  role: "admin"
  isAdmin: true
  name: "Luxora Admin"
  email: "admin@example.com"
  phoneNumber: "+91 9876543210"
  createdAt: server timestamp
```

The panel also supports custom claims with `admin: true`, or an
`admins/{uid}` document with `active: true`. For production, custom claims are
the strongest option because users cannot grant themselves that claim from the
client.

## 4. Run the Admin Panel

For web:

```bash
flutter run -d chrome
```

Open:

```text
http://localhost:<port>/admin
```

For Android, Windows, or desktop builds, navigate to `/admin` from code or use
Flutter's route tooling. The user app still starts at the existing splash
screen.

## Firestore Structure

### users

```text
users/{uid}
  uid: "auth-user-id"
  name: "Aarav Mehta"
  email: "aarav@example.com"
  phoneNumber: "+91 9876543210"
  role: "customer"
  isAdmin: false
  createdAt: Timestamp
```

### products

```text
products/{productId}
  name: "Luxora Chronograph"
  description: "Premium stainless steel chronograph watch."
  price: 24999.0
  discount: 10.0
  category: "Men"
  brand: "Luxora"
  imageUrl: "https://firebasestorage.googleapis.com/..."
  image: "https://firebasestorage.googleapis.com/..."
  imagePath: "product_images/..."
  isActive: true
  createdAt: Timestamp
  updatedAt: Timestamp
```

### orders

```text
orders/{orderId}
  userId: "auth-user-id"
  status: "Pending"
  totalAmount: 52998.0
  createdAt: Timestamp
  updatedAt: Timestamp
  userDetails:
    name: "Aarav Mehta"
    email: "aarav@example.com"
    phoneNumber: "+91 9876543210"
  address:
    fullName: "Aarav Mehta"
    phone: "+91 9876543210"
    line1: "Prestige Apartment, Electronic City"
    line2: "Near Metro Station"
    city: "Bengaluru"
    state: "Karnataka"
    pincode: "560001"
  items:
    - productId: "product-id"
      name: "Luxora Chronograph"
      imageUrl: "https://firebasestorage.googleapis.com/..."
      price: 24999.0
      quantity: 2
```

Allowed order statuses are `Pending`, `Shipped`, and `Delivered`.
