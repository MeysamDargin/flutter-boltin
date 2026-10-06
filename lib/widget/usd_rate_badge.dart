import 'package:boltin/models/change_direction.dart';
import 'package:boltin/models/market_price_item.dart';
import 'package:boltin/utils/persian_format.dart';
import 'package:flutter/material.dart';

class UsdRateBadge extends StatelessWidget {
  final MarketPriceItem item;
  final double fontSize;
  final double iconSize;

  const UsdRateBadge({
    super.key,
    required this.item,
    this.fontSize = 11,
    this.iconSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    final direction = item.usdChangeDirection;
    final Color color = switch (direction) {
      ChangeDirection.up => const Color.fromARGB(255, 39, 173, 95),
      ChangeDirection.down => const Color(0xFFE85D5D),
      ChangeDirection.noChange => Colors.white38,
    };
    final IconData arrowIcon = switch (direction) {
      ChangeDirection.up => Icons.arrow_upward_rounded,
      ChangeDirection.down => Icons.arrow_downward_rounded,
      ChangeDirection.noChange => Icons.remove_rounded,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(arrowIcon, color: Colors.white, size: iconSize),
          const SizedBox(width: 3),
          Text(
            formatPersianNumber(item.usdValue!),
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
