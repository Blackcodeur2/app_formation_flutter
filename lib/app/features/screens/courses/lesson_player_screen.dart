import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../../models/lesson.dart';
import '../../widgets/adaptive_app_bar.dart';
import '../../../config/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_formations/app/models/course.dart';
import 'package:app_formations/app/features/screens/home/providers/course_provider.dart';
import 'package:app_formations/app/features/screens/home/providers/user_courses_provider.dart';

class LessonPlayerScreen extends ConsumerStatefulWidget {
  final Lesson lesson;
  final Course course;

  const LessonPlayerScreen({
    super.key,
    required this.lesson,
    required this.course,
  });

  @override
  ConsumerState<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends ConsumerState<LessonPlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isMarkingAsCompleted = false;

  @override
  void initState() {
    super.initState();
    if (widget.lesson.type == 'video') {
      _initializePlayer();
    }
  }

  Future<void> _initializePlayer() async {
    if (widget.lesson.content.isEmpty) return;

    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.lesson.content),
    );

    await _videoPlayerController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: true,
      looping: false,
      aspectRatio: _videoPlayerController!.value.aspectRatio,
      materialProgressColors: ChewieProgressColors(
        playedColor: MyAppColors.primary,
        handleColor: MyAppColors.primary,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.white.withOpacity(0.5),
      ),
      placeholder: Container(
        color: Colors.black,
        child: const Center(child: CircularProgressIndicator(color: MyAppColors.primary)),
      ),
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 42),
              const SizedBox(height: 16),
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      },
    );

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _markAsCompleted() async {
    if (_isMarkingAsCompleted) return;

    setState(() {
      _isMarkingAsCompleted = true;
    });

    final success = await ref.read(courseServiceProvider).updateProgress(
      lessonId: widget.lesson.id,
      completed: true,
      progressPercentage: 100,
    );

    if (mounted) {
      setState(() {
        _isMarkingAsCompleted = false;
      });

      if (success) {
        // Refresh progress data across the app
        ref.invalidate(myCoursesProvider);
        ref.invalidate(courseDetailsProvider(widget.course.id));
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Leçon terminée ! Progression enregistrée.')),
        );
        _goToNextLesson();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'enregistrement de la progression.')),
        );
      }
    }
  }

  void _goToNextLesson() {
    // Find current lesson in course
    Lesson? nextLesson;
    bool foundCurrent = false;

    for (var module in widget.course.modules) {
      for (var lesson in module.lessons) {
        if (foundCurrent) {
          nextLesson = lesson;
          break;
        }
        if (lesson.id == widget.lesson.id) {
          foundCurrent = true;
        }
      }
      if (nextLesson != null) break;
    }

    if (nextLesson != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LessonPlayerScreen(
            lesson: nextLesson!,
            course: widget.course,
          ),
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AdaptiveAppBar(
        title: widget.lesson.title,
        showBack: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Player Section (Only for video lessons)
            if (widget.lesson.type == 'video')
              AspectRatio(
                aspectRatio: 16 / 9,
                child: _chewieController != null &&
                        _chewieController!.videoPlayerController.value.isInitialized
                    ? Chewie(controller: _chewieController!)
                    : Container(
                        color: Colors.black,
                        child: const Center(
                          child: CircularProgressIndicator(color: MyAppColors.primary),
                        ),
                      ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: MyAppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.lesson.type.toUpperCase(),
                          style: const TextStyle(
                            color: MyAppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (widget.lesson.duration != null)
                        Text(
                          '${widget.lesson.duration} min',
                          style: const TextStyle(color: Colors.grey),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.lesson.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.course.title,
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 32),
                  
                  const Text(
                    'Contenu',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  if (widget.lesson.type == 'text')
                    Text(
                      widget.lesson.content,
                      style: const TextStyle(height: 1.5, color: Colors.grey),
                    )
                  else
                    const Text(
                      'Regardez la vidéo ci-dessus pour suivre cette leçon.',
                      style: TextStyle(height: 1.5, color: Colors.grey),
                    ),
                  
                  const SizedBox(height: 48),
                  
                  // Complete Button
                  ElevatedButton(
                    onPressed: _isMarkingAsCompleted ? null : _markAsCompleted,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyAppColors.primary,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isMarkingAsCompleted 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Marquer comme terminée',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
