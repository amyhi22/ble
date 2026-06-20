import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

import '../services/auth_service.dart';
import '../services/session_service.dart';
import '../widgets/background/leaf_pattern_background.dart';
import '../widgets/auth/animated_text_field.dart';
import '../widgets/auth/animated_auth_button.dart';
import '../shared/app_colors.dart';
import '../shared/app_animations.dart';
import 'register_screen.dart';
import 'main_navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _focusNode = FocusNode();

  bool _isLoading = false;
  String? _errorMessage;
  late final AnimationController _formController;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _formController = AnimationController(
      duration: AppAnimations.elegantDuration,
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _formController,
        curve: AppAnimations.elegantEntrance,
      ),
    );

    _formController.forward();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  void dispose() {
    _formController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    if (SessionService.isLoginLocked) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AuthService.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainNavigationScreen(),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0.1, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              ),
              child: child,
            ),
          ),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } else {
      setState(() {
        _errorMessage = result['error'];
        _isLoading = false;
      });

      if (_errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(_errorMessage!)),
              ],
            ),
            backgroundColor: AppColors.textError,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LeafPatternBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 30),
                  Container(
                    width: 230,
                    height: 230,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/logo3.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 0),
                  Text(
                    context.tr('auth.welcome_back'),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr('auth.access_dashboard'),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        AnimatedTextField(
                          controller: _emailController,
                          label: context.tr('auth.email'),
                          hint: context.tr('auth.email_hint'),
                          prefixIcon: Icons.email_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return context.tr('auth.email_required');
                            }
                            if (!value.contains('@')) {
                              return context.tr('auth.email_invalid');
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                          focusNode: _focusNode,
                        ),
                        const SizedBox(height: 16),
                        AnimatedTextField(
                          controller: _passwordController,
                          label: context.tr('auth.password'),
                          hint: context.tr('auth.password_hint'),
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return context.tr('auth.password_required');
                            }
                            if (value.length < 6) {
                              return context.tr('auth.password_min_chars');
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleLogin(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.tr('auth.password_reset_soon')),
                            backgroundColor: AppColors.primaryBrown,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Text(
                        context.tr('auth.forgot_password'),
                        style: const TextStyle(
                          color: AppColors.secondaryGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AnimatedAuthButton(
                    onPressed: _handleLogin,
                    label: context.tr('auth.log_in'),
                    icon: Icons.login_rounded,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 24),
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.05),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _formController,
                        curve: const Interval(0.3, 1.0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          context.tr('auth.no_account'),
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) => const RegisterScreen(),
                                transitionsBuilder: (_, animation, __, child) =>
                                    FadeTransition(opacity: animation, child: child),
                                transitionDuration: AppAnimations.normal,
                              ),
                            );
                          },
                          child: Text(
                            context.tr('auth.create_account'),
                            style: const TextStyle(
                              color: AppColors.secondaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (SessionService.isLoginLocked) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.textError.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.textError.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lock_outline, color: AppColors.textError, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              context.tr(
                                'auth.login_locked',
                                namedArgs: {
                                  'minutes':
                                      '${SessionService.lockRemainingTime?.inMinutes ?? 0}',
                                },
                              ),
                              style: TextStyle(
                                color: AppColors.textError,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_errorMessage != null && !SessionService.isLoginLocked) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.textError.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.textError.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: AppColors.textError, size: 20),
                          const SizedBox(width: 12),
                          Expanded(child: Text(_errorMessage!)),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
