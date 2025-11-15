// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'mescat_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MesCat';

  @override
  String get welcomeMessage => 'Welcome to MesCat!';

  @override
  String get loginButton => 'Log In';

  @override
  String get signupButton => 'Sign Up';

  @override
  String get logoutButton => 'Log Out';

  @override
  String get profileTitle => 'User Profile';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageOption => 'Language';

  @override
  String get themeOption => 'Theme';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get disableNotifications => 'Disable Notifications';
}
