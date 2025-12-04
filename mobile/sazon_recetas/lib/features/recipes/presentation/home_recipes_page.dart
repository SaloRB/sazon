import 'package:flutter/material.dart';
import 'package:sazon_recetas/core/constants/app_colors.dart';

class HomeRecipesPage extends StatelessWidget {
  const HomeRecipesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Sazón')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            Text(
              'Tu recetario con toque propio',
              style: textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Explora recetas rápidas, caseras y con mucho sabor. Guarda tus favoritas y crea tu propio recetario.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Explorar recetas'),
            ),
            const SizedBox(height: 24),
            Text('Categorías populares', style: textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _CategoryChip(label: 'Desayunos'),
                _CategoryChip(label: 'Comida rápida'),
                _CategoryChip(label: 'Saludable'),
                _CategoryChip(label: 'Postres'),
                _CategoryChip(label: 'Para compartir'),
              ],
            ),
            const SizedBox(height: 24),
            Text('Recetas destacadas', style: textTheme.titleMedium),
            const SizedBox(height: 12),
            _FeatureCardRecipe(
              title: 'Tacos al Pastor',
              subtitle: 'Deliciosos tacos con piña y salsa especial',
            ),
            _FeatureCardRecipe(
              title: 'Tostadas de aguacate con huevo',
              subtitle: 'Listo en 10 minutos',
            ),
            _FeatureCardRecipe(
              title: 'Pasta cremosa con pollo',
              subtitle: 'Ideal para la comida',
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;

  const _CategoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.white,
      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
    );
  }
}

class _FeatureCardRecipe extends StatelessWidget {
  final String title;
  final String subtitle;

  const _FeatureCardRecipe({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(subtitle, style: textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
