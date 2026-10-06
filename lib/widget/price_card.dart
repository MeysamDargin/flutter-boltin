import 'package:boltin/models/market_price_item.dart';
import 'package:boltin/utils/persian_format.dart';
import 'package:boltin/widget/market_icon.dart';
import 'package:boltin/widget/usd_rate_badge.dart';
import 'package:flutter/material.dart';

export 'package:boltin/models/market_price_item.dart';

class MarketPriceSlider extends StatelessWidget {
  final String headerTitle;
  final String? updateText;
  final VoidCallback? onSeeAllTap;
  final List<MarketPriceItem> items;

  const MarketPriceSlider({
    super.key,
    required this.items,
    this.headerTitle = 'قیمت‌های مهم بازار',
    this.updateText,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final showSeeAllButton = onSeeAllTap != null;
    final itemCount = items.length + (showSeeAllButton ? 1 : 0);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          const SizedBox(height: 12),
          SizedBox(
            height: 104,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: itemCount,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                if (showSeeAllButton && index == items.length) {
                  return _SeeAllButton(onTap: onSeeAllTap!);
                }
                return _MarketPriceCard(item: items[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            headerTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (updateText != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                updateText!,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

class _MarketPriceCard extends StatelessWidget {
  final MarketPriceItem item;

  const _MarketPriceCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 10, 29, 62),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MarketIcon(item: item, size: 26),
              if (item.usdValue != null) UsdRateBadge(item: item),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${formatPersianNumber(item.price)} ${item.unit}',
            style: const TextStyle(color: Colors.white70, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SeeAllButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SeeAllButton({required this.onTap});

  static const _accentColor = Color.fromARGB(255, 16, 170, 116);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 96,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 10, 29, 62),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _accentColor.withValues(alpha: 0.35),
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: _accentColor,
                  size: 14,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'مشاهده\nهمه',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
