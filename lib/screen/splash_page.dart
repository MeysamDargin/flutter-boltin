import 'dart:math' as math;

import 'package:boltin/models/app_bootstrap_data.dart';
import 'package:boltin/models/app_update_info.dart';
import 'package:boltin/services/app_bootstrap_service.dart';
import 'package:boltin/widget/app_update_dialog.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({
    super.key,
    required this.onReady,
    required this.onOpenUpdateUrl,
  });

  final void Function(AppBootstrapData data) onReady;
  final void Function(AppUpdateInfo info) onOpenUpdateUrl;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  static const _minDisplay = Duration(milliseconds: 2400);
  static const _bg = Color(0xFF060B14);

  late final AnimationController _intro;
  late final AnimationController _pulse; // fast loop: radar/dial/blink
  late final AnimationController _ticker; // slow loop: chart + tape scroll

  late final Animation<double> _globalFade;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _brandOpacity;
  late final Animation<double> _brandSlide;
  late final Animation<double> _tapeOpacity;
  late final Animation<double> _statusOpacity;
  late final Animation<double> _statusSlide;

  final AppBootstrapService _bootstrapService = AppBootstrapService();

  bool _isLoading = true;
  bool _isRetrying = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    );
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16000),
    )..repeat();

    _globalFade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.0, 0.08, curve: Curves.easeOut),
    );
    _logoOpacity = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.0, 0.30, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.0, 0.46, curve: Curves.easeOutCubic),
      ),
    );
    _brandOpacity = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.34, 0.64, curve: Curves.easeOut),
    );
    _brandSlide = Tween<double>(begin: 10, end: 0).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.34, 0.70, curve: Curves.easeOutCubic),
      ),
    );
    _tapeOpacity = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.5, 0.85, curve: Curves.easeOut),
    );
    _statusOpacity = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.66, 1.0, curve: Curves.easeOut),
    );
    _statusSlide = Tween<double>(begin: 10, end: 0).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.66, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _intro.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startBootstrap());
  }

  @override
  void dispose() {
    _intro.dispose();
    _pulse.dispose();
    _ticker.dispose();
    _bootstrapService.dispose();
    super.dispose();
  }

  Future<void> _startBootstrap() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isRetrying = false;
    });

    final startedAt = DateTime.now();

    try {
      final outcome = await _bootstrapService.load();
      final elapsed = DateTime.now().difference(startedAt);
      // Hold the splash until the intro animation can finish.
      if (elapsed < _minDisplay) {
        await Future<void>.delayed(_minDisplay - elapsed);
      }
      if (!mounted) return;
      await _handleOutcome(outcome);
    } catch (error) {
      final elapsed = DateTime.now().difference(startedAt);
      if (elapsed < const Duration(milliseconds: 900)) {
        await Future<void>.delayed(
          const Duration(milliseconds: 900) - elapsed,
        );
      }
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error is AppBootstrapException
            ? error.message
            : 'ارتباط با سرور برقرار نشد. لطفاً دوباره تلاش کنید.';
      });
    }
  }

  Future<void> _retry() async {
    if (_isRetrying) return;
    setState(() => _isRetrying = true);
    await _startBootstrap();
  }

  Future<void> _handleOutcome(AppBootstrapOutcome outcome) async {
    final updateInfo = outcome.updateInfo;
    if (updateInfo != null &&
        (updateInfo.updateAvailable || updateInfo.forceUpdate)) {
      await _showUpdateDialog(updateInfo);
      if (!mounted) return;
      if (updateInfo.forceUpdate) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'برای ورود به بولتین لازم است نسخه جدید اپ را نصب کنید.';
        });
        return;
      }
    }

    widget.onReady(outcome.data);
  }

  Future<void> _showUpdateDialog(AppUpdateInfo info) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: !info.forceUpdate,
      builder: (dialogContext) {
        return AppUpdateDialog(
          info: info,
          onUpdateTap: () => widget.onOpenUpdateUrl(info),
          onLaterTap: info.forceUpdate
              ? null
              : () => Navigator.of(dialogContext).pop(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: AnimatedBuilder(
        animation: Listenable.merge([_intro, _pulse, _ticker]),
        builder: (context, _) {
          return Opacity(
            opacity: _globalFade.value.clamp(0.0, 1.0),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _MarketBackdropPainter(
                      chartProgress: _ticker.value,
                      pulse: _pulse.value,
                      intro: _intro.value,
                    ),
                  ),
                ),
                SafeArea(
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Column(
                      children: [
                        Opacity(
                          opacity: _tapeOpacity.value.clamp(0.0, 1.0),
                          child: _TickerTape(scroll: _ticker.value),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                            ),
                            child: Column(
                              children: [
                                const Spacer(flex: 5),
                                Opacity(
                                  opacity: _logoOpacity.value.clamp(
                                    0.0,
                                    1.0,
                                  ),
                                  child: Transform.scale(
                                    scale: _logoScale.value,
                                    child: _LogoNode(pulse: _pulse.value),
                                  ),
                                ),
                                const SizedBox(height: 26),
                                Opacity(
                                  opacity: _brandOpacity.value.clamp(
                                    0.0,
                                    1.0,
                                  ),
                                  child: Transform.translate(
                                    offset: Offset(0, _brandSlide.value),
                                    child: Directionality(
                                      textDirection: TextDirection.ltr,
                                      child: _BrandTitle(pulse: _pulse.value),
                                    ),
                                  ),
                                ),
                                const Spacer(flex: 4),
                                Opacity(
                                  opacity: _statusOpacity.value.clamp(
                                    0.0,
                                    1.0,
                                  ),
                                  child: Transform.translate(
                                    offset: Offset(0, _statusSlide.value),
                                    child: _StatusArea(
                                      errorMessage: _errorMessage,
                                      onRetry: _retry,
                                      isBusy: _isRetrying || _isLoading,
                                      pulse: _pulse.value,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TickerTape extends StatelessWidget {
  const _TickerTape({required this.scroll});

  final double scroll;

  static const List<_TapeItem> _items = [
    _TapeItem('شاخص کل', '۱٫۲٪+', true),
    _TapeItem('طلای ۱۸', '۰٫۴٪+', true),
    _TapeItem('دلار', '۰٫۲٪-', false),
    _TapeItem('بیت‌کوین', '۲٫۱٪+', true),
    _TapeItem('یورو', '۰٫۱٪+', true),
    _TapeItem('فرابورس', '۰٫۶٪-', false),
    _TapeItem('سکه', '۰٫۹٪+', true),
  ];

  static const double _itemWidth = 118;

  @override
  Widget build(BuildContext context) {
    final totalWidth = _itemWidth * _items.length;
    final offset = (scroll * totalWidth) % totalWidth;

    return Container(
      height: 34,
      color: Colors.white.withValues(alpha: 0.03),
      child: ClipRect(
        child: OverflowBox(
          maxWidth: double.infinity,
          alignment: Alignment.centerLeft,
          child: Transform.translate(
            offset: Offset(-offset, 0),
            child: Row(
              children: List.generate(_items.length * 3, (i) {
                final item = _items[i % _items.length];
                return SizedBox(
                  width: _itemWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.up
                            ? Icons.arrow_drop_up_rounded
                            : Icons.arrow_drop_down_rounded,
                        size: 16,
                        color: item.up
                            ? const Color(0xFF1FD18B)
                            : const Color(0xFFE5484D),
                      ),
                      Text(
                        item.change,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: item.up
                              ? const Color(0xFF1FD18B)
                              : const Color(0xFFE5484D),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _TapeItem {
  const _TapeItem(this.label, this.change, this.up);
  final String label;
  final String change;
  final bool up;
}

class _LogoNode extends StatelessWidget {
  const _LogoNode({required this.pulse});

  final double pulse;

  @override
  Widget build(BuildContext context) {
    final blink = (math.sin(pulse * math.pi * 2) + 1) / 2;

    return SizedBox(
      width: 148,
      height: 148,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(148, 148),
            painter: _RadarFramePainter(pulse: pulse),
          ),
          Container(
            width: 84,
            height: 84,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0A121F),
              border: Border.all(
                color: const Color(0xFF1FD18B).withValues(alpha: 0.6),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(
                    0xFF1FD18B,
                  ).withValues(alpha: 0.20 + blink * 0.12),
                  blurRadius: 22,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Text(
              'b',
              style: TextStyle(
                color: Color(0xFF1FD18B),
                fontSize: 30,
                fontWeight: FontWeight.w900,
                fontFamily: 'PressStart2P',
              ),
            ),
          ),
          Positioned(
            top: 18,
            right: 18,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(
                  0xFF1FD18B,
                ).withValues(alpha: 0.5 + blink * 0.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0xFF1FD18B,
                    ).withValues(alpha: 0.5 * blink),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarFramePainter extends CustomPainter {
  _RadarFramePainter({required this.pulse});

  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 68.0;

    final crosshair = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(center.dx - radius - 8, center.dy),
      Offset(center.dx + radius + 8, center.dy),
      crosshair,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius - 8),
      Offset(center.dx, center.dy + radius + 8),
      crosshair,
    );

    _drawDashedCircle(
      canvas,
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF1FD18B).withValues(alpha: 0.25),
    );

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(pulse * math.pi * 2);
    final sweepRect = Rect.fromCircle(center: Offset.zero, radius: radius);
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          const Color(0xFF1FD18B).withValues(alpha: 0.0),
          const Color(0xFF1FD18B).withValues(alpha: 0.35),
        ],
        startAngle: 0,
        endAngle: math.pi * 0.6,
      ).createShader(sweepRect);
    canvas.drawArc(sweepRect, 0, math.pi * 0.6, true, sweepPaint);
    canvas.restore();

    final bracket = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF1FD18B).withValues(alpha: 0.55);
    const bl = 12.0;
    final rect = Rect.fromCenter(
      center: center,
      width: size.width - 6,
      height: size.height - 6,
    );
    canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(bl, 0), bracket);
    canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(0, bl), bracket);
    canvas.drawLine(
      rect.topRight,
      rect.topRight + const Offset(-bl, 0),
      bracket,
    );
    canvas.drawLine(
      rect.topRight,
      rect.topRight + const Offset(0, bl),
      bracket,
    );
    canvas.drawLine(
      rect.bottomLeft,
      rect.bottomLeft + const Offset(bl, 0),
      bracket,
    );
    canvas.drawLine(
      rect.bottomLeft,
      rect.bottomLeft + const Offset(0, -bl),
      bracket,
    );
    canvas.drawLine(
      rect.bottomRight,
      rect.bottomRight + const Offset(-bl, 0),
      bracket,
    );
    canvas.drawLine(
      rect.bottomRight,
      rect.bottomRight + const Offset(0, -bl),
      bracket,
    );
  }

  void _drawDashedCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
  ) {
    const dashCount = 40;
    const dashGap = 0.55; // fraction of segment that is drawn
    for (var i = 0; i < dashCount; i++) {
      final a0 = (i / dashCount) * math.pi * 2;
      final a1 = a0 + (math.pi * 2 / dashCount) * dashGap;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        a0,
        a1 - a0,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadarFramePainter oldDelegate) =>
      oldDelegate.pulse != pulse;
}

class _BrandTitle extends StatelessWidget {
  const _BrandTitle({required this.pulse});

  final double pulse;

  @override
  Widget build(BuildContext context) {
    final cursorOn = (pulse * 2) % 1.0 < 0.5;

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'بولتین',
              style: TextStyle(
                color: Color(0xFFDCE6F0),
                fontSize: 32,
                fontWeight: FontWeight.w900,
                fontFamily: 'IRANYekanXVF',
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                'b',
                style: TextStyle(
                  color: const Color(0xFF1FD18B),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'PressStart2P',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '>',
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 12,
                  color: const Color(0xFF1FD18B).withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'نبض دنیا در یک نگاه',
                style: TextStyle(
                  fontSize: 11.5,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
              const SizedBox(width: 4),
              Opacity(
                opacity: cursorOn ? 1 : 0,
                child: Container(
                  width: 6,
                  height: 12,
                  color: const Color(0xFF1FD18B).withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusArea extends StatelessWidget {
  const _StatusArea({
    required this.errorMessage,
    required this.onRetry,
    required this.isBusy,
    required this.pulse,
  });

  final String? errorMessage;
  final VoidCallback onRetry;
  final bool isBusy;
  final double pulse;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: errorMessage == null
          ? _WaitPanel(key: const ValueKey('wait'), pulse: pulse)
          : _ErrorPanel(
              key: const ValueKey('error'),
              message: errorMessage!,
              onRetry: onRetry,
              isRetrying: isBusy,
            ),
    );
  }
}

class _WaitPanel extends StatelessWidget {
  const _WaitPanel({super.key, required this.pulse});

  final double pulse;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 22,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(7, (i) {
              final phase = (pulse + i * 0.11) % 1.0;
              final h = 6 + (0.5 + 0.5 * math.sin(phase * math.pi * 2)) * 16;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.5),
                child: Container(
                  width: 4,
                  height: h,
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF1FD18B,
                    ).withValues(alpha: 0.4 + (h / 22) * 0.6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'کمی منتظر بمانید',
          style: TextStyle(
            color: Color(0xFFDCE6F0),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'در حال دریافت اطلاعات از سرور های بولتین',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.38),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({
    super.key,
    required this.message,
    required this.onRetry,
    required this.isRetrying,
  });

  final String message;
  final VoidCallback onRetry;
  final bool isRetrying;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 360),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFF0A121F),
        border: Border.all(
          color: const Color(0xFFE5484D).withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ERROR',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  letterSpacing: 2,
                  color: const Color(0xFFE5484D).withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.podcasts_rounded,
                size: 15,
                color: const Color(0xFFE5484D).withValues(alpha: 0.7),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'ورود به اپ انجام نشد',
            style: TextStyle(
              color: Color(0xFFDCE6F0),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12.5,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 16),
          _RetryButton(isBusy: isRetrying, onTap: onRetry),
        ],
      ),
    );
  }
}

class _RetryButton extends StatefulWidget {
  const _RetryButton({required this.isBusy, required this.onTap});

  final bool isBusy;
  final VoidCallback onTap;

  @override
  State<_RetryButton> createState() => _RetryButtonState();
}

class _RetryButtonState extends State<_RetryButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.isBusy) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: widget.isBusy ? null : widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 110),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: widget.isBusy
                ? const Color(0xFF1FD18B).withValues(alpha: 0.35)
                : const Color(0xFF1FD18B),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: widget.isBusy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'تلاش مجدد',
                  style: TextStyle(
                    color: Color(0xFF06110C),
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
      ),
    );
  }
}

// Custom-painted HUD: ticker tape, radar mark, and a scrolling candlestick band.
class _MarketBackdropPainter extends CustomPainter {
  _MarketBackdropPainter({
    required this.chartProgress,
    required this.pulse,
    required this.intro,
  });

  final double chartProgress;
  final double pulse;
  final double intro;

  static const _candleCount = 46;
  static final List<double> _heights = List.generate(
    _candleCount,
    (i) => 0.15 + (math.Random(i * 7 + 3).nextDouble() * 0.7),
  );
  static final List<bool> _ups = List.generate(
    _candleCount,
    (i) => math.Random(i * 13 + 1).nextBool(),
  );

  @override
  void paint(Canvas canvas, Size size) {
    final appear = Curves.easeOut.transform(intro.clamp(0.0, 1.0));
    final rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF081020), Color(0xFF060B14), Color(0xFF04070E)],
        ).createShader(rect),
    );

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.035)
      ..strokeWidth = 1;
    const step = 42.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final glowCenter = Offset(size.width * 0.5, size.height * 0.34);
    final breathe = 0.5 + 0.5 * math.sin(pulse * math.pi * 2);
    canvas.drawCircle(
      glowCenter,
      210,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(
              0xFF1FD18B,
            ).withValues(alpha: (0.10 + breathe * 0.04) * appear),
            const Color(0xFF1FD18B).withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: glowCenter, radius: 210)),
    );

    final bandTop = size.height * 0.66;
    final bandBottom = size.height * 0.94;
    final bandHeight = bandBottom - bandTop;
    const candleWidth = 8.0;
    const candleGap = 6.0;
    const unit = candleWidth + candleGap;
    final totalWidth = unit * _candleCount;
    final scrollOffset = chartProgress * totalWidth;

    final linePoints = <Offset>[];
    for (var i = -1; i < (size.width / unit).ceil() + 2; i++) {
      final idx = ((i + (scrollOffset / unit).floor()) % _candleCount +
              _candleCount) %
          _candleCount;
      final localX = i * unit - (scrollOffset % unit) + (size.width * 0.02);
      final h = _heights[idx] * bandHeight * 0.55;
      final up = _ups[idx];
      final cy = bandBottom - h / 2 - (bandHeight * 0.12);
      final color = (up ? const Color(0xFF1FD18B) : const Color(0xFFE5484D))
          .withValues(alpha: 0.16 * appear);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(localX, cy),
            width: candleWidth,
            height: h,
          ),
          const Radius.circular(1.5),
        ),
        Paint()..color = color,
      );
      canvas.drawLine(
        Offset(localX, cy - h / 2 - 6),
        Offset(localX, cy + h / 2 + 6),
        Paint()
          ..color = color.withValues(alpha: color.a * 0.8)
          ..strokeWidth = 1,
      );
      linePoints.add(Offset(localX, cy - h / 2 - 6));
    }

    if (linePoints.length > 2) {
      final path = Path()..moveTo(linePoints.first.dx, linePoints.first.dy);
      for (final p in linePoints.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      final linePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = const Color(0xFF1FD18B).withValues(alpha: 0.32 * appear);
      canvas.drawPath(path, linePaint);

      final fillPath = Path.from(path)
        ..lineTo(linePoints.last.dx, bandBottom)
        ..lineTo(linePoints.first.dx, bandBottom)
        ..close();
      canvas.drawPath(
        fillPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1FD18B).withValues(alpha: 0.08 * appear),
              const Color(0xFF1FD18B).withValues(alpha: 0.0),
            ],
          ).createShader(Rect.fromLTRB(0, bandTop, size.width, bandBottom)),
      );
    }

    canvas.drawRect(
      Rect.fromLTRB(0, bandTop - 20, size.width, bandTop + 20),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF060B14),
            const Color(0xFF060B14).withValues(alpha: 0.0),
          ],
        ).createShader(
          Rect.fromLTRB(0, bandTop - 20, size.width, bandTop + 20),
        ),
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 1.15,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.3)],
          stops: const [0.55, 1.0],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _MarketBackdropPainter oldDelegate) {
    return oldDelegate.chartProgress != chartProgress ||
        oldDelegate.pulse != pulse ||
        oldDelegate.intro != intro;
  }
}