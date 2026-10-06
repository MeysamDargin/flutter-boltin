import 'package:flutter/material.dart';

class AiMarketSummaryCard extends StatefulWidget {
  const AiMarketSummaryCard({
    super.key,
    required this.summary,
    this.confidence,
    this.updateText,
    this.onTap,
    this.isLoading = false,
  });

  final String summary;
  final double? confidence;
  final String? updateText;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  State<AiMarketSummaryCard> createState() =>
      _AiMarketSummaryCardState();
}

class _AiMarketSummaryCardState extends State<AiMarketSummaryCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;

  bool _isExpanded = false;

  static const _cardBg = Color.fromARGB(255, 14, 29, 49);
  static const _textPrimary = Color.fromARGB(255, 222, 227, 237);
  static const _textSecondary = Color.fromARGB(255, 137, 151, 177);
  static const _gold = Color.fromARGB(255, 232, 184, 55);

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTopHeader(),

            const SizedBox(height: 20),

            _buildCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              size: 17,
              color: _gold,
            ),
            const SizedBox(width: 6),
            const Text(
              'تحلیل بازار با هوش مصنوعی',
              style: TextStyle(
                color: _gold,
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        const Spacer(),

        if (widget.updateText != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 12,
                color: _textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                widget.updateText!,
                style: const TextStyle(
                  color: _textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildCard() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = 0.16 + (0.09 * _glowController.value);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _gold.withOpacity(0.72),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _gold.withOpacity(glow),
                blurRadius: 24,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
            gradient: const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              stops: [
                0.0,
                0.42,
                1.0,
              ],
              colors: [
                Color.fromARGB(255, 28, 43, 63),
                Color.fromARGB(255, 20, 37, 58),
                Color.fromARGB(255, 13, 27, 46),
              ],
            ),
          ),

          child: ClipRRect(
            borderRadius: BorderRadius.circular(17),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                splashColor: _gold.withOpacity(0.06),
                highlightColor: _gold.withOpacity(0.025),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    11,
                  ),
                  child: widget.isLoading
                      ? _buildSkeletonLines()
                      : _buildExpandableContent(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpandableContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _isExpanded
              ? _buildExpandedText()
              : _buildCollapsedText(),
        ),

        const SizedBox(height: 7),

        _isExpanded
            ? _buildLessButton()
            : _buildMoreButton(),
      ],
    );
  }

  Widget _buildCollapsedText() {
    return Text(
      widget.summary,
      textAlign: TextAlign.right,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: _textPrimary,
        fontSize: 13.5,
        height: 1.7,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildExpandedText() {
    return Text(
      widget.summary,
      textAlign: TextAlign.right,
      style: const TextStyle(
        color: _textPrimary,
        fontSize: 13.5,
        height: 1.7,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildMoreButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _isExpanded = true;
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(
          top: 2,
          bottom: 1,
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: _gold.withOpacity(0.10),
              ),
            ),

            const SizedBox(width: 10),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'نمایش بیشتر',
                  style: TextStyle(
                    color: _gold.withOpacity(0.82),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: _gold.withOpacity(0.75),
                  size: 15,
                ),
              ],
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Container(
                height: 1,
                color: _gold.withOpacity(0.10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _isExpanded = false;
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(
          top: 2,
          bottom: 1,
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: _gold.withOpacity(0.08),
              ),
            ),

            const SizedBox(width: 10),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'نمایش کمتر',
                  style: TextStyle(
                    color: _gold.withOpacity(0.72),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.keyboard_arrow_up_rounded,
                  color: _gold.withOpacity(0.65),
                  size: 15,
                ),
              ],
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Container(
                height: 1,
                color: _gold.withOpacity(0.08),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLines() {
    Widget line(double widthFactor) {
      return Container(
        height: 11,
        margin: const EdgeInsets.only(bottom: 9),
        width: MediaQuery.of(context).size.width * widthFactor,
        decoration: BoxDecoration(
          color: _gold.withOpacity(0.12),
          borderRadius: BorderRadius.circular(6),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        line(0.75),
        line(0.60),
        line(0.45),
      ],
    );
  }
}