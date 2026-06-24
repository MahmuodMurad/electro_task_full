import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_electro/core/constants/storage_constants.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState(ThemeMode.system));

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkSaved = prefs.getBool(StorageConstants.themeMode);
    if (isDarkSaved == null) {
      emit(const ThemeState(ThemeMode.system));
    } else {
      emit(ThemeState(isDarkSaved ? ThemeMode.dark : ThemeMode.light));
    }
  }

  Future<void> toggleTheme(BuildContext context) async {
    final bool currentIsDark;
    if (state.themeMode == ThemeMode.system) {
      currentIsDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    } else {
      currentIsDark = state.themeMode == ThemeMode.dark;
    }

    final newTheme = currentIsDark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageConstants.themeMode, !currentIsDark);
    emit(ThemeState(newTheme));
  }
}

