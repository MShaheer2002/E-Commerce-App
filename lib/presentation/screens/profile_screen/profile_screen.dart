import 'dart:developer';

import 'package:e_commerce_app/core/cache.dart';
import 'package:e_commerce_app/core/common_widgets.dart/common_widgets.dart';
import 'package:e_commerce_app/core/themes/constantsColors.dart';
import 'package:e_commerce_app/presentation/providers/auth_provider.dart';
import 'package:e_commerce_app/presentation/providers/cache_provider.dart';
import 'package:flutter/material.dart';
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
                _buildMenuItem(
                  icon: Icons.login,
                  title: "Logout",
                  onTap: () async {
                    await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Are you sure you want to logout?'),
                        content: const Text('This action cannot be undone.'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                          ),
                          ElevatedButton(
                            child: const Text('Yes, Logout'),
                            onPressed: () async {
                              await auth.logout(context);

                              // Optionally clear cache on logout
                              final cache = CacheService();
                              await cache.clearCache();
                            },
                          ),
                        ],
                      ),
                    );
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
                  title: "Support",
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
                SizedBox(height: height * 0.02),
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
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          decoration: BoxDecoration(
            color: KprimaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: KprimaryColor,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: KprimaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: KprimaryColor,
          size: 16,
        ),
      ),
    );
  }
}
