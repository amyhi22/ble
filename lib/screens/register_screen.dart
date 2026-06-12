import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

import '../services/auth_service.dart';
import '../widgets/background/leaf_pattern_background.dart';
import '../widgets/auth/auth_header.dart';
import '../widgets/auth/animated_text_field.dart';
import '../widgets/auth/animated_auth_button.dart';
import '../shared/app_colors.dart';
import '../shared/app_animations.dart';
import '../utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  late final AnimationController _formController;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _formController = AnimationController(
      duration: AppAnimations.elegant,
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
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AuthService.register(
      username: _usernameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      confirmPassword: _confirmController.text,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(context.tr('auth.account_created')),
            ],
          ),
          backgroundColor: AppColors.secondaryGreen,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) Navigator.pop(context);
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: AppColors.primaryBrown,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  AuthHeader(
                    title: context.tr('auth.create_account'),
                    subtitle: context.tr('auth.join_agroscan'),
                    showLogo: false,
                  ),
                  SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        AnimatedTextField(
                          controller: _usernameController,
                          label: context.tr('auth.username'),
                          hint: context.tr('auth.username_hint'),
                          prefixIcon: Icons.person_outline,
                          validator: Validators.validateUsername,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        AnimatedTextField(
                          controller: _emailController,
                          label: context.tr('auth.email'),
                          hint: context.tr('auth.email_hint'),
                          prefixIcon: Icons.email_outlined,
                          validator: Validators.validateEmail,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        AnimatedTextField(
                          controller: _passwordController,
                          label: context.tr('auth.password'),
                          hint: context.tr('auth.password_hint'),
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          validator: Validators.validatePassword,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        AnimatedTextField(
                          controller: _confirmController,
                          label: context.tr('auth.confirm_password'),
                          hint: context.tr('auth.confirm_password_hint'),
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          validator: (value) => Validators.validateConfirmPassword(
                            value,
                            _passwordController.text,
                          ),
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleRegister(),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 24),
                    child: Text(
                      context.tr('auth.password_requirements'),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted.withOpacity(0.8),
                        height: 1.5,
                      ),
                    ),
                  ),
                  AnimatedAuthButton(
                    onPressed: _handleRegister,
                    label: context.tr('auth.create_account'),
                    icon: Icons.person_add_rounded,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        context.tr('auth.already_have_account'),
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          context.tr('auth.sign_in'),
                          style: const TextStyle(
                            color: AppColors.secondaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
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