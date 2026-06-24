import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart' show BuildContext;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_electro/core/constants/storage_constants.dart';
import 'locale_state.dart';

class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit() : super(const LocaleState(Locale('en')));

  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(StorageConstants.locale);
    String code;
    if (savedLocale != null) {
      code = savedLocale;
    } else {
      final sysCode = PlatformDispatcher.instance.locale.languageCode;
      code = (sysCode == 'ar' || sysCode == 'en') ? sysCode : 'en';
    }
    emit(LocaleState(Locale(code)));
  }

  Future<void> changeLocale(BuildContext context, String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageConstants.locale, languageCode);
    if (context.mounted) {
      await context.setLocale(Locale(languageCode));
    }
    emit(LocaleState(Locale(languageCode)));
  }
}

