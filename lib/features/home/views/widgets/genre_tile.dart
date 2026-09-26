import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../data/models/genre_model.dart';

const _genreIcons = <String, IconData>{
  'ngon-tinh': Icons.favorite_rounded,
  'dam-my': Icons.people_alt_rounded,
  'co-dai': Icons.temple_buddhist_rounded,
  'co-trang': Icons.temple_buddhist_rounded,
  'hien-dai': Icons.location_city_rounded,
  'xuyen-khong': Icons.all_inclusive_rounded,
  'hai-huoc': Icons.sentiment_very_satisfied_rounded,
  'bi-an': Icons.search_rounded,
  'kinh-di': Icons.nights_stay_rounded,
  'chua-lanh': Icons.spa_rounded,
  'bao-thu': Icons.local_fire_department_rounded,
  'cung-dau': Icons.castle_rounded,
  'trong-sinh': Icons.autorenew_rounded,
  'tong-tai': Icons.business_center_rounded,
  'kiem-hiep': Icons.sports_martial_arts_rounded,
  'hoc-duong': Icons.school_rounded,
  'huyen-huyen': Icons.auto_awesome_rounded,
};

IconData genreIcon(String slug) => _genreIcons[slug] ?? Icons.local_library_rounded;

void openGenre(GenreModel genre) => Get.toNamed(AppRoutes.genre, arguments: genre);

class GenreTile extends StatelessWidget {
  const GenreTile({super.key, required this.genre, required this.index});

  final GenreModel genre;
  final int index;

  @override
  Widget build(BuildContext context) {
    final tint = AppColors.genreTints[index % AppColors.genreTints.length];
    final ink = AppColors.genreInks[index % AppColors.genreInks.length];
    return GestureDetector(
      onTap: () => openGenre(genre),
      child: Container(
        width: 84,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(14)),
        child: Column(
          children: [
            if (genre.icon?.isNotEmpty ?? false)
              Text(genre.icon!, style: const TextStyle(fontSize: 26))
            else
              Icon(genreIcon(genre.slug), size: 28, color: ink),
            const SizedBox(height: 8),
            Text(
              genre.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink),
            ),
          ],
        ),
      ),
    );
  }
}
