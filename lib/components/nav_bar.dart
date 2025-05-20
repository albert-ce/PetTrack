import 'package:flutter/material.dart';
import 'package:pet_track/core/app_colors.dart';

class NavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const NavBar({required this.currentIndex, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: AppColors.background,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: false,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Mascotes'),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: 'Calendari',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inici'),
        BottomNavigationBarItem(icon: Icon(Icons.navigation), label: 'Rutes'),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'Perfil',
        ),
      ],
    );
  }
}
