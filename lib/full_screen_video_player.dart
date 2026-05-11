import 'package:flutter/material.dart';
import 'package:myautobiography/theme_notifier.dart';

import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FullScreenVideoPlayer extends StatefulWidget {
  final String videoAsset;
  const FullScreenVideoPlayer({Key? key, required this.videoAsset})
    : super(key: key);

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  // To trigger rebuild on position update
  VoidCallback? _listener;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      final assetUrl = Uri.base.resolve(widget.videoAsset).toString();
      _controller = VideoPlayerController.network(assetUrl)
        ..initialize().then((_) {
          setState(() {
            _isInitialized = true;
          });
          _controller.play();
        });
    } else {
      _controller = VideoPlayerController.asset(widget.videoAsset)
        ..initialize().then((_) {
          setState(() {
            _isInitialized = true;
          });
          _controller.play();
        });
    }
    // Add listener to update UI on position change
    _listener = () {
      if (mounted) setState(() {});
    };
    _controller.addListener(_listener!);
  }

  @override
  void dispose() {
    if (_listener != null) {
      _controller.removeListener(_listener!);
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: kgoldColor),
      ),
      body: Center(
        child: _isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_controller),
                    // Controls overlay
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        color: Colors.black.withOpacity(0.85),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Progress Slider with tap-to-seek and drag-to-seek
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final sliderWidth = constraints.maxWidth;
                                final duration = _controller.value.duration;
                                final position = _controller.value.position;
                                final max = duration.inMilliseconds.toDouble();
                                final value = position.inMilliseconds
                                    .clamp(0, duration.inMilliseconds)
                                    .toDouble();
                                return GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTapDown: (details) {
                                    final tapX = details.localPosition.dx;
                                    if (max > 0) {
                                      final relative = (tapX / sliderWidth)
                                          .clamp(0.0, 1.0);
                                      final seekTo = Duration(
                                        milliseconds: (max * relative).toInt(),
                                      );
                                      _controller.seekTo(seekTo);
                                    }
                                  },
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      trackHeight: 2,
                                      thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 6,
                                      ),
                                      overlayShape:
                                          const RoundSliderOverlayShape(
                                            overlayRadius: 12,
                                          ),
                                    ),
                                    child: Slider(
                                      value: value,
                                      min: 0.0,
                                      max: max > 0 ? max : 1.0,
                                      onChanged: (v) {
                                        if (max > 0) {
                                          _controller.seekTo(
                                            Duration(milliseconds: v.toInt()),
                                          );
                                        }
                                      },
                                      activeColor: kgoldColor,
                                      inactiveColor: Colors.white24,
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Control Bar
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Row(
                                children: [
                                  // Play/Pause Button
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: Icon(
                                      _controller.value.isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (_controller.value.isPlaying) {
                                          _controller.pause();
                                        } else {
                                          _controller.play();
                                        }
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  // Time Text
                                  Expanded(
                                    child: Text(
                                      '${_formatDuration(_controller.value.position)} / '
                                      '${_formatDuration(_controller.value.duration)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontFeatures: [
                                          FontFeature.tabularFigures(),
                                        ],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : const CircularProgressIndicator(color: kgoldColor),
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
