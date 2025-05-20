import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_track/core/app_colors.dart';
import 'package:pet_track/core/app_styles.dart';
import 'package:pet_track/models/pets_db.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AfegirMascotaScreen extends StatefulWidget {
  const AfegirMascotaScreen({super.key});
  @override
  State<AfegirMascotaScreen> createState() => _AfegirMascotaScreenState();
}

class _AfegirMascotaScreenState extends State<AfegirMascotaScreen> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _dataNaixementController =
      TextEditingController();
  DateTime? _dataNaixement;
  String? _tipusAnimal = 'gos';
  String? _sexe = '?';
  int _menjars = 4;
  XFile? _imatge;

  Future<void> _seleccionaImatge() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imatgeSeleccionada = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (imatgeSeleccionada != null) {
      setState(() {
        _imatge = imatgeSeleccionada;
      });
    }
  }

  Future<void> _seleccionaData() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
      labelStyle: TextStyle(color: AppColors.primary),
      focusedBorder: UnderlineInputBorder(
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
            'Afegir mascota',
            style: AppTextStyles.titleText(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(screenHeight * 0.008),
          child: Padding(
            padding: const EdgeInsets.only(right: 16, left: 16),
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
                                (bounds) => AppColors.gradient.createShader(
                                  Rect.fromLTWH(
                                    0,
                                    0,
                                    bounds.width,
                                    bounds.height,
                                  ),
                                ),
                            child: Icon(
                              Icons.add_a_photo,
                              size: screenHeight * 0.03,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: screenHeight * 0.01),
                          ShaderMask(
                            shaderCallback:
                                (bounds) => AppColors.gradient.createShader(
                                  Rect.fromLTWH(
                                    0,
                                    0,
                                    bounds.width,
                                    bounds.height,
                                  ),
                                ),
                            child: Text(
                              'Afegir imatge',
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
                TextField(
                  controller: _nomController,
                  style: TextStyle(fontSize: screenHeight * 0.02),
                  decoration: InputDecoration(labelText: 'Nom'),
                ),
                SizedBox(height: screenHeight * 0.008),
                GestureDetector(
                  onTap: _seleccionaData,
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _dataNaixementController,
                      style: TextStyle(fontSize: screenHeight * 0.02),
                      decoration: InputDecoration(
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
                        value: _menjars.toDouble(),
                        min: 1,
                        max: 8,
                        divisions: 7,
                        label: "$_menjars menjars",
                        onChanged:
                            (val) => setState(() => _menjars = val.toInt()),
                      ),
                    ),
                    Text(
                      '$_menjars menjars / dia',
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
                      onTap: () async {
                        Navigator.pop(context, true);
                        await addPet({
                          'name': _nomController.text,
                          'species': _tipusAnimal,
                          'sex': _sexe,
                          'meals': _menjars,
                          'image': _imatge?.path,
                          'birthDate': Timestamp.fromDate(
                            _dataNaixement ?? DateTime.now(),
                          ),
                        });

                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                        ),
                        child: Center(
                          child: Text(
                            'Afegir mascota',
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
