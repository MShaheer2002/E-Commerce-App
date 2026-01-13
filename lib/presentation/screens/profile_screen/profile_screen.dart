import 'dart:async';
import 'dart:developer';

import 'package:ProductPlug/core/common_widgets.dart/common_widgets.dart';
import 'package:ProductPlug/core/providers/cart_provider.dart';
import 'package:ProductPlug/core/providers/checkout_provider.dart';
import 'package:ProductPlug/core/providers/fav_provider.dart';
import 'package:ProductPlug/core/providers/notification_provider.dart';
import 'package:ProductPlug/core/themes/constantsColors.dart';
import 'package:ProductPlug/presentation/providers/auth_provider.dart';
import 'package:ProductPlug/presentation/providers/cache_provider.dart';
import 'package:ProductPlug/presentation/providers/profile_setup_provider.dart';
import 'package:ProductPlug/presentation/screens/profile_screen/widgets/delete_account_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // ignore: use_build_context_synchronously
    Future.microtask(() => context.read<CacheProvider>().loadCachedProfile());
  }

  // Future<void> _loadProfile() async {
  //   final cache = CacheService();
  //   final data =
  //       await cache.loadCachedProfile(); // return a Map<String, String>
  //   setState(() {
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    final auth = context.read<AuthProvider>();

    return Scaffold(
      appBar: customAppBar(
          context: context, title: "Profile", showBackButton: false),
      body: Background(
        showBackButton: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.06),
            child: Column(
              children: [
                SizedBox(height: height * 0.03),

                // Profile Header Section
                _buildProfileHeader(),

                SizedBox(height: height * 0.03),

                // Account Section
                _buildSectionTitle("Account"),
                SizedBox(height: height * 0.01),
                _buildMenuItem(
                  icon: Icons.edit,
                  title: "Edit Profile",
                  onTap: () {
                    context.push("/profile-setup");
                  },
                ),
                SizedBox(height: height * 0.01),
                _buildMenuItem(
                  icon: Icons.history_edu_outlined,
                  title: "Order History",
                  onTap: () {
                    context.push('/order-status');
                  },
                ),
                SizedBox(height: height * 0.01),

                SizedBox(height: height * 0.01),
                _buildMenuItem(
                  icon: Icons.login,
                  title: "Logout",
                  onTap: () async {
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.grey[900],
                        title: const Text(
                          'Are you sure you want to logout?',
                          style: TextStyle(color: Colors.white),
                        ),
                        content: const Text('This action cannot be undone.',
                            style: TextStyle(
                              color: Colors.white,
                            )),
                        actions: <Widget>[
                          TextButton(
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                          ),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all(Colors.grey.shade800),
                            ),
                            child: const Text(
                              'Yes, Logout',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                          ),
                        ],
                      ),
                    );

                    if (shouldLogout == true && context.mounted) {
                      // 1. Clear State Providers while context is available
                      context.read<CacheProvider>().clearProfile();
                      context.read<CartProvider>().clearLocalData();
                      context.read<FavoriteService>().clearFavorites();
                      context.read<CheckoutProvider>().clearCheckoutData();
                      context.read<ProfileSetupProvider>().clearData();

                      // Handle notification cleanup asynchronously
                      unawaited(context
                          .read<NotificationProvider>()
                          .clearNotifications());

                      // 2. Show success message
                      Fluttertoast.showToast(
                        msg: "Logged out successfully",
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                      );

                      // 3. Perform Auth Logout (Navigates away)
                      await auth.logout(context);
                    }
                  },
                ),

                SizedBox(height: height * 0.03),

                // General Section
                _buildSectionTitle("General"),
                SizedBox(height: height * 0.01),

                _buildMenuItem(
                  icon: Icons.privacy_tip_outlined,
                  title: "Privacy Policy",
                  onTap: () {
                    log('Privacy Policy tapped');
                    context.push("/webview",
                        extra:
                            "https://shaheerprojectsflutter.github.io/productplug-legal/privacy_policy.html");
                  },
                ),

                _buildMenuItem(
                  icon: Icons.support_agent_rounded,
                  title: "Support Center",
                  onTap: () {
                    log('Support');
                    context.push("/webview",
                        extra:
                            "https://shaheerprojectsflutter.github.io/productplug-legal/terms.html");
                  },
                ),
                _buildMenuItem(
                  icon: Icons.security_outlined,
                  title: "Terms and Condition",
                  onTap: () {
                    log('Terms of Service tapped');
                    context.push("/webview",
                        extra:
                            "https://shaheerprojectsflutter.github.io/productplug-legal/terms_and_condition.html");
                  },
                ),
                _buildMenuItem(
                  icon: Icons.security_outlined,
                  title: "Policy Center",
                  onTap: () {
                    log('Policy Center tapped');
                    context.push("/webview",
                        extra:
                            "https://shaheerprojectsflutter.github.io/productplug-legal/policy_center.html");
                  },
                ),
                SizedBox(height: height * 0.02),

                Center(
                  child: TextButton(
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (context) => DeleteAccountDialog(
                          onConfirm: () async {
                            try {
                              Fluttertoast.showToast(
                                msg: "Deleting account...",
                                backgroundColor: Colors.orange,
                                textColor: Colors.white,
                              );

                              // Clear all local states before/during deletion
                              if (context.mounted) {
                                context.read<CacheProvider>().clearProfile();
                                context.read<CartProvider>().clearLocalData();
                                context
                                    .read<FavoriteService>()
                                    .clearFavorites();
                                context
                                    .read<CheckoutProvider>()
                                    .clearCheckoutData();
                                context
                                    .read<ProfileSetupProvider>()
                                    .clearData();
                                unawaited(context
                                    .read<NotificationProvider>()
                                    .clearNotifications());
                              }

                              // Delete account (Navigation happens automatically via provider)
                              await auth.deleteAccount();

                              // Show success message
                              Fluttertoast.showToast(
                                msg: "Account deleted successfully",
                                backgroundColor: Colors.green,
                                textColor: Colors.white,
                              );
                            } on firebase.FirebaseAuthException catch (e) {
                              Fluttertoast.showToast(
                                msg: e.message ?? "Failed to delete account",
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                              );
                            } catch (e) {
                              Fluttertoast.showToast(
                                msg: "An error occurred. Please try again.",
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                              );
                            }
                          },
                        ),
                      );
                    },
                    child: const Text(
                      "Delete Account",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final profileCache = context.watch<CacheProvider>();

    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage:
              profileCache.imageUrl != null && profileCache.imageUrl!.isNotEmpty
                  ? NetworkImage(profileCache.imageUrl!)
                  : null,
          child: profileCache.imageUrl == null || profileCache.imageUrl!.isEmpty
              ? const Icon(Icons.person, size: 30, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              profileCache.name ?? "Guest User",
              style: const TextStyle(
                color: KprimaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              profileCache.email ?? "No email found",
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          decoration: BoxDecoration(
            color: (iconColor ?? KprimaryColor).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor ?? KprimaryColor,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: titleColor ?? KprimaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: titleColor ?? KprimaryColor,
          size: 16,
        ),
      ),
    );
  }
}
