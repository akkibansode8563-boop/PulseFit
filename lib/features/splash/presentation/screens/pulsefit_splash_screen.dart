import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/widgets/pulse_heart_painter.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../onboarding/presentation/screens/onboarding_screen.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

// ─── Brand Palette (Version 2.0) ─────────────────────────────────────────────
const _kBackground = Color(0xFF000000);
const _kGreen = Color(0xFF63E36A);
const _kGreenGlow = Color(0xFF4ADE80);

class PulseFitSplashScreen extends ConsumerStatefulWidget {
  const PulseFitSplashScreen({super.key});

  @override
  ConsumerState<PulseFitSplashScreen> createState() =>
      _PulseFitSplashScreenState();
}

class _PulseFitSplashScreenState extends ConsumerState<PulseFitSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  // ── 0.09–0.22 | Icon Appear ───────────────────────────────────────────────
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;

  // ── 0.22–0.30 | Heartbeat 1 "Lub" ────────────────────────────────────────
  late Animation<double> _hb1;
  // ── 0.31–0.40 | Heartbeat 2 "Dub" ────────────────────────────────────────
  late Animation<double> _hb2;

  // ── 0.22–0.38 | Ripple 1 ─────────────────────────────────────────────────
  late Animation<double> _ripple1Scale;
  late Animation<double> _ripple1Fade;
  // ── 0.30–0.46 | Ripple 2 ─────────────────────────────────────────────────
  late Animation<double> _ripple2Scale;
  late Animation<double> _ripple2Fade;

  // ── 0.44–0.62 | ECG Line ─────────────────────────────────────────────────
  late Animation<double> _ecgProgress;
  late Animation<double> _ecgFade;

  // ── 0.53–0.69 | AI Particles ─────────────────────────────────────────────
  late Animation<double> _particleFade;
  late Animation<double> _particleAngle;

  // ── 0.69–0.875 | PulseFit Text ───────────────────────────────────────────
  late Animation<double> _textFade;
  late Animation<double> _textSlide;
  late Animation<double> _textBlur;

  // ── 0.875–1.0 | Screen Exit ───────────────────────────────────────────────
  late Animation<double> _screenFade;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    // Logo fade-in
    _logoFade = _anim(begin: 0.0, end: 1.0, t0: 0.09, t1: 0.22, curve: Curves.easeOut);
    _logoScale = _anim(begin: 0.72, end: 1.0, t0: 0.09, t1: 0.22, curve: Curves.elasticOut);

    // Heartbeat 1 — Lub (sharp quick pulse)
    _hb1 = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.09).chain(CurveTween(curve: Curves.easeOut)), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.09, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 65),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.22, 0.30)));

    // Heartbeat 2 — Dub (slightly softer)
    _hb2 = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.055).chain(CurveTween(curve: Curves.easeOut)), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.055, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 65),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.31, 0.40)));

    // Ripple 1
    _ripple1Scale = _anim(begin: 1.0, end: 3.0, t0: 0.22, t1: 0.38, curve: Curves.easeOut);
    _ripple1Fade  = _anim(begin: 0.65, end: 0.0, t0: 0.22, t1: 0.38, curve: Curves.easeOut);

    // Ripple 2
    _ripple2Scale = _anim(begin: 1.0, end: 3.0, t0: 0.30, t1: 0.46, curve: Curves.easeOut);
    _ripple2Fade  = _anim(begin: 0.50, end: 0.0, t0: 0.30, t1: 0.46, curve: Curves.easeOut);

    // ECG progress — how far the line has been drawn
    _ecgProgress = _anim(begin: 0.0, end: 1.0, t0: 0.44, t1: 0.56, curve: Curves.easeInOut);
    // ECG container fade — appears then fades cleanly
    _ecgFade = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut)), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)), weight: 30),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.44, 0.64)));

    // AI Particles
    _particleFade = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.85).chain(CurveTween(curve: Curves.easeOut)), weight: 25),
      TweenSequenceItem(tween: ConstantTween(0.85), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 0.0).chain(CurveTween(curve: Curves.easeIn)), weight: 40),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.53, 0.69)));
    _particleAngle = _anim(begin: 0.0, end: 1.0, t0: 0.53, t1: 0.69);

    // Text (blur→sharp, fade, slide up)
    _textFade  = _anim(begin: 0.0, end: 1.0, t0: 0.69, t1: 0.845, curve: Curves.easeOut);
    _textSlide = _anim(begin: 14.0, end: 0.0, t0: 0.69, t1: 0.845, curve: Curves.easeOut);
    _textBlur  = _anim(begin: 9.0,  end: 0.0, t0: 0.69, t1: 0.845, curve: Curves.easeOut);

    // Screen exit
    _screenFade = _anim(begin: 1.0, end: 0.0, t0: 0.875, t1: 1.0, curve: Curves.easeInOut);

    _checkSplashFrequencyAndStart();
  }

  Future<void> _checkSplashFrequencyAndStart() async {
    final prefs = await SharedPreferences.getInstance();
    final int launchCount = (prefs.getInt('pulsefit_splash_launch_count') ?? 0) + 1;
    await prefs.setInt('pulsefit_splash_launch_count', launchCount);

    // Show full splash animation on first launch and every 3rd launch (e.g. 1, 4, 7...)
    final bool shouldShowSplash = (launchCount == 1) || (launchCount % 3 == 1);

    if (!shouldShowSplash) {
      // Direct fast route for intermediate app opens
      if (mounted) _navigate();
      return;
    }

    // Trigger haptic pulses for heartbeat animation
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) HapticFeedback.mediumImpact();
    });
    Future.delayed(const Duration(milliseconds: 980), () {
      if (mounted) HapticFeedback.lightImpact();
    });

    _ctrl.forward();
    _ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) _navigate();
    });
  }

  // Convenience factory
  Animation<double> _anim({
    required double begin,
    required double end,
    required double t0,
    required double t1,
    Curve curve = Curves.linear,
  }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: _ctrl, curve: Interval(t0, t1, curve: curve)),
    );
  }

  void _navigate() {
    final profileState = ref.read(profileProvider);
    final isComplete =
        (profileState.asData?.value?.isOnboardingComplete) ?? false;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 420),
        pageBuilder: (_, __, ___) =>
            isComplete ? const DashboardScreen() : const OnboardingScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cx = size.width / 2;
    final cy = size.height / 2.15;
    const iconSize = 108.0;
    const iconHalf = iconSize / 2;

    return Scaffold(
      backgroundColor: _kBackground,
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          // Combine base scale with heartbeat pulses
          final double hbScale = math.max(_hb1.value, _hb2.value);
          final double totalScale = _logoScale.value * hbScale;

          // AI particle orbit — subtle sweep (~60° arc)
          final double particleBaseAngle = _particleAngle.value * (math.pi / 3);

          return Opacity(
            opacity: _screenFade.value,
            child: Stack(
              children: [
                // ── Pure Black Canvas ──────────────────────────────────────
                const Positioned.fill(child: ColoredBox(color: _kBackground)),

                // ── Soft Ambient Glow (icon is present) ───────────────────
                Positioned(
                  left: cx - 90,
                  top: cy - 90,
                  child: Opacity(
                    opacity: (_logoFade.value * 0.4).clamp(0.0, 1.0),
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x4463E36A),
                            blurRadius: 90,
                            spreadRadius: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Ripple 1 — "Lub" ──────────────────────────────────────
                if (_ripple1Fade.value > 0)
                  Positioned(
                    left: cx - iconHalf,
                    top: cy - iconHalf,
                    child: Opacity(
                      opacity: _ripple1Fade.value,
                      child: Transform.scale(
                        scale: _ripple1Scale.value,
                        child: Container(
                          width: iconSize,
                          height: iconSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0x8063E36A),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // ── Ripple 2 — "Dub" ──────────────────────────────────────
                if (_ripple2Fade.value > 0)
                  Positioned(
                    left: cx - iconHalf,
                    top: cy - iconHalf,
                    child: Opacity(
                      opacity: _ripple2Fade.value,
                      child: Transform.scale(
                        scale: _ripple2Scale.value,
                        child: Container(
                          width: iconSize,
                          height: iconSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0x6063E36A),
                              width: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // ── AI Particles — gentle micro-orbit ─────────────────────
                if (_particleFade.value > 0.01)
                  ...List.generate(8, (i) {
                    final baseAngle =
                        (i / 8) * 2 * math.pi + particleBaseAngle;
                    const orbitR = 68.0;
                    final px = cx + orbitR * math.cos(baseAngle);
                    final py = cy + orbitR * math.sin(baseAngle);
                    // Slightly vary size for organic, non-uniform feel
                    final dotSize = (i % 3 == 0)
                        ? 4.5
                        : (i % 3 == 1)
                            ? 3.0
                            : 2.2;
                    return Positioned(
                      left: px - dotSize / 2,
                      top: py - dotSize / 2,
                      child: Opacity(
                        opacity: _particleFade.value,
                        child: Container(
                          width: dotSize,
                          height: dotSize,
                          decoration: const BoxDecoration(
                            color: _kGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),

                // ── ECG Line — draws left-to-right ────────────────────────
                if (_ecgFade.value > 0.01)
                  Positioned(
                    left: cx - 68,
                    top: cy + iconHalf + 6,
                    child: SizedBox(
                      width: 136,
                      height: 38,
                      child: Opacity(
                        opacity: _ecgFade.value,
                        child: CustomPaint(
                          painter: _EcgLinePainter(
                            progress: _ecgProgress.value,
                            color: _kGreen,
                          ),
                        ),
                      ),
                    ),
                  ),

                // ── Central PulseFit Icon ──────────────────────────────────
                Positioned(
                  left: cx - iconHalf,
                  top: cy - iconHalf,
                  child: Opacity(
                    opacity: _logoFade.value,
                    child: Transform.scale(
                      scale: totalScale,
                      child: Container(
                        width: iconSize,
                        height: iconSize,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_kGreen, _kGreenGlow],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: _kGreen.withValues(
                                  alpha: 0.38 * _logoFade.value),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: CustomPaint(
                          painter: PulseHeartPainter(
                            strokeColor: Colors.white,
                            strokeWidth: 3.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── "PulseFit" + Tagline (Blur → Sharp) ───────────────────
                if (_textFade.value > 0.01)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: cy + iconHalf + 46,
                    child: Opacity(
                      opacity: _textFade.value,
                      child: Transform.translate(
                        offset: Offset(0, _textSlide.value),
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(
                            sigmaX: _textBlur.value,
                            sigmaY: _textBlur.value,
                          ),
                          child: Column(
                            children: [
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Pulse',
                                      style: GoogleFonts.sora(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: -0.8,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Fit',
                                      style: GoogleFonts.sora(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: _kGreen,
                                        letterSpacing: -0.8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Health.  Fitness.  Intelligence.',
                                style: GoogleFonts.sora(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withValues(alpha: 0.40),
                                  letterSpacing: 1.8,
                                ),
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
        },
      ),
    );
  }
}

// ─── ECG Line Custom Painter ─────────────────────────────────────────────────

class _EcgLinePainter extends CustomPainter {
  final double progress;
  final Color color;

  const _EcgLinePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final mid = h * 0.55; // baseline sits slightly below center

    // ── Build realistic 1-beat ECG waveform path ──────────────────────────
    // Segments: flat → P-wave → flat → QRS complex → flat → T-wave → flat
    final path = Path();

    // Helper: map normalised x (0–1) to canvas x
    double x(double n) => n * w;

    path.moveTo(x(0.00), mid);               // START flat
    path.lineTo(x(0.06), mid);
    // P-wave (small bump)
    path.quadraticBezierTo(x(0.10), mid - h * 0.14, x(0.13), mid - h * 0.14);
    path.quadraticBezierTo(x(0.16), mid - h * 0.14, x(0.19), mid);
    path.lineTo(x(0.24), mid);               // flat between P and QRS
    // Q dip
    path.lineTo(x(0.28), mid + h * 0.18);
    // R spike — sharp peak (the most dramatic moment)
    path.lineTo(x(0.32), mid - h * 0.88);
    // S dip
    path.lineTo(x(0.37), mid + h * 0.28);
    path.lineTo(x(0.42), mid);               // return to baseline
    path.lineTo(x(0.49), mid);               // flat ST segment
    // T-wave (smooth dome)
    path.quadraticBezierTo(x(0.55), mid - h * 0.30, x(0.62), mid - h * 0.30);
    path.quadraticBezierTo(x(0.69), mid - h * 0.30, x(0.74), mid);
    path.lineTo(x(1.00), mid);               // END flat

    // ── Clip to progress ──────────────────────────────────────────────────
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    final total = metric.length;
    final drawn = metric.extractPath(0, total * progress.clamp(0.0, 1.0));

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(drawn, linePaint);

    // ── Glowing dot at the leading edge of the trace ─────────────────────
    if (progress > 0.01 && progress < 0.99) {
      final tangent = metric.getTangentForOffset(total * progress);
      if (tangent != null) {
        final pos = tangent.position;
        // Outer glow
        canvas.drawCircle(
          pos,
          7,
          Paint()..color = color.withValues(alpha: 0.22),
        );
        // Inner dot
        canvas.drawCircle(
          pos,
          3.2,
          Paint()..color = color,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_EcgLinePainter old) =>
      old.progress != progress || old.color != color;
}
