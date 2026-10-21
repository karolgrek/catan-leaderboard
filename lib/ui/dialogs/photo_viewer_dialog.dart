import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_strings.dart';

void showFullPhotoDialog(
  BuildContext context, {
  Uint8List? bytes,
  String? url,
}) {
  if (bytes == null && url == null) return;
  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
            child: InteractiveViewer(
              child: bytes != null
                  ? Image.memory(bytes, fit: BoxFit.contain)
                  : Image.network(
                      url!,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: double.infinity,
                          height: 300,
                          color: Colors.black54,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: double.infinity,
                        height: 200,
                        color: Colors.grey.shade900,
                        child: const Center(
                          child: Text(
                            AppStrings.failedToLoadImage,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
