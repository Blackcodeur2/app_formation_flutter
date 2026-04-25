import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme_provider.dart';
import '../../config/app_colors.dart';
import '../../config/platform_utils.dart';

class AdaptiveAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;

  const AdaptiveAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark || 
                  (themeMode == ThemeMode.system && Theme.of(context).brightness == Brightness.dark);
    
    final backgroundColor = isDark 
        ? MyAppColors.darkSurface.withOpacity(0.7) 
        : Colors.white.withOpacity(0.7);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AppBar(
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : MyAppColors.textBody,
              letterSpacing: -0.5,
            ),
          ),
          centerTitle: PlatformUtils.isApple,
          backgroundColor: backgroundColor,
          elevation: 0,
          leading: showBack 
              ? IconButton(
                  icon: Icon(
                    PlatformUtils.isApple ? Icons.arrow_back_ios_new_rounded : Icons.arrow_back_rounded,
                    color: isDark ? Colors.white : MyAppColors.textBody,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null,
          actions: [
            if (actions != null) ...actions!,
            IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) => RotationTransition(
                  turns: anim,
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  key: ValueKey(isDark),
                  color: isDark ? Colors.amber : Colors.blueGrey,
                ),
              ),
              onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
              tooltip: 'Basculer le thème',
            ),
            const SizedBox(width: 8),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
