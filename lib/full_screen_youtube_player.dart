import 'package:flutter/material.dart';
import 'package:myautobiography/theme_notifier.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class FullScreenYoutubePlayer extends StatefulWidget {
  final String videoId;

  const FullScreenYoutubePlayer({Key? key, required this.videoId})
    : super(key: key);

  @override
  State<FullScreenYoutubePlayer> createState() =>
      _FullScreenYoutubePlayerState();
}

class _FullScreenYoutubePlayerState extends State<FullScreenYoutubePlayer> {
  late YoutubePlayerController _controller;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();

    // Create controller
    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: false,
        mute: false,
        enableCaption: true,
        strictRelatedVideos: true,
      ),
    );

    // IMPORTANT: Use loadVideoById for Flutter Web
    _controller.loadVideoById(videoId: widget.videoId);

    // Listen for readiness
    _controller.listen((value) {
      if (!mounted) return;

      final ready = value.playerState != PlayerState.unknown;

      if (_isReady != ready) {
        setState(() {
          _isReady = ready;
        });
      }
    });

    // Fallback: force show player after 2 seconds
    // (prevents infinite loader on some browsers)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && !_isReady) {
        setState(() {
          _isReady = true;
        });
      }

      // Ensure playback starts
      _controller.playVideo();
    });
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerScaffold(
      controller: _controller,
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            iconTheme: const IconThemeData(color: kgoldColor),
          ),
          body: Center(
            child: _isReady
                ? AspectRatio(aspectRatio: 16 / 9, child: player)
                : const CircularProgressIndicator(color: kgoldColor),
          ),
        );
      },
    );
  }
}
