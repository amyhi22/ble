import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../database/history_database.dart';
import '../models/detection_history.dart';
import '../services/auth_service.dart';

// 🎨 Theme Colors
const Color kWhite = Colors.white;
const Color kOffWhite = Color(0xFFFAFAF7);
const Color kBrown = Color(0xFF594020);
const Color kGreen = Color(0xFF768E2E);
const Color kDarkGreen = Color(0xFF002319);

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen>
    with TickerProviderStateMixin {
  List<DetectionHistory> _history = [];
  bool _loading = true;

  // Animation Controllers
  late AnimationController _breathController;
  late AnimationController _emptyStateController;
  late AnimationController _listLoadController;

  @override
  void initState() {
    super.initState();

    // Organic breathing animation for cards
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Pulsing animation for empty state
    _emptyStateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Staggered load animation for list items
    _listLoadController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    _loadHistory();
  }

  @override
  void dispose() {
    _breathController.dispose();
    _emptyStateController.dispose();
    _listLoadController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() => _loading = true);

    final user = AuthService.getCurrentUser();

    if (user == null) {
      setState(() {
        _history = [];
        _loading = false;
      });
      return;
    }

    final data = HistoryDatabase.getUserHistory(user.userId);

    setState(() {
      _history = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kOffWhite,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kGreen))
          : _history.isEmpty
          ? _buildEmptyState()
          : _buildHistoryList(),
    );
  }

  // 🌿 Glassmorphism AppBar
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: AppBar(
            backgroundColor: kOffWhite.withOpacity(0.7),
            elevation: 0,
            centerTitle: true,
            title: Column(
              children: [
                const Text(
                  "Scan History",
                  style: TextStyle(
                    color: kDarkGreen,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Container(
                      height: 3,
                      width: 40 * value,
                      decoration: BoxDecoration(
                        color: kBrown,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🌱 Living Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _emptyStateController,
              builder: (context, child) {
                final scale = 1.0 + (math.sin(_emptyStateController.value * 2 * math.pi) * 0.05);
                final rotation = math.sin(_emptyStateController.value * 2 * math.pi) * 0.05;
                return Transform.scale(
                  scale: scale,
                  child: Transform.rotate(
                    angle: rotation,
                    child: child,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kGreen.withOpacity(0.1),
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  size: 64,
                  color: kGreen,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "Your plant health history\nwill grow here",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: kBrown,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to scan screen
              },
              icon: const Icon(Icons.camera_alt_rounded),
              label: const Text("Scan a Plant"),
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreen,
                foregroundColor: kWhite,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📜 Animated History List
  Widget _buildHistoryList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 110, 16, 24),
      physics: const BouncingScrollPhysics(),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];
        return _HistoryCard(
          item: item,
          index: index,
          totalItems: _history.length,
          breathController: _breathController,
          listLoadController: _listLoadController,
          onTap: () => _showDetails(item),
        );
      },
    );
  }

  // 🌿 Animated Detail Bottom Sheet
  void _showDetails(DetectionHistory item) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: _DetailSheet(item: item),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
              ),
              child: child,
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }
}

// 🃏 Living History Card with Plant Background
class _HistoryCard extends StatelessWidget {
  final DetectionHistory item;
  final int index;
  final int totalItems;
  final AnimationController breathController;
  final AnimationController listLoadController;
  final VoidCallback onTap;

  const _HistoryCard({
    required this.item,
    required this.index,
    required this.totalItems,
    required this.breathController,
    required this.listLoadController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Staggered load animation
    final intervalStart = (index / totalItems) * 0.5;
    final intervalEnd = intervalStart + 0.5;
    final loadAnimation = CurvedAnimation(
      parent: listLoadController,
      curve: Interval(intervalStart, intervalEnd, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: loadAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: loadAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - loadAnimation.value)),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: AnimatedBuilder(
          animation: breathController,
          builder: (context, child) {
            // Organic breathing effect
            final breathValue = math.sin(breathController.value * 2 * math.pi + (index * 0.8));
            final scale = 1.0 + (breathValue * 0.015);

            return Transform.scale(
              scale: scale,
              child: _TappableScale(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: kBrown.withOpacity(0.15),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: kDarkGreen.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // 🌿 Animated Plant Background
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: CustomPaint(
                            painter: _PlantBackgroundPainter(
                              animation: breathController,
                              index: index,
                            ),
                          ),
                        ),
                      ),
                      // Content
                      Row(
                        children: [
                          _buildConfidenceIndicator(),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.diseaseName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: kDarkGreen,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _formatDate(item.timestamp),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: kBrown.withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: kBrown.withOpacity(0.4),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildConfidenceIndicator() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: item.confidence),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return SizedBox(
          width: 56,
          height: 56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: 6,
                  backgroundColor: kBrown.withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(kGreen),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(
                "${(value * 100).toInt()}%",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: kDarkGreen,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final amPm = date.hour >= 12 ? "PM" : "AM";
    final min = date.minute.toString().padLeft(2, '0');
    return "${months[date.month - 1]} ${date.day}, ${date.year} • $hour:$min $amPm";
  }
}

// 🌿 Plant Background Painter
class _PlantBackgroundPainter extends CustomPainter {
  final Animation<double> animation;
  final int index;

  _PlantBackgroundPainter({
    required this.animation,
    required this.index,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Calculate floating offset based on animation
    final floatOffset = math.sin(animation.value * 2 * math.pi + (index * 0.5)) * 5;
    final rotation = math.sin(animation.value * 2 * math.pi + (index * 0.3)) * 0.1;

    // Draw leaves in corners
    _drawLeaf(
        canvas,
        size,
        Offset(size.width - 30, 20 + floatOffset),
        rotation,
        kGreen.withOpacity(0.08),
        0.6
    );

    _drawLeaf(
        canvas,
        size,
        Offset(size.width - 60, size.height - 40 + floatOffset),
        rotation + math.pi,
        kGreen.withOpacity(0.06),
        0.5
    );

    _drawLeaf(
        canvas,
        size,
        Offset(20, size.height - 30 + floatOffset),
        -rotation,
        kBrown.withOpacity(0.05),
        0.4
    );
  }

  void _drawLeaf(Canvas canvas, Size size, Offset position, double rotation, Color color, double scale) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(rotation);
    canvas.scale(scale);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(15, -20, 30, 0);
    path.quadraticBezierTo(15, 20, 0, 0);

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 📜 Detail Bottom Sheet
class _DetailSheet extends StatefulWidget {
  final DetectionHistory item;
  const _DetailSheet({required this.item});

  @override
  State<_DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends State<_DetailSheet> with TickerProviderStateMixin {
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _progressController.forward();
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      decoration: const BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: kBrown.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAnimatedHeader(item),
                  const SizedBox(height: 24),
                  _buildConfidenceSection(item),
                  const SizedBox(height: 32),
                  _buildSectionTitle("Symptoms", Icons.biotech_rounded),
                  const SizedBox(height: 12),
                  _buildAnimatedChips(item.symptoms, kGreen),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Treatments", Icons.healing_rounded),
                  const SizedBox(height: 12),
                  _buildAnimatedList(item.treatments),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Medicines", Icons.medication_rounded),
                  const SizedBox(height: 12),
                  _buildAnimatedChips(item.medicines, kBrown),
                  if (item.notes != null && item.notes!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSectionTitle("Notes", Icons.note_alt_rounded),
                    const SizedBox(height: 12),
                    _buildAnimatedNotes(item.notes!),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedHeader(DetectionHistory item) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.diseaseName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: kDarkGreen,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Detected on ${_formatDateFull(item.timestamp)}",
            style: TextStyle(
              fontSize: 14,
              color: kBrown.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceSection(DetectionHistory item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Confidence Level",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: kDarkGreen,
              ),
            ),
            AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                final value = (item.confidence * _progressController.value * 100).toInt();
                return Text(
                  "$value%",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kGreen,
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        AnimatedBuilder(
          animation: _progressController,
          builder: (context, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: item.confidence * _progressController.value,
                minHeight: 12,
                backgroundColor: kBrown.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(kGreen),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 15 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Row(
        children: [
          Icon(icon, color: kGreen, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kDarkGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedChips(List<String> items, Color bgColor) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(items.length, (index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: child,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: bgColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: bgColor.withOpacity(0.2)),
            ),
            child: Text(
              items[index],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: bgColor,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAnimatedList(List<String> items) {
    return Column(
      children: List.generate(items.length, (index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(20 * (1 - value), 0),
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: kGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    items[index],
                    style: TextStyle(
                      fontSize: 15,
                      color: kBrown.withOpacity(0.8),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAnimatedNotes(String notes) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kBrown.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBrown.withOpacity(0.1)),
        ),
        child: Text(
          notes,
          style: TextStyle(
            fontSize: 15,
            color: kBrown.withOpacity(0.8),
            height: 1.5,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  String _formatDateFull(DateTime date) {
    final months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final amPm = date.hour >= 12 ? "PM" : "AM";
    final min = date.minute.toString().padLeft(2, '0');
    return "${months[date.month - 1]} ${date.day}, ${date.year} at $hour:$min $amPm";
  }
}

// 🖐️ Micro-interaction: Tappable Scale Effect
class _TappableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _TappableScale({required this.child, required this.onTap});

  @override
  State<_TappableScale> createState() => _TappableScaleState();
}

class _TappableScaleState extends State<_TappableScale> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}