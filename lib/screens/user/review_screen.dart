import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../config/theme.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen>
    with TickerProviderStateMixin {
  int rating = 0;
  TextEditingController feedbackController = TextEditingController();
  bool isSubmitting = false;
  bool _isDarkMode = false;
  bool _enableReminder = false;
  bool _enableNotifications = true;
  bool _isAnonymous = false;
  List<String> selectedFeedbacks = [];
  List<String> uploadedPhotos = [];
  String selectedCategory = 'Service Quality';

  // Animation Controllers
  late AnimationController _avatarController;
  late AnimationController _starsController;
  late AnimationController _cardController;
  late AnimationController _slideController;
  late AnimationController _bounceController;

  // Animations
  late Animation<double> _avatarAnimation;
  late Animation<double> _starsAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _cardScaleAnimation;

  // Categories for feedback
  final List<String> categories = [
    'Service Quality',
    'Timeliness',
    'Communication',
    'Professionalism',
    'Value for Money',
  ];

  // Quick feedback options by category
  final Map<String, List<String>> feedbackOptions = {
    'Service Quality': ['Excellent service', 'Professional work', 'High quality', 'Needs improvement'],
    'Timeliness': ['On-time arrival', 'Quick response', 'Delayed service', 'Very fast'],
    'Communication': ['Clear communication', 'Responsive', 'Friendly staff', 'Poor communication'],
    'Professionalism': ['Very professional', 'Courteous behavior', 'Well equipped', 'Unprofessional'],
    'Value for Money': ['Fair pricing', 'Great value', 'Expensive', 'Worth the cost'],
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startEntryAnimations();
  }

  void _initializeAnimations() {
    _avatarController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _starsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _avatarAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _avatarController, curve: Curves.easeInOut),
    );

    _starsAnimation = CurvedAnimation(
      parent: _starsController,
      curve: Curves.elasticOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _bounceAnimation = CurvedAnimation(
      parent: _bounceController,
      curve: Curves.bounceOut,
    );

    _cardScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.elasticOut),
    );
  }

  void _startEntryAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _cardController.forward();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    feedbackController.dispose();
    _avatarController.dispose();
    _starsController.dispose();
    _cardController.dispose();
    _slideController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        return Scaffold(
          backgroundColor: _isDarkMode
              ? const Color(0xFF0A0A0A)
              : const Color(0xFFF8F9FA),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildModernAppBar(constraints, isTablet),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? constraints.maxWidth * 0.1 : 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProviderInfoCard(constraints, isTablet),
                      const SizedBox(height: 24),
                      _buildRatingSection(constraints, isTablet),
                      const SizedBox(height: 32),
                      _buildCategorySection(constraints, isTablet),
                      const SizedBox(height: 24),
                      _buildQuickFeedbackSection(constraints, isTablet),
                      const SizedBox(height: 24),
                      _buildFeedbackSection(constraints, isTablet),
                      const SizedBox(height: 24),
                      _buildPhotoUploadSection(constraints, isTablet),
                      const SizedBox(height: 24),
                      _buildSettingsSection(constraints, isTablet),
                      const SizedBox(height: 32),
                      _buildActionButtons(constraints, isTablet),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernAppBar(BoxConstraints constraints, bool isTablet) {
    return SliverAppBar(
      expandedHeight: isTablet ? 120 : 100,
      floating: false,
      pinned: true,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isDarkMode
                ? [
              const Color(0xFF1A1A1A),
              const Color(0xFF2D2D2D),
              const Color(0xFF404040)
            ]
                : [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withOpacity(0.8),
              AppTheme.primaryColor.withOpacity(0.6)
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  onPressed: () => _showSkipConfirmationDialog(context, constraints),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Rate Your Experience',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 24 : 20,
                        ),
                      ),
                      Text(
                        'Help us improve our service',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: isTablet ? 14 : 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() => _isDarkMode = !_isDarkMode);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProviderInfoCard(BoxConstraints constraints, bool isTablet) {
    return AnimatedBuilder(
      animation: _cardScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardScaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isDarkMode
                    ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
                    : [Colors.white, Colors.grey[50]!],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _isDarkMode
                      ? Colors.black.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 24 : 20),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _avatarAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _avatarAnimation.value,
                        child: Container(
                          width: isTablet ? 80 : 64,
                          height: isTablet ? 80 : 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryColor,
                                AppTheme.primaryColor.withOpacity(0.7),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.3),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.network(
                              'https://via.placeholder.com/80',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: isTablet ? 40 : 32,
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: isTablet ? 20 : 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rajesh Kumar',
                          style: TextStyle(
                            fontSize: isTablet ? 22 : 18,
                            fontWeight: FontWeight.bold,
                            color: _isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Towing Service Provider',
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.successColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: AppTheme.successColor,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Service Completed',
                                style: TextStyle(
                                  fontSize: isTablet ? 14 : 12,
                                  color: AppTheme.successColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.star_outline,
                      color: AppTheme.primaryColor,
                      size: isTablet ? 28 : 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRatingSection(BoxConstraints constraints, bool isTablet) {
    // Calculate responsive dimensions based on screen width
    final screenWidth = constraints.maxWidth;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;

    // Responsive padding
    final padding = isTablet ? 32.0 : (isSmallScreen ? 16.0 : 24.0);

    // Responsive text sizes
    final titleFontSize = isTablet ? 24.0 : (isSmallScreen ? 18.0 : 20.0);
    final ratingTextSize = isTablet ? 18.0 : (isSmallScreen ? 14.0 : 16.0);

    // Responsive star dimensions
    final starContainerSize = isTablet
        ? 60.0
        : (isSmallScreen ? 40.0 : 50.0);
    final starIconSize = isTablet
        ? 32.0
        : (isSmallScreen ? 22.0 : 28.0);

    // Responsive spacing
    final starHorizontalMargin = isTablet
        ? 8.0
        : (isSmallScreen ? 2.0 : 4.0);

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: isTablet ? 600 : double.infinity,
        ),
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isDarkMode
                ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
                : [Colors.white, Colors.grey[50]!],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title with responsive sizing and overflow protection
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'How was your experience?',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: _isDarkMode ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            SizedBox(height: isSmallScreen ? 12 : 20),

            // Stars section with overflow protection
            AnimatedBuilder(
              animation: _starsAnimation,
              builder: (context, child) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: screenWidth - (padding * 2) - 16, // Account for container padding and margins
                  ),
                  child: LayoutBuilder(
                    builder: (context, starConstraints) {
                      // Calculate available width for stars
                      final availableWidth = starConstraints.maxWidth;
                      final totalStarWidth = (starContainerSize * 5) + (starHorizontalMargin * 2 * 5);

                      // Scale down if needed
                      final scaleFactor = totalStarWidth > availableWidth
                          ? availableWidth / totalStarWidth
                          : 1.0;

                      final adjustedStarSize = starContainerSize * scaleFactor;
                      final adjustedIconSize = starIconSize * scaleFactor;
                      final adjustedMargin = starHorizontalMargin * scaleFactor;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              setState(() {
                                rating = index + 1;
                              });
                              _starsController.forward();
                              _bounceController.forward().then((_) {
                                _bounceController.reverse();
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: EdgeInsets.symmetric(
                                horizontal: adjustedMargin,
                              ),
                              child: Transform.scale(
                                scale: (index < rating ? 1.2 : 1.0) * scaleFactor,
                                child: Container(
                                  width: adjustedStarSize,
                                  height: adjustedStarSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: index < rating
                                        ? LinearGradient(
                                      colors: [
                                        Colors.amber,
                                        Colors.orange,
                                      ],
                                    )
                                        : null,
                                    color: index < rating
                                        ? null
                                        : (_isDarkMode ? Colors.grey[700] : Colors.grey[200]),
                                    boxShadow: index < rating
                                        ? [
                                      BoxShadow(
                                        color: Colors.amber.withOpacity(0.4),
                                        blurRadius: 12 * scaleFactor,
                                        spreadRadius: 2 * scaleFactor,
                                      ),
                                    ]
                                        : null,
                                  ),
                                  child: Icon(
                                    Icons.star,
                                    size: adjustedIconSize,
                                    color: index < rating
                                        ? Colors.white
                                        : (_isDarkMode ? Colors.grey[500] : Colors.grey[400]),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                );
              },
            ),

            SizedBox(height: isSmallScreen ? 12 : 16),

            // Rating text with overflow protection
            Flexible(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: ratingTextSize,
                  color: _getRatingColor(rating),
                  fontWeight: FontWeight.w600,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _getRatingText(rating),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(BoxConstraints constraints, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _isDarkMode
              ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
              : [Colors.white, Colors.grey[50]!],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category',
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: _isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((category) {
              final isSelected = selectedCategory == category;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    selectedCategory = category;
                    selectedFeedbacks.clear(); // Clear previous selections
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 20 : 16,
                    vertical: isTablet ? 12 : 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryColor.withOpacity(0.8),
                      ],
                    )
                        : null,
                    color: isSelected
                        ? null
                        : (_isDarkMode ? Colors.grey[800] : Colors.grey[100]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isSelected
                        ? [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ]
                        : null,
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : (_isDarkMode ? Colors.white70 : Colors.black87),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFeedbackSection(BoxConstraints constraints, bool isTablet) {
    final options = feedbackOptions[selectedCategory] ?? [];

    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _isDarkMode
              ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
              : [Colors.white, Colors.grey[50]!],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flash_on,
                color: AppTheme.primaryColor,
                size: isTablet ? 28 : 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Quick Feedback',
                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: _isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((feedback) {
              return _buildFeedbackChip(feedback, constraints, isTablet);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackChip(String label, BoxConstraints constraints, bool isTablet) {
    final isSelected = selectedFeedbacks.contains(label);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (_isDarkMode ? Colors.white70 : Colors.black87),
          ),
        ),
        selected: isSelected,
        selectedColor: AppTheme.primaryColor,
        checkmarkColor: Colors.white,
        backgroundColor: _isDarkMode ? Colors.grey[800] : Colors.grey[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected
                ? AppTheme.primaryColor
                : (_isDarkMode ? Colors.grey[600]! : Colors.grey[300]!),
          ),
        ),
        elevation: isSelected ? 4 : 0,
        onSelected: (selected) {
          HapticFeedback.lightImpact();
          setState(() {
            if (selected) {
              selectedFeedbacks.add(label);
              _updateFeedbackText();
            } else {
              selectedFeedbacks.remove(label);
              _updateFeedbackText();
            }
          });
        },
      ),
    );
  }

  void _updateFeedbackText() {
    final text = selectedFeedbacks.join(', ');
    feedbackController.text = text;
  }

  Widget _buildFeedbackSection(BoxConstraints constraints, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _isDarkMode
              ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
              : [Colors.white, Colors.grey[50]!],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit_note,
                color: AppTheme.primaryColor,
                size: isTablet ? 28 : 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Additional Feedback',
                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: _isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const Spacer(),
              Text(
                'Optional',
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
              ),
            ),
            child: TextField(
              controller: feedbackController,
              maxLines: isTablet ? 5 : 4,
              maxLength: 500,
              style: TextStyle(
                color: _isDarkMode ? Colors.white : Colors.black87,
                fontSize: isTablet ? 16 : 14,
              ),
              decoration: InputDecoration(
                hintText: 'Share your detailed experience...',
                hintStyle: TextStyle(
                  color: _isDarkMode ? Colors.grey[500] : Colors.grey[500],
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                counterStyle: TextStyle(
                  color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              onChanged: (text) {
                // Auto-save functionality could be added here
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoUploadSection(BoxConstraints constraints, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _isDarkMode
              ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
              : [Colors.white, Colors.grey[50]!],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.camera_alt,
                color: AppTheme.primaryColor,
                size: isTablet ? 28 : 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Add Photos',
                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: _isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${uploadedPhotos.length}/5',
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 10,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (uploadedPhotos.isEmpty) ...[
            GestureDetector(
              onTap: _handlePhotoUpload,
              child: Container(
                height: isTablet ? 150 : 120,
                decoration: BoxDecoration(
                  color: _isDarkMode ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                    style: BorderStyle.solid,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add_photo_alternate,
                          size: isTablet ? 40 : 32,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to add photos',
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Up to 5 photos',
                        style: TextStyle(
                          fontSize: isTablet ? 12 : 10,
                          color: _isDarkMode ? Colors.grey[500] : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ] else ...[
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 4 : 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: uploadedPhotos.length + (uploadedPhotos.length < 5 ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == uploadedPhotos.length && uploadedPhotos.length < 5) {
                  return GestureDetector(
                    onTap: _handlePhotoUpload,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isDarkMode ? Colors.grey[800] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.5),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Icon(
                        Icons.add,
                        color: AppTheme.primaryColor,
                        size: isTablet ? 32 : 24,
                      ),
                    ),
                  );
                }
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(uploadedPhotos[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removePhoto(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BoxConstraints constraints, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _isDarkMode
              ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
              : [Colors.white, Colors.grey[50]!],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings,
                color: AppTheme.primaryColor,
                size: isTablet ? 28 : 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Preferences',
                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: _isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Reminder Notifications',
            subtitle: 'Get reminded to rate after 24 hours',
            value: _enableReminder,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              setState(() => _enableReminder = value);
              if (value) {
                _showSnackBar('Reminder set for 24 hours', AppTheme.successColor);
              }
            },
            isTablet: isTablet,
          ),
          const SizedBox(height: 12),
          _buildSettingsTile(
            icon: Icons.campaign_outlined,
            title: 'Review Notifications',
            subtitle: 'Receive updates about your reviews',
            value: _enableNotifications,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              setState(() => _enableNotifications = value);
            },
            isTablet: isTablet,
          ),
          const SizedBox(height: 12),
          _buildSettingsTile(
            icon: Icons.visibility_off_outlined,
            title: 'Anonymous Review',
            subtitle: 'Submit review without showing your name',
            value: _isAnonymous,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              setState(() => _isAnonymous = value);
            },
            isTablet: isTablet,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required bool isTablet,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isDarkMode ? Colors.grey[800]?.withOpacity(0.5) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
            size: isTablet ? 24 : 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: _isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 10,
                    color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: AppTheme.primaryColor,
            inactiveTrackColor: _isDarkMode ? Colors.grey[700] : Colors.grey[300],
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BoxConstraints constraints, bool isTablet) {
    return Column(
      children: [
        // Submit Button
        AnimatedBuilder(
          animation: _bounceAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: 1 + (_bounceAnimation.value * 0.1),
              child: Container(
                width: double.infinity,
                height: isTablet ? 60 : 52,
                decoration: BoxDecoration(
                  gradient: rating > 0
                      ? LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withOpacity(0.8),
                    ],
                  )
                      : null,
                  color: rating > 0 ? null : Colors.grey[400],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: rating > 0
                      ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 0,
                      offset: const Offset(0, 6),
                    ),
                  ]
                      : null,
                ),
                child: ElevatedButton(
                  onPressed: rating > 0 && !isSubmitting ? _submitReview : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isSubmitting
                      ? SizedBox(
                    width: isTablet ? 28 : 24,
                    height: isTablet ? 28 : 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.send,
                        size: isTablet ? 24 : 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Submit Review',
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        // Skip Button
        TextButton.icon(
          onPressed: () => _showSkipConfirmationDialog(context, constraints),
          icon: Icon(
            Icons.skip_next,
            color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
            size: isTablet ? 20 : 18,
          ),
          label: Text(
            'Skip for now',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  // Helper Methods
  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Poor Experience';
      case 2:
        return 'Fair Service';
      case 3:
        return 'Good Service';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent!';
      default:
        return 'Tap to rate your experience';
    }
  }

  Color _getRatingColor(int rating) {
    if (rating == 0) return _isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
    if (rating <= 2) return Colors.red[400]!;
    if (rating == 3) return Colors.orange[400]!;
    return AppTheme.successColor;
  }

  void _handlePhotoUpload() {
    HapticFeedback.mediumImpact();
    if (uploadedPhotos.length >= 5) {
      _showSnackBar('Maximum 5 photos allowed', Colors.orange);
      return;
    }

    // Simulate photo upload
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: _isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppTheme.primaryColor),
              title: Text(
                'Take Photo',
                style: TextStyle(
                  color: _isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _simulatePhotoUpload();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppTheme.primaryColor),
              title: Text(
                'Choose from Gallery',
                style: TextStyle(
                  color: _isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _simulatePhotoUpload();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _simulatePhotoUpload() {
    setState(() {
      uploadedPhotos.add('https://via.placeholder.com/200');
    });
    _showSnackBar('Photo added successfully!', AppTheme.successColor);
  }

  void _removePhoto(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      uploadedPhotos.removeAt(index);
    });
    _showSnackBar('Photo removed', Colors.grey);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _submitReview() {
    if (rating == 0) {
      _showSnackBar('Please select a rating', Colors.orange);
      return;
    }

    setState(() => isSubmitting = true);
    HapticFeedback.heavyImpact();

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => isSubmitting = false);
      _showSuccessDialog();
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: _isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: AppTheme.successColor,
                size: 50,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Thank You!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your review has been submitted successfully. It helps us improve our service.',
              style: TextStyle(
                fontSize: 16,
                color: _isDarkMode ? Colors.white70 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _goToDashboard();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSkipConfirmationDialog(BuildContext context, BoxConstraints constraints) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: _isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.help_outline,
              color: Colors.orange,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Skip Review?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your feedback helps us improve our service. Are you sure you want to skip?',
              style: TextStyle(
                fontSize: 14,
                color: _isDarkMode ? Colors.white70 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _goToDashboard();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Skip',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _goToDashboard() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/dashboard',
          (route) => false,
    );
  }
}