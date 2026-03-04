import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/alert_model.dart';
import '../theme/colors.dart';

class AlertCard extends StatelessWidget {
  final AlertModel alert;
  final VoidCallback onTap;
  
  const AlertCard({
    super.key,
    required this.alert,
    required this.onTap,
  });

  Color _getGradientColor() {
    switch (alert.type) {
      case 'match':
        return AppColors.success;
      case 'claimed':
        return AppColors.primary;
      case 'nearby':
        return AppColors.warning;
      default:
        return AppColors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: alert.read 
              ? AppColors.outlineVariant 
              : AppColors.primary.withValues(alpha:0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: alert.imageUrl ?? 'https://via.placeholder.com/60',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 60,
                          height: 60,
                          color: AppColors.surfaceVariant,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 60,
                          height: 60,
                          color: AppColors.surfaceVariant,
                          child: const Icon(Icons.broken_image, size: 30),
                        ),
                      ),
                    ),
                    if (!alert.read)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                            border: Border.fromBorderSide(
                              BorderSide(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              alert.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: alert.read ? FontWeight.w600 : FontWeight.bold,
                                color: alert.read ? AppColors.onSurfaceVariant : AppColors.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getGradientColor(), 
                                  _getGradientColor().withBlue(200)
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              alert.type[0].toUpperCase() + alert.type.substring(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        alert.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: alert.read ? AppColors.mutedForeground : AppColors.onSurfaceVariant,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              alert.location,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '•',
                            style: TextStyle(color: AppColors.mutedForeground),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.access_time,
                            size: 10,
                            color: AppColors.mutedForeground,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            alert.formattedTime,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}