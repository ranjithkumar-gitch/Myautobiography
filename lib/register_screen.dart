import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:country_code_picker/country_code_picker.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:myautobiography/constants/colors.dart';
import 'package:myautobiography/models/register_request.dart';
import 'package:myautobiography/otp_screen.dart';
import 'package:myautobiography/register_service.dart';
import 'package:myautobiography/theme_notifier.dart';
import 'package:go_router/go_router.dart';
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

  void _openTermsOfService() {
    context.push('/terms-conditions');
  }

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  // At least 6 characters with an uppercase letter, a lowercase letter, a
  // number and a special character (e.g. Mab@123).
  static final _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{6,}$',
  );
  static const _passwordRules =
      'Password must be at least 6 characters and include an uppercase letter, a lowercase letter, a number and a special character.';

  // Returns the first problem with the form, or null when it is valid.
  String? _validate() {
    if (firstNameController.text.trim().isEmpty) {
      return 'Please enter your first name.';
    }
    if (lastNameController.text.trim().isEmpty) {
      return 'Please enter your last name.';
    }
    final displayName = userNameController.text.trim();
    if (displayName.isEmpty) return 'Please enter a user name.';
    if (!RegExp(r'^[A-Za-z0-9]+$').hasMatch(displayName)) {
      return 'User name can only contain letters and numbers. Spaces and special characters are not allowed.';
    }
    final email = emailController.text.trim();
    if (email.isEmpty) return 'Please enter your user account email.';
    if (!_emailRegex.hasMatch(email)) {
      return 'Please enter a valid user account email.';
    }
    if (selectedMonth == null || selectedDay == null || selectedYear == null) {
      return 'Please select your full date of birth.';
    }
    if (_digitsOnly(phoneController.text).isEmpty ||
        selectedCountryCode == null) {
      return 'Please enter your phone number.';
    }
    if (_nationalPhoneNumber(phoneController.text) == null) {
      return 'Please enter a 10-digit phone number.';
    }
    final password = passwordController.text;
    if (password.isEmpty) return 'Please enter a password.';
    if (!_passwordRegex.hasMatch(password)) return _passwordRules;
    if (confirmPasswordController.text.isEmpty) {
      return 'Please confirm your password.';
    }
    if (confirmPasswordController.text != password) {
      return 'Passwords do not match.';
    }
    if (!termsAccepted) return 'Please accept the Terms & Conditions.';
    return null;
  }

  bool termsAccepted = false;
  CountryCode? selectedCountryCode = CountryCode.fromCountryCode('US');
  bool _isLoading = false;
  String? _errorMessage;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

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
    passwordController.dispose();
    confirmPasswordController.dispose();
    _termsTapRecognizer.dispose();
    super.dispose();
  }

  void _onRegister() async {
    final validationError = _validate();
    if (validationError != null) {
      setState(() => _errorMessage = validationError);
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final dob =
        "${selectedMonth!.padLeft(2, '0')}-${selectedDay!.padLeft(2, '0')}-${selectedYear!}";
    final req = RegisterRequest(
      role: 'stargazer',
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      email: emailController.text.trim(),
      // Digits only, without the display formatting.
      phone:
          (selectedCountryCode?.dialCode ?? '') +
          _nationalPhoneNumber(phoneController.text)!,
      dob: dob,
      displayName: userNameController.text.trim(),
      password: passwordController.text,
    );
    try {
      // Sends the registration code; the OTP screen registers once it's entered.
      final resp = await RegisterService().emailCheck(
        email: req.email,
        displayName: req.displayName,
      );
      if (!mounted) return;
      if (resp.success && resp.resetToken != null) {
        // Pushed without a URL so the password never lands in browser history.
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OtpScreen(request: req, code: resp.resetToken!),
          ),
        );
      } else {
        setState(() {
          _errorMessage = resp.message ?? 'Could not send verification code.';
        });
      }
    } catch (e) {
      debugPrint('emailCheck failed: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Something went wrong. Please check your connection and try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktopWeb = kIsWeb && width > 900;

    if (isDesktopWeb) {
      // Web/Desktop layout: logo left, content right, header top, and logo top left corner
      return Scaffold(
        backgroundColor: Colors.black,
        // backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Image.asset('assets/bg_1411.jpg', fit: BoxFit.cover),
            ),

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
                      child: Image.network(
                        'https://dl9325jolfmzn.cloudfront.net/assets/image1.png',
                        fit: BoxFit.contain,
                        webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: _RegisterContent(
                              isWide: true,
                              firstNameController: firstNameController,
                              lastNameController: lastNameController,
                              userNameController: userNameController,
                              emailController: emailController,
                              phoneController: phoneController,
                              passwordController: passwordController,
                              confirmPasswordController:
                                  confirmPasswordController,
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
      body: Stack(
        fit: StackFit.expand,
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
                      const SizedBox(height: 16),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: _RegisterContent(
                          isWide: false,
                          firstNameController: firstNameController,
                          lastNameController: lastNameController,
                          userNameController: userNameController,
                          emailController: emailController,
                          phoneController: phoneController,
                          passwordController: passwordController,
                          confirmPasswordController: confirmPasswordController,
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
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
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
    required this.passwordController,
    required this.confirmPasswordController,
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
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    autofillHints: const [AutofillHints.givenName],
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
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    autofillHints: const [AutofillHints.familyName],
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
        _DisplayNameField(controller: userNameController, isWide: isWide),
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
            "User Account Email *",
            style: GoogleFonts.poppins(
              color: kgoldColor,
              fontSize: isWide ? 18 : 14,
            ),
          ),
        ),
        const SizedBox(height: 6),
        _goldBorderFieldWithLabel(
          hint: 'Enter your User Account Email',
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          autofillHints: const [AutofillHints.email],
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
        _DateOfBirthRow(
          initialMonth: selectedMonth,
          initialDay: selectedDay,
          initialYear: selectedYear,
          onChanged: onChangedDOB,
        ),
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
          initialCountryCode: selectedCountryCode,
          onCountryChanged: onChangedCountry,
        ),
        SizedBox(height: isWide ? 8 : 15),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Password *",
            style: GoogleFonts.poppins(
              color: kgoldColor,
              fontSize: isWide ? 18 : 14,
            ),
          ),
        ),
        const SizedBox(height: 6),
        _goldBorderFieldWithLabel(
          hint: 'Enter Password',
          controller: passwordController,
          obscureText: true,
          autocorrect: false,
          autofillHints: const [AutofillHints.newPassword],
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Min 6 characters with uppercase, lowercase, number & special character.',
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
            "Confirm Password *",
            style: GoogleFonts.poppins(
              color: kgoldColor,
              fontSize: isWide ? 18 : 14,
            ),
          ),
        ),
        const SizedBox(height: 6),
        _goldBorderFieldWithLabel(
          hint: 'Re-enter Password',
          controller: confirmPasswordController,
          obscureText: true,
          autocorrect: false,
          autofillHints: const [AutofillHints.newPassword],
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
                      text: 'Terms & Conditions',
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

Widget _goldBorderFieldWithLabel({
  required String hint,
  TextEditingController? controller,
  bool isPhone = false,
  List<TextInputFormatter>? inputFormatters,
  TextInputType? keyboardType,
  TextCapitalization textCapitalization = TextCapitalization.none,
  bool autocorrect = true,
  Iterable<String>? autofillHints,
  bool obscureText = false,
}) {
  return _GoldBorderFieldWithLabel(
    hint: hint,
    controller: controller,
    isPhone: isPhone,
    inputFormatters: inputFormatters,
    keyboardType: keyboardType,
    textCapitalization: textCapitalization,
    autocorrect: autocorrect,
    autofillHints: autofillHints,
    obscureText: obscureText,
  );
}

// Strips anything other than letters and digits and reports when it had to remove any.
class _AlphanumericFormatter extends TextInputFormatter {
  final VoidCallback onCharBlocked;
  _AlphanumericFormatter(this.onCharBlocked);

  static final _disallowed = RegExp(r'[^A-Za-z0-9]');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (!newValue.text.contains(_disallowed)) return newValue;
    onCharBlocked();
    final cursor = newValue.selection.end.clamp(0, newValue.text.length);
    final removedBeforeCursor = _disallowed
        .allMatches(newValue.text.substring(0, cursor))
        .length;
    return TextEditingValue(
      text: newValue.text.replaceAll(_disallowed, ''),
      selection: TextSelection.collapsed(offset: cursor - removedBeforeCursor),
    );
  }
}

// Display name input that blocks spaces/special characters and briefly shows a warning when one is typed.
class _DisplayNameField extends StatefulWidget {
  final TextEditingController controller;
  final bool isWide;
  const _DisplayNameField({required this.controller, required this.isWide});

  @override
  State<_DisplayNameField> createState() => _DisplayNameFieldState();
}

class _DisplayNameFieldState extends State<_DisplayNameField> {
  bool _showCharWarning = false;
  Timer? _hideTimer;
  late final _formatter = _AlphanumericFormatter(_onCharBlocked);

  void _onCharBlocked() {
    _hideTimer?.cancel();
    setState(() => _showCharWarning = true);
    _hideTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showCharWarning = false);
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _goldBorderFieldWithLabel(
          hint: 'User Name',
          controller: widget.controller,
          inputFormatters: [_formatter],
          keyboardType: TextInputType.text,
          autocorrect: false,
          autofillHints: const [AutofillHints.newUsername],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 150),
          child: _showCharWarning
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Only letters and numbers are allowed. No spaces or special characters.',
                    style: GoogleFonts.poppins(
                      color: Colors.redAccent,
                      fontSize: widget.isWide ? 13 : 11,
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

class _GoldBorderFieldWithLabel extends StatefulWidget {
  final String hint;
  final bool isPhone;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final Iterable<String>? autofillHints;

  /// Hides the text (for passwords) and shows an eye button to reveal it.
  final bool obscureText;
  const _GoldBorderFieldWithLabel({
    required this.hint,
    this.controller,
    this.isPhone = false,
    this.inputFormatters,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.autofillHints,
    this.obscureText = false,
  });

  @override
  State<_GoldBorderFieldWithLabel> createState() =>
      _GoldBorderFieldWithLabelState();
}

class _GoldBorderFieldWithLabelState extends State<_GoldBorderFieldWithLabel> {
  String? value;
  bool isGold = false;
  bool _textHidden = true;
  late final TextEditingController controller;
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? TextEditingController();
    isGold = controller.text.isNotEmpty;
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
    // The controller may be owned by the parent and outlive this field
    // (e.g. when the layout switches between desktop and mobile).
    controller.removeListener(_updateGold);
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
      keyboardType:
          widget.keyboardType ??
          (widget.isPhone ? TextInputType.phone : TextInputType.text),
      textCapitalization: widget.textCapitalization,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.autocorrect,
      autofillHints: widget.autofillHints,
      obscureText: widget.obscureText && _textHidden,
      inputFormatters: widget.isPhone
          ? [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ]
          : widget.inputFormatters,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF1C1C1E),
        hintText: widget.hint,
        hintStyle: const TextStyle(color: Colors.white38),
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _textHidden
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                color: isGold ? kgoldColor : Colors.white38,
                tooltip: _textHidden ? 'Show password' : 'Hide password',
                onPressed: () => setState(() => _textHidden = !_textHidden),
              )
            : null,
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
  final String? initialMonth;
  final String? initialDay;
  final String? initialYear;
  final void Function(String? month, String? day, String? year)? onChanged;
  const _DateOfBirthRow({
    this.initialMonth,
    this.initialDay,
    this.initialYear,
    this.onChanged,
  });
  @override
  State<_DateOfBirthRow> createState() => _DateOfBirthRowState();
}

class _DateOfBirthRowState extends State<_DateOfBirthRow> {
  late String? selectedMonth = widget.initialMonth;
  late String? selectedDay = widget.initialDay;
  late String? selectedYear = widget.initialYear;

  // February has 29 days only in leap years (or while no year is chosen yet).
  int _daysInMonth(String? month, String? year) {
    if (month == null) return 31;
    final m = int.tryParse(month) ?? 0;
    if (m == 2) {
      final y = int.tryParse(year ?? '');
      if (y == null) return 29;
      final isLeap = (y % 4 == 0 && y % 100 != 0) || y % 400 == 0;
      return isLeap ? 29 : 28;
    }
    const days = [0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return (m >= 1 && m <= 12) ? days[m] : 31;
  }

  // Clears the chosen day if it no longer exists for the month/year.
  void _clampDay() {
    final day = int.tryParse(selectedDay ?? '');
    if (day != null && day > _daysInMonth(selectedMonth, selectedYear)) {
      selectedDay = null;
    }
  }

  void _notifyParent() {
    if (widget.onChanged != null) {
      widget.onChanged!(selectedMonth, selectedDay, selectedYear);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxDays = _daysInMonth(selectedMonth, selectedYear);
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
              setState(() {
                selectedMonth = val;
                _clampDay();
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
              setState(() {
                selectedYear = val;
                _clampDay();
              });
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
  final CountryCode? initialCountryCode;
  final ValueChanged<CountryCode>? onCountryChanged;
  const _PhoneRow({
    this.controller,
    this.initialCountryCode,
    this.onCountryChanged,
  });
  @override
  State<_PhoneRow> createState() => _PhoneRowState();
}

class _PhoneRowState extends State<_PhoneRow> {
  late FocusNode _focusNode;
  bool _hasValue = false;
  late final TextEditingController _controller;
  // Default to +1 (US); the user can pick another country.
  late CountryCode? _selectedCountryCode =
      widget.initialCountryCode ?? CountryCode.fromCountryCode('US');

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = widget.controller ?? TextEditingController();
    _hasValue = _controller.text.isNotEmpty;
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
    _controller.removeListener(_handleValueChange);
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
                  // Re-format what was already typed for the new country.
                  final formatted = _formatPhone(
                    _digitsOnly(_controller.text),
                    _isoCodeFor(code),
                  );
                  _controller.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(
                      offset: formatted.length,
                    ),
                  );
                  if (widget.onCountryChanged != null) {
                    widget.onCountryChanged!(code);
                  }
                },
                initialSelection: _selectedCountryCode?.code ?? 'US',
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
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.telephoneNumberNational],
            inputFormatters: [
              _PhoneNumberFormatter(() => _isoCodeFor(_selectedCountryCode)),
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

// --- Phone number formatting -------------------------------------------------

String _digitsOnly(String text) => text.replaceAll(RegExp(r'\D'), '');

IsoCode? _isoCodeFor(CountryCode? country) {
  final code = country?.code;
  if (code == null) return null;
  for (final iso in IsoCode.values) {
    if (iso.name == code) return iso;
  }
  return null;
}

/// Formats [digits] the way numbers are written in [iso]'s country, e.g.
/// (201) 555-0123 for the US or 98765 43210 for India. Falls back to the plain
/// digits when there is no format (e.g. while a leading trunk 0 is typed).
String _formatPhone(String digits, IsoCode? iso) {
  if (digits.isEmpty || iso == null) return digits;
  try {
    final formatted = PhoneNumber(isoCode: iso, nsn: digits).formatNsn();
    return _digitsOnly(formatted) == digits ? formatted : digits;
  } catch (_) {
    return digits;
  }
}

/// Phone numbers must be exactly this many digits, for every country.
const _phoneDigits = 10;

/// The number to send to the API (digits only), or null unless it has
/// exactly [_phoneDigits] digits.
String? _nationalPhoneNumber(String text) {
  final digits = _digitsOnly(text);
  return digits.length == _phoneDigits ? digits : null;
}

/// Keeps the phone field formatted for the selected country as the user types.
class _PhoneNumberFormatter extends TextInputFormatter {
  final IsoCode? Function() isoCode;
  _PhoneNumberFormatter(this.isoCode);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cursor = newValue.selection.end.clamp(0, newValue.text.length);
    var digits = _digitsOnly(newValue.text);
    var digitsBeforeCursor = _digitsOnly(
      newValue.text.substring(0, cursor),
    ).length;

    // Backspace over a formatting character like ")" or "-" removed no digit;
    // delete the digit before it instead so the edit isn't undone.
    if (newValue.text.length < oldValue.text.length &&
        digits == _digitsOnly(oldValue.text) &&
        digitsBeforeCursor > 0) {
      digits =
          digits.substring(0, digitsBeforeCursor - 1) +
          digits.substring(digitsBeforeCursor);
      digitsBeforeCursor--;
    }

    if (digits.length > _phoneDigits) return oldValue;

    final formatted = _formatPhone(digits, isoCode());

    // Put the cursor after the same number of digits as before.
    var offset = 0;
    var seen = 0;
    while (offset < formatted.length && seen < digitsBeforeCursor) {
      if (RegExp(r'\d').hasMatch(formatted[offset])) seen++;
      offset++;
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}
