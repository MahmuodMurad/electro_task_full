import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager_electro/core/theme/theme_cubit.dart';
import 'package:task_manager_electro/core/theme/theme_state.dart';
import 'package:task_manager_electro/core/locale/locale_cubit.dart';
import 'package:task_manager_electro/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:task_manager_electro/features/auth/presentation/cubit/auth_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('profile'.tr())),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final user = state is AuthAuthenticated ? state.user : null;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // User info
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      (user?.name ?? '?')[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    user?.name ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(user?.email ?? ''),
                ),
              ),
              const SizedBox(height: 16),

              // Dark mode toggle
              Card(
                child: BlocBuilder<ThemeCubit, ThemeState>(
                  builder: (context, themeState) {
                    return SwitchListTile(
                      secondary: const Icon(Icons.dark_mode),
                      title: Text('dark_mode'.tr()),
                      value: themeState.themeMode == ThemeMode.dark,
                      onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // Language selector
              Card(
                child: ListTile(
                  leading: const Icon(Icons.language),
                  title: Text('language'.tr()),
                  trailing: DropdownButton<String>(
                    value: context.locale.languageCode,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'ar', child: Text('العربية')),
                    ],
                    onChanged: (code) {
                      if (code != null) {
                        context.read<LocaleCubit>().changeLocale(context, code);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Logout
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                icon: const Icon(Icons.logout),
                label: Text('logout'.tr()),
                onPressed: () => context.read<AuthCubit>().logout(),
              ),
            ],
          );
        },
      ),
    );
  }
}
