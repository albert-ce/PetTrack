import 'package:flutter/material.dart';
import 'package:pet_track/components/feed_button.dart';
import 'package:pet_track/core/app_colors.dart';
import 'package:pet_track/core/app_styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class PetCard extends StatelessWidget {
  final Map<String, dynamic> petData;
  final VoidCallback? onTap;

  const PetCard({Key? key, required this.petData, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final name = petData['name'] ?? 'Sense nom';
    final breed = petData['breed'] ?? 'Raça desconeguda';

    final birthDate =
        petData['birthDate'] is Timestamp
            ? (petData['birthDate'] as Timestamp).toDate()
            : null;
    final int? age =
        birthDate != null ? DateTime.now().year - birthDate.year : null;

    final sex = petData['sex'] ?? '?';

    final String? imagePath = petData['image'];
    final imageProvider =
        (imagePath != null && imagePath.startsWith('/'))
            ? FileImage(File(imagePath))
            : const AssetImage('assets/images/example.jpg') as ImageProvider;

    final double screenHeight = MediaQuery.of(context).size.height;
    final double cardHeight = screenHeight * 0.22;
    const double borderRadius = 20.0;
    const double horizontalPadding = 16.0;
    const double verticalPadding = 16.0;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        clipBehavior: Clip.hardEdge,
        shadowColor: Colors.transparent,
        color: AppColors.backgroundComponent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: SizedBox(
          width: double.infinity,
          height: cardHeight,
          child: Stack(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(borderRadius),
                splashColor: AppColors.accent.withAlpha(30),
                onTap: onTap,
                child: Row(
                  children: [
                    SizedBox(
                      width: cardHeight,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(borderRadius),
                          bottomLeft: Radius.circular(borderRadius),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Ink.image(image: imageProvider, fit: BoxFit.cover),
                            Ink(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.center,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.transparent,
                                    AppColors.backgroundComponent,
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: verticalPadding,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(breed, style: AppTextStyles.tinyText(context)),
                            Text(name, style: AppTextStyles.bigText(context)),
                            Text(
                              '${sex.isNotEmpty ? sex[0].toUpperCase() : ''}   ${age != null ? '$age anys' : ''}',
                              style: AppTextStyles.midText(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: horizontalPadding,
                bottom: verticalPadding,
                child: FeedButton(
                  size: cardHeight * 0.34,
                  feedInterval: const Duration(seconds: 2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
