import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../utils/extensions.dart';

class CoverImage extends StatelessWidget {
  const CoverImage(this.path, {super.key, this.width, this.height, this.radius = 10, this.fit = BoxFit.cover});

  final String? path;
  final double? width;
  final double? height;
  final double radius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final url = path.imageUrl;
    const placeholder = ColoredBox(
      color: AppColors.primarySoft,
      child: Center(child: Icon(Icons.auto_stories_rounded, color: AppColors.primary, size: 28)),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: width,
        height: height,
        child: url == null
            ? placeholder
            : CachedNetworkImage(
                imageUrl: url,
                fit: fit,
                fadeInDuration: const Duration(milliseconds: 200),
                placeholder: (_, _) => const ColoredBox(color: AppColors.line),
                errorWidget: (_, _, _) => placeholder,
              ),
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, this.url, required this.name, this.size = 40});

  final String? url;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final image = url.imageUrl;
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.primarySoft,
      foregroundImage: image == null ? null : CachedNetworkImageProvider(image),
      child: Text(
        name.isEmpty ? '?' : name.characters.first.toUpperCase(),
        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: size * 0.4),
      ),
    );
  }
}
