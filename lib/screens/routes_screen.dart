// lib/screens/routes_with_pets_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pet_track/core/app_colors.dart';
import 'package:pet_track/core/app_styles.dart';
import 'package:pet_track/models/pets_db.dart';

class RoutesWithPetsScreen extends StatefulWidget {
  const RoutesWithPetsScreen({super.key});

  @override
  State<RoutesWithPetsScreen> createState() => _RoutesWithPetsScreenState();
}

class _RoutesWithPetsScreenState extends State<RoutesWithPetsScreen> {
  late Future<List<Map<String, dynamic>>> _petsFuture;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _petsFuture = getPets();
  }

  void _togglePet(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _toggleAll(List<Map<String, dynamic>> pets) {
    setState(() {
      if (_selectedIds.length == pets.length) {
        _selectedIds.clear();
      } else {
        _selectedIds
          ..clear()
          ..addAll(pets.map((e) => e['petId'] as String));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _petsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final pets = snapshot.data ?? [];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Rutes amb mascotes',
                    style: AppTextStyles.titleText(context),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Selecciona els teus acompanyants:',
                        style: AppTextStyles.midText(context),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _toggleAll(pets),
                      style: ButtonStyle(
                        elevation: WidgetStateProperty.all(0),
                        backgroundColor: WidgetStateProperty.all(
                          Colors.grey.shade300,
                        ),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      child: Text(
                        'Selecciona tots',
                        style: AppTextStyles.midText(context),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 110,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final pet = pets[index];
                    final id = pet['petId'] as String;
                    final selected = _selectedIds.contains(id);
                    return GestureDetector(
                      onTap: () => _togglePet(id),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundImage: FileImage(
                              File(pet['image'] as String),
                            ),
                          ),
                          if (selected)
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                color: Colors.blue.withAlpha(
                                  (0.6 * 255).toInt(),
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemCount: pets.length,
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(35.6938, 139.7034),
                        zoom: 15,
                      ),
                      markers: {
                        const Marker(
                          markerId: MarkerId('start'),
                          position: LatLng(35.6938, 139.7034),
                        ),
                      },
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).padding.bottom + 80,
                        ),
                        child: SizedBox(
                          width: size.width * 0.9,
                          height: 68,
                          child: ElevatedButton(
                            onPressed: _selectedIds.isEmpty ? null : () {},
                            style: ButtonStyle(
                              elevation: WidgetStateProperty.all(0),
                              backgroundColor:
                                  WidgetStateProperty.resolveWith<Color?>((
                                    states,
                                  ) {
                                    if (states.contains(WidgetState.disabled)) {
                                      return Colors.grey;
                                    }
                                    return Colors.transparent;
                                  }),
                              shadowColor: WidgetStateProperty.all(
                                Colors.transparent,
                              ),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              padding: WidgetStateProperty.all(EdgeInsets.zero),
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient:
                                    _selectedIds.isEmpty
                                        ? null
                                        : AppColors.gradient,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  'Iniciar ruta (${_selectedIds.length})',
                                  style: AppTextStyles.bigText(
                                    context,
                                  ).copyWith(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
