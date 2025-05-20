import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_track/core/app_colors.dart';
import 'package:pet_track/core/app_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser ;

    if (user == null) {
      // No hay usuario logueado, quizás redirigir a la pantalla de login
      return const Scaffold(
        body: Center(
          child: Text("No hay usuario conectado."),
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (user.photoURL != null)
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(user.photoURL!),
              ),
            const SizedBox(height: 20),
            Text(
              user.displayName ?? 'Nombre no disponible',
              style: AppTextStyles.bigText(context)
            ),
            const SizedBox(height: 10),
            Text(
              user.email ?? 'Email no disponible',
              style: AppTextStyles.midText(context)
            ),
            const SizedBox(height: 10),
            if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty)
              Text(
                'Teléfono: ${user.phoneNumber}',
                style: AppTextStyles.midText(context)
              ),
            // Por ejemplo, un botón para cerrar sesión:
            const SizedBox(height: 30),
            Container(
                decoration: BoxDecoration(
                  gradient: AppColors.gradient,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent, 
                    shadowColor: Colors.transparent, 
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0, 
                  ),
                  child: Text(
                    'Tancar la sessió',
                    style: AppTextStyles.primaryText(context).copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
        ),
      ),
    );
  }
}