import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ---------------------------------------------------------------------------
// Palette
// ---------------------------------------------------------------------------
const kNavy = Color(0xFF0B2E86);
const kDeepNavy = Color(0xFF0A1F52);
const kInk = Color(0xFF0C1B3F);
const kSky = Color(0xFF4F8CF0);
const kPaper = Color(0xFFF4EDE0);

void main() => runApp(const VossiesVibeApp());

class VossiesVibeApp extends StatelessWidget {
  const VossiesVibeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vossie Vibe',
      home: FrontPage(onEnter: () {}, onLogin: () {}),
    );
  }
}

// ---------------------------------------------------------------------------
// Front page
// ---------------------------------------------------------------------------
class FrontPage extends StatelessWidget {
  const FrontPage({super.key, required this.onEnter, required this.onLogin});

  final VoidCallback onEnter;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDeepNavy,
      body: LayoutBuilder(
        builder: (context, box) {
          final h = box.maxHeight;
          final panelHeight = h * 0.36;

          return Stack(
            fit: StackFit.expand,
            children: [
              // ---- Background photo -------------------------------------
              Image.asset(
                'assets/images/campus_bg.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (_, _, _) => const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF2A6FD6), Color(0xFF7FA97A)],
                    ),
                  ),
                ),
              ),
              // Blue tint so the white/paper elements pop
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      kNavy.withValues(alpha: 0.55),
                      kNavy.withValues(alpha: 0.10),
                      kNavy.withValues(alpha: 0.25),
                    ],
                    stops: const [0, 0.4, 1],
                  ),
                ),
              ),

              // ---- Top-left handwritten tagline -------------------------
              Positioned(
                top: MediaQuery.of(context).padding.top + 44,
                left: 22,
                child: Transform.rotate(
                  angle: -0.22,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good\nthings\nhappen\nhere.',
                        style: GoogleFonts.caveat(
                          color: Colors.white,
                          fontSize: 24,
                          height: 1.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 34),
                        child: SizedBox(
                          width: 28,
                          height: 22,
                          child: CustomPaint(
                            painter: CrownPainter(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ---- Top-right star doodle --------------------------------
              Positioned(
                top: MediaQuery.of(context).padding.top + 34,
                right: 16,
                child: Transform.rotate(
                  angle: 0.3,
                  child: const Icon(
                    Icons.star_border_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),

              // ---- Logo sticker -----------------------------------------
              Positioned(
                top: h * 0.155,
                left: 18,
                right: 14,
                child: Transform.rotate(
                  angle: -0.07,
                  child: const LogoSticker(),
                ),
              ),

              // ---- "Campus marketplace" note ----------------------------
              Positioned(
                top: h * 0.455,
                left: 52,
                right: 34,
                child: Transform.rotate(angle: -0.035, child: const NoteCard()),
              ),

              // ---- Bottom torn blue panel -------------------------------
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: panelHeight,
                child: _BottomPanel(onEnter: onEnter, onLogin: onLogin),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Logo
// ---------------------------------------------------------------------------
class LogoSticker extends StatelessWidget {
  const LogoSticker({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // white torn outline
        TornPaper(
          color: Colors.white,
          seed: 7,
          amplitude: 7,
          child: Padding(
            padding: const EdgeInsets.all(9),
            // navy torn inner
            child: TornPaper(
              color: kInk,
              seed: 21,
              amplitude: 4,
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'VOSSIE VIBE',
                        style: GoogleFonts.permanentMarker(
                          color: Colors.white,
                          fontSize: 56,
                          height: 1.0,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 34),
                        child: Text(
                          'ViBE',
                          style: GoogleFonts.permanentMarker(
                            color: kSky,
                            fontSize: 56,
                            height: 0.95,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // crown above the "V"
        Positioned(
          top: -8,
          left: 46,
          child: Transform.rotate(
            angle: -0.08,
            child: SizedBox(
              width: 44,
              height: 34,
              child: CustomPaint(
                painter: CrownPainter(
                  color: kSky,
                  stroke: 3.2,
                  fill: kInk,
                  outline: Colors.white,
                ),
              ),
            ),
          ),
        ),
        // heart doodle
        const Positioned(
          right: 26,
          bottom: 26,
          child: Icon(Icons.favorite_border_rounded, color: kSky, size: 22),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Note card
// ---------------------------------------------------------------------------
class NoteCard extends StatelessWidget {
  const NoteCard({super.key});

  @override
  Widget build(BuildContext context) {
    final bullet = GoogleFonts.patrickHand(
      color: kInk,
      fontSize: 19,
      height: 1.25,
      fontWeight: FontWeight.w700,
    );

    return TornPaper(
      color: kPaper,
      seed: 3,
      amplitude: 5,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 16, 16),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Campus marketplace',
                  style: GoogleFonts.patrickHand(
                    color: kInk,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text('•  Student businesses', style: bullet),
                Text('•  Real people', style: bullet),
                Text('•  Good vibes', style: bullet),
              ],
            ),
            const Positioned(
              right: 4,
              bottom: 2,
              child: Icon(Icons.favorite_border_rounded, color: kInk, size: 30),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom panel (torn edge, CTA, login link, signature)
// ---------------------------------------------------------------------------
class _BottomPanel extends StatelessWidget {
  const _BottomPanel({required this.onEnter, required this.onLogin});

  final VoidCallback onEnter;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // pale torn strip peeking above the blue
        Positioned.fill(
          child: ClipPath(
            clipper: TornClipper(seed: 11, amplitude: 14, top: true),
            child: Container(color: const Color(0xFFD9E2F2)),
          ),
        ),
        Positioned.fill(
          top: 8,
          child: ClipPath(
            clipper: TornClipper(seed: 5, amplitude: 12, top: true),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0E3A9E), Color(0xFF0A2A78)],
                ),
              ),
            ),
          ),
        ),

        // bottom-right grey torn corner
        Positioned(
          right: 0,
          bottom: 0,
          width: 130,
          height: 84,
          child: ClipPath(
            clipper: TornClipper(
              seed: 31,
              amplitude: 12,
              top: true,
              left: true,
            ),
            child: Container(
              color: const Color(0xFFB7BFCD).withValues(alpha: 0.85),
            ),
          ),
        ),

        // CTA + login
        Positioned(
          left: 24,
          right: 24,
          top: 54,
          child: Column(
            children: [
              _EnterButton(onTap: onEnter),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: onLogin,
                behavior: HitTestBehavior.opaque,
                child: Text.rich(
                  TextSpan(
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                    children: const [
                      TextSpan(text: 'Already have an account? '),
                      TextSpan(
                        text: 'Log in',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // signature
        Positioned(
          left: 26,
          bottom: 26,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Transform.rotate(
                angle: -0.14,
                child: Text(
                  'Eduvos',
                  style: GoogleFonts.caveat(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 22),
                child: Icon(
                  Icons.favorite_border_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EnterButton extends StatelessWidget {
  const _EnterButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kNavy,
      shape: const StadiumBorder(
        side: BorderSide(color: Colors.white, width: 1.6),
      ),
      elevation: 6,
      shadowColor: Colors.black54,
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: SizedBox(
          height: 58,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ENTER THE VIBE',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Torn paper helpers
// ---------------------------------------------------------------------------

/// Paper-coloured widget with a ripped, irregular outline and a soft shadow.
class TornPaper extends StatelessWidget {
  const TornPaper({
    super.key,
    required this.child,
    required this.color,
    this.seed = 1,
    this.amplitude = 6,
    this.elevation = 6,
  });

  final Widget child;
  final Color color;
  final int seed;
  final double amplitude;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return PhysicalShape(
      clipper: TornClipper(
        seed: seed,
        amplitude: amplitude,
        top: true,
        bottom: true,
        left: true,
        right: true,
      ),
      color: color,
      elevation: elevation,
      shadowColor: Colors.black54,
      child: child,
    );
  }
}

/// Builds a jagged outline. Choose which edges are ripped; the others stay
/// straight (e.g. the bottom panel only rips its top edge).
class TornClipper extends CustomClipper<Path> {
  TornClipper({
    this.seed = 1,
    this.amplitude = 8,
    this.step = 9,
    this.top = false,
    this.bottom = false,
    this.left = false,
    this.right = false,
  });

  final int seed;
  final double amplitude;
  final double step;
  final bool top, bottom, left, right;

  @override
  Path getClip(Size size) {
    final r = Random(seed);
    double j() => r.nextDouble() * amplitude;
    final w = size.width;
    final h = size.height;
    final path = Path();

    // top edge (left -> right)
    path.moveTo(0, top ? j() : 0);
    if (top) {
      for (double x = step; x < w; x += step) {
        path.lineTo(x, j());
      }
    }
    path.lineTo(w, top ? j() : 0);

    // right edge (top -> bottom)
    if (right) {
      for (double y = step; y < h; y += step) {
        path.lineTo(w - j(), y);
      }
    }
    path.lineTo(w, bottom ? h - j() : h);

    // bottom edge (right -> left)
    if (bottom) {
      for (double x = w - step; x > 0; x -= step) {
        path.lineTo(x, h - j());
      }
    }
    path.lineTo(0, bottom ? h - j() : h);

    // left edge (bottom -> top)
    if (left) {
      for (double y = h - step; y > 0; y -= step) {
        path.lineTo(j(), y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant TornClipper old) =>
      old.seed != seed ||
      old.amplitude != amplitude ||
      old.top != top ||
      old.bottom != bottom ||
      old.left != left ||
      old.right != right;
}

// ---------------------------------------------------------------------------
// Crown doodle
// ---------------------------------------------------------------------------
class CrownPainter extends CustomPainter {
  CrownPainter({
    required this.color,
    this.stroke = 2.4,
    this.fill,
    this.outline,
  });

  final Color color;
  final double stroke;
  final Color? fill;
  final Color? outline;

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;

    final path = Path()
      ..moveTo(w * 0.08, h * 0.95)
      ..lineTo(w * 0.02, h * 0.18)
      ..lineTo(w * 0.28, h * 0.55)
      ..lineTo(w * 0.50, h * 0.02)
      ..lineTo(w * 0.72, h * 0.55)
      ..lineTo(w * 0.98, h * 0.18)
      ..lineTo(w * 0.92, h * 0.95)
      ..close();

    if (fill != null) {
      canvas.drawPath(path, Paint()..color = fill!);
    }
    if (outline != null) {
      canvas.drawPath(
        path,
        Paint()
          ..color = outline!
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke + 3
          ..strokeJoin = StrokeJoin.round,
      );
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CrownPainter old) =>
      old.color != color || old.stroke != stroke;
}
