import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_track/components/app_bar.dart';
import 'package:pet_track/components/info_card.dart';
import 'package:pet_track/core/app_colors.dart';
import 'package:pet_track/core/app_styles.dart';
import 'package:pet_track/screens/add_edit_pet_screen.dart';
import 'package:pet_track/components/google_auth.dart';
import 'package:pet_track/services/calendar_service.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:googleapis_auth/auth_io.dart';

class PetDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> petData;

  const PetDetailsScreen({super.key, required this.petData});

  @override
  State<PetDetailsScreen> createState() => _PetDetailsScreenState();
}

class _PetDetailsScreenState extends State<PetDetailsScreen> {
  late Map<String, dynamic> pet; // copia mutable de la mascota

  late final AuthService _authService;
  CalendarService? _calendarService;
  String? _petTrackCalendarId;
  gcal.Event? _nextEvent;
  bool _loadingEvent = true;

  @override
  void initState() {
    super.initState();
    pet = Map<String, dynamic>.from(widget.petData);
    _authService = AuthService();
    _loadNextEvent();
  }

  Future<void> _loadNextEvent() async {
    final AuthClient? client = await _authService.getAuthenticatedClient();
    if (client == null) {
      setState(() => _loadingEvent = false);
      return;
    }
    _calendarService = CalendarService(client);
    _petTrackCalendarId =
        await _calendarService!.ensurePetTrackCalendarExists();
    if (_petTrackCalendarId == null) {
      setState(() => _loadingEvent = false);
      return;
    }
    final now = DateTime.now().toUtc();
    final end = now.add(const Duration(days: 365));
    final events = await _calendarService!.getEvents(
      _petTrackCalendarId!,
      now,
      end,
    );

    final List<gcal.Event> matched = [];
    for (final e in events) {
      final raw = e.extendedProperties?.private?['petIds'];
      if (raw == null) continue;
      try {
        final ids = List<String>.from(json.decode(raw));
        if (ids.contains(pet['id'])) matched.add(e);
      } catch (_) {}
    }
    matched.sort((a, b) {
      final aStart = a.start?.dateTime ?? a.start?.date;
      final bStart = b.start?.dateTime ?? b.start?.date;
      return aStart!.compareTo(bStart!);
    });
    setState(() {
      _nextEvent = matched.isNotEmpty ? matched.first : null;
      _loadingEvent = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;

    // ────────── Dades bàsiques ──────────
    final name = pet['name'] ?? 'Mascota';
    final breed = pet['breed'] ?? 'Raça desconeguda';
    final species = pet['species'] ?? 'Espècie desconeguda';
    final bd =
        pet['birthDate'] is Timestamp
            ? (pet['birthDate'] as Timestamp).toDate()
            : null;
    final ageText =
        bd != null
            ? () {
              final now = DateTime.now();
              final duration = now.difference(bd);
              final days = duration.inDays;
              final months = (days / 30).floor();
              return days < 30
                  ? '$days dies'
                  : months < 12
                  ? '$months mesos'
                  : '${(months / 12).floor()} anys';
            }()
            : '';

    final String? imageUrl = pet['imageUrl'];
    if (imageUrl != null && imageUrl.isNotEmpty) {
      imageCache.evict(NetworkImage(imageUrl), includeLive: true);
    }
    final ImageProvider imageProvider =
        imageUrl != null && imageUrl.isNotEmpty
            ? NetworkImage(imageUrl)
            : AssetImage('assets/images/$species.png');

    // ────────── Menjars i passeigs ──────────
    int? mealsDone;
    final m = pet['meals'];
    if (m is int) mealsDone = m;
    if (m is List) mealsDone = m.length;
    final feedText = '$mealsDone menjars';

    final w = pet['walks'];
    final walkText = '$w passeigs';

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
              if (!mounted || updatedPet == null) return;
              if (updatedPet['deleted'] == true) {
                Navigator.pop(context, true);
                return;
              }
              setState(() => pet = updatedPet);
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
                      if (ageText.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(ageText, style: AppTextStyles.tinyText(context)),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Center(
              child:
                  _loadingEvent
                      ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.accent,
                        ),
                      )
                      : (_nextEvent == null
                          ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.notifications_none,
                                color: AppColors.accent,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'No hi ha esdeveniments propers',
                                style: AppTextStyles.midText(context),
                              ),
                            ],
                          )
                          : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.notifications,
                                color: AppColors.accent,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _nextEvent!.summary ?? 'Esdeveniment',
                                style: AppTextStyles.midText(context),
                              ),
                            ],
                          )),
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
