import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:country_code_picker/country_code_picker.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:myautobiography/app_shared_preferences.dart';
import 'package:myautobiography/constants/colors.dart';
import 'package:myautobiography/models/register_request.dart';
import 'package:myautobiography/onboardingscreen.dart';
import 'package:myautobiography/register_service.dart';
import 'package:myautobiography/shared_pref_helper.dart';
import 'package:myautobiography/success_screen2.dart';
import 'package:myautobiography/theme_notifier.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter/gestures.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TapGestureRecognizer _termsTapRecognizer = TapGestureRecognizer();

  @override
  void initState() {
    super.initState();
    _termsTapRecognizer.onTap = _openTermsOfService;
  }

  void _openTermsOfService() async {
    const url =
        'https://chollettiudayteja.blogspot.com/p/my-autobiography-terms-and-conditions.html';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Terms of Service.')),
      );
    }
  }

  bool termsAccepted = false;
  CountryCode? selectedCountryCode;
  bool _isLoading = false;
  String? _errorMessage;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String? selectedMonth;
  String? selectedDay;
  String? selectedYear;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    userNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _onRegister() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        userNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        selectedCountryCode == null ||
        selectedDay == null ||
        selectedMonth == null ||
        selectedYear == null ||
        !termsAccepted) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please fill all fields and accept terms.';
      });
      return;
    }
    final dob =
        "${selectedMonth!.padLeft(2, '0')}-${selectedDay!.padLeft(2, '0')}-${selectedYear!}";
    final req = RegisterRequest(
      role: 'stargazer',
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      email: emailController.text.trim(),
      phone:
          (selectedCountryCode?.dialCode ?? '') + phoneController.text.trim(),
      dob: dob,
      displayName: userNameController.text.trim(),
    );
    try {
      final service = RegisterService();
      final resp = await service.registerauth(req);
      if (resp.statusCode == 201 && resp.data != null) {
        await SharedPrefHelper.saveName(
          resp.data!.firstName,
          resp.data!.lastName,
        );
        await SharedPrefHelper.saveStargazerIdAndCreatedAt(
          resp.data!.id,
          resp.data!.createdAt,
        );
        await SharedPrefServices.setStargazerId(resp.data!.id);
        await SharedPrefServices.setStargazerCreatedAt(resp.data!.createdAt);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen2(
              firstName: resp.data!.firstName,
              lastName: resp.data!.lastName,
            ),
          ),
        );
      } else {
        setState(() {
          _errorMessage = resp.message ?? 'Registration failed.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ' + e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWeb =
        Theme.of(context).platform == TargetPlatform.fuchsia ||
        identical(0, 0.0) &&
            (Theme.of(context).platform.toString().contains('web') || false);
    // Use kIsWeb if available
    // import 'package:flutter/foundation.dart';
    // final isWeb = kIsWeb;
    final width = MediaQuery.of(context).size.width;
    final isDesktopWeb = kIsWeb && width > 900;

    if (isDesktopWeb) {
      // Web/Desktop layout: logo left, content right, header top, and logo top left corner
      return Scaffold(
        backgroundColor: Colors.black,
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
        // backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/bg_1411.jpg', fit: BoxFit.cover),
            ),
            //Logo in top left
            // Positioned(
            //   left: 40,
            //   top: 32,
            //   child: Row(
            //     crossAxisAlignment: CrossAxisAlignment.center,
            //     children: [
            //       Image.asset('assets/image1.png', height: 60),
            //       const SizedBox(width: 16),
            //       Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Text(
            //             'MY AUTOBIOGRAPHY',
            //             style: GoogleFonts.bebasNeue(
            //               color: const Color(0xffc18e3b),
            //               fontSize: 28,
            //               letterSpacing: 2,
            //             ),
            //           ),
            //           Text(
            //             '"Live a Life & Leave a Legacy"',
            //             style: GoogleFonts.poppins(
            //               color: Colors.white70,
            //               fontSize: 13,
            //               fontStyle: FontStyle.italic,
            //             ),
            //           ),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),
            // Logo and branding at top left corner
            SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo and left section
                  // Container(
                  //   width: width * 0.38,
                  //   color: Colors.black.withOpacity(0.7),
                  //   child: Column(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     crossAxisAlignment: CrossAxisAlignment.center,
                  //     children: [Image.asset('assets/image1.png', height: 600)],
                  //   ),
                  // ),
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'assets/image1.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(),
                      ),
                    ),
                  ),
                  // Right: Header and form
                  Expanded(
                    flex: 6,
                    child: SingleChildScrollView(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: _RegisterContent(
                            isWide: true,
                            firstNameController: firstNameController,
                            lastNameController: lastNameController,
                            userNameController: userNameController,
                            emailController: emailController,
                            phoneController: phoneController,
                            selectedMonth: selectedMonth,
                            selectedDay: selectedDay,
                            selectedYear: selectedYear,
                            termsAccepted: termsAccepted,
                            isLoading: _isLoading,
                            errorMessage: _errorMessage,
                            selectedCountryCode: selectedCountryCode,
                            termsTapRecognizer: _termsTapRecognizer,
                            onChangedDOB: (m, d, y) {
                              setState(() {
                                selectedMonth = m;
                                selectedDay = d;
                                selectedYear = y;
                              });
                            },
                            onChangedCountry: (code) =>
                                setState(() => selectedCountryCode = code),
                            onChangedTerms: (v) =>
                                setState(() => termsAccepted = v ?? false),
                            onRegister: _onRegister,
                          ),
                        ),
                      ),
                    ),
                  ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Default: mobile/tablet UI
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Colors.black.withValues(alpha: 0.2),
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.only(left: 16, top: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/appbar_logo.png', height: 44),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MY AUTOBIOGRAPHY',
                      style: GoogleFonts.bebasNeue(
                        color: const Color(0xffc18e3b),
                        fontSize: 18,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      '"Live a Life & Leave a Legacy"',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 10,
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
            child: Image.asset('assets/bg_1411.jpg', fit: BoxFit.cover),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Logo always on top, centered
                      SizedBox(
                        height: 250,
                        width: 250,
                        child: Image.asset(
                          'assets/logo_4kquality.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: _RegisterContent(
                          isWide: false,
                          firstNameController: firstNameController,
                          lastNameController: lastNameController,
                          userNameController: userNameController,
                          emailController: emailController,
                          phoneController: phoneController,
                          selectedMonth: selectedMonth,
                          selectedDay: selectedDay,
                          selectedYear: selectedYear,
                          termsAccepted: termsAccepted,
                          isLoading: _isLoading,
                          errorMessage: _errorMessage,
                          selectedCountryCode: selectedCountryCode,
                          termsTapRecognizer: _termsTapRecognizer,
                          onChangedDOB: (m, d, y) {
                            setState(() {
                              selectedMonth = m;
                              selectedDay = d;
                              selectedYear = y;
                            });
                          },
                          onChangedCountry: (code) =>
                              setState(() => selectedCountryCode = code),
                          onChangedTerms: (v) =>
                              setState(() => termsAccepted = v ?? false),
                          onRegister: _onRegister,
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
}

// Extracted content widget for reuse in both layouts
class _RegisterContent extends StatelessWidget {
  final bool isWide;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController userNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final String? selectedMonth;
  final String? selectedDay;
  final String? selectedYear;
  final bool termsAccepted;
  final bool isLoading;
  final String? errorMessage;
  final CountryCode? selectedCountryCode;
  final GestureRecognizer termsTapRecognizer;
  final void Function(String?, String?, String?) onChangedDOB;
  final void Function(CountryCode) onChangedCountry;
  final void Function(bool?) onChangedTerms;
  final VoidCallback onRegister;

  const _RegisterContent({
    required this.isWide,
    required this.firstNameController,
    required this.lastNameController,
    required this.userNameController,
    required this.emailController,
    required this.phoneController,
    required this.selectedMonth,
    required this.selectedDay,
    required this.selectedYear,
    required this.termsAccepted,
    required this.isLoading,
    required this.errorMessage,
    required this.selectedCountryCode,
    required this.termsTapRecognizer,
    required this.onChangedDOB,
    required this.onChangedCountry,
    required this.onChangedTerms,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb;
    final width = MediaQuery.of(context).size.width;
    final isDesktopWeb = isWeb && width > 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // const SizedBox(height: 4),
        if (isDesktopWeb)
          // Web: show "let’s get you started"
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
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
                      margin: const EdgeInsets.only(left: 8),
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
                  'let’s get you started',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.bebasNeue(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0,
                  ),
                ),
              ),
              Container(
                height: 1.5,
                width: 80,
                color: kgoldColor.withOpacity(0.5),
              ),
              const SizedBox(height: 6),
              Text(
                'Takes Less than 30 seconds.',
                style: GoogleFonts.poppins(
                  color: kwhiteColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
            ],
          )
        else
          // Mobile/Tablet: show gold divider, star, and 'Your Story Starts Here.'
          Column(
            children: [
              Row(
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
              const SizedBox(height: 12),
              ShaderMask(
                shaderCallback: (bounds) =>
                    goldTextGradient.createShader(bounds),
                child: Text(
                  'Your Story Starts Here.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 1.5,
                width: 80,
                color: kgoldColor.withOpacity(0.5),
              ),
              const SizedBox(height: 10),
              Text(
                'Takes Less than 30 seconds.',
                style: GoogleFonts.poppins(
                  color: kwhiteColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
            ],
          ),
        // First/Last Name
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "First Name *",
                    style: GoogleFonts.poppins(
                      color: kgoldColor,
                      fontSize: isWide ? 18 : 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _goldBorderFieldWithLabel(
                    hint: 'First Name',
                    controller: firstNameController,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Last Name *",
                    style: GoogleFonts.poppins(
                      color: kgoldColor,
                      fontSize: isWide ? 18 : 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _goldBorderFieldWithLabel(
                    hint: 'Last Name',
                    controller: lastNameController,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: isWide ? 8 : 15),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "User Name *",
            style: GoogleFonts.poppins(
              color: kgoldColor,
              fontSize: isWide ? 18 : 14,
            ),
          ),
        ),
        const SizedBox(height: 6),
        _goldBorderFieldWithLabel(
          hint: 'User Name',
          controller: userNameController,
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'This will be your public identity on the platform.',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: isWide ? 13 : 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        SizedBox(height: isWide ? 8 : 15),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Email Address *",
            style: GoogleFonts.poppins(
              color: kgoldColor,
              fontSize: isWide ? 18 : 14,
            ),
          ),
        ),
        const SizedBox(height: 6),
        _goldBorderFieldWithLabel(
          hint: 'Enter your Email',
          controller: emailController,
        ),
        SizedBox(height: isWide ? 8 : 15),
        // Date of Birth
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Date of Birth *",
            style: GoogleFonts.poppins(
              color: kgoldColor,
              fontSize: isWide ? 18 : 14,
            ),
          ),
        ),
        const SizedBox(height: 6),
        _DateOfBirthRow(onChanged: onChangedDOB),
        SizedBox(height: isWide ? 8 : 15),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Phone *",
            style: GoogleFonts.poppins(
              color: kgoldColor,
              fontSize: isWide ? 18 : 14,
            ),
          ),
        ),
        const SizedBox(height: 6),
        _PhoneRow(
          controller: phoneController,
          onCountryChanged: onChangedCountry,
        ),
        SizedBox(height: isWide ? 8 : 15),
        Row(
          children: [
            Checkbox(
              value: termsAccepted,
              onChanged: onChangedTerms,
              activeColor: kgoldColor,
              checkColor: Colors.black,
            ),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: 'By clicking this box, I agree to the Myautobiography ',
                  style: GoogleFonts.poppins(
                    color: kgoldColor,
                    fontSize: isWide ? 15 : 13,
                  ),
                  children: [
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                        color: kgoldColor,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        fontSize: isWide ? 15 : 13,
                      ),
                      recognizer: termsTapRecognizer,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        SizedBox(height: isWide ? 12 : 32),
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
                onPressed: isLoading ? null : onRegister,
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
                child: isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(kgoldColor),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                goldTextGradient.createShader(bounds),
                            child: Text(
                              'Register Now',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: isWide ? 22 : 18,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                goldTextGradient.createShader(bounds),
                            child: Icon(
                              Icons.chevron_right,
                              size: isWide ? 32 : 24,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}

class _GoldStarDividerWithText extends StatelessWidget {
  const _GoldStarDividerWithText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                height: 1.5,
                color: kgoldColor.withOpacity(0.5),
              ),
            ),
            // Icon(Icons.star, color: kgoldColor, size: 22),
            Text(
              'YOU ARE IN.',
              style: GoogleFonts.poppins(
                color: kgoldColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
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
        const SizedBox(height: 10),
        ShaderMask(
          shaderCallback: (bounds) => goldTextGradient.createShader(bounds),
          child: Text(
            'let’s get you started',
            textAlign: TextAlign.center,
            style: GoogleFonts.bebasNeue(
              color: Colors.white,
              fontSize: 50,
              fontWeight: FontWeight.bold,
              letterSpacing: 0,
            ),
          ),
        ),

        // Text(
        //   'Your Story Starts Here.',
        //   style: GoogleFonts.cinzel(
        //     color: kgoldColor,
        //     fontSize: 22,
        //     fontWeight: FontWeight.w500,
        //   ),
        // ),
        const SizedBox(height: 5),
        Container(height: 1.5, width: 80, color: kgoldColor.withOpacity(0.5)),
        const SizedBox(height: 5),

        Text(
          'Takes Less than 30 seconds.',
          style: GoogleFonts.poppins(
            color: kwhiteColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

Widget _goldBorderFieldWithLabel({
  required String hint,
  TextEditingController? controller,
  bool isPhone = false,
}) {
  return _GoldBorderFieldWithLabel(
    hint: hint,
    controller: controller,
    isPhone: isPhone,
  );
}

class _GoldBorderFieldWithLabel extends StatefulWidget {
  final String hint;
  final bool isPhone;
  final TextEditingController? controller;
  const _GoldBorderFieldWithLabel({
    required this.hint,
    this.controller,
    this.isPhone = false,
  });

  @override
  State<_GoldBorderFieldWithLabel> createState() =>
      _GoldBorderFieldWithLabelState();
}

class _GoldBorderFieldWithLabelState extends State<_GoldBorderFieldWithLabel> {
  String? value;
  bool isGold = false;
  late final TextEditingController controller;
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? TextEditingController();
    controller.addListener(_updateGold);
    focusNode.addListener(_updateGold);
  }

  void _updateGold() {
    setState(() {
      isGold = controller.text.isNotEmpty || focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: TextInputAction.next,
      style: const TextStyle(color: Colors.white),
      keyboardType: widget.isPhone ? TextInputType.number : TextInputType.text,
      inputFormatters: widget.isPhone
          ? [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ]
          : null,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF1C1C1E),
        hintText: widget.hint,
        hintStyle: const TextStyle(color: Colors.white38),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isGold ? kgoldColor : Colors.white38,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: kgoldColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}

class _DateOfBirthRow extends StatefulWidget {
  final void Function(String? month, String? day, String? year)? onChanged;
  const _DateOfBirthRow({this.onChanged});
  @override
  State<_DateOfBirthRow> createState() => _DateOfBirthRowState();
}

class _DateOfBirthRowState extends State<_DateOfBirthRow> {
  String? selectedMonth;
  String? selectedDay;
  String? selectedYear;

  int _daysInMonth(String? month) {
    if (month == null) return 31;
    final m = int.tryParse(month) ?? 0;
    const days = [0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return (m >= 1 && m <= 12) ? days[m] : 31;
  }

  void _notifyParent() {
    if (widget.onChanged != null) {
      widget.onChanged!(selectedMonth, selectedDay, selectedYear);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxDays = _daysInMonth(selectedMonth);
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: _dropdownBox(
            label: "Month",
            value: selectedMonth,
            items: List.generate(12, (i) => (i + 1).toString().padLeft(2, '0')),
            displayLabels: const [
              'January',
              'February',
              'March',
              'April',
              'May',
              'June',
              'July',
              'August',
              'September',
              'October',
              'November',
              'December',
            ],
            onChanged: (val) {
              final newMax = _daysInMonth(val);
              final currentDay = int.tryParse(selectedDay ?? '');
              setState(() {
                selectedMonth = val;
                if (currentDay != null && currentDay > newMax) {
                  selectedDay = null;
                }
              });
              _notifyParent();
            },
            isSelected: selectedMonth != null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: _dropdownBox(
            label: "Day",
            value: selectedDay,
            items: List.generate(
              maxDays,
              (i) => (i + 1).toString().padLeft(2, '0'),
            ),
            onChanged: (val) {
              setState(() => selectedDay = val);
              _notifyParent();
            },
            isSelected: selectedDay != null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 4,
          child: _dropdownBox(
            label: "Year",
            value: selectedYear,
            // Only show years where user is at least 18 years old (i.e., up to 2008 for 2026)
            items: List.generate(
              DateTime.now().year - 18 - 1900 + 1, // 2008 - 1900 + 1
              (i) => (DateTime.now().year - 18 - i).toString(),
            ),
            onChanged: (val) {
              setState(() => selectedYear = val);
              _notifyParent();
            },
            isSelected: selectedYear != null,
          ),
        ),
      ],
    );
  }
}

Widget _dropdownBox({
  required String label,
  required String? value,
  required List<String> items,
  required void Function(String?) onChanged,
  required bool isSelected,
  List<String>? displayLabels,
}) {
  return DropdownButtonFormField<String>(
    value: value,
    isExpanded: true,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: isSelected ? kgoldColor : Colors.white38,
        fontSize: 14,
      ),
      filled: true,
      fillColor: const Color(0xFF1C1C1E),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isSelected ? kgoldColor : Colors.white38,
          width: 2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: kgoldColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    ),
    dropdownColor: const Color(0xFF232323),
    style: const TextStyle(color: Colors.white, fontSize: 15),
    iconEnabledColor: kgoldColor,
    items: items
        .asMap()
        .entries
        .map(
          (entry) => DropdownMenuItem<String>(
            value: entry.value,
            child: Text(
              displayLabels != null ? displayLabels[entry.key] : entry.value,
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        )
        .toList(),
    onChanged: onChanged,
  );
}

class _PhoneRow extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<CountryCode>? onCountryChanged;
  const _PhoneRow({this.controller, this.onCountryChanged});
  @override
  State<_PhoneRow> createState() => _PhoneRowState();
}

class _PhoneRowState extends State<_PhoneRow> {
  late FocusNode _focusNode;
  bool _hasFocus = false;
  bool _hasValue = false;
  late final TextEditingController _controller;
  CountryCode? _selectedCountryCode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = widget.controller ?? TextEditingController();
    _focusNode.addListener(_handleFocusChange);
    _controller.addListener(_handleValueChange);
  }

  void _handleFocusChange() {
    setState(() {});
  }

  void _handleValueChange() {
    setState(() {
      _hasValue = _controller.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = (_focusNode.hasFocus || _hasValue)
        ? kgoldColor
        : Colors.white38;
    return Row(
      children: [
        SizedBox(
          width: 110,
          height: 48,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Center(
              child: CountryCodePicker(
                onChanged: (code) {
                  setState(() => _selectedCountryCode = code);
                  if (widget.onCountryChanged != null)
                    widget.onCountryChanged!(code);
                },
                initialSelection: null,
                favorite: const [],
                showCountryOnly: false,
                showOnlyCountryWhenClosed: false,
                alignLeft: true,
                headerTextStyle: TextStyle(
                  fontSize: 18,
                  color: kgoldColor,
                  fontWeight: FontWeight.w400,
                ),
                dialogSize: const Size(350, 500),
                showFlagMain: true,
                showFlagDialog: true,
                textStyle: const TextStyle(fontSize: 0), // Hide placeholder
                searchStyle: TextStyle(color: kgoldColor),
                dialogTextStyle: TextStyle(
                  color: kgoldColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                dialogBackgroundColor: Color(0xFF232323),
                barrierColor: Colors.black54,
                builder: (country) {
                  if (_selectedCountryCode == null ||
                      _selectedCountryCode!.dialCode == null ||
                      _selectedCountryCode!.dialCode!.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.arrow_drop_down_rounded,
                          color: kgoldColor,
                          size: 24,
                        ),
                      ),
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 8),
                          if (_selectedCountryCode!.flagUri != null)
                            Image.asset(
                              _selectedCountryCode!.flagUri!,
                              package: 'country_code_picker',
                              width: 24,
                              height: 18,
                            ),
                          const SizedBox(width: 6),
                          Text(
                            _selectedCountryCode!.dialCode!,
                            style: TextStyle(color: kwhiteColor, fontSize: 16),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: Icon(
                          Icons.arrow_drop_down_rounded,
                          color: kgoldColor,
                          size: 20,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF1C1C1E),
              hintText: 'Enter No.',
              hintStyle: const TextStyle(color: Colors.white38),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: (_focusNode.hasFocus || _hasValue)
                      ? kgoldColor
                      : Colors.white38,
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: kgoldColor, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
