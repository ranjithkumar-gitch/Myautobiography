import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myautobiography/constants/colors.dart';
import 'package:myautobiography/register_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:myautobiography/theme_notifier.dart';

// import 'package:flutter_svg/flutter_svg.dart';

class OnBoardingscreen extends StatelessWidget {
  const OnBoardingscreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb;
    final width = MediaQuery.of(context).size.width;
    final isDesktopWeb = isWeb && width > 900;

    if (isDesktopWeb) {
      // Web/Desktop layout with transparent header
      return Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: AppBar(
            backgroundColor: Colors.black.withOpacity(0.2),
            elevation: 0,
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
            // Starry background
            Positioned.fill(
              child: Image.asset('assets/bg_1411.png', fit: BoxFit.cover),
            ),
            // Gold concentric circles (custom painter)
            // Positioned(
            //   left: 0,
            //   top: 0,
            //   bottom: 0,
            //   child: SizedBox(
            //     width: width * 0.45,
            //     // child: CustomPaint(painter: _GoldCirclesPainter()),
            //   ),
            // ),
            // Main content
            SafeArea(
              child: SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32.0,
                      vertical: 24.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left: Gold figure (optional, fallback to empty if missing)
                        Expanded(
                          flex: 6,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Image.asset(
                                'assets/image1.png',
                                height: 600,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(),
                              ),
                            ),
                          ),
                        ),
                        // Right: Text and CTA
                        Expanded(
                          flex: 6,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32.0,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // const SizedBox(height: 80),
                                Text(
                                  'A NEW ERA OF',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 2,
                                  ),
                                ),
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      goldTextGradient.createShader(bounds),
                                  child: Text(
                                    'HUMAN STORIES',
                                    style: GoogleFonts.bebasNeue(
                                      color: Colors.white,
                                      fontSize: 80,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ),
                                Text(
                                  'IS ABOUT TO BEGIN',
                                  style: GoogleFonts.bebasNeue(
                                    color: Colors.white,
                                    fontSize: 80,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0,
                                  ),
                                ),
                                // const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      flex: 2,
                                      child: FractionallySizedBox(
                                        widthFactor: 0.5,
                                        child: Divider(
                                          color: kwhiteColor,
                                          thickness: 1,
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                      ),
                                      child: Icon(
                                        Icons.star,
                                        color: kgoldColor,
                                        size: 32,
                                      ),
                                    ),
                                    Flexible(
                                      flex: 2,
                                      child: FractionallySizedBox(
                                        widthFactor: 0.5,
                                        child: Divider(
                                          color: kwhiteColor,
                                          thickness: 1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Join early. Be part of what's coming next.",
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xffc18e3b),
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    // color: kblackColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.25),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'EARLY ACCESS IS LIMITED.',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      // ShaderMask(
                                      //   shaderCallback: (bounds) =>
                                      //       goldTextGradient.createShader(
                                      //         bounds,
                                      //       ),
                                      //   child: Text(
                                      //     'EARLY ACCESS IS LIMITED.',
                                      //     style: GoogleFonts.poppins(
                                      //       color: Colors.white,
                                      //       fontWeight: FontWeight.bold,
                                      //       fontSize: 16,
                                      //     ),
                                      //   ),
                                      // ),
                                      ShaderMask(
                                        shaderCallback: (bounds) =>
                                            goldTextGradient.createShader(
                                              bounds,
                                            ),
                                        child: Text(
                                          'THOUSANDS ARE ALREADY JOINING.',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: 320,
                                  height: 56,
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
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  RegisterScreen(),
                                            ),
                                          );
                                        },
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
                                                'SECURE MY SPOT',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 22,
                                                  letterSpacing: 1.2,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            ShaderMask(
                                              shaderCallback: (bounds) =>
                                                  goldTextGradient.createShader(
                                                    bounds,
                                                  ),
                                              child: Icon(
                                                Icons.chevron_right,
                                                size: 32,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 40),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.shield_outlined,
                                      color: Color(0xffc18e3b),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'NO SPAM. PRIORITY ACCESS WHEN WE LAUNCH.',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Default: mobile/tablet UI
    return Scaffold(
      body: Stack(
        children: [
          // Responsive background image
          Positioned.fill(
            child: Image.asset('assets/bg_1411.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Logo always on top, centered
                      SizedBox(
                        height: 180,
                        width: 180,
                        child: Image.asset(
                          'assets/logo_4kquality.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: _OnboardingContent(isWide: false),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Extracted content widget for reuse in both layouts
class _OnboardingContent extends StatelessWidget {
  final bool isWide;
  const _OnboardingContent({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ...existing code...
        Text(
          'A NEW ERA OF',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: isWide ? 28 : 20,
            fontWeight: FontWeight.w400,
            letterSpacing: 2,
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) => goldTextGradient.createShader(bounds),
          child: Text(
            'HUMAN STORIES',
            textAlign: TextAlign.center,
            style: GoogleFonts.bebasNeue(
              color: Colors.white,
              fontSize: isWide ? 44 : 30,
              fontWeight: FontWeight.bold,
              letterSpacing: 0,
            ),
          ),
        ),
        Text(
          'IS ABOUT TO BEGIN.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: isWide ? 28 : 20,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        ShaderMask(
          shaderCallback: (bounds) => goldTextGradient.createShader(bounds),
          child: Text(
            'Join early. Be part of what\'s coming next.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: isWide ? 18 : 14,
            ),
          ),
        ),
        const SizedBox(height: 32),
        // Early access note
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.group_outlined, size: 30, color: Color(0xffc18e3b)),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        goldTextGradient.createShader(bounds),
                    child: Text(
                      'EARLY ACCESS IS LIMITED.',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        goldTextGradient.createShader(bounds),
                    child: Text(
                      'THOUSANDS ARE ALREADY JOINING.',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Gold button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: Container(
            decoration: BoxDecoration(
              gradient: goldTextGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(2), // border thickness
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(14),
              ),
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  side: BorderSide.none,
                  backgroundColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          goldTextGradient.createShader(bounds),
                      child: Text(
                        'SECURE MY SPOT',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isWide ? 22 : 18,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          goldTextGradient.createShader(bounds),
                      child: Icon(
                        Icons.chevron_right,
                        size: isWide ? 32 : 25,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        // Footer note
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_outlined, color: Color(0xffc18e3b), size: 18),
            const SizedBox(width: 6),
            Text(
              'NO SPAM. PRIORITY ACCESS WHEN WE LAUNCH.',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// Custom painter for concentric gold circles
//
