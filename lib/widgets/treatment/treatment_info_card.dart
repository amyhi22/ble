import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../shared/app_colors.dart';

class TreatmentInfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accentColor;
  final List<String> items;
  final IconData decorativeIcon;
  final bool isHighlighted;
  final String? iconAsset;

  const TreatmentInfoCard({
    super.key,
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.items,
    required this.decorativeIcon,
    this.isHighlighted = false,
    this.iconAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: isHighlighted
            ? AppColors.brownGradient
            : const LinearGradient(
                colors: [Color(0xFFF8F9F5), Color(0xFFF5F5F0)],
              ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isHighlighted
                ? AppColors.shadowBrown
                : Colors.black.withOpacity(0.08),
            blurRadius: isHighlighted ? 20 : 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: isHighlighted
              ? AppColors.greenWithOpacity(0.5)
              : const Color(0xFFE8E4DC),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildHeader(), _buildItems(context)],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isHighlighted
                ? AppColors.whiteWithOpacity(0.15)
                : const Color(0xFFE8E4DC),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: isHighlighted
                  ? AppColors.brownGradient
                  : LinearGradient(
                      colors: [
                        AppColors.greenWithOpacity(0.15),
                        AppColors.greenWithOpacity(0.05),
                      ],
                    ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: isHighlighted
                  ? [
                      BoxShadow(
                        color: AppColors.shadowGreen,
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: _buildIcon(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: isHighlighted ? AppColors.textWhite : AppColors.textBrown,
                letterSpacing: 0.2,
              ),
            ),
          ),
          Icon(
            decorativeIcon,
            color: isHighlighted
                ? AppColors.green
                : AppColors.brownWithOpacity(0.3),
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    if (iconAsset != null && iconAsset!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.asset(
          iconAsset!,
          width: 20,
          height: 20,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Icon(
            icon,
            color: isHighlighted ? AppColors.textWhite : accentColor,
            size: 20,
          ),
        ),
      );
    }
    return Icon(
      icon,
      color: isHighlighted ? AppColors.textWhite : accentColor,
      size: 20,
    );
  }

  Widget _buildItems(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: items.isEmpty
          ? _buildEmptyState(context)
          : Column(
              children: items
                  .asMap()
                  .entries
                  .map((e) => _buildItem(e.value, e.key))
                  .toList(),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          context.tr('common.no_information'),
          style: TextStyle(
            color: isHighlighted ? AppColors.textWhiteMuted : AppColors.textMuted,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildItem(String item, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: index < items.length - 1 ? 12 : 0),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: isHighlighted ? AppColors.whiteWithOpacity(0.1) : const Color(0xFFFAFAF8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlighted ? AppColors.whiteWithOpacity(0.15) : const Color(0xFFE8E4DC),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: isHighlighted ? AppColors.green : AppColors.brown,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 9, color: AppColors.textWhite),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              item,
              style: TextStyle(
                fontSize: 14,
                color: isHighlighted ? AppColors.textWhiteMuted : AppColors.textBrown,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}