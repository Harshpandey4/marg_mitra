import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../terms_condition.dart';

class IntegratedLoginScreen extends ConsumerStatefulWidget {
  const IntegratedLoginScreen({super.key});

  @override
  ConsumerState<IntegratedLoginScreen> createState() => _IntegratedLoginScreenState();
}

class _IntegratedLoginScreenState extends ConsumerState<IntegratedLoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(4, (_) => FocusNode());

  bool _rememberMe = false;
  bool _acceptedTerms = false;
  bool _isProvider = false;
  bool _isOTPSent = false;
  String _selectedLanguage = 'English';
  int _resendTimer = 60;
  Timer? _timer;

  // SOS button animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<String> _languages = [
    'English',
    'हिंदी',
    'বাংলা',
    'తెలుగు',
    'தமிழ்',
    'मराठी',
    'ગુજરાતી',
    'ಕನ್ನಡ',
    'മലയാളം',
    'ਪੰਜਾਬੀ',
  ];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    _pulseController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _sendOTP() async {
    if (_formKey.currentState!.validate()) {
      if (!_acceptedTerms) {
        _showTermsError();
        return;
      }

      await ref.read(authProvider.notifier).sendOTP(
          _phoneController.text,
          isProvider: _isProvider
      );

      final authState = ref.read(authProvider);
      if (authState.errorMessage == null) {
        setState(() {
          _isOTPSent = true;
          _resendTimer = 60;
        });
        _startTimer();
      } else {
        if (mounted) {
          _showErrorSnackbar(authState.errorMessage!);
        }
      }
    }
  }

  void _verifyOTP() async {
    String otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 4) {
      _showErrorSnackbar('Please enter the complete OTP');
      return;
    }

    await ref.read(authProvider.notifier).login(
        _phoneController.text,
        otp,
        isProvider: _isProvider
    );

    final authState = ref.read(authProvider);

    if (authState.isLoggedIn && authState.errorMessage == null) {
      if (mounted) {
        final userRole = authState.currentUser?.role;
        bool shouldNavigateToProvider = false;

        if (userRole != null) {
          shouldNavigateToProvider = (userRole == UserRole.provider);
        } else {
          shouldNavigateToProvider = _isProvider;
        }

        if (shouldNavigateToProvider) {
          Navigator.pushNamedAndRemoveUntil(context, '/provider-dashboard', (route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, '/user-dashboard', (route) => false);
        }
      }
    } else if (authState.errorMessage != null) {
      if (mounted) {
        _showErrorSnackbar(authState.errorMessage!);
      }
    }
  }

  void _resendOTP() {
    if (_resendTimer == 0) {
      setState(() {
        _resendTimer = 60;
      });
      _startTimer();

      ref.read(authProvider.notifier).resendOTP(
          _phoneController.text,
          isProvider: _isProvider
      );

      _showSuccessSnackbar('OTP resent successfully');
    }
  }

  void _goBack() {
    setState(() {
      _isOTPSent = false;
      for (var controller in _otpControllers) {
        controller.clear();
      }
    });
    _timer?.cancel();
  }

  Widget _buildOTPField(int index) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: _otpControllers[index].text.isNotEmpty
              ? Colors.blue[600]!
              : Colors.grey[300]!,
          width: 1.5,
        ),
      ),
      child: TextFormField(
        controller: _otpControllers[index],
        focusNode: _otpFocusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.blue[700],
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          setState(() {});
          if (value.isNotEmpty && index < 3) {
            _otpFocusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _otpFocusNodes[index - 1].requestFocus();
          }

          if (index == 3 && value.isNotEmpty) {
            String fullOTP = _otpControllers.map((c) => c.text).join();
            if (fullOTP.length == 4) {
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted && _otpControllers.map((c) => c.text).join().length == 4) {
                  _verifyOTP();
                }
              });
            }
          }
        },
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showTermsError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms & Conditions'),
        content: const Text('Please accept the terms and conditions to proceed'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 768;
    final isMobile = size.width < 600;

    return Scaffold(
      backgroundColor: Colors.blue[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : (isTablet ? 60 : 40),
              vertical: 16,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 400 : double.infinity,
                minHeight: size.height - MediaQuery.of(context).padding.top - 32,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Section
                    if (!_isOTPSent) ...[
                      // Language Selector
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedLanguage,
                              icon: Icon(Icons.language, color: Colors.blue[600], size: 16),
                              items: _languages.map((String language) {
                                return DropdownMenuItem<String>(
                                  value: language,
                                  child: Text(
                                    language,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedLanguage = value;
                                  });
                                }
                              },
                              style: TextStyle(color: Colors.blue[700], fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ] else ...[
                      // Back Button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: _goBack,
                            icon: Icon(Icons.arrow_back, color: Colors.blue[600]),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Logo and Title
                    Column(
                      children: [
                        Container(
                          width: isTablet ? 100 : 80,
                          height: isTablet ? 100 : 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.2),
                                spreadRadius: 0,
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: EdgeInsets.all((isTablet ? 100 : 80) * 0.15), // 15% padding
                              child: _isOTPSent
                                  ? Icon(
                                Icons.sms_rounded,
                                size: isTablet ? 50 : 40,
                                color: Colors.blue[600],
                              )
                                  : Image.asset(
                                'assets/app_logo.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback icon if logo fails to load
                                  return Icon(
                                    _isProvider ? Icons.business_center_rounded : Icons.directions_car_filled_rounded,
                                    size: isTablet ? 50 : 40,
                                    color: Colors.blue[600],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _isOTPSent ? 'Verification Code' : 'Welcome to Marg Mitra',
                          style: TextStyle(
                            fontSize: isTablet ? 28 : 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isOTPSent
                              ? 'Enter the 4-digit code sent to\n${_phoneController.text}'
                              : (_isProvider ? 'Service Provider Portal' : 'Your roadside assistance partner'),
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            color: Colors.blue[600],
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),

                    SizedBox(height: _isOTPSent ? 40 : 48),

                    if (!_isOTPSent) ...[
                      // User Type Toggle
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isProvider = false),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: !_isProvider ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: !_isProvider ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ] : null,
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.person_rounded,
                                          color: !_isProvider ? Colors.blue[600] : Colors.grey[600],
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'User',
                                          style: TextStyle(
                                            color: !_isProvider ? Colors.blue[700] : Colors.grey[600],
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isProvider = true),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: _isProvider ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: _isProvider ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ] : null,
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.business_center_rounded,
                                          color: _isProvider ? Colors.blue[600] : Colors.grey[600],
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Provider',
                                          style: TextStyle(
                                            color: _isProvider ? Colors.blue[700] : Colors.grey[600],
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
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
                      ),

                      const SizedBox(height: 32),

                      // Phone Number Input
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 8),
                            child: Text(
                              'Mobile Number',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[800],
                              ),
                            ),
                          ),
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: '8268444498',
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 16,
                                ),
                                prefixIcon: Container(
                                  width: 70,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomLeft: Radius.circular(12),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '+91',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.blue[700],
                                      ),
                                    ),
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter mobile number';
                                }
                                if (value.length != 10) {
                                  return 'Mobile number should be 10 digits';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Checkboxes
                      // Replace the existing Checkboxes section (around line 615-685) with this updated code:

// Checkboxes
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value ?? false;
                                        });
                                      },
                                      activeColor: Colors.blue[600],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Remember me',
                                      style: TextStyle(
                                        color: Colors.blue[700],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: Checkbox(
                                      value: _acceptedTerms,
                                      onChanged: (value) {
                                        setState(() {
                                          _acceptedTerms = value ?? false;
                                        });
                                      },
                                      activeColor: Colors.blue[600],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: GestureDetector(
                                      onTap: () {
                                        // Navigate to Terms & Conditions screen
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const TermsConditionsScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Accept T&C',
                                        style: TextStyle(
                                          color: Colors.blue[700],
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Send OTP Button
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _sendOTP,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shadowColor: Colors.blue.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Send OTP',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      // OTP Input Section
                      Column(
                        children: [
                          // User type indicator
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _isProvider ? Colors.orange[50] : Colors.blue[50],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _isProvider ? Colors.orange[200]! : Colors.blue[200]!,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isProvider ? Icons.business_center_rounded : Icons.person_rounded,
                                  size: 16,
                                  color: _isProvider ? Colors.orange[700] : Colors.blue[700],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Logging in as ${_isProvider ? 'Service Provider' : 'User'}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _isProvider ? Colors.orange[700] : Colors.blue[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),

                          // OTP Input Fields
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(4, (index) => _buildOTPField(index)),
                          ),

                          const SizedBox(height: 32),

                          // Timer and Resend
                          if (_resendTimer > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                'Resend OTP in ${_resendTimer}s',
                                style: TextStyle(
                                  color: Colors.blue[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          else
                            TextButton(
                              onPressed: _resendOTP,
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.blue[50],
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                'Resend OTP',
                                style: TextStyle(
                                  color: Colors.blue[600],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),

                          const SizedBox(height: 40),

                          // Verify Button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _verifyOTP,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                foregroundColor: Colors.white,
                                elevation: 2,
                                shadowColor: Colors.blue.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Verify & Continue',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.check_circle_outline_rounded, size: 20),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 24),

                    if (!_isOTPSent) ...[
                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.blue[300], thickness: 0.5)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                color: Colors.blue[500],
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.blue[300], thickness: 0.5)),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Sign Up Button
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person_add_rounded,
                                color: Colors.blue[600],
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'New user? Sign up',
                                style: TextStyle(
                                  color: Colors.blue[600],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],

                    // Emergency SOS Button
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: double.infinity,
                            height: 64,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.red[500]!,
                                  Colors.red[600]!,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  Navigator.pushNamed(context, '/sos-request');
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          Icons.emergency_rounded,
                                          color: Colors.red[600],
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: const [
                                            Text(
                                              'Emergency Assistance',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              'Get instant help without login',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'SOS',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red[600],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}