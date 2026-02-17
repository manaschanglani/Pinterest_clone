import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _bottomController;

  late final Animation<double> _floatAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _bottomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _floatAnimation =
        Tween<double>(begin: -8, end: 8).animate(
          CurvedAnimation(
            parent: _floatController,
            curve: Curves.easeInOut,
          ),
        );

    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _bottomController,
            curve: Curves.easeOutCubic,
          ),
        );

    _fadeAnimation =
        Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _bottomController,
            curve: Curves.easeIn,
          ),
        );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _bottomController.forward();
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    _bottomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Stack(
                  children: [
                    _positionedImage(
                      top: -30 + _floatAnimation.value,
                      left: -40,
                      url:
                      'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
                      size: 200,
                    ),
                    _positionedImage(
                      top: -20 - _floatAnimation.value,
                      right: -60,
                      url:
                      'https://images.unsplash.com/photo-1492724441997-5dc865305da7',
                      size: 200,
                    ),
                    _positionedImage(
                      bottom: 0 + _floatAnimation.value,
                      left: -20,
                      url:
                      'https://images.unsplash.com/photo-1519681393784-d120267933ba',
                      size: 200,
                    ),
                    _positionedImage(
                      bottom: -50 - _floatAnimation.value,
                      right: -40,
                      url:
                      'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee',
                      size: 180,
                    ),
                    Center(
                      child: Transform.translate(
                        offset: Offset(0, _floatAnimation.value),
                        child: _buildImage(
                          'https://plus.unsplash.com/premium_photo-1682621097202-eca012076ff2?w=900&auto=format&fit=crop&q=60',
                          250,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          Expanded(
            flex: 4,
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.network(
                        'https://static.vecteezy.com/system/resources/previews/018/930/468/non_2x/pinterest-logo-pinterest-transparent-free-png.png',
                        width: 85,
                        height: 85,
                      ),
                      const Column(
                        children: [
                          Text(
                            'Create a life',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'you love',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () =>
                                  context.push('/signup'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                Theme.of(context)
                                    .colorScheme
                                    .primary,
                                foregroundColor:
                                Colors.white,
                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius
                                      .circular(16),
                                ),
                              ),
                              child: const Text(
                                'Sign up',
                                style: TextStyle(
                                    fontWeight:
                                    FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () =>
                                  context.push('/login'),
                              style:
                              OutlinedButton.styleFrom(
                                foregroundColor:
                                Colors.black,
                                side:
                                const BorderSide(
                                    color:
                                    Colors.black12),
                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius
                                      .circular(16),
                                ),
                              ),
                              child: const Text(
                                'Log in',
                                style: TextStyle(
                                    fontWeight:
                                    FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "By continuing, you agree to Pinterest's Terms of Service and acknowledge you've read our Privacy Policy.",
                            textAlign:
                            TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight:
                              FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
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

  Widget _positionedImage({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required String url,
    required double size,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: _buildImage(url, size),
    );
  }

  Widget _buildImage(String url, double size) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}
