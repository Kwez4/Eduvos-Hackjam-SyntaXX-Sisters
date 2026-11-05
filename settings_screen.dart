import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_state.dart';
import 'new_welcome_page.dart';
import 'supabase_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final theme = Theme.of(context);
    final text = theme.colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Appearance',
            style: theme.textTheme.titleLarge?.copyWith(
              color: text,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          for (final (mode, label, icon) in [
            (ThemeMode.light, 'Light mode', Icons.light_mode_outlined),
            (ThemeMode.dark, 'Dark mode', Icons.dark_mode_outlined),
            (ThemeMode.system, 'Use device setting', Icons.settings_brightness),
          ])
            ListTile(
              leading: Icon(icon),
              title: Text(label),
              trailing: state.themeMode == mode
                  ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                  : const Icon(Icons.circle_outlined),
              selected: state.themeMode == mode,
              onTap: () => state.setThemeMode(mode),
            ),
          const SizedBox(height: 24),
          Text(
            'Business pages',
            style: theme.textTheme.titleLarge?.copyWith(
              color: text,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose how businesses and their offerings are displayed.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          SegmentedButton<BusinessLayout>(
            segments: const [
              ButtonSegment(
                value: BusinessLayout.grid,
                label: Text('Grid'),
                icon: Icon(Icons.grid_view_rounded),
              ),
              ButtonSegment(
                value: BusinessLayout.list,
                label: Text('List'),
                icon: Icon(Icons.view_list_rounded),
              ),
            ],
            selected: {state.businessLayout},
            onSelectionChanged: (selection) =>
                state.setBusinessLayout(selection.first),
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () => _confirmSignOut(context),
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will return to the welcome page.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (shouldSignOut != true || !context.mounted) return;

    try {
      await SupabaseService.signOut();
    } on AuthException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not sign out: ${error.message}')),
      );
      return;
    }
    if (!context.mounted) return;

    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil<void>(
      MaterialPageRoute<void>(builder: (_) => const NewWelcomePage()),
      (route) => false,
    );
  }
}
