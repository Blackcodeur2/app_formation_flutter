import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_formations/app/config/app_colors.dart';
import 'package:app_formations/app/features/screens/home/providers/course_provider.dart';
import 'package:app_formations/app/features/widgets/responsive_layout_wrapper.dart';
import 'package:app_formations/app/features/screens/courses/lesson_player_screen.dart';

import 'package:app_formations/app/features/screens/home/providers/user_courses_provider.dart';

class MyCoursesScreen extends ConsumerWidget {
  const MyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myCoursesAsync = ref.watch(myCoursesProvider);

    return ResponsiveLayoutWrapper(
      maxWidth: 1000,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: kToolbarHeight + 16),
          Expanded(
            child: myCoursesAsync.when(
              data: (courses) {
                if (courses.isEmpty) return const Center(child: Text("Vous n'êtes inscrit à aucun cours"));
                
                return ListView.builder(
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    // Simulating progress for now
                    final double progress = course.completionPercentage;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: course.thumbnail != null 
                                ? Image.network(
                                    course.thumbnail!,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.image_not_supported_outlined),
                                    ),
                                  )
                                : Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.image_not_supported_outlined),
                                  ),
                              ),
                              if (course.isCompleted)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(8),
                                        topRight: Radius.circular(12),
                                      ),
                                    ),
                                    child: const Icon(Icons.check, color: Colors.white, size: 12),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        course.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ),
                                    if (course.isCompleted)
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'TERMINE',
                                          style: TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Progress Bar
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor: Theme.of(context).brightness == Brightness.dark 
                                        ? Colors.white10 
                                        : Colors.grey.shade100,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      course.isCompleted ? Colors.green : MyAppColors.primary,
                                    ),
                                    minHeight: 6,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text('${(progress * 100).toInt()}% terminé', 
                                        style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        try {
                                          final allLessons = course.modules
                                              .expand((module) => module.lessons)
                                              .toList();
                                          
                                          final nextLesson = allLessons.firstWhere(
                                            (l) => !l.isCompleted,
                                            orElse: () => allLessons.first,
                                          );
                                          
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => LessonPlayerScreen(
                                                lesson: nextLesson,
                                                course: course,
                                              ),
                                            ),
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Aucune leçon disponible pour ce cours.')),
                                          );
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: (course.isCompleted ? Colors.green : MyAppColors.primary).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(course.isCompleted ? 'Revoir' : 'Reprendre', 
                                          style: TextStyle(
                                            color: course.isCompleted ? Colors.green : MyAppColors.primary, 
                                            fontSize: 12, 
                                            fontWeight: FontWeight.bold
                                          )),
                                      ),
                                    ),
                                  ],
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
              error: (e, st) => const Center(child: Text('Erreur de chargement')),
            )
          ),
        ],
      ),
    );
  }
}
