import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_transitions.dart';

class FeatureCardItem {
  const FeatureCardItem({
    required this.id,
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.highlightOffer,
    required this.gradientColors,
    required this.icon,
    required this.buttonLabel,
    required this.onTap,
  });

  final String id;
  final String tag;
  final String title;
  final String subtitle;
  final String highlightOffer;
  final List<Color> gradientColors;
  final IconData icon;
  final String buttonLabel;
  final VoidCallback onTap;
}

class StackedFeatureCardDeck extends StatefulWidget {
  const StackedFeatureCardDeck({
    super.key,
    required this.cards,
    this.title = 'Featured Capabilities',
    this.height = 320,
  });

  final List<FeatureCardItem> cards;
  final String title;
  final double height;

  @override
  State<StackedFeatureCardDeck> createState() => _StackedFeatureCardDeckState();
}

class _StackedFeatureCardDeckState extends State<StackedFeatureCardDeck>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  double _dragOffset = 0.0;
  late final AnimationController _animController;
  Animation<double>? _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _animController.addListener(() {
      setState(() {
        _dragOffset = _slideAnimation?.value ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _nextCard() {
    if (widget.cards.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.cards.length;
      _dragOffset = 0.0;
    });
  }

  void _previousCard() {
    if (widget.cards.isEmpty) return;
    setState(() {
      _currentIndex =
          (_currentIndex - 1 + widget.cards.length) % widget.cards.length;
      _dragOffset = 0.0;
    });
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.primaryDelta ?? 0.0;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0.0;
    const threshold = 60.0;

    if (_dragOffset < -threshold || velocity < -400) {
      // Swiped Left -> Next
      _slideAnimation = Tween<double>(begin: _dragOffset, end: -350.0).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
      );
      _animController.forward(from: 0.0).then((_) {
        _nextCard();
        _dragOffset = 0.0;
      });
    } else if (_dragOffset > threshold || velocity > 400) {
      // Swiped Right -> Previous
      _slideAnimation = Tween<double>(begin: _dragOffset, end: 350.0).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
      );
      _animController.forward(from: 0.0).then((_) {
        _previousCard();
        _dragOffset = 0.0;
      });
    } else {
      // Snap back
      _slideAnimation = Tween<double>(begin: _dragOffset, end: 0.0).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
      );
      _animController.forward(from: 0.0).then((_) {
        _dragOffset = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (widget.cards.isEmpty) return const SizedBox.shrink();

    final nextIndex = (_currentIndex + 1) % widget.cards.length;
    final prevIndex =
        (_currentIndex - 1 + widget.cards.length) % widget.cards.length;

    final currentCard = widget.cards[_currentIndex];
    final backgroundCard =
        _dragOffset < 0 ? widget.cards[nextIndex] : widget.cards[prevIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: isDark ? AppColors.darkText : AppColors.ink,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 16),
                    onPressed: _previousCard,
                    tooltip: 'Previous feature',
                    visualDensity: VisualDensity.compact,
                  ),
                  Text(
                    '${_currentIndex + 1}/${widget.cards.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkMuted : AppColors.muted,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onPressed: _nextCard,
                    tooltip: 'Next feature',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: widget.height,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // 3D Layered Background Card (Image 2 stacked depth effect)
                Positioned(
                  left: _dragOffset < 0 ? 36 : 8,
                  right: _dragOffset < 0 ? 8 : 36,
                  top: 14,
                  bottom: 14,
                  child: Transform.scale(
                    scale: 0.92,
                    child: Opacity(
                      opacity: 0.75,
                      child: _buildCardContent(backgroundCard, isDark, isBackground: true),
                    ),
                  ),
                ),

                // Front Active Swipable Card
                Transform.translate(
                  offset: Offset(_dragOffset, 0),
                  child: Transform.rotate(
                    angle: (_dragOffset / 1000) * (math.pi / 16),
                    child: _buildCardContent(currentCard, isDark, isBackground: false),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Smooth Dot Pagination Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.cards.length, (idx) {
            final isActive = idx == _currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 22 : 6,
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isActive
                    ? currentCard.gradientColors.first
                    : (isDark ? Colors.white24 : Colors.black12),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCardContent(FeatureCardItem item, bool isDark, {required bool isBackground}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: item.gradientColors,
        ),
        boxShadow: isBackground
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : [
                BoxShadow(
                  color: item.gradientColors.first.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Abstract Modern Curved Ambient Art Shapes (Image 2 style)
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
            ),
            Positioned(
              left: -40,
              bottom: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.10),
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: 40,
              child: Icon(
                item.icon,
                size: 96,
                color: Colors.white.withValues(alpha: 0.18),
              ),
            ),

            // Foreground Content Layout
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Feature Category Pill Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          item.tag.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.7,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Large Bold Title (Image 2 typography)
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                          height: 1.15,
                        ),
                      ),

                      const SizedBox(height: 3),

                      // Subtitle
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),

                  // Bottom Highlight Offer & Interactive Button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.highlightOffer,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        BouncyTapWrapper(
                          onTap: item.onTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  item.buttonLabel,
                                  style: TextStyle(
                                    color: item.gradientColors.first,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 13,
                                  color: item.gradientColors.first,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
