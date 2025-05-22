import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_track/components/app_bar.dart';
import 'package:pet_track/components/info_card.dart';
import 'package:pet_track/core/app_colors.dart';
import 'package:pet_track/core/app_styles.dart';
import 'package:pet_track/screens/add_edit_pet_screen.dart';

class PetDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> petData;

  const PetDetailsScreen({Key? key, required this.petData}) : super(key: key);

  @override
  State<PetDetailsScreen> createState() => _PetDetailsScreenState();
}

class _PetDetailsScreenState extends State<PetDetailsScreen> {
  late Map<String, dynamic> pet; // copia mutable de la mascota

  @override
  void initState() {
    super.initState();
    pet = Map<String, dynamic>.from(widget.petData);
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;

    // ────────── Dades bàsiques ──────────
    final name = pet['name'] ?? 'Mascota';
    final breed = pet['breed'] ?? 'Raça desconeguda';
    final species = pet['species'] ?? 'Espècie desconeguda';
    int? age;
    final bd = pet['birthDate'];
    if (bd != null) {
      final d = bd is DateTime ? bd : (bd is Timestamp ? bd.toDate() : null);
      if (d != null) age = DateTime.now().year - d.year;
    }
    final ageStr = age != null ? (age == 1 ? '1 any' : '$age anys') : '';

    final imgPath = pet['image'] as String?;
    final ImageProvider imageProvider =
        (imgPath != null && imgPath.startsWith('/'))
            ? FileImage(File(imgPath))
            : (imgPath != null && imgPath.startsWith('http'))
            ? NetworkImage(imgPath)
            : (imgPath == null && species == 'gos')
            ? const AssetImage('assets/images/gos.png')
            : const AssetImage('assets/images/gat.png');

    // ────────── Menjars i passeigs ────────── DESMUTEIG QUAN TINGUEM BE BD
    int? mealsDone;
    final m = pet['meals'];
    if (m is int) mealsDone = m;
    if (m is List) mealsDone = m.length;

    // final mealsGoal =
    //     pet['mealsGoal'] ?? pet['mealsTarget'] ?? pet['feedTarget'];

    final feedText = '$mealsDone menjars';
    // (mealsDone != null && mealsGoal != null)
    //     ? '$mealsDone / $mealsGoal menjades'
    //     : (mealsDone != null
    //         ? '$mealsDone menjades'
    //         : 'Menjars no assignats');

    // int? walksDone;
    final w = pet['walks'];
    // if (w is int) walksDone = w;
    // if (w is List) walksDone = w.length;

    // final walksGoal =
    //     pet['walksGoal'] ?? pet['walksTarget'] ?? pet['walkTarget'];
    final walkText = '$w passeigs';
    // (walksDone != null && walksGoal != null)
    //     ? '$walksDone / $walksGoal'
    //     : (walksDone != null
    //         ? '$walksDone passeigs'
    //         : 'Passeigs no registrats');

    // ────────── UI ──────────
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBarWidget(
        height: screenH * 0.10,
        iconColor: AppColors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updatedPet = await Navigator.push<Map<String, dynamic>?>(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditPetScreen(petData: pet),
                ),
              );

              if (updatedPet != null && mounted) {
                setState(() => pet = updatedPet);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: screenW * .40,
                  height: screenW * .40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppTextStyles.bigText(context)),
                      const SizedBox(height: 5),
                      Text(breed, style: AppTextStyles.midText(context)),
                      if (ageStr.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(ageStr, style: AppTextStyles.tinyText(context)),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.notifications_none, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Text(
                    'No hi ha esdeveniments propers',
                    style: AppTextStyles.midText(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: InfoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Alimentació',
                            style: AppTextStyles.titleText(context),
                          ),
                          const SizedBox(height: 4),
                          Text(feedText, style: AppTextStyles.midText(context)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InfoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Passeigs',
                            style: AppTextStyles.titleText(context),
                          ),
                          const SizedBox(height: 4),
                          Text(walkText, style: AppTextStyles.midText(context)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              height: screenH * .20,
              decoration: BoxDecoration(
                color: AppColors.backgroundComponent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  'Gràfic / activitat',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
