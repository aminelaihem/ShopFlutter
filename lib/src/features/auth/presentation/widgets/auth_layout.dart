// lib/src/features/auth/presentation/widgets/auth_layout.dart
import 'package:flutter/material.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, required this.title, required this.subtitle, required this.child});

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Gradient de fond
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  scheme.primary.withOpacity(.12),
                  scheme.secondary.withOpacity(.08),
                  Colors.transparent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              color: scheme.primary.withOpacity(.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.local_mall_outlined, color: scheme.primary),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      child,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
