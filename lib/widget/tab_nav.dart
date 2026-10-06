import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class TabNav extends StatefulWidget {
  const TabNav({super.key, this.onTabChanged});

  final ValueChanged<int>? onTabChanged;

  @override
  State<TabNav> createState() => _TabNavState();
}

class _TabNavState extends State<TabNav> {
  int _selectedIndex = 0;

  void _selectTab(int index) {
    setState(() {
      _selectedIndex = index;
    });

    widget.onTabChanged?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    return GlassSegmentedControl.scrollable(
      quality: GlassQuality.premium,
      selectedIndex: _selectedIndex,
      onSegmentSelected: _selectTab,
      backgroundColor: const Color.fromARGB(255, 14, 37, 73),
      selectedTextStyle: TextStyle(color: const Color.fromARGB(255, 16, 170, 116), fontFamily: 'IRANYekan'),
      unselectedTextStyle: TextStyle(color: const Color.fromARGB(255, 158, 205, 255), fontFamily: 'IRANYekan'),
      indicatorColor: const Color.fromARGB(
        255,
        84,
        131,
        115,
      ).withValues(alpha: 0.2),
      settings: LiquidGlassSettings(
        glassColor: const Color.fromARGB(
          255,
          39,
          39,
          39,
        ).withValues(alpha: 0.4),
      ),
      segments: const [
        GlassSegment(label: 'اخبار ایران و جهان'),
        GlassSegment(label: 'اخبار تکنولوژی'),
      ],
    );
  }
}
