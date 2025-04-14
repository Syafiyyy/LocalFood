/// App-wide constants for Localicious
class AppConstants {
  // App Info
  static const String appName = 'Localicious';
  static const String appTagline = 'Eat & Explore';
  static const String appVersion = '1.0.0';
  
  // Shared Preferences Keys
  static const String prefUserId = 'user_id';
  static const String prefUserEmail = 'user_email';
  static const String prefUserName = 'user_name';
  static const String prefIsLoggedIn = 'is_logged_in';
  
  // Default Values
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(seconds: 2);
}

/// Firebase collection names and other Firebase constants
class FirebaseConstants {
  static const String usersCollection = 'users';
  static const String restaurantsCollection = 'restaurants';
  static const String reviewsCollection = 'reviews';
}

/// Navigation route names
class RouteConstants {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String restaurant = '/restaurant';
}

/// Animation durations
class AnimationDurations {
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds:
  500);
}

/// Navigation bar indices
class NavigationConstants {
  static const int homeIndex = 0;
  static const int exploreIndex = 1;
  static const int profileIndex = 2;
}
