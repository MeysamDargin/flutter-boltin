import 'package:boltin/models/market_price_item.dart';
import 'package:boltin/models/price_snapshot.dart';
import 'package:boltin/services/market_item_mapper.dart';
import 'package:boltin/widget/market_list_tile.dart';
import 'package:flutter/material.dart';

class AllPricesPage extends StatelessWidget {
  final PriceSnapshot snapshot;

  const AllPricesPage({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final currencyItems = currencyItemsFromSnapshot(snapshot);
    final goldItems = goldItemsFromSnapshot(snapshot);
    final cryptoItems = cryptoItemsFromSnapshot(snapshot);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 3, 19, 46),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  children: [
                    _CategorySection(
                      title: 'ارزهای کشورها',
                      items: currencyItems,
                    ),
                    const SizedBox(height: 24),
                    _CategorySection(title: 'طلا و سکه', items: goldItems),
                    const SizedBox(height: 24),
                    _CategorySection(
                      title: 'ارزهای دیجیتال',
                      items: cryptoItems,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color.fromARGB(156, 9, 33, 75),
            width: 2.0,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color.fromARGB(255, 199, 209, 226),
                size: 20,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'همه‌ی قیمت‌ها',
              style: TextStyle(
                color: Color.fromARGB(255, 199, 209, 226),
                fontSize: 18.0,
                fontWeight: FontWeight.w900,
                fontFamily: 'IRANYekanXVF',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String title;
  final List<MarketPriceItem> items;

  const _CategorySection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, right: 4),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) => MarketListTile(item: items[index]),
        ),
      ],
    );
  }
}
