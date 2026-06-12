import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../models/disease_data.dart';
import '../shared/app_colors.dart';

class TreatmentAppBar extends StatelessWidget {
  final DiseaseData? disease;
  final String diseaseName;
  final bool isHealthy;

  const TreatmentAppBar({
    super.key,
    required this.disease,
    required this.diseaseName,
    required this.isHealthy,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      floating: true,
      leading: _buildBackButton(context),
      title: Text(
        disease?.name ?? diseaseName,
        style: _titleStyle,
      ),
      actions: [_buildShareButton(context)],
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: _buttonDecoration,
      child: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: AppColors.textWhite,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildShareButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: _buttonDecoration,
      child: IconButton(
        icon: const Icon(
          Icons.share_outlined,
          color: AppColors.textWhite,
          size: 20,
        ),
        onPressed: () => _showShareSnackbar(context),
      ),
    );
  }

  void _showShareSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.tr('treatment.share_coming_soon')),
        backgroundColor: AppColors.brown,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  BoxDecoration get _buttonDecoration => BoxDecoration(
        color: AppColors.brown.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.green.withOpacity(0.5), width: 1),
      );

  TextStyle get _titleStyle => const TextStyle(
        color: AppColors.textWhite,
        fontWeight: FontWeight.w700,
        fontSize: 20,
        letterSpacing: 0.3,
      );
}