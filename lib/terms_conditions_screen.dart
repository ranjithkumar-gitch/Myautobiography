import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myautobiography/browser_history.dart';
import 'package:myautobiography/constants/colors.dart';
import 'package:myautobiography/models/terms_response.dart';
import 'package:myautobiography/terms_service.dart';
import 'package:myautobiography/theme_notifier.dart';

class TermsConditionsScreen extends StatefulWidget {
  const TermsConditionsScreen({Key? key}) : super(key: key);

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen> {
  late Future<TermsResponse> _termsFuture;

  @override
  void initState() {
    super.initState();
    _termsFuture = TermsService.fetchTerms();
  }

  void _retry() {
    setState(() => _termsFuture = TermsService.fetchTerms());
  }

  void _onBackPressed() {
    if (context.canPop()) {
      if (kIsWeb) {
        // Go back through the browser so the /terms-conditions entry is
        // removed from history; context.pop() would add a new entry instead,
        // leaving Terms reachable with the browser Back button.
        browserHistoryBack();
      } else {
        context.pop();
      }
    } else {
      // Opened directly by URL: nothing to pop. Replace this history entry
      // with the register page so Terms isn't left behind.
      Router.neglect(context, () => context.go('/register'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: kgoldColor,
          onPressed: _onBackPressed,
          tooltip: 'Back',
        ),
        centerTitle: true,
        title: ShaderMask(
          shaderCallback: (bounds) => goldTextGradient.createShader(bounds),
          child: Text(
            'Terms & Conditions',
            style: GoogleFonts.cinzel(
              color: Colors.white,
              fontSize: isWide ? 24 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.25,
              child: Image.asset('assets/bg_1411.jpg', fit: BoxFit.cover),
            ),
          ),
          SafeArea(
            child: FutureBuilder<TermsResponse>(
              future: _termsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(color: kgoldColor),
                  );
                }
                final terms = snapshot.data;
                if (snapshot.hasError ||
                    terms == null ||
                    !terms.success ||
                    terms.data == null ||
                    terms.data!.description.trim().isEmpty) {
                  return _ErrorView(
                    message:
                        terms?.message ?? 'Could not load Terms & Conditions.',
                    onRetry: _retry,
                  );
                }
                return Scrollbar(
                  thumbVisibility: isWide,
                  child: SingleChildScrollView(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isWide ? 32 : 20,
                            vertical: 24,
                          ),
                          child: HtmlWidget(
                            _toHtml(terms.data!.description),
                            textStyle: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: isWide ? 15 : 14,
                              height: 1.6,
                            ),
                            customStylesBuilder: (element) {
                              if ([
                                'h1',
                                'h2',
                                'h3',
                                'h4',
                              ].contains(element.localName)) {
                                return {'color': '#C09D41'};
                              }
                              if (element.localName == 'a') {
                                return {'color': '#C09D41'};
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: kgoldColor, size: 48),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: kgoldColor, width: 2),
                foregroundColor: kgoldColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

final _htmlTag = RegExp(
  r'<(p|br|div|h[1-6]|ul|ol|li|strong|b|a)\b',
  caseSensitive: false,
);
final _numberedHeading = RegExp(r'^\d+\.\s+\S');

// The API may return HTML or plain text. HTML is used as-is; plain text is
// converted so blank lines become paragraphs and "1. Heading" lines become headings.
String _toHtml(String content) {
  if (_htmlTag.hasMatch(content)) return content;

  String escape(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');

  final buffer = StringBuffer();
  final paragraph = <String>[];
  void flush() {
    if (paragraph.isNotEmpty) {
      buffer.write('<p>${paragraph.join('<br>')}</p>');
      paragraph.clear();
    }
  }

  var isFirstLine = true;
  for (final raw in content.split('\n')) {
    final line = raw.trim();
    if (line.isEmpty) {
      flush();
    } else if (isFirstLine) {
      buffer.write('<h2>${escape(line)}</h2>');
    } else if (_numberedHeading.hasMatch(line)) {
      flush();
      buffer.write('<h3>${escape(line)}</h3>');
    } else {
      paragraph.add(escape(line));
    }
    if (line.isNotEmpty) isFirstLine = false;
  }
  flush();
  return buffer.toString();
}
