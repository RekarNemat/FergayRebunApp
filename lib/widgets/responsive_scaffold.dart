import 'package:flutter/material.dart';
import '../screens/modals/live_stream_sheet.dart';
import '../screens/modals/notifications_sheet.dart';
import '../screens/modals/search_sheet.dart';
import '../screens/modals/teachers_sheet.dart';
import '../screens/tabs/academy_tab.dart';
import '../screens/tabs/account_tab.dart';
import '../screens/tabs/favorites_tab.dart';
import '../screens/tabs/home_tab.dart';
import '../screens/tabs/sanad_tab.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'nav_drawer.dart';

class ResponsiveMainShell extends StatelessWidget {
  final AppState appState;

  const ResponsiveMainShell({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final s = appState;
    return AnimatedBuilder(
      animation: s,
      builder: (context, _) {
        final pages = [
          SanadTab(
            appState: s,
            onGoToAccount: () => s.setTabIndex(4),
          ),
          AcademyTab(
            appState: s,
            onGoToAccount: () => s.setTabIndex(4),
          ),
          HomeTab(
            appState: s,
            onGoToAcademy: () => s.setTabIndex(1),
            onGoToSanad: () => s.setTabIndex(0),
            onGoToAccount: () => s.setTabIndex(4),
          ),
          FavoritesTab(
            appState: s,
            onGoToHome: () => s.setTabIndex(2),
            onGoToAccount: () => s.setTabIndex(4),
          ),
          AccountTab(appState: s),
        ];

        final unread = s.unreadNotificationsCount;

        return Scaffold(
          drawer: ReboonNavDrawer(
            appState: s,
            onOpenLive: () => openLiveStreamSheet(
              context,
              s,
              onOpenAccountTab: () => s.setTabIndex(4),
            ),
            onOpenTeachers: () => openAcademyTeachersSheet(context, s),
            onOpenAccountTab: () => s.setTabIndex(4),
          ),
          appBar: AppBar(
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkCard
                : Colors.white,
            foregroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : AppColors.teal800,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            leading: Builder(
              builder: (ctx) => IconButton(
                onPressed: () => Scaffold.of(ctx).openDrawer(),
                icon: Icon(
                  Icons.menu_rounded,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : AppColors.teal800,
                ),
                tooltip: 'پێڕست و ناساندن',
              ),
            ),
            title: Text(
              'فێرگەی ڕێبوون',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.teal400
                    : AppColors.teal800,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => openGlobalSearchSheet(
                  context,
                  s,
                  onOpenAccountTab: () => s.setTabIndex(4),
                ),
                icon: Icon(
                  Icons.search_rounded,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : AppColors.teal800,
                ),
                tooltip: 'گەڕان',
              ),
              Stack(
                children: [
                  IconButton(
                    onPressed: () => openNotificationsSheet(context, s),
                    icon: Icon(
                      Icons.notifications_none_rounded,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppColors.teal800,
                    ),
                    tooltip: 'ئاگادارکردنەوەکان',
                  ),
                  if (unread > 0)
                    Positioned(
                      top: 9,
                      right: 9,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: AppColors.rose600,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          body: IndexedStack(
            index: s.currentTabIndex,
            children: pages,
          ),
          bottomNavigationBar: _ReboonBottomNavBar(
            currentIndex: s.currentTabIndex,
            favCount: s.favoriteKeys.length,
            onTap: s.setTabIndex,
          ),
        );
      },
    );
  }
}

/// Exact 5-tab Bottom Navigation Bar matching Image 3 & Image 4 (#15686C + silver/white icons):
/// Right-to-Left (RTL):
/// 0: سەنەدەکان | 1: ئەکادیمیا | 2: فێرگەی ڕێبوون (official logo) | 3: وانە دڵخوازەکان | 4: هەژمار
class _ReboonBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final int favCount;
  final ValueChanged<int> onTap;

  const _ReboonBottomNavBar({
    required this.currentIndex,
    required this.favCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    const inactiveTint = Color(0xFFD5DADB);
    const activeTint = Colors.white;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.teal800,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(4, 7, 4, bottomPad > 0 ? bottomPad : 7),
      child: Row(
        children: [
          _NavItem(
            label: 'سەنەدەکان',
            assetPath: 'assets/images/icons/nav_sanad.png',
            active: currentIndex == 0,
            activeColor: activeTint,
            inactiveColor: inactiveTint,
            onTap: () => onTap(0),
          ),
          _NavItem(
            label: 'ئەکادیمیا',
            assetPath: 'assets/images/icons/nav_academy.png',
            active: currentIndex == 1,
            activeColor: activeTint,
            inactiveColor: inactiveTint,
            onTap: () => onTap(1),
          ),
          _NavItem(
            label: 'فێرگەی ڕێبوون',
            assetPath: 'assets/images/icons/nav_reboon.png',
            active: currentIndex == 2,
            activeColor: activeTint,
            inactiveColor: inactiveTint,
            iconSize: 28,
            onTap: () => onTap(2),
          ),
          _NavItem(
            label: 'وانە دڵخوازەکان',
            assetPath: 'assets/images/icons/nav_favorites.png',
            active: currentIndex == 3,
            activeColor: activeTint,
            inactiveColor: inactiveTint,
            badgeCount: favCount > 0 ? favCount : null,
            onTap: () => onTap(3),
          ),
          _NavItem(
            label: 'هەژمار',
            assetPath: 'assets/images/icons/nav_account.png',
            active: currentIndex == 4,
            activeColor: activeTint,
            inactiveColor: inactiveTint,
            onTap: () => onTap(4),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final String assetPath;
  final bool active;
  final Color activeColor;
  final Color inactiveColor;
  final double iconSize;
  final int? badgeCount;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.assetPath,
    required this.active,
    required this.activeColor,
    required this.inactiveColor,
    this.iconSize = 26,
    this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tint = active ? activeColor : inactiveColor;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white.withValues(alpha: 0.14)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: Center(
                        child: Image.asset(
                          assetPath,
                          width: iconSize,
                          height: iconSize,
                          color: tint,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                  ),
                  if (badgeCount != null)
                    Positioned(
                      top: -2,
                      left: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.rose600,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          toKurdishDigits(badgeCount!),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    color: tint,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 10.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

