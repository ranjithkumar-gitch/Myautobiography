import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myautobiography/app_shared_preferences.dart';
import 'package:myautobiography/constants/colors.dart';
import 'package:myautobiography/full_screen_video_player.dart';
import 'package:myautobiography/full_screen_youtube_player.dart';
import 'package:myautobiography/onboardingscreen.dart';
import 'package:myautobiography/request_as_star_service.dart';
import 'package:myautobiography/star_request_submitted_screen.dart';
import 'package:myautobiography/theme_notifier.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'package:video_player/video_player.dart';

class RequestAsStarScreen extends StatefulWidget {
  const RequestAsStarScreen({Key? key}) : super(key: key);

  @override
  State<RequestAsStarScreen> createState() => _RequestAsStarScreenState();
}

class _RequestAsStarScreenState extends State<RequestAsStarScreen> {
  // void _openFullScreen() async {
  //   if (_videoController.value.isPlaying) {
  //     _videoController.pause();
  //   }
  //   await Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (context) => const FullScreenVideoPlayer(
  //         videoAsset: 'assets/sources/videos/legacy5.mp4',
  //       ),
  //     ),
  //   );
  // }

  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;
  late YoutubePlayerController _youtubeController;
  bool _isYoutubeReady = false;
  final ScrollController _desktopScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _youtubeController = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: false,
        showFullscreenButton: false,
        mute: false,
        enableCaption: true,
        strictRelatedVideos: true,
      ),
    );

    // Load the YouTube video
    _youtubeController.cueVideoById(videoId: 'Riff0rzYCnQ');

    // Listen for player updates
    _youtubeController.listen((value) {
      if (!mounted) return;

      final ready = value.playerState != PlayerState.unknown;

      if (_isYoutubeReady != ready) {
        setState(() {
          _isYoutubeReady = ready;
        });
      }
    });

    // Fallback: if web keeps showing loader, force UI after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && !_isYoutubeReady) {
        setState(() {
          _isYoutubeReady = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _desktopScrollController.dispose();
    _youtubeController.close();
    super.dispose();
  }

  void _handleDesktopPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    if (!_desktopScrollController.hasClients) return;

    final position = _desktopScrollController.position;
    final target = (position.pixels + event.scrollDelta.dy).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );

    if (target != position.pixels) {
      _desktopScrollController.jumpTo(target);
    }
  }

  bool showInfo = true;

  void _onBackPressed() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }

    navigator.pushReplacement(
      MaterialPageRoute(builder: (_) => OnBoardingscreen()),
    );
  }

  void _onRequest() async {
    // Terms and conditions validation removed as per request
    // Get stargazerId from shared preferences
    final stargazerId = await SharedPrefServices.getStargazerId();
    if (stargazerId == null || stargazerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stargazer ID not found.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final resp = await RequestAsStarService.requestAsStar(
      stargazerId: stargazerId,
    );
    if (resp.statusCode == 201 && resp.success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => StarRequestSubmittedScreen(
            onExplore: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resp.message ?? 'Request failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScrollbarTheme(
      data: ScrollbarThemeData(
        thumbColor: MaterialStateProperty.all(kgoldColor),
        trackColor: MaterialStateProperty.all(Colors.transparent),
        radius: const Radius.circular(8),
        thickness: MaterialStateProperty.all(8),
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: AppBar(
            backgroundColor: Colors.black.withOpacity(0.2),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: kgoldColor,
              onPressed: _onBackPressed,
              tooltip: 'Back',
            ),
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            title: Padding(
              padding: const EdgeInsets.only(left: 40, top: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/appbar_logo.png', height: 60),
                  const SizedBox(width: 5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MY AUTOBIOGRAPHY',
                        style: GoogleFonts.bebasNeue(
                          color: const Color(0xffc18e3b),
                          fontSize: 22,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        '"Live a Life & Leave a Legacy"',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/bg_1411.png', fit: BoxFit.cover),
            ),
            // Close button for mobile UI only
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;
                if (!isWide) {
                  // return Align(
                  //   alignment: Alignment.topRight,
                  //   child: Padding(
                  //     padding: const EdgeInsets.only(top: 16.0, right: 8.0),
                  //     child: Material(
                  //       color: Colors.transparent,
                  //       child: InkWell(
                  //         borderRadius: BorderRadius.circular(24),
                  //         onTap: () {
                  //           Navigator.of(context).pushAndRemoveUntil(
                  //             MaterialPageRoute(
                  //               builder: (context) => OnBoardingscreen(),
                  //             ),
                  //             (route) => false,
                  //           );
                  //         },
                  //         child: Container(
                  //           width: 40,
                  //           height: 40,
                  //           decoration: BoxDecoration(
                  //             shape: BoxShape.circle,
                  //             color: Colors.black.withOpacity(0.7),
                  //             border: Border.all(color: kgoldColor, width: 2),
                  //           ),
                  //           child: const Center(
                  //             child: Icon(
                  //               Icons.close,
                  //               color: kgoldColor,
                  //               size: 22,
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // );
                }
                return const SizedBox.shrink();
              },
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 900;
                  if (isWide) {
                    // Web/Desktop: Logo left, content right
                    return Listener(
                      onPointerSignal: _handleDesktopPointerSignal,
                      child: Row(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 6,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Image.asset(
                                      'assets/4thscreen.PNG',
                                      height: 600,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            flex: 6,
                            child: Center(
                              child: Scrollbar(
                                controller: _desktopScrollController,
                                thumbVisibility: true,
                                interactive: true,
                                child: SingleChildScrollView(
                                  controller: _desktopScrollController,
                                  scrollDirection: Axis.vertical,
                                  physics: const BouncingScrollPhysics(
                                    parent: AlwaysScrollableScrollPhysics(),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32.0,
                                    ),
                                    constraints: const BoxConstraints(
                                      maxWidth: 500,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                  right: 8,
                                                ),
                                                height: 1.5,
                                                color: kgoldColor.withOpacity(
                                                  0.5,
                                                ),
                                              ),
                                            ),
                                            ShaderMask(
                                              shaderCallback: (bounds) =>
                                                  goldTextGradient.createShader(
                                                    bounds,
                                                  ),
                                              child: Text(
                                                'What It Means to Be a Star',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0,
                                                ),
                                              ),
                                            ),

                                            Expanded(
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                  left: 8,
                                                ),
                                                height: 1.5,
                                                color: kgoldColor.withOpacity(
                                                  0.5,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          "Turn Your Life Into",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.bebasNeue(
                                            color: Colors.white,
                                            fontSize: 50,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0,
                                          ),
                                        ),

                                        ShaderMask(
                                          shaderCallback: (bounds) =>
                                              goldTextGradient.createShader(
                                                bounds,
                                              ),
                                          child: Text(
                                            "a Living Legacy.",
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.bebasNeue(
                                              color: Colors.white,
                                              fontSize: 50,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "Be remembered. Be experienced. Be timeless. Create your digital Legacy and share your story with the world.",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            letterSpacing: 0,
                                          ),
                                        ),

                                        const SizedBox(height: 15),

                                        AspectRatio(
                                          aspectRatio: 16 / 9,
                                          child: Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: kgoldColor,
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(0),
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child: Stack(
                                              fit: StackFit.loose,
                                              children: [
                                                /// YouTube Video
                                                _isYoutubeReady
                                                    ? AbsorbPointer(
                                                        absorbing: kIsWeb,
                                                        child: YoutubePlayer(
                                                          controller:
                                                              _youtubeController,
                                                          aspectRatio: 16 / 9,
                                                        ),
                                                      )
                                                    : Container(
                                                        color: Colors.black12,
                                                        child: const Center(
                                                          child:
                                                              CircularProgressIndicator(
                                                                color:
                                                                    kgoldColor,
                                                              ),
                                                        ),
                                                      ),

                                                /// Bottom Controls (without fullscreen)
                                                if (_isYoutubeReady)
                                                  Positioned(
                                                    left: 0,
                                                    right: 0,
                                                    bottom: 0,
                                                    child: Container(
                                                      color: Colors.black
                                                          .withOpacity(0.85),
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),
                                                      child: Row(
                                                        children: [
                                                          const Spacer(),
                                                          // Fullscreen button moved to top of stack
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 15),
                                        GestureDetector(
                                          onTap: () async {
                                            await _youtubeController
                                                .pauseVideo();
                                            final videoId =
                                                YoutubePlayerController.convertUrlToId(
                                                  'https://www.youtube.com/watch?v=Riff0rzYCnQ',
                                                ) ??
                                                'Riff0rzYCnQ';
                                            // Use SchedulerBinding to ensure navigation works in all layouts
                                            WidgetsBinding.instance
                                                .addPostFrameCallback((_) {
                                                  Navigator.of(
                                                    context,
                                                    rootNavigator: true,
                                                  ).push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          FullScreenYoutubePlayer(
                                                            videoId: videoId,
                                                          ),
                                                    ),
                                                  );
                                                });
                                          },
                                          child: Text(
                                            'Click Here for Full Screen View',

                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.poppins(
                                              color: kgoldColor,

                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 15),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '1. Global Audience',

                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                Text(
                                                  '3. Preserve Your Knowledge',

                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '2. Share Your Voice',
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                Text(
                                                  '4. AI-Powered Legacy',
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 20),
                                        SizedBox(
                                          width: double.infinity,
                                          height: 60,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: goldTextGradient,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            padding: const EdgeInsets.all(2),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                              child: OutlinedButton(
                                                onPressed: _onRequest,
                                                style: OutlinedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          14,
                                                        ),
                                                  ),
                                                  side: BorderSide.none,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  padding: EdgeInsets.zero,
                                                  foregroundColor: Colors.white,
                                                  shadowColor:
                                                      Colors.transparent,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    ShaderMask(
                                                      shaderCallback:
                                                          (bounds) =>
                                                              goldTextGradient
                                                                  .createShader(
                                                                    bounds,
                                                                  ),
                                                      child: Text(
                                                        'Apply to be a star',
                                                        style:
                                                            GoogleFonts.poppins(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    ShaderMask(
                                                      shaderCallback:
                                                          (bounds) =>
                                                              goldTextGradient
                                                                  .createShader(
                                                                    bounds,
                                                                  ),
                                                      child: Icon(
                                                        Icons.arrow_forward_ios,
                                                        color: Colors.white,
                                                        size: 24,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                        Text(
                                          'Applications are limited. Selection-based access.',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            color: kwhiteColor,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Mobile/tablet: original layout
                    final maxContentWidth = double.infinity;
                    final horizontalPadding = 24.0;
                    return Center(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: 10.0,
                          ),
                          alignment: Alignment.center,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: maxContentWidth,
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 24),
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      goldTextGradient.createShader(bounds),
                                  child: Text(
                                    'What It Means to Be a Star',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.cinzel(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: kgoldColor,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Stack(
                                    children: [
                                      // Fixed height for mobile/tablet
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.width *
                                            9 /
                                            16,
                                        width: double.infinity,
                                        child: _isYoutubeReady
                                            ? AbsorbPointer(
                                                absorbing: kIsWeb,
                                                child: YoutubePlayer(
                                                  controller:
                                                      _youtubeController,
                                                  aspectRatio: 16 / 9,
                                                ),
                                              )
                                            : Container(
                                                color: Colors.black12,
                                                child: const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: kgoldColor,
                                                      ),
                                                ),
                                              ),
                                      ),
                                      // Fullscreen IconButton always on top
                                      // if (_isYoutubeReady)
                                      //   Positioned(
                                      //     right: 12,
                                      //     bottom: 12,
                                      //     child: Material(
                                      //       color: Colors.transparent,
                                      //       child: IconButton(
                                      //         padding: EdgeInsets.zero,
                                      //         constraints:
                                      //             const BoxConstraints(),
                                      //         icon: const Icon(
                                      //           Icons.fullscreen,
                                      //           color: kgoldColor,
                                      //           size: 32,
                                      //         ),
                                      //         onPressed: () async {
                                      //           await _youtubeController
                                      //               .pauseVideo();
                                      //           final videoId =
                                      //               YoutubePlayerController.convertUrlToId(
                                      //                 'https://www.youtube.com/watch?v=Riff0rzYCnQ',
                                      //               ) ??
                                      //               'Riff0rzYCnQ';
                                      //           WidgetsBinding.instance
                                      //               .addPostFrameCallback((_) {
                                      //                 Navigator.of(
                                      //                   context,
                                      //                   rootNavigator: true,
                                      //                 ).push(
                                      //                   MaterialPageRoute(
                                      //                     builder: (context) =>
                                      //                         FullScreenYoutubePlayer(
                                      //                           videoId:
                                      //                               videoId,
                                      //                         ),
                                      //                   ),
                                      //                 );
                                      //               });
                                      //         },
                                      //       ),
                                      //     ),
                                      //   ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 15),
                                GestureDetector(
                                  onTap: () async {
                                    await _youtubeController.pauseVideo();
                                    final videoId =
                                        YoutubePlayerController.convertUrlToId(
                                          'https://www.youtube.com/watch?v=Riff0rzYCnQ',
                                        ) ??
                                        'Riff0rzYCnQ';
                                    // Use SchedulerBinding to ensure navigation works in all layouts
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          Navigator.of(
                                            context,
                                            rootNavigator: true,
                                          ).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  FullScreenYoutubePlayer(
                                                    videoId: videoId,
                                                  ),
                                            ),
                                          );
                                        });
                                  },

                                  child: Text(
                                    'Click Here for Full Screen View',

                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color: kgoldColor,

                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      goldTextGradient.createShader(bounds),
                                  child: Text(
                                    'Turn Your Life Into a Living Legacy.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.cinzel(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Be remembered. Be experienced.\nBe timeless.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        height: 1.5,
                                        color: kgoldColor.withOpacity(0.5),
                                      ),
                                    ),
                                    Icon(
                                      Icons.star,
                                      color: kgoldColor,
                                      size: 22,
                                    ),
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        height: 1.5,
                                        color: kgoldColor.withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Create your digital legacy and\nshare your story with the world.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 60),
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: goldTextGradient,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: const EdgeInsets.all(2),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: OutlinedButton(
                                        onPressed: _onRequest,
                                        style: OutlinedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          side: BorderSide.none,
                                          backgroundColor: Colors.transparent,
                                          padding: EdgeInsets.zero,
                                          foregroundColor: Colors.white,
                                          shadowColor: Colors.transparent,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ShaderMask(
                                              shaderCallback: (bounds) =>
                                                  goldTextGradient.createShader(
                                                    bounds,
                                                  ),
                                              child: Text(
                                                'Request to Join as Star',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            ShaderMask(
                                              shaderCallback: (bounds) =>
                                                  goldTextGradient.createShader(
                                                    bounds,
                                                  ),
                                              child: Icon(
                                                Icons.arrow_forward_ios,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'Applications are limited. Selection-based access.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: kgoldColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
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
