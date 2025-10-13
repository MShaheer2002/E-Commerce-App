import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileRoute extends StatelessWidget {
  final Widget child;

  const ProfileRoute({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final state = GoRouterState.of(context);
    final currentIndex = _calculateIndex(state);
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/profile');
              break;
            case 2:
              context.go('/cart');
              break;
            case 3:
              context.go('/notification');
              break;
            case 4:
              context.go('/settings');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: Colors.red,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
              icon: Icon(Icons.card_travel_outlined), label: 'cart'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'notification'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'settings'),
        ],
      ),
    );
  }

  int _calculateIndex(GoRouterState state) {
    final location = state.matchedLocation;
    if (location.startsWith('/')) return 0;
    if (location.startsWith('/profile')) return 1;
    return 0;
  }
}
