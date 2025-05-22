import 'package:flutter/material.dart';
import 'package:pet_track/components/feed_button.dart';
import 'package:pet_track/core/app_colors.dart';
import 'package:pet_track/core/app_styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class PetCard extends StatefulWidget {
  final Map<String, dynamic> petData;
  final VoidCallback? onTap;
  const PetCard({super.key, required this.petData, this.onTap});

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
    final int feedDurationMinutes = ((24 / pet["meals"]) * 60).toInt();
    final birthDate =
        pet['birthDate'] is Timestamp
            ? (pet['birthDate'] as Timestamp).toDate()
            : null;
    final ageText =
        birthDate != null
            ? () {
              final now = DateTime.now();
              final duration = now.difference(birthDate);
              final days = duration.inDays;
              final months = (days / 30).floor();
              return days < 30
                  ? '$days dies'
                  : months < 12
                  ? '$months mesos'
                  : '${(months / 12).floor()} anys';
            }()
            : '';
    final petId = pet['id'];
    final lastFed =
        pet['lastFed'] is Timestamp
            ? (pet['lastFed'] as Timestamp).toDate()
            : DateTime.now();
    final sex = pet['sex'] ?? '?';
    final String? imagePath = pet['image'];
    final imageProvider =
        (imagePath != null && imagePath.startsWith('/'))
            ? FileImage(File(imagePath))
            : AssetImage('assets/images/$species.png') as ImageProvider;

    void updateLastFed() {
      final _auth = FirebaseAuth.instance;
      final user = _auth.currentUser;
      FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('pets')
          .doc(petId)
          .update({'lastFed': DateTime.now()});
    }

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
                onTap: widget.onTap,
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
                top: verticalPadding,
                child: FeedButton(
                  size: cardHeight * 0.34,
                  feedInterval: Duration(minutes: feedDurationMinutes),
                  lastFed: lastFed,
                  onFeed: updateLastFed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
