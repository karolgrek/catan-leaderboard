class AppConstants {
  AppConstants._();

  // Firebase & Storage
  static const String storageBucket =
      'catan-leaderboard-1be8b.firebasestorage.app';
  static const String usersCollection = 'users';
  static const String groupsCollection = 'groups';
  static const String sessionsCollection = 'sessions';
  static const String notificationsCollection = 'notifications';

  // Photo Compression
  static const int maxPhotoDimension = 1440;
  static const int photoJpegQuality = 75;

  // Game & Leaderboard Rules
  static const int maxStandardPlayers = 4;
  static const int minWinStreakForAlert = 2;
  static const int underdogLossStreakThreshold = 5;
  static const int initialDisplayedSessionsCount = 3;
  static const int topMedalsCount = 3;

  // Catan Probability Dots for Leaderboard Ranks
  static const String rankDotsFirst = '•••••';
  static const String rankDotsSecond = '••••';
  static const String rankDotsThird = '•••';
  static const String rankDotsDefault = '••';

  // Hex Background & UI Geometry
  static const double hexRadius = 34.0;
  static const double hexColorAlpha = 0.20;
  static const double hexStrokeAlpha = 0.16;
  static const double hexStrokeWidth = 1.2;
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;
  static const double drawerTopRadius = 32.0;

  // Date Picker Bounds
  static const int minPickerYear = 2000;
  static const int maxPickerYear = 2101;
}
