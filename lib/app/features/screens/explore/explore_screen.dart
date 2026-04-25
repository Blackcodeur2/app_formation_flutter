import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_colors.dart';
import '../../widgets/course_card.dart';
import '../home/providers/course_provider.dart';
import '../home/providers/category_provider.dart';
import '../home/home_screen.dart' show searchQueryProvider, selectedCategoryProvider;
import '../../widgets/responsive_layout_wrapper.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = ref.watch(searchQueryProvider);
    final categoryId = ref.watch(selectedCategoryProvider);
    
    final coursesAsync = ref.watch(filteredCoursesProvider((search: search, categoryId: categoryId)));
    final categoriesAsync = ref.watch(categoriesProvider);

    return ResponsiveLayoutWrapper(
      maxWidth: 1000,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: kToolbarHeight + 16),
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white.withOpacity(0.05) 
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              onChanged: (value) => ref.read(searchQueryProvider.notifier).update(value),
              decoration: const InputDecoration(
                hintText: 'Rechercher un cours...',
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Categories
          SizedBox(
            height: 40,
            child: categoriesAsync.when(
              data: (categories) {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length + 1,
                  itemBuilder: (context, index) {
                    final bool isAll = index == 0;
                    final catId = isAll ? null : categories[index - 1].id;
                    final String catName = isAll ? 'Toutes' : categories[index - 1].name;
                    final isSelected = selectedCategoryProvider != null && categoryId == catId;
                    
                    return GestureDetector(
                      onTap: () => ref.read(selectedCategoryProvider.notifier).update(catId),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: isSelected ? MyAppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? MyAppColors.primary : Colors.grey.shade300,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            catName,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => const Text('Erreur catégories'),
            ),
          ),
          const SizedBox(height: 32),
          // Results Grid
          Expanded(
            child: coursesAsync.when(
              data: (courses) {
                if (courses.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Aucun cours trouvé', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 700 ? 3 : (constraints.maxWidth > 500 ? 2 : 1);
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 0.82,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        return CourseCard(course: courses[index]);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => const Center(child: Text('Erreur de chargement des cours')),
            )
          ),
        ],
      ),
    );
  }
}
