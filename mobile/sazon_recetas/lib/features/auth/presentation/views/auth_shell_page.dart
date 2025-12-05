import 'package:flutter/material.dart';

import 'package:sazon_recetas/core/core.dart';
import 'package:sazon_recetas/features/features.dart';

class AuthShellPage extends StatefulWidget {
  const AuthShellPage({super.key});

  @override
  State<AuthShellPage> createState() => _AuthShellPageState();
}

class _AuthShellPageState extends State<AuthShellPage> {
  bool showLogin = true;

  void _toggleAuthMode() {
    setState(() {
      showLogin = !showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'Sazón',
                style: textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                showLogin
                    ? 'Inicia sesión para acceder a tus recetas y favoritos.'
                    : 'Crea tu cuenta y guarda tus propias recetas.',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              _AuthTabs(showLogin: showLogin, onToggle: _toggleAuthMode),
              const SizedBox(height: 16),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: showLogin ? const LoginForm() : const RegisterForm(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthTabs extends StatelessWidget {
  final bool showLogin;
  final VoidCallback onToggle;

  const _AuthTabs({required this.showLogin, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final selectedStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: AppColors.primary,
      fontWeight: FontWeight.w600,
    );

    final unselectedStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: AppColors.textDark.withValues(alpha: 0.5),
    );

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (!showLogin) onToggle();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Iniciar sesión',
                style: showLogin ? selectedStyle : unselectedStyle,
              ),
              const SizedBox(height: 4),
              Container(
                height: 3,
                width: 110,
                decoration: BoxDecoration(
                  color: showLogin ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        GestureDetector(
          onTap: () {
            if (showLogin) onToggle();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Crear cuenta',
                style: !showLogin ? selectedStyle : unselectedStyle,
              ),
              const SizedBox(height: 4),
              Container(
                height: 3,
                width: 110,
                decoration: BoxDecoration(
                  color: !showLogin ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
