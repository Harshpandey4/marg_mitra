import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';
import '../../config/app_constants.dart';
import 'tracking_screen.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class SOSRequestScreen extends StatefulWidget {
  final String? preselectedService;

  SOSRequestScreen({this.preselectedService});

  @override
  _SOSRequestScreenState createState() => _SOSRequestScreenState();
}

class _SOSRequestScreenState extends State<SOSRequestScreen>
    with TickerProviderStateMixin {
  String? selectedService;
  TextEditingController descriptionController = TextEditingController();
  bool isEmergency = false;
  bool isLocationLoading = true;
  bool _animationsInitialized = false;

  // Animation controllers
  AnimationController? _slideController;
  AnimationController? _pulseController;
  AnimationController? _emergencyController;

  Animation<Offset>? _slideAnimation;
  Animation<double>? _pulseAnimation;
  Animation<double>? _emergencyAnimation;

  @override
  void initState() {
    super.initState();
    selectedService = widget.preselectedService;
    _initializeAnimations();

    // Simulate location loading
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          isLocationLoading = false;
        });
      }
    });
  }

  void _initializeAnimations() {
    // Initialize animation controllers
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _emergencyController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    // Initialize animations
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController!,
      curve: Curves.easeOutBack,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController!,
      curve: Curves.easeInOut,
    ));

    _emergencyAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _emergencyController!,
      curve: Curves.elasticOut,
    ));

    // Mark animations as initialized
    _animationsInitialized = true;

    // Start animations
    _slideController?.forward();
    _pulseController?.repeat(reverse: true);
  }

  @override
  void dispose() {
    _slideController?.dispose();
    _pulseController?.dispose();
    _emergencyController?.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: isEmergency ? Colors.red.shade50 : Colors.blue[100],
      appBar: _buildAnimatedAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: _animationsInitialized && _slideAnimation != null
                ? SlideTransition(
              position: _slideAnimation!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEmergencyToggleCard(),
                  SizedBox(height: 20),
                  _buildServiceSelectionSection(),
                  SizedBox(height: 20),
                  _buildDescriptionSection(),
                  SizedBox(height: 20),
                  _buildLocationCard(),
                  SizedBox(height: 20),
                  if (isEmergency) _buildEmergencyProtocolCard(),
                  if (isEmergency) SizedBox(height: 20),
                  _buildSubmitButton(),
                  SizedBox(height: 20),
                ],
              ),
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEmergencyToggleCard(),
                SizedBox(height: 20),
                _buildServiceSelectionSection(),
                SizedBox(height: 20),
                _buildDescriptionSection(),
                SizedBox(height: 20),
                _buildLocationCard(),
                SizedBox(height: 20),
                if (isEmergency) _buildEmergencyProtocolCard(),
                if (isEmergency) SizedBox(height: 20),
                _buildSubmitButton(),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAnimatedAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: isEmergency ? Colors.red.shade600 : AppTheme.primaryColor,
      title: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: Text(
          isEmergency ? 'EMERGENCY REQUEST' : 'Request Assistance',
          key: ValueKey(isEmergency),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isEmergency ? 18 : 20,
          ),
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isEmergency
                ? [Colors.red.shade600, Colors.red.shade800]
                : [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyToggleCard() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isEmergency
              ? [Colors.red.shade100, Colors.red.shade50]
              : [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isEmergency ? Colors.red.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _toggleEmergency(),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isEmergency ? Colors.red.shade600 : Colors.orange.shade400,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: (isEmergency ? Colors.red : Colors.orange).withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isEmergency ? Icons.emergency : Icons.warning_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isEmergency ? Colors.red.shade800 : Colors.grey.shade800,
                        ),
                        child: Text('Emergency Situation'),
                      ),
                      SizedBox(height: 4),
                      Text(
                        isEmergency
                            ? 'Emergency mode activated - priority response'
                            : 'Toggle if this is a safety emergency',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedScale(
                  scale: isEmergency ? 1.2 : 1.0,
                  duration: Duration(milliseconds: 200),
                  child: Switch(
                    value: isEmergency,
                    activeColor: Colors.red.shade600,
                    onChanged: (value) => _toggleEmergency(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.medical_services, color: AppTheme.primaryColor, size: 24),
            SizedBox(width: 8),
            Text(
              'Select Service Type',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.serviceTypes.asMap().entries.map((entry) {
              int index = entry.key;
              String service = entry.value;
              bool isSelected = selectedService == service;

              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 200 + (index * 50)),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      child: FilterChip(
                        label: Text(
                          service,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey.shade700,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            selectedService = selected ? service : null;
                          });
                          HapticFeedback.selectionClick();
                        },
                        backgroundColor: Colors.yellow[50],
                        selectedColor: isEmergency ? Colors.red.shade500 : AppTheme.primaryColor,
                        elevation: isSelected ? 4 : 0,
                        pressElevation: 8,
                        checkmarkColor: Colors.white,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.description, color: AppTheme.primaryColor, size: 24),
            SizedBox(width: 8),
            Text(
              'Describe the Problem',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.yellow[50],
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: descriptionController,
            maxLines: 4,
            style: TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Provide detailed information about your situation...',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: EdgeInsets.all(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade500,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.location_on, color: Colors.white, size: 20),
                ),
                SizedBox(width: 12),
                Text(
                  'Current Location',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              child: isLocationLoading
                  ? Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade500),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Fetching your precise location...',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade600, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Location found: 123 Main Street, City, State',
                            style: TextStyle(
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        isLocationLoading = true;
                      });
                      Future.delayed(Duration(seconds: 1), () {
                        if (mounted) {
                          setState(() {
                            isLocationLoading = false;
                          });
                        }
                      });
                    },
                    icon: Icon(Icons.refresh, size: 18),
                    label: Text('Update Location'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue.shade600,
                      side: BorderSide(color: Colors.blue.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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

  Widget _buildEmergencyProtocolCard() {
    return _animationsInitialized && _emergencyAnimation != null
        ? ScaleTransition(
      scale: _emergencyAnimation!,
      child: _buildEmergencyProtocolContent(),
    )
        : _buildEmergencyProtocolContent();
  }

  Widget _buildEmergencyProtocolContent() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade200, Colors.red.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade400, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.2),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.emergency, color: Colors.white, size: 20),
                ),
                SizedBox(width: 15),
                Text(
                  'Emergency Protocols Activated',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildProtocolItem('Emergency contacts will be notified immediately', Icons.contact_emergency),
            SizedBox(height: 8),
            _buildProtocolItem('Priority matching with nearest providers', Icons.priority_high),
            SizedBox(height: 8),
            _buildProtocolItem('Real-time location sharing enabled', Icons.location_searching),
            SizedBox(height: 8),
            _buildProtocolItem('Automatic status updates to authorities', Icons.security),
          ],
        ),
      ),
    );
  }

  Widget _buildProtocolItem(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.red.shade600, size: 16),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.red.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    bool canSubmit = selectedService != null;

    return _animationsInitialized && _pulseAnimation != null
        ? AnimatedBuilder(
      animation: _pulseAnimation!,
      builder: (context, child) {
        return Transform.scale(
          scale: isEmergency && canSubmit ? _pulseAnimation!.value : 1.0,
          child: _buildSubmitButtonContent(canSubmit),
        );
      },
    )
        : _buildSubmitButtonContent(canSubmit);
  }

  Widget _buildSubmitButtonContent(bool canSubmit) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: canSubmit ? [
          BoxShadow(
            color: (isEmergency ? Colors.red : AppTheme.primaryColor).withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ] : null,
      ),
      child: ElevatedButton(
        onPressed: canSubmit ? _submitRequest : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEmergency ? Colors.red.shade600 : AppTheme.primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          elevation: canSubmit ? 8 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isEmergency) Icon(Icons.emergency, size: 24),
            if (isEmergency) SizedBox(width: 8),
            Text(
              isEmergency ? 'SEND EMERGENCY REQUEST' : 'REQUEST ASSISTANCE',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleEmergency() {
    setState(() {
      isEmergency = !isEmergency;
      if (isEmergency) {
        HapticFeedback.heavyImpact();
        _emergencyController?.forward();
      } else {
        _emergencyController?.reverse();
      }
    });
  }

  void _submitRequest() {
    HapticFeedback.mediumImpact();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isEmergency ? Colors.red.shade100 : Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isEmergency ? Colors.red.shade600 : AppTheme.primaryColor,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                isEmergency
                    ? 'Sending Emergency Request...'
                    : 'Finding the best provider for you...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                isEmergency
                    ? 'Contacting emergency services and notifying your contacts'
                    : 'Matching you with qualified service providers nearby',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );

    // Simulate API call
    Future.delayed(Duration(seconds: isEmergency ? 3 : 2), () {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => TrackingScreen()),
        );
      }
    });
  }
}