import 'package:boltin/models/app_bootstrap_data.dart';
import 'package:boltin/screen/home_page.dart';
import 'package:boltin/screen/news_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:vibration/vibration.dart';

class ButtonNavbar extends StatefulWidget {
  final int initialIndex;
  final AppBootstrapData? bootstrapData;
  const ButtonNavbar(this.initialIndex, {super.key, this.bootstrapData});

  @override
  State<ButtonNavbar> createState() => _ButtonNavbarState();
}

class _ButtonNavbarState extends State<ButtonNavbar> {
  late int currentIndex;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pages = [
      const NewsPage(),
      HomePage(bootstrapData: widget.bootstrapData),
    ];
  }

  Future<void> onTabTapped(int index) async {
    if (currentIndex != index) {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator ?? false) {
        Vibration.vibrate(duration: 33);
      }
    }
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final isIOS =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
    final sysBottom = isIOS ? 0.0 : MediaQuery.viewPaddingOf(context).bottom;

    return Scaffold(
      backgroundColor: const Color(0xffFEFEFE),
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          IndexedStack(index: currentIndex, children: _pages),

          Positioned(
            left: 50,
            right: 50,
            bottom: sysBottom,
            child: Container(
              child: GlassTabBar.bottom(
                selectedIndex: currentIndex,
                onTabSelected: onTabTapped,
                selectedIconColor: const Color.fromARGB(255, 16, 170, 116),
                unselectedIconColor: const Color.fromARGB(255, 158, 205, 255),
                labelFontSize: 11,
                iconSize: 28,
                iconLabelSpacing: 0,
                indicatorColor: const Color.fromARGB(255, 84, 131, 115).withValues(alpha: 0.2),
                quality: GlassQuality.premium,
                interactionBehavior: GlassInteractionBehavior.full,
                settings: LiquidGlassSettings(
                  blur: 1,
                  glassColor: const Color.fromARGB(255, 39, 39, 39).withValues(alpha: 0.4),
                ),
                tabs: [
                  GlassTab(
                    label: 'خبر ها',
                    icon: const Icon(Icons.newspaper_rounded),
                    activeIcon: const Icon(Icons.newspaper_rounded),
                  ),
                  GlassTab(
                    label: 'فید',
                    icon: const ImageIcon(
                      AssetImage(
                        'assets/icons/home-smile-angle-svgrepo-com (2).png',
                      ),
                      size: 28,
                    ),
                    activeIcon: const ImageIcon(
                      AssetImage(
                        'assets/icons/home-smile-angle-svgrepo-com (1).png',
                      ),
                      size: 28,
                    ),
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
