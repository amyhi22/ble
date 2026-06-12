import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'main_navigation.dart';
import '../widgets/custom_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String bgImage =
        "https://images.unsplash.com/photo-1625246333195-f81961856163?q=80&w=1000&auto=format&fit=crop";

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            bgImage,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(color: Colors.green[100]);
            },
          ),
          Container(
            color: Colors.black.withOpacity(0.4),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.tr('welcome.title'),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('welcome.subtitle'),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 40),
                  CustomButton(
                    text: context.tr('welcome.get_started'),
                    backgroundColor: const Color(0xFF593718),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainNavigationScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}