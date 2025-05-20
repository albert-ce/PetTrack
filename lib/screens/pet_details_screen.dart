import 'package:flutter/material.dart';
import 'package:pet_track/core/app_colors.dart';
import 'package:pet_track/core/app_styles.dart';

class PetDetailsScreen extends StatelessWidget {
  const PetDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FOTO + INFO BÁSICA -------------------------------------------------
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: screenWidth * 0.40,
                  height: screenWidth * 0.40,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundComponent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(Icons.pets, size: 48, color: AppColors.grey),
                  ),
                ),
                const SizedBox(width: 16),
                // Nombre, raza y edad
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nombre', style: AppTextStyles.bigText(context)),
                      const SizedBox(height: 5),
                      Text(
                        'Golden Retriever',
                        style: AppTextStyles.midText(context),
                      ),
                      const SizedBox(height: 2),
                      Text('2 años', style: AppTextStyles.tinyText(context)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // EVENTO PRÓXIMO ----------------------------------------------------
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.notifications_none, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Text(
                    'No hay eventos próximos',
                    style: AppTextStyles.midText(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // WIDGETS DE ALIMENTACIÓN Y PASEOS ---------------------------------
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _InfoCard(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Alimentación',
                            style: AppTextStyles.titleText(context),
                            maxLines: 1,
                          ),
                          const SizedBox(height: 4),
                          Text('3 / 4', style: AppTextStyles.midText(context)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _InfoCard(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Paseos',
                            style: AppTextStyles.titleText(context),
                          ),
                          const SizedBox(height: 4),
                          Text('2 / 4', style: AppTextStyles.midText(context)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // GRÁFICO / ACTIVIDAD ---------------------------------------------
            Container(
              width: double.infinity,
              height: screenHeight * 0.20,
              decoration: BoxDecoration(
                color: AppColors.backgroundComponent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  'Gráfico / actividad',
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

// ---------------------------------------------------------------------------
//  WIDGET REUTILIZABLE PARA LOS MÓDULOS DE INFORMACIÓN (Alimentación, Paseos)
// ---------------------------------------------------------------------------
class _InfoCard extends StatelessWidget {
  final Widget child;
  const _InfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundComponent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}
