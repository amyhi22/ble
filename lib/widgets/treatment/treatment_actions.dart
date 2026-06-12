import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../models/disease_data.dart';
import '../../database/history_database.dart';
import '../../models/detection_history.dart';
import '../../services/session_service.dart';
import '../shared/app_colors.dart';
import 'animated_button.dart';
import '../dialogs/contact_expert_dialog.dart';

class TreatmentActions extends StatelessWidget {
  final DiseaseData? disease;
  final String diseaseName;
  final double confidence;

  const TreatmentActions({
    super.key,
    required this.disease,
    required this.diseaseName,
    this.confidence = 0.94,
  });

  @override
  Widget build(BuildContext context) {
    final isHealthy = disease?.name.toLowerCase() == 'healthy';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.brownGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBrown,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: AppColors.greenWithOpacity(0.4),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          if (!isHealthy) ...[
            AnimatedButton(
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.tr('history.saving')),
                    backgroundColor: const Color(0xFF768E2E),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 1),
                  ),
                );

                try {
                  final currentUserId = SessionService.currentUserId;

                  if (currentUserId == null) {
                    throw Exception(context.tr('auth.login_required'));
                  }

                  final history = DetectionHistory(
                    userId: currentUserId,
                    diseaseName: disease?.name ?? diseaseName,
                    confidence: confidence,
                    symptoms: disease?.symptoms ?? [],
                    treatments: disease?.treatments ?? [],
                    medicines: disease?.medicines ?? [],
                  );

                  await HistoryDatabase.saveDetection(history);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(context.tr('history.saved')),
                          ],
                        ),
                        backgroundColor: const Color(0xFF768E2E),
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          context.tr(
                            'history.save_error',
                            namedArgs: {'error': e.toString()},
                          ),
                        ),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              icon: Icons.save_rounded,
              label: context.tr('history.save_to_history'),
            ),
            const SizedBox(height: 12),
          ],
          AnimatedButton(
            onPressed: () => _showContactDialog(context),
            icon: Icons.support_agent_rounded,
            label: context.tr('expert.contact'),
            isOutlined: true,
          ),
        ],
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ContactExpertDialog(
        diseaseName: disease?.name,
      ),
    );
  }
}