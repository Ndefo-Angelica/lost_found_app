import 'package:flutter/material.dart';
import '../theme/colors.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool expanded;
  final double height;
  final IconData? icon;
  final List<Color>? colors;
  final Color? textColor;
  
  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.expanded = true,
    this.height = 56,
    this.icon,
    this.colors,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors = colors ?? [AppColors.primary, AppColors.primaryDark];
    final buttonTextColor = textColor ?? Colors.white;
    
    return Container(
      width: expanded ? double.infinity : null,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha:0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: buttonTextColor),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: TextStyle(
                    color: buttonTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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