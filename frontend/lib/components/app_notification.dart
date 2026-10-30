import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/components/font/manrope_font.dart';
import 'package:frontend/core/theme/app_colors.dart';

enum NotificationType { success, error, warning, info }

class AppNotification {
  static OverlayEntry? _currentEntry;

  static void showSuccess(
    BuildContext context, {
    String title = 'Berhasil',
    required String message,
    Duration duration = const Duration(milliseconds: 2800),
  }) {
    show(
      context,
      type: NotificationType.success,
      title: title,
      message: message,
      duration: duration,
    );
  }

  static void showError(
    BuildContext context, {
    String title = 'Gagal',
    required String message,
    Duration duration = const Duration(milliseconds: 3200),
  }) {
    show(
      context,
      type: NotificationType.error,
      title: title,
      message: message,
      duration: duration,
    );
  }

  static void show(
    BuildContext context, {
    required NotificationType type,
    required String title,
    required String message,
    Duration duration = const Duration(milliseconds: 3000),
  }) {
    _currentEntry?.remove();
    _currentEntry = null;

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _TopNotificationWidget(
        type: type,
        title: title,
        message: message,
        duration: duration,
        onDismiss: () {
          if (_currentEntry == entry) {
            entry.remove();
            _currentEntry = null;
          }
        },
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
  }
}

class _TopNotificationWidget extends StatefulWidget {
  final NotificationType type;
  final String title;
  final String message;
  final Duration duration;
  final VoidCallback onDismiss;

  const _TopNotificationWidget({
    required this.type,
    required this.title,
    required this.message,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_TopNotificationWidget> createState() => _TopNotificationWidgetState();
}

class _TopNotificationWidgetState extends State<_TopNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _offsetAnimation =
        Tween<Offset>(begin: const Offset(0.3, -1.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutBack,
            reverseCurve: Curves.easeInBack,
          ),
        );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    _controller.forward();

    _dismissTimer = Timer(widget.duration, () {
      _dismiss();
    });
  }

  void _dismiss() async {
    if (!mounted) return;
    _dismissTimer?.cancel();
    await _controller.reverse();
    if (mounted) {
      widget.onDismiss();
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color badgeColor;
    final Color borderColor;
    final IconData iconData;

    switch (widget.type) {
      case NotificationType.success:
        badgeColor = AppColors.primary;
        borderColor = AppColors.primary.withValues(alpha: 0.25);
        iconData = Icons.check_circle_rounded;
        break;
      case NotificationType.error:
        badgeColor = const Color(0xFFDC2626);
        borderColor = const Color(0xFFDC2626).withValues(alpha: 0.25);
        iconData = Icons.error_rounded;
        break;
      case NotificationType.warning:
        badgeColor = const Color(0xFFF59E0B);
        borderColor = const Color(0xFFF59E0B).withValues(alpha: 0.25);
        iconData = Icons.warning_rounded;
        break;
      case NotificationType.info:
        badgeColor = AppColors.secondary;
        borderColor = AppColors.secondary.withValues(alpha: 0.25);
        iconData = Icons.info_rounded;
        break;
    }

    final screenWidth = MediaQuery.of(context).size.width;
    // Ukuran notifikasi setengah lebar dan berada di ujung kanan
    final maxCardWidth = (screenWidth * 0.52).clamp(280.0, 380.0);

    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 12, right: 16, left: 16),
          child: SlideTransition(
            position: _offsetAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: _dismiss,
                  onVerticalDragUpdate: (details) {
                    if (details.primaryDelta != null &&
                        details.primaryDelta! < -4) {
                      _dismiss();
                    }
                  },
                  child: Container(
                    constraints: BoxConstraints(maxWidth: maxCardWidth),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: badgeColor.withValues(alpha: 0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(iconData, color: badgeColor, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ManropeFont(
                                widget.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.5,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              ManropeFont(
                                widget.message,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: Colors.grey.shade400,
                          ),
                          onPressed: _dismiss,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
