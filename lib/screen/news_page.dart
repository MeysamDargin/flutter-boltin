import 'package:flutter/material.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 3, 19, 46),
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'آخرین خبرها',
          style: TextStyle(
            color: Color.fromARGB(255, 199, 209, 226),
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 3, 19, 46),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: Color.fromARGB(156, 9, 33, 75),
          ),
        ),
      ),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 26),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color.fromARGB(70, 126, 152, 187),
                  ),
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color.fromARGB(255, 20, 39, 70),
                      Color.fromARGB(255, 10, 29, 62),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(
                          255,
                          16,
                          170,
                          116,
                        ).withValues(alpha: 0.13),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color.fromARGB(
                            255,
                            16,
                            170,
                            116,
                          ).withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.newspaper_rounded,
                        color: Color.fromARGB(255, 16, 170, 116),
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'بخش خبرها در حال توسعه است',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color.fromARGB(255, 236, 240, 247),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'تیم بولتین در حال آماده‌سازی تجربه‌ای سریع و دقیق برای دنبال‌کردن تازه‌ترین خبرهاست. این بخش در یکی از به‌روزرسانی‌های آینده در دسترس قرار می‌گیرد.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color.fromARGB(255, 164, 178, 199),
                        fontSize: 13,
                        height: 1.9,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(
                          255,
                          16,
                          170,
                          116,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            color: Color.fromARGB(255, 16, 170, 116),
                            size: 16,
                          ),
                          SizedBox(width: 7),
                          Text(
                            'به‌زودی در آپدیت‌های بعدی',
                            style: TextStyle(
                              color: Color.fromARGB(255, 99, 210, 170),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
