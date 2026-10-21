import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../dialogs/photo_viewer_dialog.dart';
import '../theme/app_theme.dart';

class RoundPhotoPickerCard extends StatelessWidget {
  final String label;
  final Uint8List? bytes;
  final String? existingUrl;
  final IconData icon;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const RoundPhotoPickerCard({
    super.key,
    required this.label,
    required this.bytes,
    required this.existingUrl,
    required this.icon,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasImage = bytes != null || existingUrl != null;

    return GestureDetector(
      onTap: () {
        if (hasImage) {
          showFullPhotoDialog(context, bytes: bytes, url: existingUrl);
        } else {
          onPick();
        }
      },
      child: Container(
        width: double.infinity,
        height: 130,
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
          image: hasImage
              ? DecorationImage(
                  image: bytes != null
                      ? MemoryImage(bytes!) as ImageProvider
                      : NetworkImage(existingUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: !hasImage
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 32, color: AppColors.textSecondary),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Tap to add photo',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              )
            : Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.black54,
                        radius: 16,
                        child: IconButton(
                          icon: const Icon(
                            Icons.fullscreen,
                            size: 16,
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.zero,
                          tooltip: 'View full photo',
                          onPressed: () => showFullPhotoDialog(
                            context,
                            bytes: bytes,
                            url: existingUrl,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Colors.black54,
                        radius: 16,
                        child: IconButton(
                          icon: const Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.zero,
                          tooltip: 'Change photo',
                          onPressed: onPick,
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Colors.black54,
                        radius: 16,
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.zero,
                          tooltip: 'Remove',
                          onPressed: onRemove,
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

class RoundPhotoThumbnail extends StatelessWidget {
  final String url;
  final String label;
  final IconData icon;

  const RoundPhotoThumbnail({
    super.key,
    required this.url,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => showFullPhotoDialog(context, url: url),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              url,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.grey.shade400,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) =>
                  Icon(icon, size: 24, color: Colors.grey.shade400),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 2),
                color: Colors.black.withValues(alpha: 0.55),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
