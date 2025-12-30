import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ProductPlug/core/common_widgets.dart/common_widgets.dart';
import 'package:ProductPlug/core/providers/notification_provider.dart';
import 'package:ProductPlug/core/themes/constantsColors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      // body: CustomBackground(child: Container()),
      body: Background(
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: height * 0.015),
              // Centered Image
              Center(
                child: Image.asset(
                  "assets/images/titles/drops_cleaned.png",
                  height: 50,
                ),
              ),

              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: provider.notificationStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final notifications = snapshot.data!.docs;
                    if (notifications.isEmpty) {
                      return const Center(child: Text('No notifications yet.'));
                    }

                    return ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final doc = notifications[index].data();
                        return buildNotificationItem(
                            username: doc['title'] ?? 'No title',
                            action: "",
                            timeAgo: (doc['timestamp'] as Timestamp?)
                                    ?.toDate()
                                    .toLocal()
                                    .toString()
                                    .split('.')[0] ??
                                '',
                            avatarUrl:
                                "https://img.freepik.com/free-photo/bottle-coconut-water-put-dark-background_1150-28239.jpg",
                            commentText: doc['body'] ?? '');
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNotificationItem({
    required String username,
    required String action,
    required String timeAgo,
    required String avatarUrl,
    String? previewImageUrl,
    String? commentText,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: avatarUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: avatarUrl,
                        fit: BoxFit.cover,
                        errorWidget: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade800,
                            child: Icon(
                              Icons.person,
                              color: Colors.grey.shade600,
                              size: 24,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey.shade800,
                        child: Icon(
                          Icons.person,
                          color: Colors.grey.shade600,
                          size: 24,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          username,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: KprimaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  if (commentText != null && commentText.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        commentText,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Preview Image (if available)
            if (previewImageUrl != null && previewImageUrl.isNotEmpty) ...[
              const SizedBox(width: 12),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: CachedNetworkImage(
                    imageUrl: previewImageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade800,
                        child: Icon(
                          Icons.image,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
