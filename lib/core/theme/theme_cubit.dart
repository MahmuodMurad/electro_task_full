import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_electro/core/constants/storage_constants.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState(ThemeMode.light));

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(StorageConstants.themeMode) ?? false;
    emit(ThemeState(isDark ? ThemeMode.dark : ThemeMode.light));
  }

  Future<void> toggleTheme() async {
    final isDark = state.themeMode == ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageConstants.themeMode, !isDark);
    emit(ThemeState(!isDark ? ThemeMode.dark : ThemeMode.light));
  }
}

