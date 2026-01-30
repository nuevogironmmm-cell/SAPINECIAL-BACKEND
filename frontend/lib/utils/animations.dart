import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

/// ============================================================
/// SISTEMA DE ANIMACIONES EDUCATIVAS
/// ============================================================
/// Diseñado para reforzar el aprendizaje sin distraer.
/// Cada animación tiene un propósito pedagógico específico.
/// ============================================================

// ============================================================
// DURACIÓN DE ANIMACIONES (Consistencia UX)
// ============================================================

class AnimationDurations {
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration emphasis = Duration(milliseconds: 700);
}

// ============================================================
// CURVAS PERSONALIZADAS (Sensación natural)
// ============================================================

class AnimationCurves {
  static const Curve smooth = Curves.easeInOutCubic;
  static const Curve bounce = Curves.elasticOut;
  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve attention = Curves.easeInOutBack;
}

// ============================================================
// WIDGET: FADE IN SLIDE (Entrada suave con deslizamiento)
// Uso pedagógico: Introduce contenido nuevo de forma gradual,
// permitiendo que el estudiante procese la información.
// ============================================================

class FadeInSlide extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Offset beginOffset;
  final Curve curve;

  const FadeInSlide({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.delay = Duration.zero,
    this.beginOffset = const Offset(0, 0.1),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<FadeInSlide> createState() => _FadeInSlideState();
}

class _FadeInSlideState extends State<FadeInSlide>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

// ============================================================
// WIDGET: SCALE IN (Entrada con escala)
// Uso pedagógico: Resalta elementos importantes como títulos
// o respuestas correctas, captando la atención del estudiante.
// ============================================================

class ScaleIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final double beginScale;
  final Curve curve;

  const ScaleIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 350),
    this.delay = Duration.zero,
    this.beginScale = 0.8,
    this.curve = Curves.easeOutBack,
  });

  @override
  State<ScaleIn> createState() => _ScaleInState();
}

class _ScaleInState extends State<ScaleIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.beginScale,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

// ============================================================
// WIDGET: ANIMATED BUTTON (Botón con micro-interacciones)
// Uso pedagógico: Feedback táctil inmediato que confirma
// las acciones del usuario, reduciendo incertidumbre.
// ============================================================

class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color? pressedColor;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final double elevation;

  const AnimatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor = const Color(0xFFC5A065),
    this.pressedColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(15)),
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    this.elevation = 4,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? _handleTapDown : null,
      onTapUp: widget.onPressed != null ? _handleTapUp : null,
      onTapCancel: widget.onPressed != null ? _handleTapCancel : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: _isPressed
                ? (widget.pressedColor ?? widget.backgroundColor.withOpacity(0.8))
                : widget.backgroundColor,
            borderRadius: widget.borderRadius,
            boxShadow: [
              BoxShadow(
                color: widget.backgroundColor.withOpacity(_isPressed ? 0.2 : 0.4),
                blurRadius: _isPressed ? 4 : widget.elevation * 2,
                offset: Offset(0, _isPressed ? 2 : widget.elevation),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// ============================================================
// WIDGET: PULSE ANIMATION (Pulso de atención)
// Uso pedagógico: Llama la atención sobre elementos
// importantes sin ser intrusivo. Ideal para respuestas correctas.
// ============================================================

class PulseAnimation extends StatefulWidget {
  final Widget child;
  final bool animate;
  final Duration duration;
  final double minScale;
  final double maxScale;

  const PulseAnimation({
    super.key,
    required this.child,
    this.animate = true,
    this.duration = const Duration(milliseconds: 1000),
    this.minScale = 1.0,
    this.maxScale = 1.05,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PulseAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}

// ============================================================
// WIDGET: SUCCESS CELEBRATION (Celebración de �éxito)
// Uso pedagógico: Refuerzo positivo visual que motiva al
// estudiante y celebra sus logros de aprendizaje.
// ============================================================

class SuccessCelebration extends StatefulWidget {
  final Widget child;
  final bool celebrate;
  final VoidCallback? onComplete;

  const SuccessCelebration({
    super.key,
    required this.child,
    this.celebrate = false,
    this.onComplete,
  });

  @override
  State<SuccessCelebration> createState() => _SuccessCelebrationState();
}

class _SuccessCelebrationState extends State<SuccessCelebration>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _glowController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 0.95), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.05), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeOut),
    );

    _bounceController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(SuccessCelebration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.celebrate && !oldWidget.celebrate) {
      _bounceController.forward(from: 0);
      _glowController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_bounceAnimation, _glowAnimation]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: widget.celebrate
                ? [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.5 * _glowAnimation.value),
                      blurRadius: 30 * _glowAnimation.value,
                      spreadRadius: 5 * _glowAnimation.value,
                    ),
                  ]
                : null,
          ),
          child: Transform.scale(
            scale: _bounceAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

// ============================================================
// WIDGET: SHAKE ANIMATION (Sacudida para error)
// Uso pedagógico: Feedback negativo suave que indica error
// sin ser punitivo, invitando a intentar de nuevo.
// ============================================================

class ShakeAnimation extends StatefulWidget {
  final Widget child;
  final bool shake;
  final VoidCallback? onComplete;

  const ShakeAnimation({
    super.key,
    required this.child,
    this.shake = false,
    this.onComplete,
  });

  @override
  State<ShakeAnimation> createState() => _ShakeAnimationState();
}

class _ShakeAnimationState extends State<ShakeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 5), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 5, end: 0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(ShakeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shake && !oldWidget.shake) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value, 0),
          child: widget.child,
        );
      },
    );
  }
}

// ============================================================
// WIDGET: STAGGERED LIST (Lista con entrada escalonada)
// Uso pedagógico: Presenta opciones de forma secuencial,
// permitiendo al estudiante procesar cada una.
// ============================================================

class StaggeredList extends StatelessWidget {
  final List<Widget> children;
  final Duration itemDelay;
  final Duration itemDuration;
  final Offset beginOffset;

  const StaggeredList({
    super.key,
    required this.children,
    this.itemDelay = const Duration(milliseconds: 100),
    this.itemDuration = const Duration(milliseconds: 400),
    this.beginOffset = const Offset(0.3, 0),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(children.length, (index) {
        return FadeInSlide(
          duration: itemDuration,
          delay: Duration(milliseconds: itemDelay.inMilliseconds * index),
          beginOffset: beginOffset,
          child: children[index],
        );
      }),
    );
  }
}

// ============================================================
// WIDGET: PROGRESS INDICATOR ANIMATED (Indicador de progreso)
// Uso pedagógico: Muestra el avance de forma visual,
// motivando al estudiante a completar la lección.
// ============================================================

class AnimatedProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Color backgroundColor;
  final Color progressColor;
  final Duration duration;
  final BorderRadius borderRadius;

  const AnimatedProgressBar({
    super.key,
    required this.progress,
    this.height = 8,
    this.backgroundColor = Colors.white12,
    this.progressColor = const Color(0xFFC5A065),
    this.duration = const Duration(milliseconds: 500),
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              AnimatedContainer(
                duration: duration,
                curve: Curves.easeInOutCubic,
                width: constraints.maxWidth * progress.clamp(0.0, 1.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      progressColor,
                      progressColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: borderRadius,
                  boxShadow: [
                    BoxShadow(
                      color: progressColor.withOpacity(0.5),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// WIDGET: SLIDE TRANSITION WRAPPER (Transición entre slides)
// Uso pedagógico: Transición suave entre contenidos que
// mantiene la continuidad del aprendizaje.
// ============================================================

class SlideTransitionWrapper extends StatelessWidget {
  final Widget child;
  final String slideKey;

  const SlideTransitionWrapper({
    super.key,
    required this.child,
    required this.slideKey,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(slideKey),
        child: child,
      ),
    );
  }
}

// ============================================================
// WIDGET: CONFETTI BURST (Explosión de confeti para logros)
// Uso pedagógico: Celebración visual para logros importantes
// que genera satisfacción y motivación.
// ============================================================

class ConfettiBurst extends StatefulWidget {
  final bool trigger;
  final Widget child;

  const ConfettiBurst({
    super.key,
    required this.trigger,
    required this.child,
  });

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with TickerProviderStateMixin {
  final List<_ConfettiParticle> _particles = [];
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(ConfettiBurst oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _generateParticles();
      _controller.forward(from: 0);
    }
  }

  void _generateParticles() {
    final random = math.Random();
    _particles.clear();
    for (int i = 0; i < 20; i++) {
      _particles.add(_ConfettiParticle(
        color: [
          Colors.green,
          Colors.amber,
          Colors.blue,
          Colors.pink,
          Colors.purple,
        ][random.nextInt(5)],
        angle: random.nextDouble() * math.pi * 2,
        speed: 100 + random.nextDouble() * 150,
        size: 6 + random.nextDouble() * 6,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        if (_particles.isNotEmpty)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _ConfettiPainter(
                  particles: _particles,
                  progress: _controller.value,
                ),
                size: Size.infinite,
              );
            },
          ),
      ],
    );
  }
}

class _ConfettiParticle {
  final Color color;
  final double angle;
  final double speed;
  final double size;

  _ConfettiParticle({
    required this.color,
    required this.angle,
    required this.speed,
    required this.size,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    for (final particle in particles) {
      final distance = particle.speed * progress;
      final gravity = 200 * progress * progress;
      final x = center.dx + math.cos(particle.angle) * distance;
      final y = center.dy + math.sin(particle.angle) * distance + gravity;
      
      final paint = Paint()
        ..color = particle.color.withOpacity(1 - progress)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(x, y), particle.size * (1 - progress * 0.5), paint);
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => 
      oldDelegate.progress != progress;
}

// ============================================================
// WIDGET: TYPING TEXT (Texto que aparece letra por letra)
// Uso pedagógico: Simula escritura en tiempo real, 
// manteniendo la atención en textos importantes.
// ============================================================

class TypingText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration characterDelay;
  final VoidCallback? onComplete;

  const TypingText({
    super.key,
    required this.text,
    this.style,
    this.characterDelay = const Duration(milliseconds: 50),
    this.onComplete,
  });

  @override
  State<TypingText> createState() => _TypingTextState();
}

class _TypingTextState extends State<TypingText> {
  String _displayedText = '';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() async {
    for (int i = 0; i <= widget.text.length; i++) {
      if (!mounted) return;
      await Future.delayed(widget.characterDelay);
      if (!mounted) return;
      setState(() {
        _currentIndex = i;
        _displayedText = widget.text.substring(0, i);
      });
    }
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      style: widget.style,
    );
  }
}

// ============================================================
// WIDGET: CONFETI DE PANTALLA COMPLETA (Celebración épica)
// Uso pedagógico: Celebración máxima al completar todas las
// lecciones o lograr puntaje perfecto.
// ============================================================

class FullScreenConfetti extends StatefulWidget {
  final bool trigger;
  final Duration duration;
  final int particleCount;
  final VoidCallback? onComplete;

  const FullScreenConfetti({
    super.key,
    required this.trigger,
    this.duration = const Duration(seconds: 3),
    this.particleCount = 100,
    this.onComplete,
  });

  @override
  State<FullScreenConfetti> createState() => _FullScreenConfettiState();
}

class _FullScreenConfettiState extends State<FullScreenConfetti>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<_FullConfettiParticle> _particles = [];
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!mounted) return;
        setState(() => _isAnimating = false);
        widget.onComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(FullScreenConfetti oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger && !_isAnimating) {
      _startConfetti();
    }
  }

  void _startConfetti() {
    final random = math.Random();
    _particles.clear();
    
    final colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.cyan,
      Colors.amber,
      Colors.teal,
    ];
    
    for (int i = 0; i < widget.particleCount; i++) {
      _particles.add(_FullConfettiParticle(
        x: random.nextDouble(),
        y: -0.1 - random.nextDouble() * 0.3,
        color: colors[random.nextInt(colors.length)],
        size: 8 + random.nextDouble() * 8,
        speedY: 0.3 + random.nextDouble() * 0.4,
        speedX: (random.nextDouble() - 0.5) * 0.2,
        rotation: random.nextDouble() * math.pi * 2,
        rotationSpeed: (random.nextDouble() - 0.5) * 0.3,
        shape: random.nextInt(3), // 0: circle, 1: square, 2: star
      ));
    }
    
    setState(() => _isAnimating = true);
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAnimating) return const SizedBox.shrink();
    
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _FullConfettiPainter(
                particles: _particles,
                progress: _controller.value,
              ),
              size: Size.infinite,
            );
          },
        ),
      ),
    );
  }
}

class _FullConfettiParticle {
  double x;
  double y;
  final Color color;
  final double size;
  final double speedY;
  final double speedX;
  double rotation;
  final double rotationSpeed;
  final int shape;

  _FullConfettiParticle({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.speedY,
    required this.speedX,
    required this.rotation,
    required this.rotationSpeed,
    required this.shape,
  });
}

class _FullConfettiPainter extends CustomPainter {
  final List<_FullConfettiParticle> particles;
  final double progress;

  _FullConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final currentY = particle.y + particle.speedY * progress * 2;
      final currentX = particle.x + particle.speedX * progress + 
                       math.sin(progress * math.pi * 4) * 0.02;
      final currentRotation = particle.rotation + particle.rotationSpeed * progress * 10;
      
      if (currentY > 1.2) continue;
      
      final x = currentX * size.width;
      final y = currentY * size.height;
      
      final paint = Paint()
        ..color = particle.color.withOpacity(math.max(0, 1 - progress * 0.5))
        ..style = PaintingStyle.fill;
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(currentRotation);
      
      switch (particle.shape) {
        case 0: // Circle
          canvas.drawCircle(Offset.zero, particle.size / 2, paint);
          break;
        case 1: // Square
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: particle.size, height: particle.size),
            paint,
          );
          break;
        case 2: // Star
          _drawStar(canvas, particle.size / 2, paint);
          break;
      }
      
      canvas.restore();
    }
  }
  
  void _drawStar(Canvas canvas, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 4 * math.pi / 5) - math.pi / 2;
      final point = Offset(
        math.cos(angle) * radius,
        math.sin(angle) * radius,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_FullConfettiPainter oldDelegate) => 
      oldDelegate.progress != progress;
}

// ============================================================
// WIDGET: COUNTDOWN TIMER (Temporizador con cuenta regresiva)
// Uso pedagógico: Añade urgencia a las actividades y
// otorga bonus por responder rápidamente.
// ============================================================

class CountdownTimer extends StatefulWidget {
  final int totalSeconds;
  final VoidCallback? onComplete;
  final Function(int remainingSeconds)? onTick;
  final bool autoStart;
  final Color? backgroundColor;
  final Color? progressColor;
  final Color? textColor;
  final double size;

  const CountdownTimer({
    super.key,
    required this.totalSeconds,
    this.onComplete,
    this.onTick,
    this.autoStart = true,
    this.backgroundColor,
    this.progressColor,
    this.textColor,
    this.size = 80,
  });

  @override
  State<CountdownTimer> createState() => CountdownTimerState();
}

class CountdownTimerState extends State<CountdownTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _remainingSeconds = 0;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.totalSeconds;
    _controller = AnimationController(
      duration: Duration(seconds: widget.totalSeconds),
      vsync: this,
    );
    
    if (widget.autoStart) {
      start();
    }
  }

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _controller.forward();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _remainingSeconds--;
        widget.onTick?.call(_remainingSeconds);
      });
      
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _isRunning = false;
        widget.onComplete?.call();
      }
    });
  }

  void pause() {
    _timer?.cancel();
    _controller.stop();
    _isRunning = false;
  }

  void reset() {
    _timer?.cancel();
    _controller.reset();
    setState(() {
      _remainingSeconds = widget.totalSeconds;
      _isRunning = false;
    });
  }

  void stop() {
    _timer?.cancel();
    _controller.stop();
    _isRunning = false;
  }
  
  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = _remainingSeconds / widget.totalSeconds;
    final isUrgent = _remainingSeconds <= 10;
    final isCritical = _remainingSeconds <= 5;
    
    final bgColor = widget.backgroundColor ?? Colors.white.withOpacity(0.1);
    final progressColor = widget.progressColor ?? 
        (isCritical ? Colors.red : (isUrgent ? Colors.orange : theme.colorScheme.primary));
    final txtColor = widget.textColor ?? 
        (isCritical ? Colors.red : (isUrgent ? Colors.orange : Colors.white));
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: isCritical ? 1.1 : 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: isCritical ? (1.0 + math.sin(DateTime.now().millisecondsSinceEpoch / 100) * 0.05) : scale,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bgColor,
              border: Border.all(
                color: progressColor.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: isUrgent ? [
                BoxShadow(
                  color: progressColor.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ] : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Progress circle
                SizedBox(
                  width: widget.size - 8,
                  height: widget.size - 8,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 4,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation(progressColor),
                  ),
                ),
                // Time text
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$_remainingSeconds',
                      style: TextStyle(
                        color: txtColor,
                        fontSize: widget.size * 0.35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'seg',
                      style: TextStyle(
                        color: txtColor.withOpacity(0.7),
                        fontSize: widget.size * 0.15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// WIDGET: RANKING LEADERBOARD (Tabla de posiciones)
// Uso pedagógico: Gamificación que motiva a los estudiantes
// mostrando su posición relativa en tiempo real.
// ============================================================

class RankingEntry {
  final String name;
  final double percentage;
  final String icon;
  final bool isCurrentUser;
  final int position;

  RankingEntry({
    required this.name,
    required this.percentage,
    required this.icon,
    this.isCurrentUser = false,
    this.position = 0,
  });
}

class LeaderboardWidget extends StatelessWidget {
  final List<RankingEntry> entries;
  final int maxVisible;
  final String? currentUserName;

  const LeaderboardWidget({
    super.key,
    required this.entries,
    this.maxVisible = 5,
    this.currentUserName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Ordenar por porcentaje descendente
    final sortedEntries = List<RankingEntry>.from(entries)
      ..sort((a, b) => b.percentage.compareTo(a.percentage));
    
    // Asignar posiciones
    final rankedEntries = sortedEntries.asMap().entries.map((e) {
      return RankingEntry(
        name: e.value.name,
        percentage: e.value.percentage,
        icon: e.value.icon,
        isCurrentUser: e.value.name == currentUserName,
        position: e.key + 1,
      );
    }).take(maxVisible).toList();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber.withOpacity(0.15),
            Colors.orange.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.amber.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
              const SizedBox(width: 8),
              Text(
                'Top ${rankedEntries.length}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Rankings
          ...rankedEntries.map((entry) => _buildRankingRow(context, entry)),
        ],
      ),
    );
  }

  Widget _buildRankingRow(BuildContext context, RankingEntry entry) {
    final positionColors = {
      1: Colors.amber,
      2: Colors.grey.shade400,
      3: Colors.orange.shade700,
    };
    
    final positionEmojis = {
      1: '🥇',
      2: '🥈',
      3: '🥉',
    };
    
    final color = positionColors[entry.position] ?? Colors.white54;
    final emoji = positionEmojis[entry.position];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: entry.isCurrentUser 
            ? Colors.amber.withOpacity(0.2)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: entry.isCurrentUser 
            ? Border.all(color: Colors.amber, width: 2)
            : null,
      ),
      child: Row(
        children: [
          // Position
          SizedBox(
            width: 32,
            child: emoji != null
                ? Text(emoji, style: const TextStyle(fontSize: 20))
                : Text(
                    '${entry.position}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
          
          // Icon
          Text(entry.icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          
          // Name
          Expanded(
            child: Text(
              entry.isCurrentUser ? '${entry.name} (Tú)' : entry.name,
              style: TextStyle(
                color: entry.isCurrentUser ? Colors.amber : Colors.white,
                fontWeight: entry.isCurrentUser ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Percentage
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${entry.percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// WIDGET: BONUS INDICATOR (Indicador de bonus por velocidad)
// Uso pedagógico: Muestra el bonus que el estudiante puede
// ganar si responde rápido.
// ============================================================

class SpeedBonusIndicator extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final double basePoints;

  const SpeedBonusIndicator({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.basePoints,
  });

  double get bonusMultiplier {
    if (remainingSeconds <= 0) return 1.0;
    final ratio = remainingSeconds / totalSeconds;
    if (ratio >= 0.8) return 1.5;
    if (ratio >= 0.6) return 1.3;
    if (ratio >= 0.4) return 1.2;
    if (ratio >= 0.2) return 1.1;
    return 1.0;
  }
  
  double get totalPoints => basePoints * bonusMultiplier;
  
  String get bonusLabel {
    if (bonusMultiplier >= 1.5) return '🔥 ¡SÚPER RÁPIDO!';
    if (bonusMultiplier >= 1.3) return '⚡ ¡Muy rápido!';
    if (bonusMultiplier >= 1.2) return '✨ ¡Rápido!';
    if (bonusMultiplier >= 1.1) return '👍 Buen tiempo';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    if (bonusMultiplier <= 1.0) return const SizedBox.shrink();
    
    final color = bonusMultiplier >= 1.5 
        ? Colors.orange 
        : (bonusMultiplier >= 1.3 ? Colors.amber : Colors.green);
    
    return FadeInSlide(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              bonusLabel,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '+${((bonusMultiplier - 1) * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

