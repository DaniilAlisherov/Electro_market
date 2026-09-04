import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class RoleGateScreen extends StatefulWidget {
  const RoleGateScreen({super.key});
  @override
  State<RoleGateScreen> createState() => _RoleGateScreenState();
}

class _RoleGateScreenState extends State<RoleGateScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();

  @override
  void dispose() { _intro.dispose(); super.dispose(); }

  Widget _animated(double start, Widget child, {Offset begin = const Offset(0, 18), double scale = .97}) {
    final a = CurvedAnimation(parent: _intro, curve: Interval(start, 1, curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: a,
      child: SlideTransition(
        position: Tween<Offset>(begin: begin, end: Offset.zero).animate(a),
        child: ScaleTransition(scale: Tween<double>(begin: scale, end: 1).animate(a), child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B13),
      body: Stack(children: [
        const Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0B1727), Color(0xFF050B13), Color(0xFF08111D)])))),
        Positioned(top: -110, right: -80, child: _Glow(270, const Color(0xFF347EC8))),
        Positioned(bottom: -150, left: -120, child: _Glow(310, const Color(0xFF4BA3FF))),
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  _animated(0, const _BrandMark()),
                  const SizedBox(height: 20),
                  _animated(.08, const Text('ЭлектроМаркет', style: TextStyle(color: Colors.white, fontSize: 29, fontWeight: FontWeight.w700, letterSpacing: -.8))),
                  const SizedBox(height: 8),
                  _animated(.14, Text('Электротехника без лишнего шума.', textAlign: TextAlign.center, style: GoogleFonts.inter(color: Colors.white.withValues(alpha: .58), fontSize: 13, height: 1.4))),
                  const SizedBox(height: 32),
                  _animated(.22, _RoleCard(icon: Icons.person_outline_rounded, title: 'Я покупатель', subtitle: 'Вход по номеру телефона', onTap: () => context.push('/login/buyer'))),
                  const SizedBox(height: 12),
                  _animated(.34, _RoleCard(icon: Icons.storefront_outlined, title: 'Я продавец', subtitle: 'Телефон + секретный код', onTap: () => context.push('/login/seller'))),
                  const SizedBox(height: 24),
                  _animated(.48, Text('Простой вход • Понятный интерфейс • Быстрая покупка', textAlign: TextAlign.center, style: GoogleFonts.inter(color: Colors.white.withValues(alpha: .32), fontSize: 10.5))),
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _Glow extends StatelessWidget {
  final double size;
  final Color color;
  const _Glow(this.size, this.color);
  @override
  Widget build(BuildContext context) => ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: 55, sigmaY: 55), child: Container(width: size, height: size, decoration: BoxDecoration(color: color.withValues(alpha: .10), shape: BoxShape.circle)));
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();
  @override
  Widget build(BuildContext context) => Container(
    width: 78, height: 78,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF93C9FF), Color(0xFF347EC8), Color(0xFF15508F)]),
      boxShadow: [BoxShadow(color: const Color(0xFF4BA3FF).withValues(alpha: .20), blurRadius: 28, spreadRadius: 2)],
    ),
    child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 40),
  );
}

class _RoleCard extends StatelessWidget {
  final IconData icon; final String title; final String subtitle; final VoidCallback onTap;
  const _RoleCard({required this.icon, required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(20), onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .055),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: .10)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .35), blurRadius: 24, offset: const Offset(0, 10), spreadRadius: -6)],
        ),
        child: Row(children: [
          Container(width: 46, height: 46, decoration: BoxDecoration(color: const Color(0xFF4BA3FF).withValues(alpha: .12), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: const Color(0xFF9DD0FF), size: 22)),
          const SizedBox(width: 13),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: .48), fontSize: 11.5))])),
          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white.withValues(alpha: .35)),
        ]),
      ),
    ),
  );
}
