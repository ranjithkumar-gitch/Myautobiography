import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myautobiography/constants/colors.dart';
import 'package:myautobiography/onboardingscreen.dart';
import 'package:myautobiography/request_as_star_screen.dart';
import 'package:myautobiography/theme_notifier.dart';

class SuccessScreen2 extends StatelessWidget {
  final String? firstName;
  final String? lastName;
  const SuccessScreen2({Key? key, this.firstName, this.lastName})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String welcomeName =
        ((firstName ?? '').isNotEmpty || (lastName ?? '').isNotEmpty)
        ? '${firstName ?? ''} ${lastName ?? ''}'.trim()
        : '';
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWeb = kIsWeb;
          final isWide = isWeb && constraints.maxWidth > 900;
          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset('assets/bg_1411.PNG', fit: BoxFit.cover),
              ),
              // Close button for mobile UI only
              if (!isWide)
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0, right: 8.0),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => OnBoardingscreen(),
                            ),
                            (route) => false,
                          );
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.7),
                            border: Border.all(color: kgoldColor, width: 2),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.close,
                              color: kgoldColor,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (isWide)
                SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 6,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Image.asset(
                              'assets/img_right.png',
                              height: 600,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Center(
                          child: SingleChildScrollView(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32.0,
                              ),
                              constraints: const BoxConstraints(maxWidth: 500),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 5),
                                  Row(
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
                                        'YOU ARE IN.',
                                        style: GoogleFonts.poppins(
                                          color: kgoldColor,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
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
                                  ShaderMask(
                                    shaderCallback: (bounds) =>
                                        goldTextGradient.createShader(bounds),
                                    child: Text(
                                      "welcome to early access",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.bebasNeue(
                                        color: Colors.white,
                                        fontSize: 50,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  // _GoldStarDivider(),
                                  // const SizedBox(height: 18),
                                  Text(
                                    welcomeName.isNotEmpty
                                        ? "$welcomeName, You are now part of the early access community of"
                                        : "Welcome the world's first living legacy platform",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color: kwhiteColor,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  ShaderMask(
                                    shaderCallback: (bounds) =>
                                        goldTextGradient.createShader(bounds),
                                    child: Text(
                                      'MyAutobiography',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                      horizontal: 18,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: kgoldColor,
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                      color: Colors.transparent,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'YOU ARE NOW A',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ShaderMask(
                                          shaderCallback: (bounds) =>
                                              goldTextGradient.createShader(
                                                bounds,
                                              ),
                                          child: Text(
                                            'STARGAZER',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.bebasNeue(
                                              color: Colors.white,
                                              fontSize: 48,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  ShaderMask(
                                    shaderCallback: (bounds) =>
                                        goldTextGradient.createShader(bounds),
                                    child: Text(
                                      'HAVE A STORY THE WORLD SHOULD EXPERIENCE?',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        color: kwhiteColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Take the next step. Apply to become a Star and share \nyour untold stories to the world.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color: kwhiteColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                  _GoldStarDivider(),
                                  const SizedBox(height: 10),
                                  _InlineLegacyCountdown(),
                                  const SizedBox(height: 12),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 0.0,
                                    ),
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: OutlinedButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const RequestAsStarScreen(),
                                            ),
                                          );
                                        },
                                        style: OutlinedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          side: const BorderSide(
                                            color: kgoldColor,
                                            width: 2,
                                          ),
                                          padding: EdgeInsets.zero,
                                          foregroundColor: kgoldColor,
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
                                                'Request to be a star',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Icon(
                                              Icons.chevron_right,
                                              color: kgoldColor,
                                              size: 28,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 0.0,
                                    ),
                                    child: Text(
                                      'Applications are limited. Selection-based access.',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        color: kwhiteColor,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (!isWide)
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        alignment: Alignment.center,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: double.infinity,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 24),
                              Image.asset('assets/logo_4kquality.png'),
                              const SizedBox(height: 4),
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    goldTextGradient.createShader(bounds),
                                child: Text(
                                  "You're in, welcome to early access",
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
                              _GoldStarDivider(),
                              const SizedBox(height: 10),
                              Text(
                                welcomeName.isNotEmpty
                                    ? "Welcome to $welcomeName, the world's first living legacy platform"
                                    : "Welcome to the world's first living legacy platform",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: kwhiteColor,
                                  fontSize: 16,
                                ),
                              ),
                              // const SizedBox(height: 10),
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    goldTextGradient.createShader(bounds),
                                child: Text(
                                  'You are now a Stargazer',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.cinzel(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ),
                              // const SizedBox(height: 10),
                              _GoldStarDivider(),
                              const SizedBox(height: 10),
                              _InlineLegacyCountdown(),
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32.0,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const RequestAsStarScreen(),
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      side: const BorderSide(
                                        color: kgoldColor,
                                        width: 2,
                                      ),
                                      padding: EdgeInsets.zero,
                                      foregroundColor: kgoldColor,
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
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Icon(
                                          Icons.chevron_right,
                                          color: kgoldColor,
                                          size: 22,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32.0,
                                ),
                                child: Text(
                                  'Applications are limited. Selection-based access.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: kgoldColor,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              // const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// Gold divider with star widget
class _GoldStarDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}

// Inline 90 days timer widget
class _InlineLegacyCountdown extends StatefulWidget {
  @override
  State<_InlineLegacyCountdown> createState() => _InlineLegacyCountdownState();
}

class _InlineLegacyCountdownState extends State<_InlineLegacyCountdown> {
  late DateTime targetDate;
  late Timer _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    // Set target date to August 9th, 12:00 AM (midnight) of the current or next year if already passed
    final now = DateTime.now();
    int year = now.year;
    final august9 = DateTime(year, 8, 9, 0, 0, 0);
    if (now.isAfter(august9)) {
      // If already past this year's Aug 9, use next year
      targetDate = DateTime(year + 1, 8, 9, 0, 0, 0);
    } else {
      targetDate = august9;
    }
    _updateRemaining();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateRemaining(),
    );
  }

  void _updateRemaining() {
    final now = DateTime.now();
    setState(() {
      _remaining = targetDate.difference(now);
      if (_remaining.isNegative) {
        _remaining = Duration.zero;
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final days = twoDigits(_remaining.inDays);
    final hours = twoDigits(_remaining.inHours % 24);
    final minutes = twoDigits(_remaining.inMinutes % 60);
    final seconds = twoDigits(_remaining.inSeconds % 60);
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => goldTextGradient.createShader(bounds),
          child: Text(
            'Your legacy begins in:',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTimeBox(days, 'Days'),
            const SizedBox(width: 10),
            _buildTimeBox(hours, 'Hours'),
            const SizedBox(width: 10),
            _buildTimeBox(minutes, 'Min'),
            const SizedBox(width: 10),
            _buildTimeBox(seconds, 'Sec'),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeBox(String value, String label) {
    return Container(
      width: 60,
      height: 70,
      decoration: BoxDecoration(
        color: kgoldColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.shade700.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              color: kblackColor,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(color: kblackColor, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
