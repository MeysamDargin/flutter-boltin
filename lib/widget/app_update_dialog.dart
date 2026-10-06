import 'package:boltin/models/app_update_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppUpdateDialog extends StatelessWidget {
  const AppUpdateDialog({
    super.key,
    required this.info,
    required this.onUpdateTap,
    this.onLaterTap,
  });

  final AppUpdateInfo info;
  final VoidCallback onUpdateTap;
  final VoidCallback? onLaterTap;

  @override
  Widget build(BuildContext context) {
    final title = info.forceUpdate
        ? 'آپدیت اجباری'
        : 'نسخه جدید بولتین آماده است';
    final subtitle = info.forceUpdate
        ? 'برای ادامه استفاده از اپ لازم است همین حالا نسخه جدید را نصب کنید.'
        : 'برای دریافت آخرین بهبودها و امکانات، بهتره اپ را به‌روز کنید.';

    return PopScope(
      canPop: !info.forceUpdate,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 236, 240, 247),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 184, 195, 214),
                      fontSize: 13.5,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _MetaChip(label: 'آخرین نسخه', value: info.latestVersion),
                  const SizedBox(height: 8),
                  _MetaChip(
                    label: 'حداقل نسخه مجاز',
                    value: info.minRequiredVersion,
                  ),
                  if ((info.releaseNotes ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'توضیحات نسخه',
                      style: TextStyle(
                        color: Color.fromARGB(255, 232, 184, 55),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color.fromARGB(90, 18, 33, 54),
                        border: Border.all(
                          color: const Color.fromARGB(60, 126, 152, 187),
                        ),
                      ),
                      child: Text(
                        info.releaseNotes!,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 214, 221, 232),
                          fontSize: 13,
                          height: 1.8,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      if (!info.forceUpdate)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onLaterTap,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color.fromARGB(120, 126, 152, 187),
                              ),
                              foregroundColor: const Color.fromARGB(
                                255,
                                214,
                                221,
                                232,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text('بعدا'),
                          ),
                        ),
                      if (!info.forceUpdate) const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onUpdateTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              16,
                              170,
                              116,
                            ),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            info.forceUpdate ? 'آپدیت و ادامه' : 'به‌روزرسانی',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color.fromARGB(70, 13, 28, 47),
        border: Border.all(color: const Color.fromARGB(70, 126, 152, 187)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color.fromARGB(255, 150, 166, 191),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Color.fromARGB(255, 235, 240, 247),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
