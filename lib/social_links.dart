import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:myautobiography/theme_notifier.dart';

class _SocialLink {
  final String name;
  final FaIconData icon;
  final String url;
  const _SocialLink(this.name, this.icon, this.url);
}

const _links = [
  _SocialLink(
    'Instagram',
    FontAwesomeIcons.instagram,
    'https://www.instagram.com/myautobiography.official/',
  ),
  _SocialLink(
    'Facebook',
    FontAwesomeIcons.facebookF,
    'https://www.facebook.com/myautobiography.official',
  ),
  _SocialLink(
    'LinkedIn',
    FontAwesomeIcons.linkedinIn,
    'https://www.linkedin.com/company/myautobiography/',
  ),
  _SocialLink(
    'TikTok',
    FontAwesomeIcons.tiktok,
    'https://www.tiktok.com/@myautobiography.com',
  ),
];

/// Row of gold, circular social media buttons that open in a new tab.
class SocialLinks extends StatelessWidget {
  final bool isWide;
  const SocialLinks({super.key, required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final link in _links)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _SocialButton(link: link, size: isWide ? 44 : 40),
          ),
      ],
    );
  }
}

class _SocialButton extends StatefulWidget {
  final _SocialLink link;
  final double size;
  const _SocialButton({required this.link, required this.size});

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _hovered = false;

  Future<void> _open() async {
    final opened = await launchUrl(
      Uri.parse(widget.link.url),
      // The web only supports the default mode (a new tab via
      // webOnlyWindowName); native apps open the social media app when
      // installed.
      mode: kIsWeb
          ? LaunchMode.platformDefault
          : LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    );
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open ${widget.link.name}.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.link.name,
      child: Semantics(
        link: true,
        label: widget.link.name,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            onTap: _open,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _hovered
                    ? kgoldColor
                    : Colors.black.withValues(alpha: 0.4),
                border: Border.all(color: kgoldColor, width: 1.5),
              ),
              alignment: Alignment.center,
              child: FaIcon(
                widget.link.icon,
                size: widget.size * 0.45,
                color: _hovered ? Colors.black : kgoldColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
