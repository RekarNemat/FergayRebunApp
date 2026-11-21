import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Official calligraphic vertical pill emblem of "ڕێبوون" using the authentic
/// brand asset extracted from the official Reboon Organization logo.
class ReboonEmblem extends StatelessWidget {
  final double height;
  final Color backgroundColor;
  final Color strokeColor;

  const ReboonEmblem({
    super.key,
    this.height = 36,
    this.backgroundColor = AppColors.gold,
    this.strokeColor = AppColors.teal800,
  });

  @override
  Widget build(BuildContext context) {
    final bool useGold =
        backgroundColor.toARGB32() == AppColors.gold.toARGB32() ||
        backgroundColor.toARGB32() == AppColors.amber500.toARGB32() ||
        backgroundColor.toARGB32() == AppColors.amber400.toARGB32();
    final String assetPath = useGold
        ? 'assets/images/reboon_emblem_gold.png'
        : 'assets/images/reboon_emblem_green.png';

    return SizedBox(
      width: height * 0.47,
      height: height,
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

class TeacherAvatarBubble extends StatelessWidget {
  final String name;
  final double size;
  final Color colorStart;
  final Color colorEnd;
  final bool showOnlineDot;

  const TeacherAvatarBubble({
    super.key,
    required this.name,
    this.size = 32,
    this.colorStart = AppColors.teal600,
    this.colorEnd = AppColors.teal800,
    this.showOnlineDot = true,
  });

  String _initials(String raw) {
    final clean = raw
        .replaceFirst(RegExp(r'^(د\.|م\.|الشيخ|الأستاذ)\s*'), '')
        .trim();
    final parts = clean.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}.${parts[1][0]}';
    }
    return clean.isNotEmpty ? clean.characters.take(2).toString() : 'ڕ';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colorStart, colorEnd],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.9),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              _initials(name),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: size * 0.34,
                height: 1.0,
              ),
            ),
          ),
          if (showOnlineDot)
            Positioned(
              bottom: -1,
              left: -1,
              child: Container(
                width: size * 0.32,
                height: size * 0.32,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Decorative classical Islamic book cover with spine & ornament
class StylizedBookCover extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final double width;
  final double height;
  final String? badge;

  const StylizedBookCover({
    super.key,
    required this.title,
    this.subtitle = '',
    required this.color,
    this.width = 110,
    this.height = 148,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final darker = Color.lerp(color, Colors.black, 0.35) ?? color;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [color, darker],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.28),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Spine line on the right (RTL book spine)
          Positioned(
            top: 0,
            bottom: 0,
            right: 8,
            child: Container(
              width: 2,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          // Inner ornamental frame
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.amber400.withValues(alpha: 0.55),
                  width: 1.2,
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 12, 14, 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.amber400.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.amber400,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  const Icon(
                    Icons.auto_stories_rounded,
                    color: AppColors.amber400,
                    size: 18,
                  ),
                Expanded(
                  child: Center(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: width * 0.115,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

