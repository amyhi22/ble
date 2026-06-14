import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../models/disease_data.dart';
import '../shared/app_colors.dart';
import 'animated_button.dart';
import '../dialogs/contact_expert_dialog.dart';

class TreatmentActions extends StatelessWidget {
  final DiseaseData? disease;
  final String diseaseName;

  // نبقيه لتجنب كسر الملفات الأخرى التي تمرره
  final double confidence;

  const TreatmentActions({
    super.key,
    required this.disease,
    required this.diseaseName,
    this.confidence = 0.94,
  });

  @override
  Widget build(BuildContext context) {
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