import 'package:e_commerce_app/core/common_widgets.dart/bottom_nav_bar.dart';
import 'package:e_commerce_app/core/common_widgets.dart/common_widgets.dart';
import 'package:e_commerce_app/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    // final user = auth.user;

    return Scaffold(
      body: Background(
          child: Stack(
        children: [
          BottomNavBar(),
        ],
      )),
    );
  }
}



//  showDialog<bool>(
//                 context: context,
//                 builder: (context) => AlertDialog(
//                   title: const Text('Are you sure you want to logout?'),
//                   content: const Text('This action cannot be undone.'),
//                   actions: <Widget>[
//                     TextButton(
//                       child: const Text('Cancel'),
//                       onPressed: () {
//                         Navigator.of(context).pop(false);
//                       },
//                     ),
//                     ElevatedButton(
//                       child: const Text('Yes, Logout'),
//                       onPressed: () {
//                         auth.logout();
//                         Navigator.of(context).pop(true);
//                       },
//                     ),
//                   ],
//                 ),
//               );