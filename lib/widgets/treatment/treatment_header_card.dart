import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../models/disease_data.dart';
import '../shared/app_colors.dart';

class TreatmentHeaderCard extends StatelessWidget {
  final DiseaseData? disease;
  final String diseaseName;
  final bool isHealthy;

  const TreatmentHeaderCard({
    super.key,
    required this.disease,
    required this.diseaseName,
    required this.isHealthy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: _getHeaderGradient(),
        borderRadius: BorderRadius.circular(28),
        boxShadow: _getHeaderShadows(),
        border: Border.all(color: AppColors.whiteWithOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildDiseaseIcon(),
              const SizedBox(width: 16),
              Expanded(child: _buildText(context)),
              _buildConfidenceBadge(context),
            ],
          ),
          if (!isHealthy) ...[
            const SizedBox(height: 20),
            _buildWarningCard(context),
          ],
        ],
      ),
    );
  }

  Widget _buildDiseaseIcon() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.8, end: 1.0),
      builder: (context, scale, child) => Transform.scale(
        scale: scale,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: _buildIconContent(),
        ),
      ),
    );
  }

  Widget _buildIconContent() {
    if (disease?.iconPath != null && disease!.iconPath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          disease!.iconPath!,
          width: 32,
          height: 32,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Icon(
            isHealthy ? Icons.check_circle : Icons.eco_rounded,
            color: AppColors.textWhite,
            size: 32,
          ),
        ),
      );
    }

    return Icon(
      isHealthy ? Icons.check_circle : Icons.eco_rounded,
      color: AppColors.textWhite,
      size: 32,
    );
  }

  Widget _buildText(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          disease?.name ?? diseaseName,
          style: const TextStyle(
            color: AppColors.textWhite,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isHealthy
                ? Colors.white.withOpacity(0.2)
                : AppColors.greenWithOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isHealthy
                ? context.tr('treatment.crop_healthy')
                : context.tr('treatment.disease_detected'),
            style: const TextStyle(
              color: AppColors.textWhiteMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfidenceBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.whiteWithOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.whiteWithOpacity(0.15)),
      ),
      child: Text(
        context.tr('treatment.confidence'),
        style: const TextStyle(
          color: AppColors.textWhite,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildWarningCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greenWithOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.greenWithOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.timer_outlined,
              color: AppColors.green,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.tr('treatment.warning_message'),
              style: const TextStyle(
                color: AppColors.textWhiteMuted,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getHeaderGradient() {
    if (isHealthy) {
      return LinearGradient(
        colors: [
          AppColors.greenWithOpacity(0.9),
          AppColors.brownWithOpacity(0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return AppColors.brownGradient;
  }

  List<BoxShadow> _getHeaderShadows() {
    final baseColor = isHealthy ? AppColors.green : AppColors.brown;
    return [
      BoxShadow(
        color: baseColor.withOpacity(0.4),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
      const BoxShadow(
        color: Colors.black26,
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ];
  }
}