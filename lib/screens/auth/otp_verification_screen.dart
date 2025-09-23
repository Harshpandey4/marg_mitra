import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';

class OTPVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  final bool isProvider;

  const OTPVerificationScreen({
    super.key,
    required this.phoneNumber,
    this.isProvider = false,
  });

  @override
  ConsumerState<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends ConsumerState<OTPVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  int _resendTimer = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
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

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _verifyOTP() async {
    String otp = _controllers.map((c) => c.text).join();

    if (otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the complete OTP')),
      );
      return;
    }


    await ref.read(authProvider.notifier).login(
        widget.phoneNumber,
        otp,
        isProvider: widget.isProvider
    );

    final authState = ref.read(authProvider);

    if (authState.isLoggedIn && authState.errorMessage == null) {
      if (mounted) {
        //
        final userRole = authState.currentUser?.role;

        // Determine navigation based on role or isProvider flag
        bool shouldNavigateToProvider = false;

        if (userRole != null) {
          // If backend returns a role, use it
          shouldNavigateToProvider = (userRole == UserRole.provider);
        } else {
          // Fallback to isProvider flag if no role from backend
          shouldNavigateToProvider = widget.isProvider;
        }

        if (shouldNavigateToProvider) {
          Navigator.pushNamedAndRemoveUntil(context, '/provider-dashboard', (route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, '/user-dashboard', (route) => false);
        }
      }
    } else if (authState.errorMessage != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authState.errorMessage!)),
        );
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
          widget.phoneNumber,
          isProvider: widget.isProvider
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP resent successfully')),
      );
    }
  }

  Widget _buildOTPField(int index) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }

          // Auto-verify when all 4 digits are entered
          if (index == 3 && value.isNotEmpty) {
            String fullOTP = _controllers.map((c) => c.text).join();
            if (fullOTP.length == 4) {
              // Optional: Auto-verify after a short delay
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted && _controllers.map((c) => c.text).join().length == 4) {
                  _verifyOTP();
                }
              });
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isProvider ? 'Provider Verification' : 'User Verification',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Header - Dynamic icon based on user type
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  widget.isProvider ? Icons.business : Icons.message,
                  size: 40,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'OTP Verification',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                widget.isProvider
                    ? ' Marg Mitra have sent an OTP to verify your service provider account'
                    : 'Marg Mitra have sent an OTP to your mobile number',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                widget.phoneNumber,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E88E5),
                ),
              ),

              const SizedBox(height: 40),

              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) => _buildOTPField(index)),
              ),

              const SizedBox(height: 30),

              // Timer and Resend
              if (_resendTimer > 0)
                Text(
                  'Resend OTP in ${_resendTimer}s',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                )
              else
                TextButton(
                  onPressed: _resendOTP,
                  child: const Text(
                    'Resend OTP',
                    style: TextStyle(
                      color: Color(0xFF1E88E5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              const SizedBox(height: 40),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Verify & Continue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // User type indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: widget.isProvider ? Colors.orange.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.isProvider ? Colors.orange.withOpacity(0.3) : Colors.blue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isProvider ? Icons.business : Icons.person,
                      size: 16,
                      color: widget.isProvider ? Colors.orange : Colors.blue,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Logging in as ${widget.isProvider ? 'Service Provider' : 'User'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.isProvider ? Colors.orange[700] : Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}