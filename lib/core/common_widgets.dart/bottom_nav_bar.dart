// ignore_for_file: library_private_types_in_public_api

import 'dart:developer';

import 'package:ProductPlug/core/cache.dart';
import 'package:ProductPlug/core/helpers/auth_gate_helper.dart';
import 'package:ProductPlug/core/themes/constantsColors.dart';
import 'package:ProductPlug/presentation/providers/auth_provider.dart';
import 'package:ProductPlug/presentation/providers/cache_provider.dart';
import 'package:ProductPlug/presentation/screens/cart_screen/cart_screen.dart';
import 'package:ProductPlug/presentation/screens/fav_screen/fav_screen.dart';
import 'package:ProductPlug/presentation/screens/home_screen/home_screen.dart';
import 'package:ProductPlug/presentation/screens/notification_screen/notification_screen.dart';
import 'package:ProductPlug/presentation/screens/profile_screen/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  Map<String, String?>? profileData;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final cache = CacheService();
    final data = await cache.loadCachedProfile();
    setState(() {
      profileData = data;
    });
  }

  final List<Widget Function()> _screens = [
    () => const HomeScreen(),
    () => const FavScreen(),
    () => const CartScreen(),
    () => const NotificationScreen(),
    () => const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    // ✅ Check authentication for restricted tabs
    // Index 0 = Home (public)
    // Index 1 = Favorites (requires auth)
    // Index 2 = Cart (requires auth)
    // Index 3 = Notifications (requires auth)
    // Index 4 = Profile (requires auth)

    if (index > 0) {
      // Check if user is authenticated
      final isAuthenticated = AuthGateHelper.checkAuthAndPrompt(
        context,
        actionMessage: _getAuthMessageForTab(index),
        onLoginSuccess: () {
          // Navigate to the tab after successful login
          setState(() => _selectedIndex = index);
        },
      );

      // If already authenticated, navigate immediately
      if (isAuthenticated) {
        setState(() => _selectedIndex = index);
      }
    } else {
      // Home tab is always accessible
      setState(() => _selectedIndex = index);
    }
  }

  String _getAuthMessageForTab(int index) {
    switch (index) {
      case 1:
        return 'Please sign in to view your favorites.\n\nCreate an account to save products you love.';
      case 2:
        return 'Please sign in to view your cart.\n\nCreate an account to save items and checkout.';
      case 3:
        return 'Please sign in to view notifications.\n\nCreate an account to stay updated.';
      case 4:
        return 'Please sign in to access your profile.\n\nCreate an account to manage your orders and settings.';
      default:
        return 'Please sign in to continue.';
    }
  }

  BottomNavigationBarItem _buildNavItem(dynamic iconData, int index) {
    final isSelected = _selectedIndex == index;
    Widget iconWidget;

    if (iconData is IconData) {
      iconWidget = Icon(
        iconData,
        color: isSelected ? KprimaryColor : Colors.grey,
        size: 28,
      );
    } else if (iconData is String && iconData.endsWith(".png")) {
      iconWidget = Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Image.asset(iconData),
      );
    } else if (iconData is Widget) {
      iconWidget = iconData;
    } else {
      iconWidget = const Icon(Icons.circle); // fallback
    }

    return BottomNavigationBarItem(label: '', icon: iconWidget);
  }

  @override
  Widget build(BuildContext context) {
    final cache = context.watch<CacheProvider>();
    final auth = context.watch<AuthProvider>();

    // ✅ Auto-reset to Home (Index 0) if logged out
    int displayedIndex = _selectedIndex;
    if (!auth.isLoggedIn && _selectedIndex != 0) {
      displayedIndex = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
        }
      });
    }

    final profileImageUrl = cache.imageUrl;
    log('[Profile Setup Provider] from nav bar ${profileData?['imageUrl']}');
    final List<dynamic> icons = [
      Icons.home,
      Icons.favorite_border_outlined,
      "assets/images/appIcon.png",
      Icons.notifications_none,
      Container(
        height: 28,
        width: 28,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: profileImageUrl != null && profileImageUrl.isNotEmpty
            ? ClipOval(
                child: Image.network(
                  profileImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.person),
                ),
              )
            : profileData?['imageUrl'] != null
                ? ClipOval(
                    child: Image.network(
                      profileData?['imageUrl'] ?? "",
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.person),
                    ),
                  )
                : const Icon(Icons.person),
      ),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: KeyedSubtree(
          key: ValueKey<int>(displayedIndex),
          child: _screens[displayedIndex](),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // The top separator line
          Container(
            height: 1, // thickness of the line
            color: KprimaryColor,
          ),
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/tabbar.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                splashFactory: NoSplash.splashFactory,
              ),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                elevation: 0,
                items: List.generate(
                  icons.length,
                  (index) => _buildNavItem(icons[index], index),
                ),
                currentIndex: displayedIndex,
                onTap: _onItemTapped,
                selectedFontSize: 0,
                unselectedFontSize: 0,
                showSelectedLabels: false,
                showUnselectedLabels: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
