import 'package:flutter/material.dart';
import 'package:pet_track/components/feed_button.dart';
import 'package:pet_track/core/app_colors.dart';
import 'package:pet_track/core/app_styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class PetCard extends StatefulWidget {
  final Map<String, dynamic> petData;

  const PetCard({super.key, required this.petData});

  @override
  State<PetCard> createState() => _PetCardState();
}

class _PetCardState extends State<PetCard> {
  @override
  Widget build(BuildContext context) {
    final pet = widget.petData;
    final name = pet['name'] ?? 'Sense nom';
    final species = pet['species'] ?? 'Espècie desconeguda';
    final breed = pet['breed'] ?? 'Raça desconeguda';
    final birthDate =
        pet['birthDate'] is Timestamp
            ? (pet['birthDate'] as Timestamp).toDate()
            : null;
    final ageText =
        birthDate != null
            ? () {
              final now = DateTime.now();
              final duration = now.difference(birthDate);
              final months = (duration.inDays / 30).floor();
              return months < 12
                  ? '$months mesos'
                  : '${(months / 12).floor()} anys';
            }()
            : '';

    final sex = pet['sex'] ?? '?';
    final String? imagePath = pet['image'];
    final imageProvider =
        (imagePath != null && imagePath.startsWith('/'))
            ? FileImage(File(imagePath))
            : AssetImage('assets/images/$species.png') as ImageProvider;

    final double screenHeight = MediaQuery.of(context).size.height;
    final double cardHeight = screenHeight * 0.22;
    final double borderRadius = 20.0;
    final double horizontalPadding = 16.0;
    final double verticalPadding = 16.0;

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
                onTap: () {},
                child: Row(
                  children: [
                    SizedBox(
                      width: cardHeight,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
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
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: verticalPadding,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(breed, style: AppTextStyles.tinyText(context)),
                            Text(name, style: AppTextStyles.bigText(context)),
                            Text(
                              '${sex.isNotEmpty ? sex[0].toUpperCase() : ''}   $ageText',
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
