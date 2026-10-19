import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'offline_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _logoOpacity = 0.0;
  Offset _logoOffset = const Offset(0, 0.3);
  double _textOpacity = 0.0;
  Offset _textOffset = const Offset(0, 0.3);

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _logoOpacity = 1.0;
        _logoOffset = Offset.zero;
      });
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _textOpacity = 1.0;
        _textOffset = Offset.zero;
      });
    });

    _timer = Timer(const Duration(seconds: 3), () async {
      if (!mounted) return;
      await _checkAndNavigate();
    });
  }

  Future<void> _checkAndNavigate() async {
    final online = await _checkInternet();
    if (!mounted) return;

    if (online) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OfflineScreen()),
      );
    }
  }

  Future<bool> _checkInternet() async {
    try {
      final uri = Uri.parse('https://www.google.com/generate_204');
      final resp = await http.get(uri).timeout(const Duration(seconds: 3));
      return resp.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSlide(
              offset: _logoOffset,
              duration: const Duration(seconds: 2),
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                opacity: _logoOpacity,
                duration: const Duration(seconds: 2),
                child: Image.asset('assets/logo1.png', width: 300),
              ),
            ),
            const SizedBox(height: 16),
            AnimatedSlide(
              offset: _textOffset,
              duration: const Duration(seconds: 2),
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                opacity: _textOpacity,
                duration: const Duration(seconds: 2),
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(fontSize: 20, color: Colors.black87),
                    children: const [
                      TextSpan(text: "Because every "),
                      TextSpan(
                        text: "Second Matters",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1BA24A),
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            AnimatedSlide(
              offset: _textOffset,
              duration: const Duration(seconds: 2),
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                opacity: _textOpacity,
                duration: const Duration(seconds: 2),
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(fontSize: 20, color: Colors.black87),
                    children: const [
                      TextSpan(text: "لان كل"),
                      TextSpan(
                        text: "ثانية مهمة",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1BA24A),
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
