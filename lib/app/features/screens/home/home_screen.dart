import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_colors.dart';
import '../../widgets/course_card.dart';
import 'providers/course_provider.dart';
import 'providers/category_provider.dart';
import '../../widgets/responsive_layout_wrapper.dart';
import '../../auth/providers/auth_provider.dart';
import 'widgets/home_components.dart';
import 'widgets/card_components.dart';

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  
  void update(String query) {
    state = query;
  }
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(() {
  return SearchQueryNotifier();
});

class SelectedCategoryNotifier extends Notifier<int?> {
  @override
  int? build() => null;
  
  void update(int? categoryId) {
    state = categoryId;
  }
}

final selectedCategoryProvider = NotifierProvider<SelectedCategoryNotifier, int?>(() {
  return SelectedCategoryNotifier();
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final search = ref.watch(searchQueryProvider);
    final categoryId = ref.watch(selectedCategoryProvider);
    
    final coursesAsync = ref.watch(filteredCoursesProvider((search: search, categoryId: categoryId)));
    final categoriesAsync = ref.watch(categoriesProvider);

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveLayoutWrapper(
            maxWidth: 1200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: kToolbarHeight + 16),

                // Hero Banner
                coursesAsync.when(
                  data: (courses) => HeroBanner(
                    featuredCourse: courses.isNotEmpty ? courses.first : null,
                  ),
                  loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                  error: (e, st) => const SizedBox(height: 200, child: Center(child: Text('Erreur de chargement'))),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white.withOpacity(0.05) 
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (value) => ref.read(searchQueryProvider.notifier).update(value),
                      decoration: const InputDecoration(
                        hintText: 'Que souhaites-tu apprendre ?',
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search, color: MyAppColors.primary, size: 20),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Categories (Horizontal Chips)
                SectionHeader(title: 'Catégories', onSeeAll: () {}),
                SizedBox(
                  height: 48,
                  child: categoriesAsync.when(
                    data: (categories) {
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                        itemCount: categories.length + 1, // +1 for "All"
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return CategoryCard(
                              category: 'Toutes',
                              icon: Icons.apps_rounded,
                              color: MyAppColors.primary,
                              isSelected: categoryId == null,
                              onTap: () => ref.read(selectedCategoryProvider.notifier).update(null),
                            );
                          }
                          final cat = categories[index - 1];
                          // Simple hash for color and default icon
                          final colorList = [Colors.orange, Colors.blue, Colors.green, Colors.purple, Colors.red];
                          final color = colorList[cat.id % colorList.length];
                          
                          return CategoryCard(
                            category: cat.name,
                            icon: Icons.category_outlined,
                            color: color,
                            isSelected: categoryId == cat.id,
                            onTap: () => ref.read(selectedCategoryProvider.notifier).update(cat.id),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, st) => const Center(child: Text('Impossible de charger les catégories')),
                  ),
                ),

                // Featured Courses
                SectionHeader(title: 'Formations', onSeeAll: () {}),
                SizedBox(
                  height: 320,
                  child: coursesAsync.when(
                    data: (courses) {
                      if (courses.isEmpty) {
                        return const Center(child: Text('Aucune formation trouvée'));
                      }
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 24),
                        itemCount: courses.length,
                        itemBuilder: (context, index) {
                          return CourseCard(course: courses[index]);
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, st) => const Center(child: Text('Erreur de chargement des cours')),
                  ),
                ),

                // Top Rated Section (Mock implementation using the same courses for now)
                SectionHeader(title: 'Les plus populaires', onSeeAll: () {}),
                coursesAsync.when(
                  data: (courses) {
                    if (courses.isEmpty) return const SizedBox.shrink();
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: courses.length > 3 ? 3 : courses.length,
                      itemBuilder: (context, index) {
                        final course = courses[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: course.thumbnail != null 
                                ? Image.network(
                                    course.thumbnail!,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 80, 
                                    height: 80, 
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.image_not_supported_outlined),
                                  ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      course.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.people_outline, color: Colors.grey, size: 16),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            '${course.enrollmentsCount} étudiants',
                                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      course.formattedPrice,
                                      style: const TextStyle(
                                        color: MyAppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
