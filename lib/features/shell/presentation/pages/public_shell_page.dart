import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../favorites/presentation/bloc/favorites_bloc.dart';
import '../../../search/presentation/pages/search_page.dart';
import '../../../favorites/presentation/pages/favorites_page.dart';
import '../../../campus_map/presentation/pages/campus_map_page.dart';

class PublicShellPage extends StatefulWidget {
  const PublicShellPage({super.key});

  @override
  State<PublicShellPage> createState() => _PublicShellPageState();
}

class _PublicShellPageState extends State<PublicShellPage> {
  int _currentIndex = 0;

  final List<_NavItem> _navItems = const [
    _NavItem(
      icon: Icons.search_rounded,
      activeIcon: Icons.search_rounded,
      label: 'Buscar',
    ),
    _NavItem(
      icon: Icons.bookmark_border_rounded,
      activeIcon: Icons.bookmark_rounded,
      label: 'Guardados',
    ),
    _NavItem(
      icon: Icons.map_outlined,
      activeIcon: Icons.map_rounded,
      label: 'Mapa',
    ),
  ];

  void _onTap(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // FavoritesBloc compartido entre SearchPage y FavoritesPage
    return BlocProvider(
      create: (_) => FavoritesBloc.create()..add(const FavoritesStarted()),
      child: Builder(
        builder: (context) {
          final pages = [
            const SearchPage(),
            const FavoritesPage(),
            const CampusMapPage(edificioResaltado: '1', showBackButton: false),
          ];

          return Scaffold(
            body: AnimatedSwitcher(
              duration: 350.ms,
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.04),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: KeyedSubtree(
                key: ValueKey(_currentIndex),
                child: pages[_currentIndex],
              ),
            ),
            bottomNavigationBar: _AnimatedBottomNav(
              currentIndex: _currentIndex,
              items: _navItems,
              onTap: _onTap,
              isDark: isDark,
            ),
          );
        },
      ),
    );
  }
}

class _AnimatedBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;
  final bool isDark;

  const _AnimatedBottomNav({
    required this.currentIndex,
    required this.items,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgSurface : AppColors.bgPrimary,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              ...List.generate(items.length, (i) {
                final isActive = i == currentIndex;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(i),
                    behavior: HitTestBehavior.opaque,
                    child: _NavTile(
                      item: items[i],
                      isActive: isActive,
                      isDark: isDark,
                    ),
                  ),
                );
              }),
              _AdminButton(isDark: isDark),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 200.ms)
        .slideY(begin: 0.3, curve: Curves.easeOutCubic);
  }
}

class _NavTile extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final bool isDark;

  const _NavTile({
    required this.item,
    required this.isActive,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isDark ? AppColors.darkBlueMid : AppColors.blueMid;
    final inactiveColor =
        isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: 250.ms,
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          decoration: BoxDecoration(
            color: isActive
                ? (isDark
                    ? AppColors.darkBlueMid.withOpacity(0.15)
                    : AppColors.blueSurface)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            isActive ? item.activeIcon : item.icon,
            size: 22,
            color: isActive ? activeColor : inactiveColor,
          ),
        ),
        const SizedBox(height: 2),
        AnimatedDefaultTextStyle(
          duration: 200.ms,
          style: AppTextStyles.caption.copyWith(
            color: isActive ? activeColor : inactiveColor,
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
          ),
          child: Text(item.label),
        ),
      ],
    );
  }
}

class _AdminButton extends StatelessWidget {
  final bool isDark;
  const _AdminButton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/admin-login'),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBgOverlay : AppColors.bgOverlay,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.borderLight,
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.admin_panel_settings_outlined,
                size: 16,
                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
