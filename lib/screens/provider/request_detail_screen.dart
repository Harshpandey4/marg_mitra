import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';

class RequestDetailScreen extends StatefulWidget {
  const RequestDetailScreen({
    super.key,
    required this.serviceData,
    this.requestId,
  });

  final Map<String, dynamic> serviceData;
  final String? requestId;

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  String currentStatus = 'Accepted';
  bool isNavigating = false;
  String? selectedCancelReason;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = widget.serviceData;
    final isEmergency = service['isEmergency'] as bool? ?? false;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: _isDarkMode ? const Color(0xFF121212) : Colors.grey[50],
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isEmergency
                      ? [AppTheme.emergencyColor, AppTheme.emergencyColor.withOpacity(0.8)]
                      : [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
                ),
              ),
            ),
            title: Text(
              'Service Details',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: constraints.maxWidth * 0.05,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.dark_mode_outlined, color: Colors.white),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() => _isDarkMode = !_isDarkMode);
                },
              ),
              IconButton(
                icon: const Icon(Icons.call, color: Colors.white),
                onPressed: _makeCall,
              ),
              IconButton(
                icon: const Icon(Icons.message, color: Colors.white),
                onPressed: _openChat,
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                if (isEmergency) _buildEmergencyBanner(constraints),
                _buildMapPlaceholder(constraints),
                Padding(
                  padding: EdgeInsets.all(constraints.maxWidth * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCustomerInfoCard(service, constraints),
                      SizedBox(height: constraints.maxHeight * 0.02),
                      _buildServiceDetailsCard(service, isEmergency, constraints),
                      SizedBox(height: constraints.maxHeight * 0.02),
                      _buildStatusUpdateCard(constraints),
                      if (currentStatus != 'completed') ...[
                        SizedBox(height: constraints.maxHeight * 0.02),
                        _buildActionButtons(constraints),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmergencyBanner(BoxConstraints constraints) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(constraints.maxWidth * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.emergencyColor,
            AppTheme.emergencyColor.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.emergencyColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.emergency,
            color: Colors.white,
            size: constraints.maxWidth * 0.06,
          ),
          SizedBox(width: constraints.maxWidth * 0.02),
          Expanded(
            child: Text(
              'EMERGENCY REQUEST - Priority Response Required',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: constraints.maxWidth * 0.04,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder(BoxConstraints constraints) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          height: constraints.maxHeight * 0.3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isDarkMode
                  ? [Colors.grey[800]!, Colors.grey[900]!]
                  : [Colors.grey[200]!, Colors.grey[300]!],
            ),
            boxShadow: [
              BoxShadow(
                color: _isDarkMode ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: constraints.maxWidth * 0.2 + (_pulseController.value * 10),
                      height: constraints.maxWidth * 0.2 + (_pulseController.value * 10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryColor.withOpacity(0.3 - (_pulseController.value * 0.2)),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.map,
                          size: constraints.maxWidth * 0.12,
                          color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ),
                    SizedBox(height: constraints.maxHeight * 0.01),
                    Text(
                      'Interactive Map View',
                      style: TextStyle(
                        fontSize: constraints.maxWidth * 0.04,
                        color: _isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    SizedBox(height: constraints.maxHeight * 0.01),
                    ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          isNavigating = !isNavigating;
                        });
                      },
                      icon: Icon(
                        Icons.navigation,
                        size: constraints.maxWidth * 0.05,
                      ),
                      label: Text(
                        isNavigating ? 'Stop Navigation' : 'Start Navigation',
                        style: TextStyle(fontSize: constraints.maxWidth * 0.04),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isNavigating ? AppTheme.emergencyColor : AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: constraints.maxWidth * 0.04,
                          vertical: constraints.maxHeight * 0.015,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isNavigating)
                Positioned(
                  top: constraints.maxHeight * 0.02,
                  left: constraints.maxWidth * 0.04,
                  right: constraints.maxWidth * 0.04,
                  child: Container(
                    padding: EdgeInsets.all(constraints.maxWidth * 0.03),
                    decoration: BoxDecoration(
                      color: _isDarkMode ? Colors.black87 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _isDarkMode ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.navigation,
                          color: _isDarkMode ? Colors.white : AppTheme.primaryColor,
                          size: constraints.maxWidth * 0.05,
                        ),
                        SizedBox(width: constraints.maxWidth * 0.02),
                        Text(
                          'ETA: 8 minutes • 2.3 km',
                          style: TextStyle(
                            color: _isDarkMode ? Colors.white : Colors.black87,
                            fontSize: constraints.maxWidth * 0.04,
                          ),
                        ),
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

  Widget _buildCustomerInfoCard(Map<String, dynamic> service, BoxConstraints constraints) {
    return Card(
      elevation: 0,
      color: _isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: _isDarkMode ? Colors.grey[700]! : Colors.grey[200]!),
      ),
      child: Padding(
        padding: EdgeInsets.all(constraints.maxWidth * 0.04),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: const NetworkImage('https://via.placeholder.com/50'),
              radius: constraints.maxWidth * 0.06,
            ),
            SizedBox(width: constraints.maxWidth * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${service['customerName'] ?? 'Unknown Customer'}',
                    style: TextStyle(
                      fontSize: constraints.maxWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: _isDarkMode ? Colors.white : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: constraints.maxHeight * 0.005),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: constraints.maxWidth * 0.04,
                        color: Colors.amber,
                      ),
                      SizedBox(width: constraints.maxWidth * 0.01),
                      Text(
                        '4.5 Customer Rating',
                        style: TextStyle(
                          fontSize: constraints.maxWidth * 0.035,
                          color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: _makeCall,
                  icon: Icon(
                    Icons.call,
                    color: AppTheme.primaryColor,
                    size: constraints.maxWidth * 0.06,
                  ),
                ),
                IconButton(
                  onPressed: _openChat,
                  icon: Icon(
                    Icons.message,
                    color: AppTheme.primaryColor,
                    size: constraints.maxWidth * 0.06,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceDetailsCard(
      Map<String, dynamic> service, bool isEmergency, BoxConstraints constraints) {
    return Card(
      elevation: 0,
      color: _isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: _isDarkMode ? Colors.grey[700]! : Colors.grey[200]!),
      ),
      child: Padding(
        padding: EdgeInsets.all(constraints.maxWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service Details',
              style: TextStyle(
                fontSize: constraints.maxWidth * 0.045,
                fontWeight: FontWeight.bold,
                color: _isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: constraints.maxHeight * 0.015),
            _buildDetailRow('Service Type', '${service['serviceType'] ?? 'N/A'}', constraints),
            _buildDetailRow('Request ID', '${service['id'] ?? 'N/A'}', constraints),
            _buildDetailRow('Location', '${service['location'] ?? 'N/A'}', constraints),
            _buildDetailRow('Time', '${service['time'] ?? 'N/A'}', constraints),
            if (service['description'] != null)
              _buildDetailRow('Description', '${service['description']}', constraints),
            _buildDetailRow('Priority', isEmergency ? 'EMERGENCY' : 'Regular', constraints),
            if (service['amount'] != null)
              _buildDetailRow('Amount', '₹${service['amount']}', constraints),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, BoxConstraints constraints) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: constraints.maxHeight * 0.005),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: constraints.maxWidth * 0.3,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontSize: constraints.maxWidth * 0.04,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: _isDarkMode ? Colors.white : Colors.black87,
                fontSize: constraints.maxWidth * 0.04,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusUpdateCard(BoxConstraints constraints) {
    return Card(
      elevation: 0,
      color: _isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: _isDarkMode ? Colors.grey[700]! : Colors.grey[200]!),
      ),
      child: Padding(
        padding: EdgeInsets.all(constraints.maxWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update Status',
              style: TextStyle(
                fontSize: constraints.maxWidth * 0.045,
                fontWeight: FontWeight.bold,
                color: _isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: constraints.maxHeight * 0.015),
            _buildStatusButton('On the Way', 'en_route', constraints),
            _buildStatusButton('Arrived at Location', 'arrived', constraints),
            _buildStatusButton('Service Started', 'started', constraints),
            _buildStatusButton('Service Completed', 'completed', constraints),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(String label, String status, BoxConstraints constraints) {
    bool isSelected = currentStatus == status;
    return Container(
      margin: EdgeInsets.only(bottom: constraints.maxHeight * 0.01),
      width: double.infinity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: ElevatedButton(
          onPressed: () => _updateStatus(status, label),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected
                ? AppTheme.primaryColor
                : (_isDarkMode ? Colors.grey[800] : Colors.grey[200]),
            foregroundColor: isSelected ? Colors.white : (_isDarkMode ? Colors.white70 : Colors.black87),
            elevation: isSelected ? 2 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(vertical: constraints.maxHeight * 0.015),
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: constraints.maxWidth * 0.04),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BoxConstraints constraints) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: constraints.maxHeight * 0.06,
          child: ElevatedButton.icon(
            onPressed: () => _completeService(),
            icon: Icon(
              Icons.check_circle,
              size: constraints.maxWidth * 0.05,
            ),
            label: Text(
              'Mark as Completed',
              style: TextStyle(fontSize: constraints.maxWidth * 0.04),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(vertical: constraints.maxHeight * 0.015),
            ),
          ),
        ),
        SizedBox(height: constraints.maxHeight * 0.015),
        SizedBox(
          width: double.infinity,
          height: constraints.maxHeight * 0.06,
          child: OutlinedButton.icon(
            onPressed: () => _showCancelDialog(),
            icon: Icon(
              Icons.cancel,
              size: constraints.maxWidth * 0.05,
              color: AppTheme.emergencyColor,
            ),
            label: Text(
              'Cancel Service',
              style: TextStyle(
                fontSize: constraints.maxWidth * 0.04,
                color: AppTheme.emergencyColor,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppTheme.emergencyColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(vertical: constraints.maxHeight * 0.015),
            ),
          ),
        ),
      ],
    );
  }

  void _updateStatus(String status, String label) {
    setState(() {
      currentStatus = status;
    });
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status updated to: $label'),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _makeCall() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: _isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
        title: Text(
          'Call Customer',
          style: TextStyle(
            color: _isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Calling ${widget.serviceData['customerName'] ?? 'customer'}...',
          style: TextStyle(color: _isDarkMode ? Colors.white70 : Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  void _openChat() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: _isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
        title: Text(
          'Chat Feature',
          style: TextStyle(
            color: _isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Opening secure chat with ${widget.serviceData['customerName'] ?? 'customer'}...',
          style: TextStyle(color: _isDarkMode ? Colors.white70 : Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  void _completeService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: _isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
        title: Text(
          'Complete Service',
          style: TextStyle(
            color: _isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to mark this service as completed?',
              style: TextStyle(color: _isDarkMode ? Colors.white70 : Colors.black54),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Service Cost (₹)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: _isDarkMode ? Colors.grey[800] : Colors.grey[100],
              ),
              keyboardType: TextInputType.number,
              style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black87),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                currentStatus = 'completed';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Service marked as completed!'),
                  backgroundColor: AppTheme.successColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: _isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
        title: Text(
          'Cancel Service',
          style: TextStyle(
            color: _isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please select a reason for cancellation:',
              style: TextStyle(color: _isDarkMode ? Colors.white70 : Colors.black54),
            ),
            SizedBox(height: 16),
            ...[
              'Customer not available',
              'Unable to reach location',
              'Vehicle breakdown',
              'Weather conditions',
              'Other',
            ].map((reason) => RadioListTile<String>(
              title: Text(
                reason,
                style: TextStyle(
                  fontSize: 14,
                  color: _isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              value: reason,
              groupValue: selectedCancelReason,
              activeColor: AppTheme.primaryColor,
              onChanged: (value) {
                setState(() {
                  selectedCancelReason = value;
                });
              },
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Back',
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Service cancelled'),
                  backgroundColor: AppTheme.emergencyColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.emergencyColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Cancel Service'),
          ),
        ],
      ),
    );
  }
}