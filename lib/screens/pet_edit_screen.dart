import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_track/core/app_colors.dart';
import 'package:pet_track/core/app_styles.dart';
import 'package:pet_track/models/pets_db.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PetEditScreen extends StatefulWidget {
  final Map<String, dynamic> petData;
  const PetEditScreen({super.key, required this.petData});

  @override
  State<PetEditScreen> createState() => _PetEditScreenState();
}

class _PetEditScreenState extends State<PetEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _breedCtrl;
  late TextEditingController _mealsGoalCtrl;
  late TextEditingController _walksGoalCtrl;
  DateTime? _birthDate;
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    final p = widget.petData;
    _nameCtrl = TextEditingController(text: p['name']);
    _breedCtrl = TextEditingController(text: p['breed']);
    _mealsGoalCtrl = TextEditingController(
      text: (p['mealsGoal'] ?? '').toString(),
    );
    _walksGoalCtrl = TextEditingController(
      text: (p['walksGoal'] ?? '').toString(),
    );
    _birthDate =
        p['birthDate'] is Timestamp
            ? (p['birthDate'] as Timestamp).toDate()
            : p['birthDate'];
    _photoPath = p['image'];
  }

  @override
  Widget build(BuildContext context) {
    final picker = ImagePicker();
    return Scaffold(
      appBar: AppBar(title: const Text('Edita la mascota')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  final img = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (img != null) setState(() => _photoPath = img.path);
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      _photoPath != null
                          ? FileImage(File(_photoPath!))
                          : const AssetImage('assets/images/example.jpg')
                              as ImageProvider,
                ),
              ),
              const SizedBox(height: 24),
              // Nombre -------------------------------------------------------
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator:
                    (v) => v == null || v.trim().isEmpty ? 'Obligatori' : null,
              ),
              const SizedBox(height: 16),
              // Raza ---------------------------------------------------------
              TextFormField(
                controller: _breedCtrl,
                decoration: const InputDecoration(labelText: 'Raça'),
              ),
              const SizedBox(height: 16),
              // Fecha de nacimiento -----------------------------------------
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Data de naixement'),
                subtitle: Text(
                  _birthDate != null
                      ? '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'
                      : 'Sense data',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _birthDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _birthDate = picked);
                },
              ),
              const Divider(),
              // Metas --------------------------------------------------------
              TextFormField(
                controller: _mealsGoalCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Objectiu menjades/dia',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _walksGoalCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Objectiu passeigs/dia',
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (!_formKey.currentState!.validate()) return;

          final id = widget.petData['id'] as String;
          final update = <String, dynamic>{
            'name': _nameCtrl.text.trim(),
            'breed': _breedCtrl.text.trim(),
            'birthDate': _birthDate,
            'meals': int.tryParse(_mealsGoalCtrl.text),
            'walks': int.tryParse(_walksGoalCtrl.text),
            'image': _photoPath,
          };
          update.removeWhere((_, v) => v == null);

          await updatePet(id, update); // 🔄 Firestore
          final merged = {...widget.petData, ...update};

          if (!mounted) return;
          Navigator.pop(context, merged); // devolvemos la mascota actualizada
        },

        label: const Text('Guardar'),
        icon: const Icon(Icons.check),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
