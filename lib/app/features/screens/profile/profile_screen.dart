import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_colors.dart';
import '../../widgets/responsive_layout_wrapper.dart';
import '../../auth/providers/auth_provider.dart';
import '../home/providers/user_courses_provider.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final myCoursesAsync = ref.watch(myCoursesProvider);

    return SingleChildScrollView(
      child: ResponsiveLayoutWrapper(
        maxWidth: 800,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: kToolbarHeight + 16),
            // Header
            CircleAvatar(
              radius: 50,
              backgroundColor: MyAppColors.secondary,
              backgroundImage: user?.avatar != null 
                  ? NetworkImage(user!.avatar!) 
                  : null,
              child: user?.avatar == null 
                  ? const Icon(Icons.person, size: 50, color: Colors.white) 
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              user != null ? '${user.prenom} ${user.nom}' : 'Utilisateur Inconnu',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              user?.email ?? 'Aucun email', 
              style: const TextStyle(color: Colors.grey),
            ),
            if (user != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: MyAppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user.role.toUpperCase(),
                  style: const TextStyle(color: MyAppColors.primary, fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
            ],
            const SizedBox(height: 32),
            // Real Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  myCoursesAsync.maybeWhen(data: (courses) => courses.length.toString(), orElse: () => '0'), 
                  'Cours'
                ),
                _buildStatItem(
                  myCoursesAsync.maybeWhen(data: (courses) => courses.where((c) => c.isCompleted).length.toString(), orElse: () => '0'), 
                  'Certificats'
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Menu
            _buildMenuItem(
              context, 
              Icons.person_outline, 
              'Informations personnelles',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                );
              },
            ),
            _buildMenuItem(context, Icons.security_outlined, 'Sécurité & Mot de passe'),
            _buildMenuItem(context, Icons.dark_mode_outlined, 'Mode sombre', 
              trailing: Switch.adaptive(value: Theme.of(context).brightness == Brightness.dark, onChanged: (_) {})),
            _buildMenuItem(
              context, 
              Icons.logout_rounded, 
              'Se déconnecter', 
              color: Colors.red,
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Déconnexion'),
                    content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true), 
                        child: const Text('Déconnexion', style: TextStyle(color: Colors.red))
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  ref.read(authProvider.notifier).logout();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, {Widget? trailing, Color? color, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Icon(icon, color: color ?? MyAppColors.primary),
        title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        onTap: onTap ?? () {},
      ),
    );
  }
}
