import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import 'common_widgets.dart';

/// Opens any uploaded video, audio, PDF, or attachment URL cleanly.
Future<void> openUploadedMediaUrl(
  BuildContext context,
  String url, {
  String? fallbackMessage,
}) async {
  final trimmed = url.trim();
  if (trimmed.isEmpty) {
    if (fallbackMessage != null && context.mounted) {
      showReboonToast(context, fallbackMessage);
    }
    return;
  }
  final uri = Uri.tryParse(trimmed);
  if (uri != null && await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else if (context.mounted) {
    showReboonToast(
      context,
      fallbackMessage ?? 'کردنەوەی فایل: $trimmed',
    );
  }
}

/// Renders either a Data URI (`data:image/...;base64,...`) or an HTTP/HTTPS URL,
/// gracefully falling back to [fallback] whenever empty or failing to load.
class SmartUploadedImage extends StatelessWidget {
  final String imageUrl;
  final Widget fallback;
  final BoxFit fit;
  final Alignment alignment;

  const SmartUploadedImage({
    super.key,
    required this.imageUrl,
    required this.fallback,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  Uint8List? _tryDecodeDataUri(String raw) {
    final idx = raw.indexOf('base64,');
    if (idx < 0) return null;
    try {
      return base64Decode(raw.substring(idx + 7));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final trimmed = imageUrl.trim();
    if (trimmed.isEmpty) return fallback;

    if (trimmed.startsWith('data:image/')) {
      final bytes = _tryDecodeDataUri(trimmed);
      if (bytes == null || bytes.isEmpty) return fallback;
      return Image.memory(
        bytes,
        fit: fit,
        alignment: alignment,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, _, _) => fallback,
      );
    }

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return Image.network(
        trimmed,
        fit: fit,
        alignment: alignment,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, _, _) => fallback,
      );
    }

    return fallback;
  }
}

/// Compact row of clickable action chips for uploaded Video, Audio, PDF, and Attachments.
class MediaAttachmentsBar extends StatelessWidget {
  final String videoUrl;
  final String audioUrl;
  final String pdfUrl;
  final String attachmentUrl;
  final Color accentColor;
  final bool darkSurface;

  const MediaAttachmentsBar({
    super.key,
    this.videoUrl = '',
    this.audioUrl = '',
    this.pdfUrl = '',
    this.attachmentUrl = '',
    this.accentColor = AppColors.teal700,
    this.darkSurface = false,
  });

  bool get hasAny =>
      videoUrl.trim().isNotEmpty ||
      audioUrl.trim().isNotEmpty ||
      pdfUrl.trim().isNotEmpty ||
      attachmentUrl.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!hasAny) return const SizedBox.shrink();

    Widget buildBtn(IconData icon, String label, String url, Color color) {
      return ActionChip(
        avatar: Icon(icon, size: 16, color: darkSurface ? Colors.white : color),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: darkSurface ? Colors.white : color,
          ),
        ),
        backgroundColor: darkSurface
            ? color.withValues(alpha: 0.35)
            : color.withValues(alpha: 0.1),
        side: BorderSide(
          color: darkSurface
              ? Colors.white.withValues(alpha: 0.28)
              : color.withValues(alpha: 0.3),
        ),
        onPressed: () => openUploadedMediaUrl(context, url),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        if (videoUrl.trim().isNotEmpty)
          buildBtn(Icons.play_circle_fill_rounded, '🎬 بینینی ڤیدیۆ', videoUrl,
              accentColor),
        if (audioUrl.trim().isNotEmpty)
          buildBtn(Icons.headphones_rounded, '🎧 گوێگرتن لە دەنگ', audioUrl,
              const Color(0xFF0284C7)),
        if (pdfUrl.trim().isNotEmpty)
          buildBtn(Icons.picture_as_pdf_rounded, '📄 فایلی PDF', pdfUrl,
              const Color(0xFFD97706)),
        if (attachmentUrl.trim().isNotEmpty)
          buildBtn(Icons.attach_file_rounded, '📎 فایلی هاوپێچ', attachmentUrl,
              const Color(0xFF7C3AED)),
      ],
    );
  }
}
