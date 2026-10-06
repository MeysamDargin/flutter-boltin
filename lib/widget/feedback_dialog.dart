import 'package:boltin/services/feedback_service.dart';
import 'package:flutter/material.dart';

typedef FeedbackSubmitCallback =
    Future<void> Function({
      required String text,
      required FeedbackCategory category,
      int? rating,
      String? email,
    });

class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog({super.key, required this.onSubmit});

  final FeedbackSubmitCallback onSubmit;

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  static const _accent = Color.fromARGB(255, 16, 170, 116);

  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _emailController = TextEditingController();

  FeedbackCategory _category = FeedbackCategory.suggestion;
  int? _rating;
  bool _isSubmitting = false;
  String? _submitError;

  @override
  void dispose() {
    _messageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      await widget.onSubmit(
        text: _messageController.text,
        category: _category,
        rating: _rating,
        email: _emailController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _submitError =
            'ارسال بازخورد انجام نشد. اتصال اینترنت را بررسی و دوباره تلاش کنید.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color.fromARGB(70, 126, 152, 187)),
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color.fromARGB(255, 23, 40, 65),
              Color.fromARGB(255, 14, 28, 47),
              Color.fromARGB(255, 9, 20, 36),
            ],
          ),
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              18,
              20,
              18 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: _accent.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(
                          Icons.forum_outlined,
                          color: _accent,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ارسال بازخورد',
                              style: TextStyle(
                                color: Color.fromARGB(255, 236, 240, 247),
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'نظرت به بهتر شدن بولتین کمک می‌کند',
                              style: TextStyle(
                                color: Color.fromARGB(255, 150, 166, 191),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const _FieldLabel('موضوع بازخورد'),
                  const SizedBox(height: 9),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _CategoryChip(
                        label: 'پیشنهاد',
                        icon: Icons.lightbulb_outline_rounded,
                        selected: _category == FeedbackCategory.suggestion,
                        onTap: () => setState(
                          () => _category = FeedbackCategory.suggestion,
                        ),
                      ),
                      _CategoryChip(
                        label: 'گزارش مشکل',
                        icon: Icons.bug_report_outlined,
                        selected: _category == FeedbackCategory.bug,
                        onTap: () =>
                            setState(() => _category = FeedbackCategory.bug),
                      ),
                      _CategoryChip(
                        label: 'انتقاد',
                        icon: Icons.sentiment_dissatisfied_outlined,
                        selected: _category == FeedbackCategory.complaint,
                        onTap: () => setState(
                          () => _category = FeedbackCategory.complaint,
                        ),
                      ),
                      _CategoryChip(
                        label: 'سایر',
                        icon: Icons.more_horiz_rounded,
                        selected: _category == FeedbackCategory.other,
                        onTap: () =>
                            setState(() => _category = FeedbackCategory.other),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const _FieldLabel('متن بازخورد'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _messageController,
                    enabled: !_isSubmitting,
                    minLines: 4,
                    maxLines: 7,
                    maxLength: 5000,
                    textInputAction: TextInputAction.newline,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 236, 240, 247),
                      fontSize: 13,
                      height: 1.6,
                    ),
                    decoration: _inputDecoration(
                      hint: 'پیشنهاد، انتقاد یا مشکلی که دیدی را اینجا بنویس...',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'لطفاً متن بازخورد را بنویسید';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  const _FieldLabel('امتیاز شما (اختیاری)'),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (index) {
                      final value = index + 1;
                      final selected = value <= (_rating ?? 0);
                      return IconButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => setState(() => _rating = value),
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.only(left: 5),
                        icon: Icon(
                          selected
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: selected
                              ? const Color.fromARGB(255, 232, 184, 55)
                              : Colors.white38,
                          size: 28,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  const _FieldLabel('ایمیل برای پیگیری (اختیاری)'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    enabled: !_isSubmitting,
                    keyboardType: TextInputType.emailAddress,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 236, 240, 247),
                      fontSize: 13,
                    ),
                    decoration: _inputDecoration(hint: 'name@example.com'),
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      if (email.isEmpty) return null;
                      final valid = RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                      ).hasMatch(email);
                      return valid ? null : 'ایمیل واردشده معتبر نیست';
                    },
                  ),
                  if (_submitError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _submitError!,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 232, 93, 93),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        disabledBackgroundColor: _accent.withValues(alpha: 0.45),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'ارسال بازخورد',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color.fromARGB(255, 112, 130, 157),
        fontSize: 12,
      ),
      filled: true,
      fillColor: const Color.fromARGB(90, 13, 28, 47),
      counterStyle: const TextStyle(color: Colors.white38, fontSize: 10),
      errorStyle: const TextStyle(
        color: Color.fromARGB(255, 232, 93, 93),
        fontSize: 11,
      ),
      contentPadding: const EdgeInsets.all(13),
      border: _fieldBorder(const Color.fromARGB(70, 126, 152, 187)),
      enabledBorder: _fieldBorder(const Color.fromARGB(70, 126, 152, 187)),
      focusedBorder: _fieldBorder(_accent),
      errorBorder: _fieldBorder(const Color.fromARGB(255, 232, 93, 93)),
      focusedErrorBorder: _fieldBorder(const Color.fromARGB(255, 232, 93, 93)),
    );
  }

  OutlineInputBorder _fieldBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color.fromARGB(255, 214, 221, 232),
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const accent = Color.fromARGB(255, 16, 170, 116);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? accent.withValues(alpha: 0.15)
                : const Color.fromARGB(70, 13, 28, 47),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? accent
                  : const Color.fromARGB(70, 126, 152, 187),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? accent : Colors.white54,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? const Color.fromARGB(255, 231, 246, 240)
                      : const Color.fromARGB(255, 184, 195, 214),
                  fontSize: 11.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
