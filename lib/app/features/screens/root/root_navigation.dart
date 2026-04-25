import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../config/platform_utils.dart';
import '../home/home_screen.dart';
import '../explore/explore_screen.dart';
import '../courses/my_courses_screen.dart';
import '../profile/profile_screen.dart';
import '../../widgets/adaptive_app_bar.dart';

class RootNavigation extends StatefulWidget {
  const RootNavigation({super.key});

  @override
  State<RootNavigation> createState() => _RootNavigationState();
}

class _RootNavigationState extends State<RootNavigation> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    'BetterLife Academy',
    'Explorer',
    'Mes Formations',
    'Mon Profil',
  ];

  final List<Widget> _screens = [
    const HomeScreen(),
    const ExploreScreen(),
    const MyCoursesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 800;
        final bool useVerticalNav = isWide || PlatformUtils.isDesktop;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AdaptiveAppBar(
            title: _titles[_selectedIndex],
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_rounded),
              ),
            ],
          ),
          body: Row(
            children: [
              if (useVerticalNav)
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  labelType: NavigationRailLabelType.selected,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  selectedIconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
                  unselectedIconTheme: const IconThemeData(color: Colors.grey),
                  selectedLabelTextStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home_filled),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.explore_outlined),
                      selectedIcon: Icon(Icons.explore),
                      label: Text('Explore'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.play_circle_outline),
                      selectedIcon: Icon(Icons.play_circle_fill),
                      label: Text('Courses'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: Text('Profile'),
                    ),
                  ],
                ),
              if (useVerticalNav) const VerticalDivider(thickness: 1, width: 1),
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: _screens,
                ),
              ),
            ],
          ),
          bottomNavigationBar: (!useVerticalNav)
              ? Container(
                  margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: BottomNavigationBar(
                        currentIndex: _selectedIndex,
                        onTap: (index) => setState(() => _selectedIndex = index),
                        type: BottomNavigationBarType.fixed,
                        backgroundColor: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white.withOpacity(0.05) 
                            : Colors.white.withOpacity(0.8),
                        selectedItemColor: Theme.of(context).colorScheme.primary,
                        unselectedItemColor: Colors.grey,
                        showSelectedLabels: true,
                        showUnselectedLabels: true,
                        selectedFontSize: 12,
                        unselectedFontSize: 12,
                        elevation: 0,
                        items: const [
                          BottomNavigationBarItem(
                            icon: Icon(Icons.home_outlined),
                            activeIcon: Icon(Icons.home_filled),
                            label: 'Accueil',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.explore_outlined),
                            activeIcon: Icon(Icons.explore),
                            label: 'Explorer',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.play_circle_outline),
                            activeIcon: Icon(Icons.play_circle_fill),
                            label: 'Mes Cours',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.person_outline),
                            activeIcon: Icon(Icons.person),
                            label: 'Profil',
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}

// Add this extension for older Flutter versions compatibility if needed
extension on BottomNavigationBar {
    // Some versions use onDestinationSelected in modern adaptive scaffolds, 
    // but standard BottomNavigationBar uses onTap.
}
