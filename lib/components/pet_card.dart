import 'package:flutter/material.dart';
import 'package:pet_track/components/feed_button.dart';
import 'package:pet_track/core/app_colors.dart';
import 'package:pet_track/core/app_styles.dart';

class PetCard extends StatefulWidget {
  const PetCard({super.key});

  @override
  State<PetCard> createState() => _PetCardState();
}

class _PetCardState extends State<PetCard> {
  @override
  Widget build(BuildContext context) {
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
                            Ink.image(
                              image: const AssetImage(
                                'assets/images/example.jpg',
                              ),
                              fit: BoxFit.cover,
                            ),
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
                            Text(
                              'Labrador retriever',
                              style: AppTextStyles.tinyText(context),
                            ),
                            Text(
                              'Flusky',
                              style: AppTextStyles.bigText(context),
                            ),
                            Text(
                              'M   2 anys',
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
