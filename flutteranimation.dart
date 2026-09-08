import 'package:flutter/material.dart';

void main() {
  runApp(const AnimationApp());
}

class AnimationApp extends StatelessWidget {
  const AnimationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Animations',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AnimationPage(),
    );
  }
}

class AnimationPage extends StatefulWidget {
  const AnimationPage({super.key});

  @override
  State<AnimationPage> createState() => _AnimationPageState();
}

class _AnimationPageState extends State<AnimationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _fade;
  late Animation<Offset> _slide;
  late Animation<double> _scale;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);

    _slide = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(_controller);

    _scale = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(_controller);

    _rotation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);
  }

  void startAnimation() {
    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Animation Demo'),
        centerTitle: true,
      ),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Fade Animation
                FadeTransition(
                  opacity: _fade,
                  child: const Text(
                    'FADE',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Slide Animation
                SlideTransition(
                  position: _slide,
                  child: Container(
                    width: 200,
                    height: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Text(
                      'SLIDE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Scale Animation
                ScaleTransition(
                  scale: _scale,
                  child: const Icon(
                    Icons.star,
                    size: 70,
                    color: Colors.orange,
                  ),
                ),

                const SizedBox(height: 20),

                // Rotation Animation
                RotationTransition(
                  turns: _rotation,
                  child: const Icon(
                    Icons.refresh,
                    size: 70,
                    color: Colors.green,
                  ),
                ),

                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: startAnimation,
                  child: const Text(
                    'START ANIMATION',
                    style: TextStyle(fontSize: 16),
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
