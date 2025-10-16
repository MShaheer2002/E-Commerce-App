import 'package:e_commerce_app/core/common_widgets.dart/common_widgets.dart';
import 'package:e_commerce_app/core/themes/constantsColors.dart';
import 'package:e_commerce_app/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    final auth = context.read<AuthProvider>();
    final user = auth.user;

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
                _buildProfileHeader(context, height, width),

                SizedBox(height: height * 0.03),

                // Account Section
                _buildSectionTitle("Account"),
                SizedBox(height: height * 0.01),
                _buildMenuItem(
                  icon: Icons.edit,
                  title: "Edit Profile",
                  onTap: () {
                    // Navigate to edit profile
                  },
                ),
                _buildMenuItem(
                  icon: Icons.notifications_outlined,
                  title: "Notification",
                  onTap: () {
                    // Navigate to notifications
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
                            onPressed: () {
                              auth.logout();
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
                  icon: Icons.settings_outlined,
                  title: "Settings",
                  onTap: () {
                    // Navigate to settings
                  },
                ),
                _buildMenuItem(
                  icon: Icons.security_outlined,
                  title: "Security",
                  onTap: () {
                    // Navigate to security
                  },
                ),
                _buildMenuItem(
                  icon: Icons.privacy_tip_outlined,
                  title: "Privacy Policy",
                  onTap: () {
                    // Navigate to privacy policy
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

  Widget _buildProfileHeader(
      BuildContext context, double height, double width) {
    return Container(
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Profile Avatar
          Container(
            height: 60,
            width: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF00D4FF), Color(0xFF00FFB9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),

          SizedBox(width: width * 0.04),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "HS1 Matty",
                  style: TextStyle(
                    color: KprimaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "hs1matty@gmail.com",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Edit Icon
          IconButton(
            onPressed: () {
              // Navigate to edit profile
            },
            icon: const Icon(
              Icons.edit_outlined,
              color: Colors.grey,
              size: 24,
            ),
          ),
        ],
      ),
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
            color: KprimaryColor.withOpacity(0.1),
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
