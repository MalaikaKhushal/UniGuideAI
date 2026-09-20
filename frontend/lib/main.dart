import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const UniGuideApp());
}

// ============================================================
// APP COLORS
// Official COMSATS University Islamabad inspired color palette
// ============================================================

class AppColors {
  static const deepNavy = Color(
    0xFF002147,
  ); // COMSATS Official Deep Academic Navy
  static const navy = Color(0xFF073B6D); // University Primary Navy
  static const royalBlue = Color(0xFF0B63B7); // Vibrant University Blue
  static const accentCyan = Color(0xFF00B4D8); // Modern AI Tech Luminous Cyan
  static const accentCyanGlow = Color(0xFF38BDF8); // Electric Cyan Glow
  static const accentGold = Color(0xFFF59E0B); // Academic Seal Gold / Amber
  static const lightBlue = Color(0xFFEDF5FD); // Ice Blue Surface Accent
  static const surface = Colors.white;
  static const background = Color(
    0xFFF4F7FB,
  ); // Institutional Slate/Ice Background
  static const card = Colors.white;
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF475569);
  static const textMuted = Color(0xFF94A3B8);
  static const border = Color(0xFFE2E8F0);
  static const borderSubtle = Color(0xFFECEFF3);
}

// ============================================================
// MAIN APP
// ============================================================

class UniGuideApp extends StatelessWidget {
  const UniGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniGuide AI - COMSATS Student Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.deepNavy,
          primary: AppColors.deepNavy,
          secondary: AppColors.royalBlue,
          surface: Colors.white,
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.royalBlue,
              width: 1.8,
            ),
          ),
        ),
      ),
      home: const MainNavigation(),
    );
  }
}

// ============================================================
// MAIN NAVIGATION
// ============================================================

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  int selectedIndex = 0;
  final GlobalKey<AssistantPageState> assistantKey =
      GlobalKey<AssistantPageState>();

  void navigateToTab(int index, {String? query}) {
    setState(() {
      selectedIndex = index;
    });

    if (index == 1 && query != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        assistantKey.currentState?.askQuickQuestion(query);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(
        onAskQuestion: (query) => navigateToTab(1, query: query),
        onGoToAssistant: () => navigateToTab(1),
      ),
      AssistantPage(key: assistantKey),
      const ResourcesPage(),
      const AboutPage(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 960;

        return Scaffold(
          body: Row(
            children: [
              if (isDesktop)
                _DesktopNavigation(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) => navigateToTab(index),
                ),
              Expanded(child: pages[selectedIndex]),
            ],
          ),
          bottomNavigationBar: isDesktop
              ? null
              : NavigationBar(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) => navigateToTab(index),
                  indicatorColor: AppColors.lightBlue,
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(
                        Icons.home,
                        color: AppColors.royalBlue,
                      ),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.auto_awesome_outlined),
                      selectedIcon: Icon(
                        Icons.auto_awesome,
                        color: AppColors.royalBlue,
                      ),
                      label: 'AI Assistant',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.link_outlined),
                      selectedIcon: Icon(
                        Icons.link,
                        color: AppColors.royalBlue,
                      ),
                      label: 'Quick Access',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.info_outline),
                      selectedIcon: Icon(
                        Icons.info,
                        color: AppColors.royalBlue,
                      ),
                      label: 'About',
                    ),
                  ],
                ),
        );
      },
    );
  }
}

// ============================================================
// DESKTOP SIDEBAR NAVIGATION
// Official COMSATS University branded drawer with unified AI Seal
// ============================================================

class _DesktopNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const _DesktopNavigation({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 28),

            // ==================================================
            // CENTERED OFFICIAL UNIVERSITY AI LOGO
            // ==================================================
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 106,
                    height: 106,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentCyan.withValues(alpha: 0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: AppColors.deepNavy.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      border: Border.all(
                        color: AppColors.royalBlue.withValues(alpha: 0.35),
                        width: 2.0,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/UniGuideAILogo.png',
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    'UniGuide AI',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: AppColors.deepNavy,
                      letterSpacing: -0.3,
                    ),
                  ),

                  const SizedBox(height: 3),

                  const Text(
                    'COMSATS UNIVERSITY',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.royalBlue,
                      letterSpacing: 0.8,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFC8DFEF)),
                    ),
                    child: const Text(
                      'Abbottabad Campus',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
            const Divider(
              height: 1,
              indent: 20,
              endIndent: 20,
              color: AppColors.borderSubtle,
            ),
            const SizedBox(height: 18),

            // Nav items with smooth hover state
            _navItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: 'Home',
              index: 0,
            ),
            _navItem(
              icon: Icons.auto_awesome_outlined,
              activeIcon: Icons.auto_awesome_rounded,
              label: 'AI Assistant',
              index: 1,
            ),
            _navItem(
              icon: Icons.link_rounded,
              activeIcon: Icons.link_rounded,
              label: 'Quick Access',
              index: 2,
            ),
            _navItem(
              icon: Icons.info_outline_rounded,
              activeIcon: Icons.info_rounded,
              label: 'About UniGuide',
              index: 3,
            ),

            const Spacer(),

            // Live status & student assistant badge
            Padding(
              padding: const EdgeInsets.all(18),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF0F6FC), Color(0xFFE5F1FC)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD4E6F5)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.deepNavy.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.deepNavy,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                'COMSATS Portal AI',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.deepNavy,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Official RAG Grounded',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final bool selected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      child: _HoverBuilder(
        builder: (context, hovering) {
          final Color bgColor = selected
              ? AppColors.lightBlue
              : (hovering ? const Color(0xFFF7FAFD) : Colors.transparent);

          final Color textColor = selected
              ? AppColors.deepNavy
              : (hovering ? AppColors.royalBlue : AppColors.textSecondary);

          return Material(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onDestinationSelected(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(
                      selected ? activeIcon : icon,
                      color: selected ? AppColors.royalBlue : textColor,
                      size: 20,
                    ),
                    const SizedBox(width: 14),
                    Text(
                      label,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                    ),
                    if (selected) const Spacer(),
                    if (selected)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.royalBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// PARALLAX ANIMATED BACKGROUND & TECH MESH
// Continuous organic floating nodes, neural connections,
// and multi-depth parallax scrolling responsive to touch/wheel
// ============================================================

class _ParallaxAnimatedBackground extends StatefulWidget {
  final Widget child;
  final ScrollController? scrollController;

  const _ParallaxAnimatedBackground({
    required this.child,
    this.scrollController,
  });

  @override
  State<_ParallaxAnimatedBackground> createState() =>
      _ParallaxAnimatedBackgroundState();
}

class _ParallaxAnimatedBackgroundState
    extends State<_ParallaxAnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    widget.scrollController?.addListener(_onScrollUpdate);
  }

  @override
  void didUpdateWidget(covariant _ParallaxAnimatedBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController?.removeListener(_onScrollUpdate);
      widget.scrollController?.addListener(_onScrollUpdate);
    }
  }

  void _onScrollUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScrollUpdate);
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double scrollOffset =
        (widget.scrollController?.hasClients ?? false)
            ? widget.scrollController!.offset
            : 0.0;

    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _bgController,
            builder: (context, _) {
              return CustomPaint(
                painter: _TechParallaxPainter(
                  animationValue: _bgController.value,
                  scrollOffset: scrollOffset,
                ),
              );
            },
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _TechParallaxPainter extends CustomPainter {
  final double animationValue;
  final double scrollOffset;

  _TechParallaxPainter({
    required this.animationValue,
    required this.scrollOffset,
  });

  static final List<({double x, double y, double depth, double size, int type, double phase})>
      _nodes = [
    (x: 0.06, y: 0.10, depth: 0.14, size: 4.5, type: 0, phase: 0.2),
    (x: 0.88, y: 0.08, depth: 0.22, size: 6.0, type: 1, phase: 1.1),
    (x: 0.22, y: 0.26, depth: 0.32, size: 3.5, type: 0, phase: 2.3),
    (x: 0.78, y: 0.28, depth: 0.16, size: 5.0, type: 2, phase: 3.4),
    (x: 0.12, y: 0.48, depth: 0.28, size: 4.0, type: 1, phase: 0.7),
    (x: 0.92, y: 0.52, depth: 0.18, size: 6.5, type: 0, phase: 1.9),
    (x: 0.35, y: 0.65, depth: 0.35, size: 3.0, type: 2, phase: 2.8),
    (x: 0.82, y: 0.72, depth: 0.24, size: 5.5, type: 1, phase: 4.2),
    (x: 0.08, y: 0.85, depth: 0.15, size: 4.5, type: 0, phase: 3.1),
    (x: 0.62, y: 0.15, depth: 0.20, size: 4.0, type: 2, phase: 0.5),
    (x: 0.48, y: 0.38, depth: 0.30, size: 3.5, type: 1, phase: 1.7),
    (x: 0.68, y: 0.86, depth: 0.26, size: 5.0, type: 0, phase: 2.2),
    (x: 0.52, y: 0.78, depth: 0.18, size: 4.2, type: 2, phase: 3.9),
    (x: 0.28, y: 0.92, depth: 0.32, size: 3.8, type: 1, phase: 1.4),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final double t = animationValue * 2 * math.pi;

    // 1. Soft Ambient Luminous Radial Gradient Orbs
    final double orb1X = size.width * 0.85 + math.cos(t) * 35;
    final double orb1Y = size.height * 0.15 + math.sin(t * 0.8) * 25 - (scrollOffset * 0.08);
    final Paint orb1Paint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.accentCyan.withValues(alpha: 0.08),
          AppColors.accentCyan.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(orb1X, orb1Y), radius: 260));
    canvas.drawCircle(Offset(orb1X, orb1Y), 260, orb1Paint);

    final double orb2X = size.width * 0.12 + math.sin(t * 0.9) * 30;
    final double orb2Y = size.height * 0.75 + math.cos(t * 0.7) * 30 - (scrollOffset * 0.12);
    final Paint orb2Paint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.royalBlue.withValues(alpha: 0.07),
          AppColors.royalBlue.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(orb2X, orb2Y), radius: 300));
    canvas.drawCircle(Offset(orb2X, orb2Y), 300, orb2Paint);

    // 2. Computed particle positions with parallax scroll wrapping
    final List<Offset> positions = [];
    final double effectiveHeight = size.height + 120;

    for (final node in _nodes) {
      final double xOffset = math.cos(t + node.phase) * 16.0;
      final double yOffset = math.sin(t * 0.9 + node.phase) * 14.0;
      final double x = ((node.x * size.width + xOffset) % size.width + size.width) % size.width;

      final double rawY = (node.y * size.height + yOffset - (scrollOffset * node.depth));
      final double y = ((rawY % effectiveHeight) + effectiveHeight) % effectiveHeight - 60;

      positions.add(Offset(x, y));
    }

    // 3. Subtle Neural Connection Lines between close particles
    final Paint linePaint = Paint()
      ..strokeWidth = 1.0;

    for (int i = 0; i < positions.length; i++) {
      for (int j = i + 1; j < positions.length; j++) {
        final double dist = (positions[i] - positions[j]).distance;
        if (dist < 130) {
          final double lineOpacity = (1.0 - (dist / 130)) * 0.10;
          linePaint.color = AppColors.royalBlue.withValues(alpha: lineOpacity);
          canvas.drawLine(positions[i], positions[j], linePaint);
        }
      }
    }

    // 4. Draw Floating Tech Particle Nodes
    for (int i = 0; i < positions.length; i++) {
      final pos = positions[i];
      final node = _nodes[i];
      final double pulse = 0.85 + (math.sin(t * 1.5 + node.phase) * 0.25);

      if (node.type == 0) {
        final Paint glow = Paint()
          ..color = AppColors.accentCyan.withValues(alpha: 0.18 * pulse)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(pos, node.size * 1.8, glow);

        final Paint core = Paint()
          ..color = AppColors.royalBlue.withValues(alpha: 0.40 * pulse);
        canvas.drawCircle(pos, node.size * 0.7, core);
      } else if (node.type == 1) {
        final Paint plusPaint = Paint()
          ..color = AppColors.accentCyan.withValues(alpha: 0.30 * pulse)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round;
        final double arm = node.size * 1.1;
        canvas.drawLine(Offset(pos.dx - arm, pos.dy), Offset(pos.dx + arm, pos.dy), plusPaint);
        canvas.drawLine(Offset(pos.dx, pos.dy - arm), Offset(pos.dx, pos.dy + arm), plusPaint);
      } else {
        final Paint diamondPaint = Paint()
          ..color = AppColors.royalBlue.withValues(alpha: 0.25 * pulse)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;
        final Path path = Path();
        final double d = node.size * 1.0;
        path.moveTo(pos.dx, pos.dy - d);
        path.lineTo(pos.dx + d, pos.dy);
        path.lineTo(pos.dx, pos.dy + d);
        path.lineTo(pos.dx - d, pos.dy);
        path.close();
        canvas.drawPath(path, diamondPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TechParallaxPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.scrollOffset != scrollOffset;
  }
}

// ============================================================
// HOME PAGE (Stateful with Parallax & Ambient Animation)
// ============================================================

class HomePage extends StatefulWidget {
  final ValueChanged<String> onAskQuestion;
  final VoidCallback onGoToAssistant;

  const HomePage({
    super.key,
    required this.onAskQuestion,
    required this.onGoToAssistant,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ambientController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 3.6s continuous smooth loop for ambient luminous waves
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: _ParallaxAnimatedBackground(
          scrollController: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 48),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeroSection(onGoToAssistant: widget.onGoToAssistant),

                  const SizedBox(height: 38),

                  // "What can I help you with?" section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 4,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.royalBlue,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'What can I help you with?',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  const Padding(
                    padding: EdgeInsets.only(left: 14),
                    child: Text(
                      'Tap any topic to instantly get verified answers from official COMSATS records.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Luminous Animated Question Chips with moving effects
                  _QuestionChips(
                    animation: _ambientController,
                    onSelectTopic: widget.onAskQuestion,
                  ),

                  const SizedBox(height: 42),

                  // Official Quick Access Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 4,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.royalBlue,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Official COMSATS Resources',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  const Padding(
                    padding: EdgeInsets.only(left: 14),
                    child: Text(
                      'Direct access to official university portals, student management system, and admissions.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 4 Dynamic Luminous Equal-Height Resource Cards
                  _QuickAccessGrid(animation: _ambientController),

                  const SizedBox(height: 38),

                  // System Highlights Banner with matching AI Logo
                  _SystemHighlightsBanner(
                    animation: _ambientController,
                    onGoToAssistant: widget.onGoToAssistant,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      toolbarHeight: 76,
      titleSpacing: 24,
      title: const _BrandLogo(height: 60),
    );
  }
}

// ============================================================
// BRAND LOGO (Top AppBar)
// Enlarged, razor-sharp unified AI Seal + Vector Typography
// ============================================================

class _BrandLogo extends StatelessWidget {
  final double height;

  const _BrandLogo({this.height = 60});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Crisp unified AI Seal container
        Container(
          width: height,
          height: height,
          padding: const EdgeInsets.all(3.0),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.accentCyan.withValues(alpha: 0.24),
                blurRadius: 12,
                offset: const Offset(0, 3),
                spreadRadius: 1,
              ),
              BoxShadow(
                color: AppColors.deepNavy.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: AppColors.royalBlue.withValues(alpha: 0.35),
              width: 1.6,
            ),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/UniGuideAILogo.png',
              width: height * 0.92,
              height: height * 0.92,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),

        const SizedBox(width: 14),

        // Crystal-clear Native Vector Typography
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'UniGuide',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    color: AppColors.deepNavy,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3.5,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.royalBlue, AppColors.accentCyan],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.royalBlue.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'COMSATS University Islamabad',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.accentCyan,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Abbottabad Campus',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.royalBlue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================
// HERO SECTION
// Official COMSATS academic hero banner
// ============================================================

class _HeroSection extends StatelessWidget {
  final VoidCallback onGoToAssistant;

  const _HeroSection({required this.onGoToAssistant});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 34),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF001F3F), // Deep Academic Navy
            Color(0xFF073B6D), // COMSATS Navy
            Color(0xFF094E8F), // Royal Navy Accent
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withValues(alpha: 0.25),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool compact = constraints.maxWidth < 740;

          return Flex(
            direction: compact ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.center, // Centered alignment
            children: [
              Expanded(
                flex: compact ? 0 : 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Official university campus tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.accentCyan,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'COMSATS UNIVERSITY ISLAMABAD • ABBOTTABAD',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Your Smart COMSATS\nStudent Assistant',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        height: 1.15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      'Instant, verified answers about semester fees, admissions, scholarships, hostel accommodation, bus routes, academic policies, and campus life.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 15,
                        height: 1.6,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 26),

                    // Primary Action Button with hover lift
                    _HoverBuilder(
                      builder: (context, hovering) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          transform: Matrix4.translationValues(
                            0,
                            hovering ? -3 : 0,
                            0,
                          ),
                          child: FilledButton.icon(
                            onPressed: onGoToAssistant,
                            icon: const Icon(Icons.auto_awesome, size: 19),
                            label: const Text(
                              'Ask UniGuide AI',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.deepNavy,
                              elevation: hovering ? 10 : 3,
                              shadowColor: AppColors.accentCyan.withValues(
                                alpha: 0.35,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 17,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 22),

                    // Fast Feature Badges
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        _featurePill(Icons.shield_outlined, 'Verified Sources'),
                        _featurePill(Icons.bolt_outlined, 'Fast RAG Engine'),
                        _featurePill(
                          Icons.translate_outlined,
                          'Urdu / English',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (!compact) const SizedBox(width: 40),

              // ================================================
              // RIGHT HERO ILLUSTRATION WITH CONTINUOUS RIPPLE
              // Centered with new COMSATS AI Seal
              // ================================================
              if (!compact)
                const Expanded(
                  flex: 2,
                  child: Center(child: _HeroRippleIllustration()),
                ),

              if (compact) const SizedBox(height: 32),

              if (compact) const Center(child: _HeroRippleIllustration()),
            ],
          );
        },
      ),
    );
  }

  Widget _featurePill(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.accentCyan),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// HERO RIPPLE ILLUSTRATION
// Continuous animated concentric ripple waves in COMSATS cyan
// Subtle floating vertical sine-wave motion
// Symmetrical unified COMSATS AI seal
// ============================================================

class _HeroRippleIllustration extends StatefulWidget {
  const _HeroRippleIllustration();

  @override
  State<_HeroRippleIllustration> createState() =>
      _HeroRippleIllustrationState();
}

class _HeroRippleIllustrationState extends State<_HeroRippleIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _rippleController;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rippleController,
      builder: (context, child) {
        final double floatY =
            math.sin(_rippleController.value * 2 * math.pi) * 5.0;

        return SizedBox(
          width: 320,
          height: 320,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ------------------------------------------------
              // 3 CONTINUOUS CONCENTRIC RIPPLE WAVES
              // ------------------------------------------------
              for (int i = 0; i < 3; i++) ...[_buildRippleRing(i)],

              // Ambient glowing aura behind the badge
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00B4D8).withValues(alpha: 0.35),
                      blurRadius: 46,
                      spreadRadius: 8,
                    ),
                  ],
                ),
              ),

              // ------------------------------------------------
              // CENTRAL BADGE WITH FLOATING MOTION
              // ------------------------------------------------
              Transform.translate(
                offset: Offset(0, floatY),
                child: Container(
                  width: 222,
                  height: 222,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      center: Alignment(-0.2, -0.3),
                      radius: 0.9,
                      colors: [Color(0xFF0C3D70), Color(0xFF031B36)],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.38),
                        blurRadius: 26,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: AppColors.accentCyan.withValues(alpha: 0.28),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/UniGuideAILogo.png',
                        width: 210,
                        height: 210,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ),
              ),

              // ------------------------------------------------
              // FLOATING LIVE STATUS BADGE
              // ------------------------------------------------
              Positioned(
                bottom: 18,
                child: Transform.translate(
                  offset: Offset(0, floatY * 0.7),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: const Color(
                            0xFF10B981,
                          ).withValues(alpha: 0.25),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFFD4E6F5),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981), // Live green
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 7),
                        const Text(
                          'COMSATS AI • Active',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.deepNavy,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRippleRing(int index) {
    final double phase = (_rippleController.value + (index / 3.0)) % 1.0;
    final double progress = Curves.easeOutQuad.transform(phase);
    final double size = 222 + (progress * 96);
    final double opacity = (1.0 - progress) * 0.58;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF00B4D8).withValues(alpha: opacity),
          width: 2.2 * (1.0 - (progress * 0.35)),
        ),
      ),
    );
  }
}

// ============================================================
// QUESTION CHIPS (Luminous, Moving, Glowing Animated)
// ============================================================

class _QuestionChips extends StatelessWidget {
  final Animation<double> animation;
  final ValueChanged<String> onSelectTopic;

  const _QuestionChips({required this.animation, required this.onSelectTopic});

  @override
  Widget build(BuildContext context) {
    final questions = [
      (
        'Fees & Dues',
        Icons.payments_outlined,
        'What is the fee structure for BS Software Engineering at COMSATS Abbottabad?',
      ),
      (
        'Admissions 2024',
        Icons.how_to_reg_outlined,
        'What is the admission procedure and criteria for undergraduate programs at COMSATS Abbottabad?',
      ),
      (
        'Scholarships & Aid',
        Icons.school_outlined,
        'What scholarships and financial assistance programs are offered at COMSATS Abbottabad?',
      ),
      (
        'Hostel & Mess',
        Icons.apartment_outlined,
        'What are the hostel accommodation facilities and fee at COMSATS Abbottabad?',
      ),
      (
        'Campus Transport',
        Icons.directions_bus_outlined,
        'What are the bus routes and transport fees for students at COMSATS Abbottabad?',
      ),
      (
        'Student Affairs',
        Icons.support_agent_outlined,
        'What student services and societies are active under Student Affairs at COMSATS Abbottabad?',
      ),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: questions.asMap().entries.map((entry) {
        final int index = entry.key;
        final item = entry.value;

        return _LuminousQuestionChip(
          index: index,
          animation: animation,
          label: item.$1,
          icon: item.$2,
          onTap: () => onSelectTopic(item.$3),
        );
      }).toList(),
    );
  }
}

class _LuminousQuestionChip extends StatefulWidget {
  final int index;
  final Animation<double> animation;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _LuminousQuestionChip({
    required this.index,
    required this.animation,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_LuminousQuestionChip> createState() => _LuminousQuestionChipState();
}

class _LuminousQuestionChipState extends State<_LuminousQuestionChip> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, child) {
        // Continuous gentle floating and luminous breathing
        final double phase =
            (widget.animation.value + (widget.index * 0.16)) % 1.0;
        final double floatY = isHovering
            ? -5.0
            : math.sin(phase * 2 * math.pi) * 2.2;
        final double breathingGlow =
            0.10 + (math.sin(phase * 2 * math.pi) + 1.0) / 2.0 * 0.22;

        return Transform.translate(
          offset: Offset(0, floatY),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => isHovering = true),
            onExit: (_) => setState(() => isHovering = false),
            child: GestureDetector(
              onTap: widget.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: isHovering ? AppColors.lightBlue : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isHovering ? AppColors.accentCyan : AppColors.border,
                    width: isHovering ? 1.6 : 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isHovering
                          ? AppColors.accentCyan.withValues(alpha: 0.45)
                          : const Color(
                              0xFF00B4D8,
                            ).withValues(alpha: breathingGlow),
                      blurRadius: isHovering ? 18 : 8,
                      spreadRadius: isHovering ? 2 : 0.6,
                      offset: Offset(0, isHovering ? 5 : 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedScale(
                      scale: isHovering ? 1.15 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        widget.icon,
                        size: 19,
                        color: isHovering
                            ? AppColors.royalBlue
                            : AppColors.navy,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: isHovering
                            ? AppColors.deepNavy
                            : AppColors.textPrimary,
                        letterSpacing: -0.1,
                      ),
                    ),
                    if (isHovering) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.auto_awesome,
                        size: 13,
                        color: AppColors.accentCyan,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// QUICK ACCESS GRID (Equal Height, Moving, Luminous Animated)
// Fixes: 4 cards with exact uniform size and glowing animations
// ============================================================

class _QuickAccessGrid extends StatelessWidget {
  final Animation<double> animation;

  const _QuickAccessGrid({required this.animation});

  @override
  Widget build(BuildContext context) {
    final resources = [
      (
        'CUI Abbottabad',
        'Official campus website, announcements, faculty directories & departments',
        Icons.language_rounded,
        'https://cuiatd.edu.pk/',
        'Official Portal',
      ),
      (
        'CUOnline Portal',
        'Student Information System (SIS), grades, attendance & fee challans',
        Icons.school_rounded,
        'https://cuonline.comsats.edu.pk/',
        'Student SIS',
      ),
      (
        'Admissions Portal',
        'Online application, eligibility criteria, merit lists & entry test details',
        Icons.how_to_reg_rounded,
        'https://admissions.comsats.edu.pk/',
        'Admissions',
      ),
      (
        'Student Webmail',
        'Official university Outlook Office 365 student and faculty email',
        Icons.mail_outline_rounded,
        'https://outlook.office.com/',
        'Office 365',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = 1;

        if (constraints.maxWidth >= 960) {
          columns = 4;
        } else if (constraints.maxWidth >= 580) {
          columns = 2;
        }

        final width = (constraints.maxWidth - ((columns - 1) * 16)) / columns;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: resources.asMap().entries.map((entry) {
            final int index = entry.key;
            final resource = entry.value;

            return SizedBox(
              width: width,
              child: _LuminousResourceCard(
                index: index,
                animation: animation,
                title: resource.$1,
                description: resource.$2,
                icon: resource.$3,
                url: resource.$4,
                category: resource.$5,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ============================================================
// LUMINOUS RESOURCE CARD (Equal Height & Dynamic Animations)
// ============================================================

class _LuminousResourceCard extends StatefulWidget {
  final int index;
  final Animation<double> animation;
  final String title;
  final String description;
  final IconData icon;
  final String url;
  final String category;

  const _LuminousResourceCard({
    required this.index,
    required this.animation,
    required this.title,
    required this.description,
    required this.icon,
    required this.url,
    required this.category,
  });

  @override
  State<_LuminousResourceCard> createState() => _LuminousResourceCardState();
}

class _LuminousResourceCardState extends State<_LuminousResourceCard> {
  bool isHovering = false;

  Future<void> _openLink() async {
    final uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, child) {
        // Staggered continuous gentle floating wave
        final double phase =
            (widget.animation.value + (widget.index * 0.25)) % 1.0;
        final double floatY = isHovering
            ? -8.0
            : math.sin(phase * 2 * math.pi) * 3.2;
        final double breathingGlow =
            0.08 + (math.sin(phase * 2 * math.pi) + 1.0) / 2.0 * 0.16;

        return Transform.translate(
          offset: Offset(0, floatY),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => isHovering = true),
            onExit: (_) => setState(() => isHovering = false),
            child: GestureDetector(
              onTap: _openLink,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOut,
                height: 248, // EXACT UNIFORM HEIGHT FOR ALL 4 CARDS
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isHovering ? AppColors.accentCyan : AppColors.border,
                    width: isHovering ? 1.8 : 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isHovering
                          ? AppColors.accentCyan.withValues(alpha: 0.38)
                          : const Color(
                              0xFF00B4D8,
                            ).withValues(alpha: breathingGlow),
                      blurRadius: isHovering ? 28 : 12,
                      spreadRadius: isHovering ? 3 : 1,
                      offset: Offset(0, isHovering ? 10 : 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: Icon Badge & Category Capsule
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isHovering
                                  ? [AppColors.deepNavy, AppColors.royalBlue]
                                  : [
                                      AppColors.lightBlue,
                                      const Color(0xFFE2EFFB),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: isHovering
                                ? [
                                    BoxShadow(
                                      color: AppColors.royalBlue.withValues(
                                        alpha: 0.35,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: AnimatedRotation(
                              turns: isHovering ? 0.03 : 0.0,
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                widget.icon,
                                color: isHovering
                                    ? Colors.white
                                    : AppColors.deepNavy,
                                size: 23,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isHovering
                                ? AppColors.lightBlue
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isHovering
                                  ? const Color(0xFFCBE2F5)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Text(
                            widget.category,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: isHovering
                                  ? AppColors.royalBlue
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: isHovering
                            ? AppColors.royalBlue
                            : AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Expanded(
                      child: Text(
                        widget.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          height: 1.45,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Bottom Link Row
                    Row(
                      children: [
                        Text(
                          'Open resource',
                          style: TextStyle(
                            color: isHovering
                                ? AppColors.royalBlue
                                : AppColors.navy,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 6),
                        AnimatedPadding(
                          duration: const Duration(milliseconds: 180),
                          padding: EdgeInsets.only(left: isHovering ? 5 : 0),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: isHovering
                                ? AppColors.royalBlue
                                : AppColors.navy,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// SYSTEM HIGHLIGHTS BANNER
// Updated to use the unified COMSATS AI Seal
// ============================================================

class _SystemHighlightsBanner extends StatelessWidget {
  final Animation<double> animation;
  final VoidCallback onGoToAssistant;

  const _SystemHighlightsBanner({
    required this.animation,
    required this.onGoToAssistant,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final double glowAlpha =
            0.12 + (math.sin(animation.value * 2 * math.pi) + 1.0) / 2.0 * 0.18;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentCyan.withValues(alpha: glowAlpha),
                blurRadius: 18,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Consistent Unified COMSATS AI Seal
              Container(
                width: 60,
                height: 60,
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentCyan.withValues(alpha: 0.35),
                      blurRadius: 14,
                      spreadRadius: 2,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(
                    color: AppColors.royalBlue.withValues(alpha: 0.4),
                    width: 2.0,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/UniGuideAILogo.png',
                    width: 55,
                    height: 55,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'COMSATS Abbottabad Official AI Portal',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.deepNavy,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Designed to give students and parents quick access to verified university regulations, fee rules, and campus contacts.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              FilledButton(
                onPressed: onGoToAssistant,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.deepNavy,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: AppColors.accentCyan.withValues(alpha: 0.3),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Chat Now',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// ASSISTANT PAGE
// FastAPI RAG Backend preserved 100% with modern CUI Chat UI
// ============================================================

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});

  @override
  State<AssistantPage> createState() => AssistantPageState();
}

class AssistantPageState extends State<AssistantPage> {
  // ----------------------------------------------------------
  // FastAPI backend
  // For Web / Chrome: 127.0.0.1:8000
  // Android emulator: 10.0.2.2:8000
  // ----------------------------------------------------------
  static const String baseUrl = 'http://127.0.0.1:8000';

  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  // Conversation messages
  final List<Map<String, dynamic>> messages = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initial assistant welcome message
    messages.add({
      'role': 'assistant',
      'text':
          'Hello! 👋 I am **UniGuide AI**, your official COMSATS Abbottabad student assistant.\n\nAsk me anything regarding:\n- **Fee Structure** & Payment Challans\n- **Admissions**, Eligibility & NAT/NTS Tests\n- **Scholarships** (HEC, Merit, Financial Aid)\n- **Hostel** Allotment & Mess Rules\n- **Campus Transport** & Bus Routes\n- **Student Affairs** & Societies',
      'sources': <String>[],
    });
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void clearConversation() {
    setState(() {
      messages.clear();
      messages.add({
        'role': 'assistant',
        'text':
            'Hello! 👋 Conversation has been reset. How can I assist you with COMSATS Abbottabad today?',
        'sources': <String>[],
      });
    });
  }

  // ==========================================================
  // SEND QUESTION TO FASTAPI
  // PRESERVED EXACT BACKEND CONTRACT
  // ==========================================================
  Future<void> sendQuestion() async {
    final question = controller.text.trim();

    if (question.isEmpty || isLoading) {
      return;
    }

    setState(() {
      messages.add({'role': 'user', 'text': question, 'sources': <String>[]});
      controller.clear();
      isLoading = true;
    });

    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ask'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'question': question}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final answer =
            data['answer']?.toString() ?? 'I could not generate an answer.';

        final rawSources = data['sources'];
        List<String> sources = [];
        if (rawSources is List) {
          sources = rawSources.map((source) => source.toString()).toList();
        }

        setState(() {
          messages.add({
            'role': 'assistant',
            'text': answer,
            'sources': sources,
          });
          isLoading = false;
        });
      } else {
        setState(() {
          messages.add({
            'role': 'assistant',
            'text':
                'Sorry, I could not process your question right now. (Status: ${response.statusCode}). Please verify that FastAPI is running.',
            'sources': <String>[],
          });
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        messages.add({
          'role': 'assistant',
          'text':
              'I am unable to connect to the UniGuide AI server. Please make sure the FastAPI backend is running on `http://127.0.0.1:8000`.',
          'sources': <String>[],
        });
        isLoading = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
      );
    });
  }

  void askQuickQuestion(String question) {
    controller.text = question;
    sendQuestion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 74,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentCyan.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: AppColors.royalBlue.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/UniGuideAILogo.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'UniGuide AI',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.deepNavy,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.circle, color: Color(0xFF16A34A), size: 7),
                          SizedBox(width: 4),
                          Text(
                            'ONLINE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF15803D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'COMSATS Abbottabad • Student Assistant',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Clear conversation',
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.textSecondary,
            ),
            onPressed: clearConversation,
          ),
          const SizedBox(width: 12),
        ],
      ),

      body: _ParallaxAnimatedBackground(
        scrollController: scrollController,
        child: Column(
        children: [
          // Chat messages list
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final bool isUser = message['role'] == 'user';
                final String text = message['text']?.toString() ?? '';
                final List<String> sources = (message['sources'] is List)
                    ? (message['sources'] as List)
                          .map((item) => item.toString())
                          .toList()
                    : <String>[];

                return _ChatBubble(
                  text: text,
                  isUser: isUser,
                  sources: sources,
                  query: index > 0
                      ? messages[index - 1]['text']?.toString() ?? ''
                      : '',
                );
              },
            ),
          ),

          // Typing / thinking indicator
          if (isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentCyan.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.royalBlue,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'UniGuide AI is analyzing COMSATS records...',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.navy,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Quick question chips for first-time session
          if (messages.length <= 1 && !isLoading)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _QuickQuestionChip(
                      label: 'BSSE semester fee',
                      onTap: () => askQuickQuestion(
                        'What is the BS Software Engineering fee at COMSATS Abbottabad?',
                      ),
                    ),
                    _QuickQuestionChip(
                      label: 'Admission procedure',
                      onTap: () => askQuickQuestion(
                        'What is the admission procedure at COMSATS Abbottabad?',
                      ),
                    ),
                    _QuickQuestionChip(
                      label: 'Available scholarships',
                      onTap: () => askQuickQuestion(
                        'What scholarships are available for students at COMSATS Abbottabad?',
                      ),
                    ),
                    _QuickQuestionChip(
                      label: 'Hostel charges',
                      onTap: () => askQuickQuestion(
                        'What is the hostel fee and accommodation rules at COMSATS Abbottabad?',
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Message input bar
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.deepNavy.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: controller,
                        minLines: 1,
                        maxLines: 5,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => sendQuestion(),
                        decoration: InputDecoration(
                          hintText:
                              'Ask about fees, admissions, hostel, scholarships...',
                          hintStyle: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.chat_bubble_outline_rounded,
                            color: AppColors.royalBlue,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          suffixIcon: controller.text.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    setState(() {
                                      controller.clear();
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 20,
                                  ),
                                )
                              : null,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Container(
                    height: 54,
                    width: 54,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isLoading
                            ? [AppColors.textMuted, AppColors.textMuted]
                            : [AppColors.deepNavy, AppColors.royalBlue],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.deepNavy.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      tooltip: 'Send question',
                      onPressed: isLoading ? null : sendQuestion,
                      icon: const Icon(
                        Icons.arrow_upward_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }
}

// ============================================================
// CHAT BUBBLE & OFFICIAL CUI CITATIONS
// Markdown rendering for structured answers + Copy action
// ============================================================

class _ChatBubble extends StatefulWidget {
  final String text;
  final bool isUser;
  final List<String> sources;
  final String query;

  const _ChatBubble({
    required this.text,
    required this.isUser,
    required this.sources,
    required this.query,
  });

  @override
  State<_ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<_ChatBubble> {
  bool isCopied = false;

  String _cleanAnswer(String value) {
    final lines = value.split('\n');

    final cleanedLines = lines.where((line) {
      final trimmed = line.trim();
      final lower = trimmed.toLowerCase();
      if (lower.contains('source file:')) return false;
      if (lower.startsWith('source:') || lower.startsWith('sources:')) return false;
      if (lower.startsWith('**source:**') || lower.startsWith('*source:*')) return false;
      if (lower.startsWith('**sources:**') || lower.startsWith('sources used:')) return false;
      if (lower.startsWith('source :') || lower.startsWith('**source :**')) return false;
      if (lower.contains('official url:')) return false;
      if (lower.startsWith('official url')) return false;
      if (RegExp(r'\b[0-9]{2}_[a-zA-Z0-9_]+\.md\b').hasMatch(lower)) return false;
      if (lower.contains('.md') && (lower.contains('file') || lower.contains('source') || lower.contains('information') || lower.contains('di gayi'))) return false;
      return true;
    }).toList();

    return cleanedLines.join('\n').trim();
  }

  String? _pickRelevantSource() {
    if (widget.sources.isEmpty) return null;
    final q = widget.query.toLowerCase();

    String? findSource(List<String> keywords) {
      for (final source in widget.sources) {
        final lowerSource = source.toLowerCase();
        if (keywords.any((keyword) => lowerSource.contains(keyword))) {
          return source;
        }
      }
      return null;
    }

    if (q.contains('fee') ||
        q.contains('fees') ||
        q.contains('tuition') ||
        q.contains('cost') ||
        q.contains('payment')) {
      return findSource(['fee']);
    }
    if (q.contains('admission') ||
        q.contains('apply') ||
        q.contains('application') ||
        q.contains('merit') ||
        q.contains('nat') ||
        q.contains('nts')) {
      return findSource(['admission']);
    }
    if (q.contains('scholarship') ||
        q.contains('financial aid') ||
        q.contains('financial assistance') ||
        q.contains('concession')) {
      return findSource(['scholar']);
    }
    if (q.contains('hostel') ||
        q.contains('room') ||
        q.contains('mess') ||
        q.contains('accommodation')) {
      return findSource(['hostel']);
    }
    if (q.contains('transport') ||
        q.contains('bus') ||
        q.contains('route') ||
        q.contains('pick and drop')) {
      return findSource(['transport']);
    }
    if (q.contains('student affairs') ||
        q.contains('card') ||
        q.contains('societ') ||
        q.contains('activity') ||
        q.contains('campus life')) {
      return findSource(['student_affairs']) ?? findSource(['general']);
    }
    if (q.contains('rule') ||
        q.contains('rules') ||
        q.contains('discipline') ||
        q.contains('conduct')) {
      return findSource(['rule', 'conduct']);
    }
    if (q.contains('contact') ||
        q.contains('phone') ||
        q.contains('email') ||
        q.contains('office') ||
        q.contains('address')) {
      return findSource(['contact']);
    }
    if (q.contains('program') ||
        q.contains('degree') ||
        q.contains('department') ||
        q.contains('software engineering') ||
        q.contains('computer science')) {
      return findSource(['program']);
    }
    if (q.contains('faq') || q.contains('how can i') || q.contains('what is')) {
      return findSource(['faq']);
    }

    return findSource(['general']) ?? widget.sources.first;
  }

  String _referenceTitle(String source) {
    final lower = source.toLowerCase();
    if (lower.contains('fee')) return 'CUI Fee Structure';
    if (lower.contains('admission')) return 'CUI Admissions';
    if (lower.contains('scholar')) return 'CUI Scholarships';
    if (lower.contains('hostel')) return 'CUI Hostel';
    if (lower.contains('transport')) return 'CUI Transport';
    if (lower.contains('student_affairs')) return 'CUI Student Affairs';
    if (lower.contains('rule') || lower.contains('conduct')) {
      return 'CUI Rules & Conduct';
    }
    if (lower.contains('contact')) return 'CUI Contact';
    if (lower.contains('program')) return 'CUI Undergraduate Programs';
    if (lower.contains('faq')) return 'CUI FAQs';
    return 'CUI Abbottabad';
  }

  String _referenceUrl(String source) {
    final lower = source.toLowerCase();
    if (lower.contains('fee')) {
      return 'https://www.cuiatd.edu.pk/admissions-overview/fee-structure/';
    }
    if (lower.contains('admission')) {
      return 'https://www.cuiatd.edu.pk/admissions/';
    }
    if (lower.contains('scholar')) {
      return 'https://www.cuiatd.edu.pk/admissions/scholarships/';
    }
    if (lower.contains('hostel')) {
      return 'https://www.cuiatd.edu.pk/students/hostel/';
    }
    if (lower.contains('transport')) {
      return 'https://www.cuiatd.edu.pk/students/transport-2/';
    }
    if (lower.contains('student_affairs')) {
      return 'https://www.cuiatd.edu.pk/about/offices-and-administration/student-affairs/';
    }
    if (lower.contains('rule') || lower.contains('conduct')) {
      return 'https://www.cuiatd.edu.pk/students/code-of-conduct/';
    }
    if (lower.contains('contact')) return 'https://cuiatd.edu.pk/contact-us/';
    if (lower.contains('program')) {
      return 'https://www.cuiatd.edu.pk/admissions-overview/undergraduate/';
    }
    if (lower.contains('faq')) return 'https://cuiatd.edu.pk/faqs/';
    return 'https://cuiatd.edu.pk/';
  }

  Widget _referenceCard(String source) {
    final title = _referenceTitle(source);
    final url = _referenceUrl(source);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F9FD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD3E2F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.royalBlue.withValues(alpha: 0.3),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.royalBlue.withValues(alpha: 0.12),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/cui_logo.png',
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/UniGuideAILogo.png',
                      width: 24,
                      height: 24,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.deepNavy,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.open_in_new_rounded,
              size: 15,
              color: AppColors.royalBlue,
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(String content) {
    Clipboard.setData(ClipboardData(text: content));
    setState(() {
      isCopied = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          isCopied = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cleanedAnswer = _cleanAnswer(widget.text);
    final relevantSource = !widget.isUser ? _pickRelevantSource() : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: widget.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!widget.isUser)
            Container(
              width: 38,
              height: 38,
              margin: const EdgeInsets.only(right: 12, top: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.royalBlue.withValues(alpha: 0.35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentCyan.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/UniGuideAILogo.png',
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),

          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 780),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: widget.isUser ? AppColors.deepNavy : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(widget.isUser ? 20 : 6),
                  bottomRight: Radius.circular(widget.isUser ? 6 : 20),
                ),
                border: widget.isUser
                    ? null
                    : Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: widget.isUser
                        ? AppColors.deepNavy.withValues(alpha: 0.16)
                        : Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Structured markdown formatting for AI answers
                  if (!widget.isUser)
                    MarkdownBody(
                      data: cleanedAnswer,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14.5,
                          height: 1.6,
                        ),
                        h1: const TextStyle(
                          color: AppColors.deepNavy,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          height: 1.4,
                        ),
                        h2: const TextStyle(
                          color: AppColors.deepNavy,
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          height: 1.4,
                        ),
                        h3: const TextStyle(
                          color: AppColors.royalBlue,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          height: 1.4,
                        ),
                        strong: const TextStyle(
                          color: AppColors.deepNavy,
                          fontWeight: FontWeight.w800,
                        ),
                        code: const TextStyle(
                          backgroundColor: Color(0xFFF1F5F9),
                          fontFamily: 'monospace',
                          fontSize: 13,
                          color: AppColors.deepNavy,
                        ),
                        listBullet: const TextStyle(
                          color: AppColors.royalBlue,
                          fontWeight: FontWeight.bold,
                        ),
                        tableBorder: TableBorder.all(
                          color: AppColors.border,
                          width: 1,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        tableHead: const TextStyle(
                          color: AppColors.deepNavy,
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                        ),
                        tableBody: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13.5,
                        ),
                        tableCellsPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        tableColumnWidth: const IntrinsicColumnWidth(),
                        blockquote: const TextStyle(
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                          fontSize: 14,
                        ),
                        blockquoteDecoration: BoxDecoration(
                          color: AppColors.lightBlue.withValues(alpha: 0.5),
                          border: const Border(
                            left: BorderSide(
                              color: AppColors.royalBlue,
                              width: 3.5,
                            ),
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onTapLink: (text, href, title) {
                        if (href != null) {
                          launchUrl(
                            Uri.parse(href),
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                    )
                  else
                    Text(
                      cleanedAnswer,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        height: 1.55,
                      ),
                    ),

                  // Actions & references row for assistant answers
                  if (!widget.isUser) ...[
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: AppColors.borderSubtle),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (relevantSource != null)
                          _referenceCard(relevantSource)
                        else
                          const SizedBox(),

                        // Copy Answer action
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => _copyToClipboard(cleanedAnswer),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isCopied
                                      ? Icons.check_circle_rounded
                                      : Icons.copy_rounded,
                                  size: 15,
                                  color: isCopied
                                      ? const Color(0xFF16A34A)
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  isCopied ? 'Copied' : 'Copy',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: isCopied
                                        ? const Color(0xFF16A34A)
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          if (widget.isUser) const SizedBox(width: 48),
        ],
      ),
    );
  }
}

// ============================================================
// QUICK QUESTION CHIP
// ============================================================

class _QuickQuestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickQuestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      avatar: const Icon(
        Icons.auto_awesome,
        size: 16,
        color: AppColors.royalBlue,
      ),
      onPressed: onTap,
      backgroundColor: Colors.white,
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      labelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

// ============================================================
// RESOURCES PAGE
// ============================================================

class ResourcesPage extends StatefulWidget {
  const ResourcesPage({super.key});

  @override
  State<ResourcesPage> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _resAnimController;

  @override
  void initState() {
    super.initState();
    _resAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat();
  }

  @override
  void dispose() {
    _resAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 74,
        titleSpacing: 24,
        title: const Text(
          'COMSATS Official Quick Access',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: AppColors.deepNavy,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Institutional Portals & Services',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Verified links to official COMSATS Abbottabad academic systems and student services.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                _QuickAccessGrid(animation: _resAnimController),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ABOUT PAGE
// Official institutional credentials and project information
// ============================================================

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 74,
        titleSpacing: 24,
        title: const Text(
          'About UniGuide AI',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: AppColors.deepNavy,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 48),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentCyan.withValues(alpha: 0.28),
                            blurRadius: 18,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: AppColors.royalBlue.withValues(alpha: 0.4),
                          width: 2.0,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/UniGuideAILogo.png',
                          width: 74,
                          height: 74,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'UniGuide AI',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppColors.deepNavy,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'COMSATS University Islamabad • Abbottabad Campus',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.royalBlue,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'AI-Powered Student Assistant & Knowledge Retrieval System',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 36),

                _aboutCard(
                  icon: Icons.auto_awesome_rounded,
                  title: 'Retrieval-Augmented Generation (RAG)',
                  text:
                      'UniGuide AI indexes official university prospectuses, fee challans, admission circulars, transport routes, and hostel regulations into vector embeddings for grounded, hallucination-free student assistance.',
                ),

                const SizedBox(height: 16),

                _aboutCard(
                  icon: Icons.verified_user_rounded,
                  title: 'Official Source Grounding',
                  text:
                      'Every response generated by UniGuide AI includes direct citation links to official CUI Abbottabad web pages, allowing students to verify information instantly.',
                ),

                const SizedBox(height: 16),

                _aboutCard(
                  icon: Icons.translate_rounded,
                  title: 'Multilingual Support',
                  text:
                      'Students can ask queries in natural English, Urdu, or Roman Urdu (e.g. "BSSE ki fees kitni hay?"). The semantic search accurately retrieves the right institutional context.',
                ),

                const SizedBox(height: 16),

                _aboutCard(
                  icon: Icons.security_rounded,
                  title: 'Student Privacy & Fast Performance',
                  text:
                      'Queries are processed directly through the local high-speed FastAPI backend on port 8000, ensuring immediate response times and reliable operation during submission evaluation.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _aboutCard({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.lightBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.deepNavy, size: 24),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.55,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HOVER BUILDER HELPER WIDGET
// Provides clean mouse cursor and hover state tracking
// ============================================================

class _HoverBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, bool isHovering) builder;

  const _HoverBuilder({required this.builder});

  @override
  State<_HoverBuilder> createState() => _HoverBuilderState();
}

class _HoverBuilderState extends State<_HoverBuilder> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() => isHovering = false),
      child: widget.builder(context, isHovering),
    );
  }
}
