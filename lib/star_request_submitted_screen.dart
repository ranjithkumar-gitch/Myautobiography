import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myautobiography/constants/colors.dart';
import 'package:myautobiography/onboardingscreen.dart';
import 'package:myautobiography/theme_notifier.dart';

class StarRequestSubmittedScreen extends StatelessWidget {
  // Chevron gold-bordered box widget for inspiration message

  final VoidCallback? onExplore;
  const StarRequestSubmittedScreen({Key? key, this.onExplore})
    : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
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
                Image.asset('assets/image1.png', height: 60),
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
            child: Image.asset('assets/bg_1411.PNG', fit: BoxFit.cover),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;
                if (isWide) {
                  // Web/Desktop: left logo, right content
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left branding/logo
                      Expanded(
                        flex: 6,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            'assets/5thscreen.PNG',
                            height: 600,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(),
                          ),
                        ),
                      ),
                      // Right content
                      Expanded(
                        flex: 6,
                        child: Center(
                          child: SingleChildScrollView(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                              ),
                              alignment: Alignment.center,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 500,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 5),
                                    Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: goldTextGradient,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(15),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.black,
                                        ),
                                        child: ShaderMask(
                                          shaderCallback: (bounds) =>
                                              goldTextGradient.createShader(
                                                bounds,
                                              ),
                                          child: Icon(
                                            Icons.star,
                                            color: Colors.white,
                                            size: 54,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    // ShaderMask(
                                    //   shaderCallback: (bounds) =>
                                    //       goldTextGradient.createShader(bounds),
                                    //   child: Text(
                                    //     'Your Journey Has Begun.',
                                    //     textAlign: TextAlign.center,
                                    //     style: GoogleFonts.cinzel(
                                    //       color: Colors.white,
                                    //       fontSize: 22,
                                    //       fontWeight: FontWeight.bold,
                                    //       letterSpacing: 0,
                                    //     ),
                                    //   ),
                                    // ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                              right: 8,
                                            ),
                                            height: 1.5,
                                            color: kgoldColor.withOpacity(0.5),
                                          ),
                                        ),
                                        Text(
                                          'Your Journey Has Begun!',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            color: kgoldColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            letterSpacing: 0,
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                              left: 8,
                                            ),
                                            height: 1.5,
                                            color: kgoldColor.withOpacity(0.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "Star request",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.bebasNeue(
                                        color: Colors.white,
                                        fontSize: 50,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                    // ShaderMask(
                                    //   shaderCallback: (bounds) =>
                                    //       goldTextGradient.createShader(bounds),
                                    //   child: Text(
                                    //     "Turn Your Life Into",
                                    //     textAlign: TextAlign.center,
                                    //     style: GoogleFonts.bebasNeue(
                                    //       color: Colors.white,
                                    //       fontSize: 50,
                                    //       fontWeight: FontWeight.bold,
                                    //       letterSpacing: 0,
                                    //     ),
                                    //   ),
                                    // ),
                                    ShaderMask(
                                      shaderCallback: (bounds) =>
                                          goldTextGradient.createShader(bounds),
                                      child: Text(
                                        "submitted.",
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
                                      'Your request to become a star has been successfully submitted.',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 0,
                                      ),
                                    ),

                                    const SizedBox(height: 8),
                                    Container(
                                      height: 1.5,
                                      width: 60,
                                      color: kgoldColor.withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Our team is reviewing your profile.',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    // Chevron gold-bordered box with styled text
                                    _InspireChevronBox(),

                                    const SizedBox(height: 5),
                                    // Text(
                                    //   'If selected, your story could be experienced by audiences across the world.',
                                    //   textAlign: TextAlign.center,
                                    //   style: GoogleFonts.poppins(
                                    //     color: Colors.white,
                                    //     fontSize: 14,
                                    //   ),
                                    // ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'You\'ll hear from us soon.',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.bebasNeue(
                                        color: Colors.white,
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                    Text(
                                      'We ‘ll  notify you once our review is complete.',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                    // ShaderMask(
                                    //   shaderCallback: (bounds) =>
                                    //       goldTextGradient.createShader(bounds),
                                    //   child: Text(
                                    //     'You\'ll hear from us soon.',
                                    //     textAlign: TextAlign.center,
                                    //     style: GoogleFonts.bebasNeue(
                                    //       color: Colors.white,
                                    //       fontSize: 20,
                                    //       fontWeight: FontWeight.bold,
                                    //       letterSpacing: 0,
                                    //     ),
                                    //   ),
                                    // ),
                                    const SizedBox(height: 25),
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
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          child: OutlinedButton(
                                            onPressed:
                                                onExplore ??
                                                () {
                                                  Navigator.of(
                                                    context,
                                                  ).popUntil(
                                                    (route) => route.isFirst,
                                                  );
                                                },
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
                                                          .createShader(bounds),
                                                  child: Text(
                                                    'Thank You',
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.white,
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                ShaderMask(
                                                  shaderCallback: (bounds) =>
                                                      goldTextGradient
                                                          .createShader(bounds),
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
                                    const SizedBox(height: 24),
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
                  // Mobile/tablet: show existing centered UI
                  return Center(
                    child: SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        alignment: Alignment.center,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 56),
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: goldTextGradient,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black,
                                  ),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) =>
                                        goldTextGradient.createShader(bounds),
                                    child: Icon(
                                      Icons.star,
                                      color: Colors.white,
                                      size: 54,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    goldTextGradient.createShader(bounds),
                                child: Text(
                                  'Your Journey Has Begun.',
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
                                  Icon(Icons.star, color: kgoldColor, size: 22),
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
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    goldTextGradient.createShader(bounds),
                                child: Text(
                                  'Star Request Submitted.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.cinzel(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Your request to become a Star has been successfully submitted.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 1.5,
                                width: 60,
                                color: kgoldColor.withOpacity(0.5),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Our team is reviewing your profile.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),

                              const SizedBox(height: 18),

                              Text(
                                "You\'ll hear from us soon.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.bebasNeue(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0,
                                ),
                              ),
                              const SizedBox(height: 18),
                              // ShaderMask(
                              //   shaderCallback: (bounds) =>
                              //       goldTextGradient.createShader(bounds),
                              //   child: Text(
                              //     'You\'ll hear from us soon.',
                              //     textAlign: TextAlign.center,
                              //     style: GoogleFonts.cinzel(
                              //       color: Colors.white,
                              //       fontSize: 20,
                              //       fontWeight: FontWeight.bold,
                              //       letterSpacing: 0,
                              //     ),
                              //   ),
                              // ),
                              const SizedBox(height: 32),
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
                                      onPressed:
                                          onExplore ??
                                          () {
                                            Navigator.of(context).popUntil(
                                              (route) => route.isFirst,
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
                                              'Thank You',
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
                              const SizedBox(height: 24),
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
    );
  }
}

class _InspireChevronBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: CustomPaint(
        painter: _ChevronBorderPainter(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ShaderMask(
                shaderCallback: (bounds) =>
                    goldTextGradient.createShader(bounds),
                child: Text(
                  'YOUR STORY HAS THE POWER TO INSPIRE',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.bebasNeue(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'If selected, your story could be experienced by audiences accros the world.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for chevron gold border
class _ChevronBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kgoldColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - 16);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(0, size.height - 16);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
