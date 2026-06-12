import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:easy_localization/easy_localization.dart';

import '../services/session_service.dart';
import 'home_screen.dart';
import 'camera_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  bool _isInitialized = false;

  final List<Widget> _screens = const [
    HomeScreen(),
    CameraScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkSession();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (!mounted) return;

    final currentUserId = SessionService.currentUserId;

    if (currentUserId == null) {
      _redirectToLogin();
      return;
    }

    setState(() {
      _isInitialized = true;
    });
  }

  void _redirectToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFFF5F7F5),
        title: Text(
          context.tr('common.logout'),
          style: const TextStyle(color: Color(0xFF594020)),
        ),
        content: Text(
          context.tr('common.logout_confirmation'),
          style: const TextStyle(color: Color(0xFF6B5D4F)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.tr('common.cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(context.tr('common.logout')),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await SessionService.logout();
      _redirectToLogin();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('common.logged_out_successfully')),
          backgroundColor: const Color(0xFF768E2E),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7F5),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Color(0xFF768E2E),
              ),
              const SizedBox(height: 16),
              Text(
                context.tr('common.loading'),
                style: const TextStyle(
                  color: Color(0xFF594020),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        color: Colors.white,
        backgroundColor: const Color(0xFFF5F5F5),
        buttonBackgroundColor: const Color(0xFF594020),
        height: 65,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        items: <Widget>[
          Icon(
            Icons.home_rounded,
            size: 28,
            color: _currentIndex == 0 ? Colors.white : Colors.black54,
          ),
          Icon(
            Icons.center_focus_strong,
            size: 28,
            color: _currentIndex == 1 ? Colors.white : Colors.black54,
          ),
          Icon(
            Icons.person_rounded,
            size: 28,
            color: _currentIndex == 2 ? Colors.white : Colors.black54,
          ),
        ],
        onTap: (index) {
          if (SessionService.currentUserId == null) {
            _redirectToLogin();
            return;
          }

          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}