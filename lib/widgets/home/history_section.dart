import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../models/detection_history.dart';

class HistorySection extends StatelessWidget {
  final List<DetectionHistory> historyItems;
  final bool isLoading;
  final Function(String id) onDelete;
  final Function(DetectionHistory item) onTapItem;

  const HistorySection({
    super.key,
    required this.historyItems,
    required this.isLoading,
    required this.onDelete,
    required this.onTapItem,
  });

  static const Color primaryColor = Color(0xFF002319);
  static const Color accentColor = Color(0xFF768E2E);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'history.latest_checks'.tr(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {},
              child: Text(
                'common.show_all'.tr(),
                style: const TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: CircularProgressIndicator(
                color: accentColor,
              ),
            ),
          )
        else if (historyItems.isEmpty)
          _buildEmptyState()
        else
          SizedBox(
            height: 170,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: historyItems.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (_, index) {
                final item = historyItems[index];
                return _HistoryCard(
                  item: item,
                  onDelete: () => onDelete(item.id),
                  onTap: () => onTapItem(item),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 35),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.history, color: Colors.grey.shade400, size: 42),
          const SizedBox(height: 10),
          Text(
            'history.no_checks_yet'.tr(),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final DetectionHistory item;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _HistoryCard({
    required this.item,
    required this.onDelete,
    required this.onTap,
  });

  static const Color primaryColor = Color(0xFF002319);
  static const Color accentColor = Color(0xFF768E2E);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          width: 250,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      color: accentColor,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: Colors.grey,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                item.diseaseName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.formattedDate,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}