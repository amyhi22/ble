import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

import '../database/disease_database.dart';
import '../database/history_database.dart';
import '../models/detection_history.dart';
import '../services/session_service.dart';
import '../widgets/treatment/animated_card.dart';
import '../widgets/treatment/treatment_app_bar.dart';
import '../widgets/treatment/treatment_header_card.dart';
import '../widgets/treatment/treatment_info_card.dart';
import '../widgets/treatment/treatment_actions.dart';
import '../widgets/irrigation/irrigation_card.dart';
import '../widgets/shared/app_colors.dart';
import '../widgets/shared/app_animations.dart';

class TreatmentScreen extends StatefulWidget {
  final String diseaseName;

  const TreatmentScreen({
    super.key,
    required this.diseaseName,
  });

  @override
  State<TreatmentScreen> createState() => _TreatmentScreenState();
}

class _TreatmentScreenState extends State<TreatmentScreen> {
  bool _historySaved = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveHistoryAutomatically();
    });
  }

  Future<void> _saveHistoryAutomatically() async {
    if (_historySaved) return;

    try {
      final disease = DiseaseDatabase.getDisease(widget.diseaseName);
      final isHealthy = disease?.name.toLowerCase() == 'healthy';

      if (isHealthy) return;

      final currentUserId = SessionService.currentUserId;

      if (currentUserId == null) return;

      final diseaseTitle = disease?.name ?? widget.diseaseName;

      if (HistoryDatabase.alreadyExistsToday(
        userId: currentUserId,
        diseaseName: diseaseTitle,
      )) {
        return;
      }

      final history = DetectionHistory(
        userId: currentUserId,
        diseaseName: diseaseTitle,
        confidence: 0.94,
        symptoms: disease?.symptoms ?? [],
        treatments: disease?.treatments ?? [],
        medicines: disease?.medicines ?? [],
      );

      await HistoryDatabase.saveDetection(history);

      _historySaved = true;
    } catch (e) {
      debugPrint('Auto save error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final disease = DiseaseDatabase.getDisease(widget.diseaseName);
    final isHealthy = disease?.name.toLowerCase() == 'healthy';

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.darkGreen,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              TreatmentAppBar(
                disease: disease,
                diseaseName: widget.diseaseName,
                isHealthy: isHealthy,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      AnimatedCard(
                        delay: 100,
                        child: TreatmentHeaderCard(
                          disease: disease,
                          diseaseName: widget.diseaseName,
                          isHealthy: isHealthy,
                        ),
                      ),
                      const SizedBox(height: 24),
                      AnimatedCard(
                        delay: 200,
                        child: TreatmentInfoCard(
                          title: context.tr('treatment_sections.symptoms'),
                          icon: Icons.visibility_outlined,
                          accentColor: AppColors.green,
                          items: disease?.symptoms ?? [],
                          decorativeIcon: Icons.remove_red_eye,
                          isHighlighted: false,
                          iconAsset: disease?.iconPath,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AnimatedCard(
                        delay: 300,
                        child: TreatmentInfoCard(
                          title: context.tr('treatment_sections.treatments'),
                          icon: Icons.medical_services_outlined,
                          accentColor: AppColors.green,
                          items: disease?.treatments ?? [],
                          decorativeIcon: Icons.healing,
                          isHighlighted: false,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AnimatedCard(
                        delay: 400,
                        child: TreatmentInfoCard(
                          title: context.tr(
                            'treatment_sections.recommended_products',
                          ),
                          icon: Icons.medication_outlined,
                          accentColor: AppColors.brown,
                          items: disease?.medicines ?? [],
                          decorativeIcon: Icons.local_pharmacy,
                          isHighlighted: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AnimatedCard(
                        delay: 500,
                        child: IrrigationCard(
                          diseaseName: widget.diseaseName,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AnimatedCard(
                        delay: 600,
                        child: TreatmentInfoCard(
                          title: context.tr(
                            'treatment_sections.prevention_tips',
                          ),
                          icon: Icons.lightbulb_outline,
                          accentColor: AppColors.green,
                          items: disease?.advice ?? [],
                          decorativeIcon: Icons.psychology_alt,
                          isHighlighted: false,
                        ),
                      ),
                      const SizedBox(height: 24),
                      AnimatedCard(
                        delay: 700,
                        child: TreatmentActions(
                          disease: disease,
                          diseaseName: widget.diseaseName,
                          confidence: 0.94,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TreatmentPageRoute extends PageRouteBuilder {
  final Widget page;

  TreatmentPageRoute({required this.page})
      : super(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) => FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
        ),
        child: child,
      ),
    ),
    transitionDuration: AppAnimations.elegantDuration,
  );
}