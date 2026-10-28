import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

class VideoPlayerModal extends StatefulWidget {
  final String videoTitle;
  final String duration;
  final String imageUrl;

  const VideoPlayerModal({
    super.key,
    required this.videoTitle,
    required this.duration,
    required this.imageUrl,
  });

  @override
  State<VideoPlayerModal> createState() => _VideoPlayerModalState();
}

class _VideoPlayerModalState extends State<VideoPlayerModal> {
  bool isPlaying = true;
  double currentProgress = 0.35;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Video Player Container
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      children: [
                        Image.network(
                          widget.imageUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppColors.primary,
                            child: const Center(
                              child: Icon(Icons.movie, color: AppColors.secondary, size: 48),
                            ),
                          ),
                        ),

                        Container(color: Colors.black.withValues(alpha: 0.4)),
                        if (!isPlaying)
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: AppColors.secondary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.play_arrow,
                                  color: Colors.white, size: 40),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Top Bar Close Button
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                // Playing Overlay Badge
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "VIDEO REVIEW PABRIK",
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Video Controls & Info
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.darkSurface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.videoTitle,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Progress Slider
                  Row(
                    children: [
                      Text("03:04",
                          style: GoogleFonts.plusJakartaSans(
                              color: Colors.white70, fontSize: 11)),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6),
                          ),
                          child: Slider(
                            value: currentProgress,
                            activeColor: AppColors.secondary,
                            inactiveColor: Colors.white24,
                            onChanged: (val) {
                              setState(() {
                                currentProgress = val;
                              });
                            },
                          ),
                        ),
                      ),
                      Text(widget.duration,
                          style: GoogleFonts.plusJakartaSans(
                              color: Colors.white70, fontSize: 11)),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.replay_10, color: Colors.white),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isPlaying = !isPlaying;
                          });
                        },
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.secondary,
                          child: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon:
                            const Icon(Icons.forward_10, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
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
