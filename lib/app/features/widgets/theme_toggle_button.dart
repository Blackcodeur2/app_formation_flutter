import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/config/theme_provider.dart';

class ThemeToggleButton extends ConsumerWidget {
  final Color? color;
  const ThemeToggleButton({super.key, this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark || 
        (themeMode == ThemeMode.system && Theme.of(context).brightness == Brightness.dark);

    return IconButton(
      icon: Icon(
        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
        color: color ?? (isDark ? Colors.white : Colors.black87),
      ),
      onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
      tooltip: 'Changer le thème',
    );
  }
}
