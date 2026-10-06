import 'package:boltin/models/channel_summary.dart';
import 'package:boltin/utils/persian_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class AiNewsSummaryCard extends StatefulWidget {
  const AiNewsSummaryCard({
    super.key,
    required this.title,
    required this.category,
    this.summary,
    this.isLoading = false,
    this.hasError = false,
    this.onRetry,
  });

  final String title;
  final SummaryCategory category;
  final ChannelSummary? summary;
  final bool isLoading;
  final bool hasError;
  final VoidCallback? onRetry;

  static const geopoliticsAccent = Color.fromARGB(255, 220, 152, 64);
  static const technologyAccent = Color.fromARGB(255, 56, 184, 210);

  static Color accentFor(SummaryCategory category) {
    switch (category) {
      case SummaryCategory.geopolitics:
        return geopoliticsAccent;
      case SummaryCategory.technology:
        return technologyAccent;
    }
  }

  @override
  State<AiNewsSummaryCard> createState() => _AiNewsSummaryCardState();
}

class _AiNewsSummaryCardState extends State<AiNewsSummaryCard> {
  bool _isExpanded = false;

  static const _cardBgTop = Color.fromARGB(255, 18, 38, 66);
  static const _cardBgMid = Color.fromARGB(255, 12, 30, 55);
  static const _cardBgBottom = Color.fromARGB(255, 8, 24, 46);
  static const _textPrimary = Color.fromARGB(255, 222, 227, 237);
  static const _textSecondary = Color.fromARGB(255, 137, 151, 177);
  static const _collapsedMaxHeight = 118.0;

  Color get _accent => AiNewsSummaryCard.accentFor(widget.category);

  @override
  void didUpdateWidget(covariant AiNewsSummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final categoryChanged = oldWidget.category != widget.category;
    final oldId = oldWidget.summary?.summaryId;
    final newId = widget.summary?.summaryId;
    if ((categoryChanged || oldId != newId) && _isExpanded) {
      _isExpanded = false;
    }
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
            _buildHeader(),
            const SizedBox(height: 12),
            _buildCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final updateText = widget.summary == null
        ? null
        : formatRelativePersian(widget.summary!.createdAt);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.auto_awesome_rounded, size: 16, color: _accent),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            widget.title,
            style: TextStyle(
              color: _accent,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              fontFamily: 'IRANYekan',
            ),
          ),
        ),
        if (updateText != null) ...[
          const Icon(
            Icons.access_time_rounded,
            size: 12,
            color: _textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            updateText,
            style: const TextStyle(
              color: _textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: 'IRANYekan',
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _accent.withValues(alpha: 0.28),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _accent.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [_cardBgTop, _cardBgMid, _cardBgBottom],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (widget.isLoading) {
      return _buildSkeleton();
    }

    if (widget.hasError) {
      return _buildMessageState(
        icon: Icons.wifi_off_rounded,
        message: 'دریافت خلاصه خبر ناموفق بود',
        actionLabel: 'تلاش مجدد',
        onAction: widget.onRetry,
      );
    }

    final summary = widget.summary;
    if (summary == null || summary.summaryText.trim().isEmpty) {
      return _buildMessageState(
        icon: Icons.article_outlined,
        message: 'هنوز خلاصه‌ای برای این بخش آماده نشده',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (summary.postCount > 0) ...[
          _buildMetaChip(summary),
          const SizedBox(height: 10),
        ],
        AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _isExpanded
              ? _buildMarkdown(summary.summaryText)
              : _buildCollapsedMarkdown(summary.summaryText),
        ),
        const SizedBox(height: 6),
        _isExpanded ? _buildToggleButton(expand: false) : _buildToggleButton(expand: true),
      ],
    );
  }

  Widget _buildMetaChip(ChannelSummary summary) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'بر اساس ${toPersianDigits(summary.postCount)} خبر',
          style: TextStyle(
            color: _accent.withValues(alpha: 0.9),
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            fontFamily: 'IRANYekan',
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsedMarkdown(String markdown) {
    return Stack(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: _collapsedMaxHeight),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: _buildMarkdown(markdown),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 36,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _cardBgBottom.withValues(alpha: 0),
                    _cardBgBottom.withValues(alpha: 0.95),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMarkdown(String markdown) {
    final baseStyle = const TextStyle(
      color: _textPrimary,
      fontSize: 13.2,
      height: 1.75,
      fontWeight: FontWeight.w500,
      fontFamily: 'IRANYekan',
    );

    return MarkdownBody(
      data: markdown,
      shrinkWrap: true,
      softLineBreak: true,
      styleSheet: MarkdownStyleSheet(
        p: baseStyle,
        strong: baseStyle.copyWith(fontWeight: FontWeight.w800,color: _accent),
        em: baseStyle.copyWith(fontStyle: FontStyle.italic),
        listBullet: baseStyle.copyWith(color: _accent),
        listIndent: 18,
        h1: baseStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w800),
        h2: baseStyle.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
        h3: baseStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
        blockSpacing: 8,
        textAlign: WrapAlignment.start,
        unorderedListAlign: WrapAlignment.start,
        orderedListAlign: WrapAlignment.start,
      ),
    );
  }

  Widget _buildToggleButton({required bool expand}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _isExpanded = expand),
      child: Padding(
        padding: const EdgeInsets.only(top: 2, bottom: 1),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: _accent.withValues(alpha: 0.10),
              ),
            ),
            const SizedBox(width: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  expand ? 'نمایش بیشتر' : 'نمایش کمتر',
                  style: TextStyle(
                    color: _accent.withValues(alpha: 0.85),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'IRANYekan',
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  expand
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.keyboard_arrow_up_rounded,
                  color: _accent.withValues(alpha: 0.75),
                  size: 15,
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 1,
                color: _accent.withValues(alpha: 0.10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageState({
    required IconData icon,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Icon(icon, size: 22, color: _textSecondary),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _textSecondary,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              fontFamily: 'IRANYekan',
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 10),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: _accent,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
              child: Text(
                actionLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'IRANYekan',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    Widget line(double widthFactor) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          height: 10,
          margin: const EdgeInsets.only(bottom: 9),
          width: MediaQuery.sizeOf(context).width * widthFactor,
          decoration: BoxDecoration(
            color: _accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        line(0.72),
        line(0.58),
        line(0.44),
      ],
    );
  }
}
