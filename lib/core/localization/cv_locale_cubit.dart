import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CvLocaleCubit extends Cubit<Locale> {
  CvLocaleCubit() : super(const Locale('en')) {
    _loadSavedLocale();
  }

  static const String _storageKey = 'cv_locale';

  Future<void> _loadSavedLocale() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final savedLanguage = preferences.getString(_storageKey);

      if (savedLanguage == 'ar') {
        emit(const Locale('ar'));
      } else if (savedLanguage == 'en') {
        emit(const Locale('en'));
      }
    } catch (_) {
      // Keep English as the default if local storage is unavailable.
    }
  }

  void setLocale(Locale locale) {
    final languageCode = locale.languageCode;

    if (languageCode != 'ar' && languageCode != 'en') {
      return;
    }

    if (languageCode == state.languageCode) {
      return;
    }

    final newLocale = Locale(languageCode);

    emit(newLocale);
    _saveLocale(languageCode);
  }

  void setArabic() {
    setLocale(const Locale('ar'));
  }

  void setEnglish() {
    setLocale(const Locale('en'));
  }

  void toggleLocale() {
    if (state.languageCode == 'ar') {
      setEnglish();
    } else {
      setArabic();
    }
  }

  Future<void> _saveLocale(String languageCode) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_storageKey, languageCode);
    } catch (_) {
      // Ignore storage errors. The current session still works normally.
    }
  }
}
