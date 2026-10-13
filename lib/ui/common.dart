// Pieces the signed-out screens share: the centered card the web client's
// sign-in page uses, and the way errors are shown.

import 'package:flutter/material.dart';

import '../theme.dart';

/// A card in the middle of the window, like the web client's sign-in page.
class CenteredCard extends StatelessWidget {
  const CenteredCard({super.key, required this.child, this.leading});

  final Widget child;

  /// Above the card's top-left corner, e.g. a way back.
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: palette.sidebar,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x55000000),
                          blurRadius: 40,
                          offset: Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
            if (leading != null) Positioned(top: 8, left: 8, child: leading!),
          ],
        ),
      ),
    );
  }
}

/// The logo and the product's name at the top of a card.
class Masthead extends StatelessWidget {
  const Masthead({super.key, this.subtitle});

  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.asset('assets/logo.png', width: 72, height: 72),
        ),
        const SizedBox(height: 12),
        Text(
          'Wisetalk',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: palette.text,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: palette.muted),
          ),
        ],
      ],
    );
  }
}

/// What went wrong, said in the card where people look.
class ErrorBox extends StatelessWidget {
  const ErrorBox(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: palette.error.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          message,
          style: TextStyle(color: palette.error, fontSize: 14),
        ),
      ),
    );
  }
}
