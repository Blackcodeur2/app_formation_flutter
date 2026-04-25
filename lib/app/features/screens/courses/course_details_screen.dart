import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_formations/app/models/course.dart';
import 'package:app_formations/app/config/app_colors.dart';
import 'package:app_formations/app/features/widgets/responsive_layout_wrapper.dart';
import 'package:app_formations/app/features/screens/courses/lesson_player_screen.dart';
import 'package:app_formations/app/features/screens/home/providers/user_courses_provider.dart';
import 'package:app_formations/app/features/screens/home/providers/course_provider.dart';

class CourseDetailsScreen extends ConsumerWidget {
  final Course course;

  const CourseDetailsScreen({super.key, required this.course});

  Future<void> _enroll(BuildContext context, WidgetRef ref) async {
    final service = ref.read(courseServiceProvider);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Inscription en cours...')),
    );

    final success = await service.enrollInCourse(course.id);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      if (success) {
        ref.read(myCoursesProvider.notifier).addCourse(course);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Félicitations ! Vous êtes inscrit.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l\'inscription. Veuillez réessayer.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch for the full course details
    final fullCourseAsync = ref.watch(courseDetailsProvider(course.id));
    final currentCourse = fullCourseAsync.value ?? course;
    
    final userCoursesAsync = ref.watch(myCoursesProvider);
    final isEnrolled = userCoursesAsync.maybeWhen(
      data: (courses) => courses.any((c) => c.id == course.id),
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, currentCourse),
          SliverToBoxAdapter(
            child: ResponsiveLayoutWrapper(
              maxWidth: 900,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildInfoChip(context, Icons.star, '4.8 (120 avis)', color: Colors.amber),
                      const SizedBox(width: 8),
                      _buildInfoChip(context, Icons.people_outline, '${currentCourse.enrollmentsCount} inscrits'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Présentation du cours',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentCourse.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
                  ),
                  const SizedBox(height: 32),
                  
                  if (fullCourseAsync.isLoading)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ))
                  else if (currentCourse.modules.isNotEmpty) ...[
                    Text(
                      'Le programme du cours',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ...currentCourse.modules.asMap().entries.map((entry) {
                      final module = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            radius: 14,
                            backgroundColor: MyAppColors.primary.withOpacity(0.1),
                            child: Text('${entry.key + 1}', style: const TextStyle(fontSize: 12, color: MyAppColors.primary)),
                          ),
                          title: Text(module.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${module.lessons.length} leçons', style: const TextStyle(fontSize: 12)),
                          children: module.lessons.map((lesson) => ListTile(
                            leading: Icon(_getLessonIcon(lesson.type), size: 20, color: Colors.grey),
                            title: Text(lesson.title, style: const TextStyle(fontSize: 14)),
                            trailing: Icon(
                              !isEnrolled 
                                ? Icons.lock_outline 
                                : (lesson.isCompleted ? Icons.check_circle : Icons.play_circle_outline), 
                              size: 16, 
                              color: lesson.isCompleted ? Colors.green : Colors.grey
                            ),
                            onTap: isEnrolled ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LessonPlayerScreen(
                                    lesson: lesson,
                                    course: currentCourse,
                                  ),
                                ),
                              );
                            } : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Veuillez vous inscrire pour accéder au contenu')),
                              );
                            },
                          )).toList(),
                        ),
                      );
                    }),
                  ],
                  
                  if (currentCourse.instructor != null) ...[
                    const SizedBox(height: 32),
                    Text(
                      'Votre instructeur',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundImage: currentCourse.instructor!.avatar != null 
                                ? NetworkImage(currentCourse.instructor!.avatar!) 
                                : null,
                            child: currentCourse.instructor!.avatar == null ? const Icon(Icons.person) : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${currentCourse.instructor!.prenom} ${currentCourse.instructor!.nom}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const Text('Expert en éducation', style: TextStyle(color: Colors.grey, fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, ref, currentCourse, isEnrolled),
    );
  }

  Widget _buildAppBar(BuildContext context, Course currentCourse) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            currentCourse.thumbnail != null 
              ? Image.network(currentCourse.thumbnail!, fit: BoxFit.cover)
              : Container(color: Colors.grey),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.3), Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
          ],
        ),
        title: Text(
          currentCourse.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, WidgetRef ref, Course currentCourse, bool isEnrolled) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (!isEnrolled)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Prix total', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(
                    currentCourse.formattedPrice,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: MyAppColors.primary),
                  ),
                ],
              ),
            if (!isEnrolled) const SizedBox(width: 24),
            Expanded(
              child: ElevatedButton(
                onPressed: isEnrolled 
                  ? () {
                      if (currentCourse.modules.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Chargement des leçons en cours...')),
                        );
                        return;
                      }
                      try {
                        final allLessons = currentCourse.modules
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
                              course: currentCourse,
                            ),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Aucune leçon disponible pour ce cours.')),
                        );
                      }
                    }
                  : () => _enroll(context, ref),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: MyAppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  isEnrolled ? 'Continuer la formation' : 'S\'inscrire au cours',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color ?? Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  IconData _getLessonIcon(String type) {
    switch (type) {
      case 'video':
        return Icons.play_circle_outline_rounded;
      case 'text':
        return Icons.menu_book_rounded;
      case 'quiz':
        return Icons.quiz_outlined;
      default:
        return Icons.article_outlined;
    }
  }
}
