import 'package:flutter/material.dart';

import 'login_screen.dart';

const _navy = Color(0xFF123D73);

class NewWelcomePage extends StatelessWidget {
  const NewWelcomePage({super.key});

  void _openLogin(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            return Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'lib/newwelcomepage/pictures/dc482783-6eec-4bf0-8163-4563ccfd46a9.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
                Positioned(
                  top: height * 0.06,
                  left: width * 0.07,
                  child: Transform.rotate(
                    angle: -0.08,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final word in const ['SHOP', 'SUPPORT', 'CONNECT'])
                          Text(
                            word,
                            style: TextStyle(
                              color: _navy,
                              fontSize: (width * 0.06).clamp(18.0, 34.0),
                              fontWeight: FontWeight.w900,
                              height: 0.95,
                              letterSpacing: 1,
                            ),
                          ),
                        Container(
                          width: 100,
                          height: 5,
                          margin: const EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                            color: _navy,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: height * 0.05,
                  left: 0,
                  right: 0,
                  child: const Text(
                    '♛',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _navy, fontSize: 64, height: 1),
                  ),
                ),
                Positioned(
                  top: height * 0.08,
                  right: width * 0.08,
                  child: const Text(
                    '☆',
                    style: TextStyle(color: _navy, fontSize: 56, height: 1),
                  ),
                ),
                Positioned(
                  top: height * 0.28,
                  left: 0,
                  right: 0,
                  child: Transform.rotate(
                    angle: -0.05,
                    child: Text(
                      'Your campus.\nYour people.\nYour businesses.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _navy,
                        fontSize: (width * 0.055).clamp(20.0, 32.0),
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                        height: 1.15,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: height * 0.12,
                  left: width * 0.31,
                  width: width * 0.38,
                  height: height * 0.15,
                  child: Image.asset(
                    'lib/newwelcomepage/pictures/Image__7_-removebg-preview (1).png',
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  bottom: height * 0.10,
                  left: width * 0.08,
                  width: width * 0.84,
                  height: height * 0.43,
                  child: Image.asset(
                    'lib/newwelcomepage/pictures/campus.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomCenter,
                  ),
                ),
                Positioned(
                  top: height * 0.46,
                  right: width * 0.06,
                  child: Transform.rotate(
                    angle: 0.08,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF4E7),
                        border: Border.all(
                          color: _navy.withValues(alpha: 0.12),
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Text(
                        'EDUVOS\nDURBAN',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _navy,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: height * 0.34,
                  right: width * 0.10,
                  child: const Text(
                    '♡',
                    style: TextStyle(color: _navy, fontSize: 58, height: 1),
                  ),
                ),
                Positioned(
                  left: width * 0.07,
                  top: height * 0.43,
                  child: Transform.rotate(
                    angle: -0.35,
                    child: const Text(
                      '╱╲',
                      style: TextStyle(color: _navy, fontSize: 34),
                    ),
                  ),
                ),
                Positioned(
                  right: width * 0.06,
                  top: height * 0.61,
                  child: const Text(
                    '✦',
                    style: TextStyle(color: _navy, fontSize: 34),
                  ),
                ),
                Positioned(
                  left: width * 0.10,
                  right: width * 0.10,
                  bottom: height * 0.035,
                  child: SizedBox(
                    height: 58,
                    child: ElevatedButton(
                      onPressed: () => _openLogin(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _navy,
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 3),
                        shape: const StadiumBorder(),
                        elevation: 8,
                        textStyle: TextStyle(
                          fontSize: (width * 0.045).clamp(16.0, 22.0),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      child: const Text('ENTER THE VIBE  →'),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
