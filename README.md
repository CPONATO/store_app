# Shop App - Flutter E-commerce Application

## 📱 Overview

Shop App is a comprehensive e-commerce mobile application built with Flutter and Riverpod for state management. The app provides a complete shopping experience with user authentication, product browsing, cart management, order processing, and user account features.

## ✨ Features

### 🔐 Authentication

- User registration and login
- Secure token-based authentication
- Account management and profile updates
- Account deletion functionality

### 🛍️ Shopping Experience

- Browse products by categories and subcategories
- Search products with real-time results
- Product detail pages with image galleries
- Product reviews and ratings
- Popular and top-rated product sections

### 🛒 Cart & Favorites

- Add/remove products to cart
- Quantity management
- Persistent cart across sessions
- Favorites/wishlist functionality
- User-specific cart and favorites storage

### 📦 Order Management

- Complete checkout process
- Shipping address management
- Order history and tracking
- Order status updates (Processing, Delivered)
- Cash on Delivery payment option

### 👤 User Profile

- Profile information management
- Shipping address configuration
- Order statistics dashboard
- Delivered order count tracking

### 🏪 Store Features

- Browse different vendors/stores
- View vendor-specific products
- Store information and descriptions

## 🛠️ Technical Stack

### Frontend

- **Framework**: Flutter 3.7.2+
- **State Management**: Riverpod 2.5.1
- **HTTP Client**: http 1.2.1
- **Local Storage**: SharedPreferences 2.2.3
- **UI Components**: Cupertino Icons, Google Fonts
- **Ratings**: Custom Rating Bar 3.0.0

### Backend Integration

- RESTful API integration
- Token-based authentication
- Image handling and display
- Error handling and response management

## 📁 Project Structure

```
lib/
├── controllers/           # API controllers for different features
│   ├── auth_controller.dart
│   ├── product_controller.dart
│   ├── order_controller.dart
│   └── ...
├── models/               # Data models
│   ├── user.dart
│   ├── product.dart
│   ├── cart.dart
│   └── ...
├── provider/             # Riverpod state providers
│   ├── user_provider.dart
│   ├── cart_provider.dart
│   ├── favorite_provider.dart
│   └── ...
├── services/             # Utility services
│   └── manage_http_response.dart
├── views/                # UI screens and widgets
│   ├── screens/
│   │   ├── authentication_screens/
│   │   ├── nav_screens/
│   │   └── detail/
│   └── widgets/
└── global_variables.dart # Global configuration
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.7.2 or higher)
- Dart SDK
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd shop_app
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure backend URL**

   ```dart
   // In lib/global_variables.dart
   String uri = 'http://your-backend-url:port';
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

## 🔧 Configuration

### Backend API Configuration

Update the `uri` variable in `lib/global_variables.dart` to point to your backend server:

```dart
String uri = 'http://your_ip:3000'; // Development
// String uri = 'https://your-production-api.com'; // Production
```

### Dependencies

The app uses the following main dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  google_fonts: ^6.1.0
  http: ^1.2.1
  flutter_riverpod: ^2.5.1
  shared_preferences: ^2.2.3
  custom_rating_bar: ^3.0.0
  flutter_stripe: ^10.1.1
```

## 📱 App Flow

### Main Navigation

The app uses a bottom navigation bar with the following tabs:

- **Home**: Featured products, categories, banners
- **Favorites**: User's saved products
- **Category**: Browse by product categories
- **Store**: Browse different vendors
- **Cart**: Shopping cart management
- **Account**: User profile and settings

### Key User Flows

1. **Registration/Login Flow**

   - User creates account or logs in
   - Token stored securely in SharedPreferences
   - Automatic state restoration on app restart

2. **Shopping Flow**

   - Browse products by category or search
   - View product details with images and reviews
   - Add to cart or favorites
   - Proceed to checkout with shipping address
   - Place order with payment method selection

3. **Order Management**
   - View order history
   - Track order status
   - Leave product reviews for delivered orders

## 🎨 UI/UX Features

- **Modern Design**: Clean, intuitive interface with consistent theming
- **Responsive Layout**: Adapts to different screen sizes
- **Loading States**: Proper loading indicators and error handling
- **Image Handling**: Fallback for failed image loads
- **Smooth Navigation**: Fluid transitions between screens
- **Search Functionality**: Real-time product search

## 📊 State Management

The app uses Riverpod for state management with the following providers:

- `userProvider`: User authentication state
- `cartProvider`: Shopping cart state
- `favoriteProvider`: Favorites/wishlist state
- `orderProvider`: Order history state
- `categoryProvider`: Product categories
- `productProvider`: Product listings
- And more...

## 🔄 Data Persistence

- **User Authentication**: Tokens stored in SharedPreferences
- **Cart Data**: Per-user cart persistence
- **Favorites**: Per-user favorites storage
- **User Preferences**: App settings and user data

## 🐛 Error Handling

The app includes comprehensive error handling:

- Network error management
- API response error handling
- User-friendly error messages
- Fallback UI states for empty data
- Image loading error handling

## 🔮 Future Enhancements

Potential improvements and features:

- [ ] Push notifications for order updates
- [ ] Advanced search filters
- [ ] Product recommendations
- [ ] Social sharing features
- [ ] Multiple payment gateways
- [ ] Dark mode support
- [ ] Offline mode capabilities
- [ ] Advanced analytics

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Riverpod for excellent state management
- All contributors and testers

---

**Made with ❤️ using Flutter**
