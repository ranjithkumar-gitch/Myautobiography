import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myautobiography/app_shared_preferences.dart';
import 'package:myautobiography/constants/colors.dart';
import 'package:myautobiography/models/register_request.dart';
import 'package:myautobiography/register_service.dart';
import 'package:myautobiography/shared_pref_helper.dart';
import 'package:myautobiography/theme_notifier.dart';

/// Asks for the registration code emailed by emailCheck-v2, then registers
/// the user and continues to the success page.
class OtpScreen extends StatefulWidget {
  final RegisterRequest request;
  final String code;
  const OtpScreen({super.key, required this.request, required this.code});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const _resendSeconds = 30;

  final _otpController = TextEditingController();
  final _otpFocus = FocusNode();
  late String _code = widget.code;
  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  int _resendIn = _resendSeconds;
  Timer? _resendTimer;

  int get _length => _code.length;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    _otpController.addListener(() => setState(() {}));
    _otpFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _otpController.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _resendIn = _resendSeconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendIn <= 1) timer.cancel();
      if (mounted) setState(() => _resendIn--);
    });
  }

  Future<void> _resend() async {
    setState(() {
      _isResending = true;
      _errorMessage = null;
    });
    try {
      final resp = await RegisterService().emailCheck(
        email: widget.request.email,
        displayName: widget.request.displayName,
      );
      if (!mounted) return;
      if (resp.success && resp.resetToken != null) {
        _code = resp.resetToken!;
        _otpController.clear();
        _startResendTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A new code has been sent.')),
        );
      } else {
        setState(() => _errorMessage = resp.message ?? 'Could not resend code.');
      }
    } catch (e) {
      debugPrint('emailCheck failed: $e');
      if (mounted) {
        setState(
          () => _errorMessage =
              'Something went wrong. Please check your connection and try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Future<void> _verify() async {
    if (_isLoading) return;
    final entered = _otpController.text;
    if (entered.length < _length) {
      setState(() => _errorMessage = 'Please enter the $_length-digit code.');
      return;
    }
    if (entered != _code) {
      setState(() => _errorMessage = 'Incorrect code. Please try again.');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final resp = await RegisterService().registerauth(widget.request);
      if (resp.statusCode == 201 && resp.data != null) {
        // The response masks names (e.g. "b*******"), so keep what was typed.
        await SharedPrefHelper.saveName(
          widget.request.firstName,
          widget.request.lastName,
        );
        await SharedPrefHelper.saveStargazerIdAndCreatedAt(
          resp.data!.id,
          resp.data!.createdAt,
        );
        await SharedPrefServices.setStargazerId(resp.data!.id);
        await SharedPrefServices.setStargazerCreatedAt(resp.data!.createdAt);
        if (!mounted) return;
        // Replace /register (and this screen on top of it) so Back from the
        // success page goes to onboarding, not the filled form or this code.
        Router.neglect(
          context,
          () => context.pushReplacement(
            '/success',
            extra: {
              'firstName': widget.request.firstName,
              'lastName': widget.request.lastName,
            },
          ),
        );
      } else {
        if (!mounted) return;
        setState(() => _errorMessage = resp.message ?? 'Registration failed.');
      }
    } catch (e) {
      debugPrint('registerauth failed: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Something went wrong. Please check your connection and try again.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: kgoldColor,
          tooltip: 'Back',
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset('assets/bg_1411.jpg', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: isWide ? 84 : 72,
                        height: isWide ? 84 : 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.4),
                          border: Border.all(color: kgoldColor, width: 2),
                        ),
                        child: Icon(
                          Icons.mark_email_read_outlined,
                          color: kgoldColor,
                          size: isWide ? 40 : 34,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            goldTextGradient.createShader(bounds),
                        child: Text(
                          'Verify Your Email',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cinzel(
                            color: Colors.white,
                            fontSize: isWide ? 32 : 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 1.5,
                        width: 80,
                        color: kgoldColor.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 14),
                      Text.rich(
                        TextSpan(
                          text: 'Enter the $_length-digit code we sent to\n',
                          children: [
                            TextSpan(
                              text: widget.request.email,
                              style: const TextStyle(
                                color: kgoldColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: kwhiteColor,
                          fontSize: isWide ? 15 : 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _OtpBoxes(
                        controller: _otpController,
                        focusNode: _otpFocus,
                        length: _length,
                        isWide: isWide,
                        onCompleted: _verify,
                      ),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      const SizedBox(height: 28),
                      _GoldButton(
                        label: 'Verify & Register',
                        isLoading: _isLoading,
                        isWide: isWide,
                        onPressed: _verify,
                      ),
                      const SizedBox(height: 20),
                      _ResendRow(
                        resendIn: _resendIn,
                        isResending: _isResending,
                        onResend: _isLoading ? null : _resend,
                      ),
                      const SizedBox(height: 24),
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

/// Code input shown as one box per digit. A transparent TextField on top
/// handles typing, pasting and SMS/email autofill.
class _OtpBoxes extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final int length;
  final bool isWide;
  final VoidCallback onCompleted;
  const _OtpBoxes({
    required this.controller,
    required this.focusNode,
    required this.length,
    required this.isWide,
    required this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final text = controller.text;
    final boxSize = isWide ? 56.0 : 46.0;
    return SizedBox(
      height: boxSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: boxSize,
                  height: boxSize,
                  margin: EdgeInsets.symmetric(horizontal: isWide ? 6 : 4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 2,
                      color:
                          i < text.length ||
                              (focusNode.hasFocus && i == text.length)
                          ? kgoldColor
                          : Colors.white38,
                    ),
                  ),
                  child: Text(
                    i < text.length ? text[i] : '',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: isWide ? 24 : 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                autofocus: true,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                showCursor: false,
                enableInteractiveSelection: false,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(length),
                ],
                onChanged: (value) {
                  if (value.length == length) onCompleted();
                },
                onSubmitted: (_) => onCompleted(),
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResendRow extends StatelessWidget {
  final int resendIn;
  final bool isResending;
  final VoidCallback? onResend;
  const _ResendRow({
    required this.resendIn,
    required this.isResending,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.poppins(color: Colors.white70, fontSize: 14);
    if (isResending) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: kgoldColor),
      );
    }
    if (resendIn > 0) {
      return Text(
        'Resend code in 0:${resendIn.toString().padLeft(2, '0')}',
        style: style,
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Didn't get the code? ", style: style),
        TextButton(
          onPressed: onResend,
          style: TextButton.styleFrom(
            foregroundColor: kgoldColor,
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Resend',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: kgoldColor,
            ),
          ),
        ),
      ],
    );
  }
}

/// Gold-bordered button matching "Register Now" on the register screen.
class _GoldButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final bool isWide;
  final VoidCallback onPressed;
  const _GoldButton({
    required this.label,
    required this.isLoading,
    required this.isWide,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
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
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              side: BorderSide.none,
              padding: EdgeInsets.zero,
              foregroundColor: Colors.white,
            ),
            child: isLoading
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(kgoldColor),
                  )
                : ShaderMask(
                    shaderCallback: (bounds) =>
                        goldTextGradient.createShader(bounds),
                    child: Text(
                      label,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isWide ? 20 : 17,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
