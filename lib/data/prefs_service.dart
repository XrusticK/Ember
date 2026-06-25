import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';

/// Тонкая типизированная обёртка над SharedPreferences.
/// Единственный класс, который знает о существовании самого хранилища.
class PrefsService {
  PrefsService(this._prefs);

  final SharedPreferences _prefs;

  static Future<PrefsService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return PrefsService(prefs);
  }

  bool get onboardingDone => _prefs.getBool(PrefKeys.onboardingDone) ?? false;
  Future<void> setOnboardingDone(bool v) =>
      _prefs.setBool(PrefKeys.onboardingDone, v);

  bool get isPremium => _prefs.getBool(PrefKeys.isPremium) ?? false;
  Future<void> setPremium(bool v) => _prefs.setBool(PrefKeys.isPremium, v);

  int get streakCount => _prefs.getInt(PrefKeys.streakCount) ?? 0;
  Future<void> setStreakCount(int v) => _prefs.setInt(PrefKeys.streakCount, v);

  /// Дата последнего «прочитано» в формате yyyy-MM-dd (или null).
  String? get lastOpenDate => _prefs.getString(PrefKeys.lastOpenDate);
  Future<void> setLastOpenDate(String v) =>
      _prefs.setString(PrefKeys.lastOpenDate, v);

  List<String> get favorites => _prefs.getStringList(PrefKeys.favorites) ?? [];
  Future<void> setFavorites(List<String> v) =>
      _prefs.setStringList(PrefKeys.favorites, v);

  String? get selectedTheme => _prefs.getString(PrefKeys.selectedTheme);
  Future<void> setSelectedTheme(String v) =>
      _prefs.setString(PrefKeys.selectedTheme, v);
}
