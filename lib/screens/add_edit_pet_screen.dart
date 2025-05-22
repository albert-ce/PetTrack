// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_track/core/app_colors.dart';
import 'package:pet_track/core/app_styles.dart';
import 'package:pet_track/models/pets_db.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AddEditPetScreen extends StatefulWidget {
  final Map<String, dynamic>? petData; // null = afegir, !null = edició
  const AddEditPetScreen({super.key, this.petData});

  @override
  State<AddEditPetScreen> createState() => _AddEditPetScreenState();
}

class _AddEditPetScreenState extends State<AddEditPetScreen> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _dataNaixementController =
      TextEditingController();
  final TextEditingController _racaController = TextEditingController();

  DateTime? _dataNaixement;
  String? _tipusAnimal = 'gos';
  String? _sexe = '?';
  int _menjarsAlDia = 4;
  XFile? _imatge;
  String? _raca;
  bool _carregantRaca = false;

  bool get _editant => widget.petData != null;

  @override
  void initState() {
    super.initState();

    // Prefill quan estem en mode edició
    if (_editant) {
      final p = widget.petData!;
      _nomController.text = p['name'] ?? '';
      _racaController.text = p['breed'] ?? '';

      final bd = p['birthDate'];
      _dataNaixement = bd is Timestamp ? bd.toDate() : (bd as DateTime?);
      if (_dataNaixement != null) {
        _dataNaixementController.text =
            _dataNaixement!.toLocal().toString().split(' ')[0];
      }
      _tipusAnimal = p['species'] ?? _tipusAnimal;
      _sexe = p['sex'] ?? _sexe;
      _menjarsAlDia = p['dailyFeedGoal'] ?? _menjarsAlDia;
      if (p['image'] != null &&
          p['image'] is String &&
          (p['image'] as String).isNotEmpty) {
        final path = p['image'] as String;
        if (File(path).existsSync()) {
          _imatge = XFile(path);
        }
      }
    }
  }

  Future<String> _obtenirRaca(File imatge) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) return 'Raça desconeguda';

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash:generateContent?key=$apiKey',
    );
    final base64Image = base64Encode(await imatge.readAsBytes());
    const prompt = '''
Ets un expert en animals. Identifica la raça exacta o més aproximada que puguis del gos o gat que apareix a la imatge.
Dona'm únicament el nom, sense cap altre text ni puntuació.
Si no ho saps, respon exactament així: Raça desconeguda''';

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt},
            {
              'inlineData': {'mimeType': 'image/jpeg', 'data': base64Image},
            },
          ],
        },
      ],
    });

    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final text = json['candidates']?[0]?['content']?['parts']?[0]?['text'];
        if (text != null && text.trim().isNotEmpty) return text.trim();
      }
    } catch (_) {}
    return 'Raça desconeguda';
  }

  Future<void> _seleccionaImatge() async {
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Fer foto'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? imatge = await picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (imatge != null) _processaImatge(imatge);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Seleccionar de la galeria'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? imatge = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (imatge != null) _processaImatge(imatge);
                },
              ),
            ],
          ),
    );
  }

  Future<void> _processaImatge(XFile imatge) async {
    setState(() {
      _imatge = imatge;
      _carregantRaca = true;
      _raca = null;
      _racaController.text = '';
    });
    final raca = await _obtenirRaca(File(imatge.path));
    if (!mounted) return;
    setState(() {
      _carregantRaca = false;
      _raca = raca;
      _racaController.text = raca;
    });
  }

  Future<void> _desaMascota() async {
    final dades = <String, dynamic>{
      'name': _nomController.text.trim(),
      'breed': _raca ?? _racaController.text.trim(),
      'birthDate':
          _dataNaixement == null ? null : Timestamp.fromDate(_dataNaixement!),
      'species': _tipusAnimal,
      'sex': _sexe,
      'dailyFeedGoal': _menjarsAlDia,
      'image': _imatge?.path,
    }..removeWhere((_, v) => v == null || (v is String && v.isEmpty));

    if (_editant) {
      final id = widget.petData!['id'] as String;
      await updatePet(id, dades);
      if (mounted) Navigator.pop(context, {...widget.petData!, ...dades});
    } else {
      await addPet({...dades, 'dailyFeedCount': 0, 'lastFeed': DateTime.now()});
      if (mounted) Navigator.pop(context, true);
    }
  }

  Widget _botoCircular({
    required IconData icona,
    required bool seleccionat,
    required VoidCallback onTap,
    required double radius,
    required double iconSize,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius,
        backgroundColor:
            seleccionat ? AppColors.primary : AppColors.backgroundComponent,
        child: Icon(
          icona,
          color: seleccionat ? Colors.white : Colors.black,
          size: iconSize,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);

    final inputDecorationTheme = theme.inputDecorationTheme.copyWith(
      labelStyle: const TextStyle(color: AppColors.primary),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary),
      ),
    );

    return Theme(
      data: theme.copyWith(
        inputDecorationTheme: inputDecorationTheme,
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.primary,
          selectionColor: AppColors.primary.withAlpha((255 * 0.4).toInt()),
          selectionHandleColor: AppColors.primary,
        ),
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: Text(
            _editant ? 'Editar mascota' : 'Afegir mascota',
            style: AppTextStyles.titleText(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(screenHeight * 0.008),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundComponent,
                    borderRadius: BorderRadius.circular(screenHeight * 0.015),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(screenHeight * 0.015),
                    onTap: _seleccionaImatge,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenHeight * 0.02,
                        vertical: screenHeight * 0.015,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ShaderMask(
                            shaderCallback:
                                (bounds) =>
                                    AppColors.gradient.createShader(bounds),
                            child: Icon(
                              _imatge == null
                                  ? Icons.add_a_photo
                                  : Icons.check_circle,
                              size: screenHeight * 0.03,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: screenHeight * 0.01),
                          ShaderMask(
                            shaderCallback:
                                (bounds) =>
                                    AppColors.gradient.createShader(bounds),
                            child: Text(
                              _imatge == null
                                  ? 'Afegir imatge'
                                  : 'Imatge afegida',
                              style: AppTextStyles.primaryText(
                                context,
                              ).copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.0125),
                if (_carregantRaca) ...[
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: AppColors.primary),
                      const SizedBox(width: 8),
                      const Text('Detectant raça amb IA...'),
                      const SizedBox(width: 8),
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ],
                  ),
                ] else if (_raca != null) ...[
                  TextField(
                    controller: _racaController,
                    decoration: const InputDecoration(
                      labelText: 'Raça detectada',
                      suffixIcon: Icon(
                        Icons.auto_awesome,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.0125),
                ],
                TextField(
                  controller: _nomController,
                  decoration: const InputDecoration(labelText: 'Nom'),
                ),
                SizedBox(height: screenHeight * 0.008),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _dataNaixement ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _dataNaixement = picked;
                        _dataNaixementController.text =
                            _dataNaixement!.toLocal().toString().split(' ')[0];
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _dataNaixementController,
                      decoration: const InputDecoration(
                        labelText: 'Data de naixement',
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.025),
                Text('Animal:', style: AppTextStyles.midText(context)),
                SizedBox(height: screenHeight * 0.0125),
                Row(
                  children: [
                    _botoCircular(
                      icona: FontAwesomeIcons.dog,
                      seleccionat: _tipusAnimal == 'gos',
                      onTap: () => setState(() => _tipusAnimal = 'gos'),
                      radius: screenHeight * 0.035,
                      iconSize: screenHeight * 0.03,
                    ),
                    SizedBox(width: screenHeight * 0.01),
                    _botoCircular(
                      icona: FontAwesomeIcons.cat,
                      seleccionat: _tipusAnimal == 'gat',
                      onTap: () => setState(() => _tipusAnimal = 'gat'),
                      radius: screenHeight * 0.035,
                      iconSize: screenHeight * 0.03,
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.0125),
                Text('Sexe:', style: AppTextStyles.midText(context)),
                SizedBox(height: screenHeight * 0.0125),
                Row(
                  children: [
                    _botoCircular(
                      icona: FontAwesomeIcons.mars,
                      seleccionat: _sexe == 'M',
                      onTap: () => setState(() => _sexe = 'M'),
                      radius: screenHeight * 0.035,
                      iconSize: screenHeight * 0.03,
                    ),
                    SizedBox(width: screenHeight * 0.01),
                    _botoCircular(
                      icona: FontAwesomeIcons.venus,
                      seleccionat: _sexe == 'F',
                      onTap: () => setState(() => _sexe = 'F'),
                      radius: screenHeight * 0.035,
                      iconSize: screenHeight * 0.03,
                    ),
                    SizedBox(width: screenHeight * 0.01),
                    _botoCircular(
                      icona: FontAwesomeIcons.question,
                      seleccionat: _sexe == '?',
                      onTap: () => setState(() => _sexe = '?'),
                      radius: screenHeight * 0.035,
                      iconSize: screenHeight * 0.03,
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.0125),
                Text('Menjars:', style: AppTextStyles.midText(context)),
                SizedBox(height: screenHeight * 0.0125),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        thumbColor: AppColors.primary,
                        activeColor: AppColors.primary,
                        inactiveColor: AppColors.backgroundComponent,
                        value: _menjarsAlDia.toDouble(),
                        min: 1,
                        max: 8,
                        divisions: 7,
                        label: '$_menjarsAlDia menjars',
                        onChanged:
                            (val) =>
                                setState(() => _menjarsAlDia = val.toInt()),
                      ),
                    ),
                    Text(
                      '$_menjarsAlDia menjars / dia',
                      style: AppTextStyles.tinyText(
                        context,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                Material(
                  borderRadius: BorderRadius.circular(screenHeight * 0.015),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: AppColors.gradient,
                      borderRadius: BorderRadius.circular(screenHeight * 0.015),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(screenHeight * 0.015),
                      onTap: _desaMascota,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                        ),
                        child: Center(
                          child: Text(
                            _editant ? 'Guardar' : 'Afegir mascota',
                            style: AppTextStyles.bigText(context).copyWith(
                              color: Colors.white,
                              fontSize: screenHeight * 0.03,
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
        ),
      ),
    );
  }
}
