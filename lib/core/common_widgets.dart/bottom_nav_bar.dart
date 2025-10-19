import 'package:e_commerce_app/core/themes/constantsColors.dart';
import 'package:e_commerce_app/presentation/screens/add_product_screen/add_product_screen.dart';
import 'package:e_commerce_app/presentation/screens/cart_screen/cart_screen.dart';
import 'package:e_commerce_app/presentation/screens/home_screen/home_screen.dart';
import 'package:e_commerce_app/presentation/screens/notification_screen/notification_screen.dart';
import 'package:e_commerce_app/presentation/screens/profile_screen/profile_screen.dart';
import 'package:e_commerce_app/presentation/screens/search_screen/search_screen.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  final List<Widget Function()> _screens = [
    () => const HomeScreen(),
    () => const SearchScreen(),
    () => const CartScreen(),
    () => const NotificationScreen(),
    () => const ProfileScreen(),
  ];

  final List<dynamic> _icons = [
    Icons.home,
    Icons.search,
    "assets/images/appIcon.png",
    Icons.notifications_none,
    Container(
      height: 28,
      width: 28,
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: Icon(Icons.person),
    )
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
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
    } else if (iconData is String) {
      iconWidget = Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Image.asset(
          iconData,
        ),
      );
    } else {
      iconWidget = iconData;
    }

    return BottomNavigationBarItem(
      label: '',
      icon: iconWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex](),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/tabbar.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          items: List.generate(
            _icons.length,
            (index) => _buildNavItem(_icons[index], index),
          ),
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedFontSize: 0,
          unselectedFontSize: 0,
          showSelectedLabels: false,
          showUnselectedLabels: false,
        ),
      ),
    );
  }
}
