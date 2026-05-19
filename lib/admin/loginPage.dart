import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myautobiography/main.dart' show isAdminLoggedIn;
import 'services/admin_auth_service.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  // Basic RFC-5322-inspired email pattern
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
  );

  Future<void> _submit() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final result = await AdminAuthService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;

    if (result.success) {
      isAdminLoggedIn = true;
      if (mounted) context.go('/hvr/admin/dashboard');
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result.errorMessage ?? 'Login failed.';
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer,
              colorScheme.surface,
              colorScheme.secondaryContainer,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo / Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.admin_panel_settings_rounded,
                        size: 40,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'MAB Admin',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sign in to your account',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Card
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: colorScheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                      color: colorScheme.surface.withOpacity(0.92),
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Email field
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                style: TextStyle(color: colorScheme.onSurface),
                                decoration: InputDecoration(
                                  labelText: 'Email address',
                                  hintText: 'you@example.com',
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: colorScheme.primary,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: colorScheme.outline,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: colorScheme.surfaceContainerHighest
                                      .withOpacity(0.4),
                                ),
                                validator: (value) {
                                  final v = value?.trim() ?? '';
                                  if (v.isEmpty) {
                                    return 'Please enter your email.';
                                  }
                                  if (!_emailRegex.hasMatch(v)) {
                                    return 'Enter a valid email address.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 18),

                              // Password field
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _submit(),
                                style: TextStyle(color: colorScheme.onSurface),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  hintText: '••••••••',
                                  prefixIcon: Icon(
                                    Icons.lock_outline_rounded,
                                    color: colorScheme.primary,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: colorScheme.outline,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: colorScheme.surfaceContainerHighest
                                      .withOpacity(0.4),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password.';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters.';
                                  }
                                  return null;
                                },
                              ),

                              // Error message
                              AnimatedSize(
                                duration: const Duration(milliseconds: 250),
                                child: _errorMessage != null
                                    ? Container(
                                        margin: const EdgeInsets.only(top: 14),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colorScheme.errorContainer,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.error_outline_rounded,
                                              color: colorScheme.error,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                _errorMessage!,
                                                style: TextStyle(
                                                  color: colorScheme.error,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),

                              const SizedBox(height: 24),

                              // Sign In button
                              SizedBox(
                                height: 52,
                                child: FilledButton(
                                  onPressed: _isLoading ? null : _submit,
                                  style: FilledButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: colorScheme.onPrimary,
                                          ),
                                        )
                                      : const Text(
                                          'Sign In',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),
                    Text(
                      'Build Version: 1.0.1, Deployment: 14 May 2026',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '© 2026 MAB Admin. All rights reserved.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
