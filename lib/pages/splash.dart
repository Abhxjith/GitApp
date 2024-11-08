import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  bool _showNameScreen = true;
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _fadeOut;
  late Animation<Offset> _slideIn;
  late Animation<double> _scaleText;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _navigateToHomeScreen();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    _fadeIn = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 0.5, curve: Curves.easeIn),
    ));

    _fadeOut = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.5, 1.0, curve: Curves.easeOut),
    ));

    _slideIn = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _scaleText = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _controller.forward();
  }

  void _navigateToHomeScreen() async {
    await Future.delayed(Duration(seconds: 3));
    setState(() {
      _showNameScreen = false;
    });
    await Future.delayed(Duration(seconds: 4));
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: Center(
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 1000),
          child: _showNameScreen
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SlideTransition(
                      position: _slideIn,
                      child: FadeTransition(
                        opacity: _fadeIn,
                        child: ScaleTransition(
                          scale: _scaleText,
                          child: Text(
                            'GitApp',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : FadeTransition(
                  opacity: _fadeIn,
                  child: Lottie.network(
                    'https://lottie.host/abf26072-0739-474a-849d-10299877aae2/KngcYQfqVM.json',
                    width: 400,
                    height: 400,
                  ),
                ),
        ),
      ),
    );
  }
}