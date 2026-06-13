import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../services/session_service.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'login_screen.dart';
import 'scan_history_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    setState(() => _isLoading = true);

    final user = AuthService.getCurrentUser();

    setState(() {
      _currentUser = user;
      _isLoading = false;
    });
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFFF5F7F5),
        title: Text(
          context.tr('profile.logout_title'),
          style: const TextStyle(color: Color(0xFF594020)),
        ),
        content: Text(
          context.tr('profile.logout_message'),
          style: const TextStyle(color: Color(0xFF6B5D4F)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.tr('common.cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(context.tr('common.logout')),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await SessionService.logout();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF768E2E)),
            )
          else if (_currentUser != null) ...[
            Center(
              child: Container(
                width: 320,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF594020), Color(0xFF3D2B15)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF594020).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _currentUser!.username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentUser!.email,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr(
                        'profile.member_since',
                        namedArgs: {
                          'date':
                          '${_currentUser!.createdAt.day}/${_currentUser!.createdAt.month}/${_currentUser!.createdAt.year}',
                        },
                      ),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 📌 Scan History
            _buildActionCard(
              icon: Icons.history_rounded,
              title: context.tr('profile.scan_history'),
              subtitle: context.tr('profile.scan_history_subtitle'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScanHistoryScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // 📌 Settings
            _buildActionCard(
              icon: Icons.settings_rounded,
              title: context.tr('profile.settings'),
              subtitle: context.tr('profile.settings_subtitle'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // 📌 Help
            _buildActionCard(
              icon: Icons.help_outline_rounded,
              title: context.tr('profile.help_support'),
              subtitle: context.tr('profile.help_support_subtitle'),
              onTap: () {},
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: Text(context.tr('common.logout')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.red.shade200),
                  ),
                ),
              ),
            ),
          ] else ...[
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Color(0xFF594020),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('profile.not_logged_in'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF594020),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: Text(context.tr('profile.go_to_login')),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shadowColor: const Color(0xFF594020).withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE8E4DC)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF768E2E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF768E2E)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF594020),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B5D4F),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF6B5D4F),
              ),
            ],
          ),
        ),
      ),
    );
  }
}