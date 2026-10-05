import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myautobiography/social_links.dart';
import 'package:myautobiography/theme_notifier.dart';

/// Site footer: legal links, social links and copyright line.
class AppFooter extends StatelessWidget {
  final bool isWide;
  const AppFooter({super.key, required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // No fill, so the page's star background shows through.
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: isWide ? 20 : 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: isWide ? 48 : 24,
            runSpacing: 8,
            children: [
              _FooterLink(
                label: 'Terms & Conditions',
                isWide: isWide,
                onTap: () => context.push('/terms-conditions'),
              ),
              _FooterLink(
                label: 'Privacy Policy',
                isWide: isWide,
                onTap: () => context.push('/privacy-policy'),
              ),
            ],
          ),
          SizedBox(height: isWide ? 16 : 20),
          SocialLinks(isWide: isWide),
          SizedBox(height: isWide ? 16 : 20),
          Text(
            '© 2026 My Autobiography. All rights reserved.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white60,
              fontSize: isWide ? 12 : 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatefulWidget {
  final String label;
  final bool isWide;
  final VoidCallback onTap;
  const _FooterLink({
    required this.label,
    required this.isWide,
    required this.onTap,
  });

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      link: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 150),
              style: GoogleFonts.poppins(
                color: _hovered ? kgoldColor : Colors.white70,
                fontSize: widget.isWide ? 14 : 13,
              ),
              child: Text(widget.label),
            ),
          ),
        ),
      ),
    );
  }
}
