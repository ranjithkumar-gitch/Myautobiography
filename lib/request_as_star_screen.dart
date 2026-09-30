import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myautobiography/app_shared_preferences.dart';
import 'package:myautobiography/constants/colors.dart';
import 'package:myautobiography/onboardingscreen.dart';
import 'package:myautobiography/request_as_star_service.dart';
import 'package:myautobiography/star_request_submitted_screen.dart';
import 'package:myautobiography/theme_notifier.dart';

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
    final isWide = MediaQuery.of(context).size.width > 900;
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
          preferredSize: Size.fromHeight(isWide ? 100 : 80),
          child: AppBar(
            backgroundColor: Colors.black.withValues(alpha: 0.2),
            elevation: 0,
            // leading: IconButton(
            //   icon: const Icon(Icons.arrow_back_ios_new_rounded),
            //   color: kgoldColor,
            //   onPressed: _onBackPressed,
            //   tooltip: 'Back',
            // ),
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            title: Padding(
              padding: EdgeInsets.only(
                left: isWide ? 40 : 4,
                top: isWide ? 10 : 8,
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/bg_1411.jpg', fit: BoxFit.cover),
            ),
            // Close button for mobile UI only
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;
                if (!isWide) {}
                return const SizedBox.shrink();
              },
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 900;
                  if (isWide) {
                    // Web/Desktop: Logo left, content right
                    return Row(
                      children: [
                        Expanded(
                          flex: 6,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.network(
                              'https://dl9325jolfmzn.cloudfront.net/assets/4thscreen.jpg',
                              fit: BoxFit.contain,
                              webHtmlElementStrategy:
                                  WebHtmlElementStrategy.fallback,
                              // Fall back to the bundled copy if the CDN can't be reached.
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.network(
                                    'https://dl9325jolfmzn.cloudfront.net/assets/4thscreen.jpg',
                                    fit: BoxFit.contain,
                                  ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: SingleChildScrollView(
                            child: ConstrainedBox(
                              // Fill the full height so content sits centered on screen.
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32.0,
                                    vertical: 24.0,
                                  ),
                                  constraints: const BoxConstraints(
                                    maxWidth: 680,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
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
                                                fontSize: 18,
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
                                          fontSize: 48,
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
                                            fontSize: 48,
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
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: 0,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
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
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              Text(
                                                '3. Preserve Your Knowledge',
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
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              Text(
                                                '4. AI-Powered Legacy',
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
                                      const SizedBox(height: 40),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 52,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: goldTextGradient,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
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
                                                      BorderRadius.circular(14),
                                                ),
                                                side: BorderSide.none,
                                                backgroundColor:
                                                    Colors.transparent,
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
                                                        goldTextGradient
                                                            .createShader(
                                                              bounds,
                                                            ),
                                                    child: Text(
                                                      'Apply to be a star',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            color: Colors.white,
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  ShaderMask(
                                                    shaderCallback: (bounds) =>
                                                        goldTextGradient
                                                            .createShader(
                                                              bounds,
                                                            ),
                                                    child: const Icon(
                                                      Icons.arrow_forward_ios,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Applications are limited. Selection-based access.',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          color: kwhiteColor,
                                          fontSize: 15,
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
}
