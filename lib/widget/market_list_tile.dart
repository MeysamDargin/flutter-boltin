import 'package:boltin/models/market_price_item.dart';
import 'package:boltin/utils/persian_format.dart';
import 'package:boltin/widget/market_icon.dart';
import 'package:boltin/widget/usd_rate_badge.dart';
import 'package:flutter/material.dart';

class MarketListTile extends StatelessWidget {
  final MarketPriceItem item;

  const MarketListTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 10, 29, 62),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          MarketIcon(item: item, size: 34),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${formatPersianNumber(item.price)} ${item.unit}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (item.usdValue != null) ...[
            const SizedBox(width: 10),
            UsdRateBadge(item: item),
          ],
        ],
      ),
    );
  }
}
