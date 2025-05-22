import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_track/components/app_bar.dart';
import 'package:pet_track/core/app_colors.dart';
import 'package:pet_track/core/app_styles.dart';
import 'package:pet_track/models/pets_db.dart';

class PetEditScreen extends StatefulWidget {
  final Map<String, dynamic> petData;
  const PetEditScreen({super.key, required this.petData});

  @override
  State<PetEditScreen> createState() => _PetEditScreenState();
}

class _PetEditScreenState extends State<PetEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl,
      _breedCtrl,
      _mealsGoalCtrl,
      _walksGoalCtrl;
  DateTime? _birthDate;
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    final p = widget.petData;
    _nameCtrl = TextEditingController(text: p['name'] ?? '');
    _breedCtrl = TextEditingController(text: p['breed'] ?? '');
    _mealsGoalCtrl = TextEditingController(text: '${p['mealsGoal'] ?? ''}');
    _walksGoalCtrl = TextEditingController(text: '${p['walksGoal'] ?? ''}');
    _birthDate =
        p['birthDate'] is Timestamp
            ? (p['birthDate'] as Timestamp).toDate()
            : p['birthDate'];
    _photoPath = p['image'];
  }

  Future<void> _pickImage() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => _photoPath = img.path);
  }

  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: AppColors.backgroundComponent,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBarWidget(height: h * .10, iconColor: AppColors.background),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: h * .08,
                  backgroundColor: AppColors.backgroundComponent,
                  backgroundImage:
                      _photoPath != null
                          ? (_photoPath!.startsWith('/')
                                  ? FileImage(File(_photoPath!))
                                  : NetworkImage(_photoPath!))
                              as ImageProvider
                          : const AssetImage('assets/images/example.jpg'),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              TextFormField(
                controller: _nameCtrl,
                decoration: _dec('Nom'),
                style: AppTextStyles.midText(context),
                validator:
                    (v) => v == null || v.trim().isEmpty ? 'Obligatori' : null,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _breedCtrl,
                decoration: _dec('Raça'),
                style: AppTextStyles.midText(context),
              ),
              const SizedBox(height: 20),

              ListTile(
                tileColor: AppColors.backgroundComponent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  'Data de naixement',
                  style: AppTextStyles.midText(context),
                ),
                subtitle: Text(
                  _birthDate != null
                      ? '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'
                      : 'Sense data',
                  style: AppTextStyles.tinyText(context),
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
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _mealsGoalCtrl,
                      decoration: _dec('Menjars/dia'),
                      keyboardType: TextInputType.number,
                      style: AppTextStyles.midText(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _walksGoalCtrl,
                      decoration: _dec('Passeigs/dia'),
                      keyboardType: TextInputType.number,
                      style: AppTextStyles.midText(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),

      floatingActionButton: GestureDetector(
        onTap: _save,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          decoration: BoxDecoration(
            gradient: AppColors.gradient,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 4),
                blurRadius: 6,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Guardar',
                style: AppTextStyles.midText(
                  context,
                ).copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final id = widget.petData['id'] as String;
    final update = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      'breed': _breedCtrl.text.trim(),
      'birthDate': _birthDate,
      'meals': int.tryParse(_mealsGoalCtrl.text),
      'walks': int.tryParse(_walksGoalCtrl.text),
      'image': _photoPath,
    }..removeWhere((_, v) => v == null);

    await updatePet(id, update);
    final merged = {...widget.petData, ...update};

    if (!mounted) return;
    Navigator.pop(context, merged);
  }
}
