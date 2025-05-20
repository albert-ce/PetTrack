import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_track/components/pet_card.dart';
import 'package:pet_track/core/app_colors.dart';
import 'package:pet_track/core/app_styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_track/screens/afegir_mascota_screen.dart';

class PetListScreen extends StatefulWidget {
  const PetListScreen({super.key});

  @override
  State<PetListScreen> createState() => _PetListScreenState();
}

class _PetListScreenState extends State<PetListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var db = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
            child: Text(
              'Les meves mascotes',
              style: AppTextStyles.titleText(context),
            ),
          ),
          const PetCard(),
          const PetCard(),
          const PetCard(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const AfegirMascotaScreen(),
              transitionsBuilder: (_, animation, __, child) {
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(animation);
                return SlideTransition(position: offsetAnimation, child: child);
              },
            ),
          );
          // final User? user = _auth.currentUser;
          // if (user != null) {
          //   // Crear datos del usuario
          //   final userData = <String, dynamic>{
          //     "first": "Ada",
          //     "last": "Lovelace",
          //     "born": 1815,
          //   };
          //   // Add a new document with a generated ID
          //   try {
          //     await db.collection("users").doc(user.uid).set(userData);
          //     print('Documento creado para el usuario: ${user.uid}');
          //   } catch (e) {
          //     print('Error al crear el documento: $e');
          //   }
          // } else {
          //   print('No hay usuario autenticado');
          //   // Aquí podrías mostrar un diálogo o navegar a la pantalla de login
          // }
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppColors.gradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: screenHeight * 0.08,
            height: screenHeight * 0.08,
            alignment: Alignment.center,
            child: const Icon(Icons.add, color: Colors.white, size: 32),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
