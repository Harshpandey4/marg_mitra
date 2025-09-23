import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';

class UserProviderCommunicationScreen extends StatefulWidget {
  final String providerId;
  final String providerName;
  final String providerPhone;
  final String providerVehicle;
  final String serviceType;
  final String requestId;
  final double providerRating;

  const UserProviderCommunicationScreen({
    Key? key,
    required this.providerId,
    required this.providerName,
    required this.providerPhone,
    required this.providerVehicle,
    required this.serviceType,
    required this.requestId,
    required this.providerRating,
  }) : super(key: key);

  @override
  _UserProviderCommunicationScreenState createState() => _UserProviderCommunicationScreenState();
}

class _UserProviderCommunicationScreenState extends State<UserProviderCommunicationScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _typingController;
  late Animation<double> _typingAnimation;

  List<ChatMessage> messages = [];
  bool isProviderTyping = false;
  bool isChatActive = true;
  String serviceStatus = 'Accepted';
  DateTime estimatedArrival = DateTime.now().add(Duration(minutes: 15));
  double providerDistance = 2.5; // km

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _typingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _typingController, curve: Curves.easeInOut),
    );
    _typingController.repeat();

    _initializeChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingController.dispose();
    super.dispose();
  }

  void _initializeChat() {
    // Initialize with system messages and sample conversation
    messages = [
      ChatMessage(
        id: '1',
        text: 'Your service request has been accepted! I\'m heading to your location now.',
        isFromUser: false,
        timestamp: DateTime.now().subtract(Duration(minutes: 5)),
        messageType: MessageType.system,
      ),
      ChatMessage(
        id: '2',
        text: 'Great! Thank you for accepting. How long will it take?',
        isFromUser: true,
        timestamp: DateTime.now().subtract(Duration(minutes: 4)),
      ),
      ChatMessage(
        id: '3',
        text: 'I\'ll be there in approximately 15 minutes. Currently 2.5 km away.',
        isFromUser: false,
        timestamp: DateTime.now().subtract(Duration(minutes: 3)),
      ),
      ChatMessage(
        id: '4',
        text: 'Perfect! I\'m waiting by the roadside. Blue sedan.',
        isFromUser: true,
        timestamp: DateTime.now().subtract(Duration(minutes: 2)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildProviderInfoCard(),
          Expanded(child: _buildChatArea()),
          if (isProviderTyping) _buildTypingIndicator(),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.primaryColor,
            child: Text(
              widget.providerName[0].toUpperCase(),
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.providerName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 14),
                    SizedBox(width: 2),
                    Text(
                      '${widget.providerRating}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Verified',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.phone, color: AppTheme.primaryColor),
          onPressed: _makePhoneCall,
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.black),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            PopupMenuItem(value: 'location', child: Text('Share My Location')),
            PopupMenuItem(value: 'sos', child: Text('Emergency SOS')),
            PopupMenuItem(value: 'cancel', child: Text('Cancel Service')),
            PopupMenuItem(value: 'report', child: Text('Report Issue')),
          ],
        ),
      ],
    );
  }

  Widget _buildProviderInfoCard() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  serviceStatus,
                  style: TextStyle(
                    color: _getStatusColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Spacer(),
              Icon(Icons.access_time, color: Colors.grey[600], size: 16),
              SizedBox(width: 4),
              Text(
                'ETA: ${_formatTime(estimatedArrival)}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vehicle',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      widget.providerVehicle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Distance',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${providerDistance} km away',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Service',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      widget.serviceType,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickAction(
                  Icons.my_location,
                  'Track Provider',
                      () => _trackProvider(),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildQuickAction(
                  Icons.emergency,
                  'Emergency SOS',
                      () => _emergencySOS(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
                icon,
                color: icon == Icons.emergency ? Colors.red : AppTheme.primaryColor,
                size: 20
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatArea() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock, size: 14, color: Colors.grey[500]),
                SizedBox(width: 4),
                Text(
                  'Messages are encrypted and secure',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(messages[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isFromUser = message.isFromUser;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isFromUser) _buildMessageAvatar(false),
          Flexible(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isFromUser ? AppTheme.primaryColor : Colors.grey[200],
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomRight: isFromUser ? Radius.circular(4) : Radius.circular(18),
                  bottomLeft: isFromUser ? Radius.circular(18) : Radius.circular(4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.messageType == MessageType.system)
                    Container(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 14,
                            color: isFromUser ? Colors.white70 : Colors.grey[600],
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Service Update',
                            style: TextStyle(
                              fontSize: 10,
                              color: isFromUser ? Colors.white70 : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isFromUser ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatMessageTime(message.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: isFromUser ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                      if (isFromUser) ...[
                        SizedBox(width: 4),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 14,
                          color: message.isRead ? Colors.blue[300] : Colors.white70,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isFromUser) _buildMessageAvatar(true),
        ],
      ),
    );
  }

  Widget _buildMessageAvatar(bool isUser) {
    return CircleAvatar(
      radius: 12,
      backgroundColor: isUser ? AppTheme.primaryColor : Colors.grey[400],
      child: Icon(
        isUser ? Icons.person : Icons.build,
        size: 14,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.grey[400],
            child: Icon(Icons.build, size: 14, color: Colors.white),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(18),
            ),
            child: AnimatedBuilder(
              animation: _typingAnimation,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 2),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey[600]?.withOpacity(
                          (0.4 + 0.6 * (((_typingAnimation.value + index * 0.3) % 1.0))).clamp(0.4, 1.0),
                        ),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                );
              },
            ),
          ),
          SizedBox(width: 8),
          Text(
            '${widget.providerName} is typing...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.attach_file, color: Colors.grey[600]),
                    onPressed: _showAttachmentOptions,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getStatusColor() {
    switch (serviceStatus) {
      case 'Accepted':
        return AppTheme.primaryColor;
      case 'En Route':
        return Colors.orange;
      case 'Arrived':
        return AppTheme.successColor;
      case 'In Progress':
        return Colors.blue;
      case 'Completed':
        return AppTheme.successColor;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatMessageTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${time.day}/${time.month}';
    }
  }

  // Action methods
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: _messageController.text.trim(),
        isFromUser: true,
        timestamp: DateTime.now(),
      ));
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate provider response
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          isProviderTyping = true;
        });
      }
    });

    Future.delayed(Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          isProviderTyping = false;
          messages.add(ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: 'Got it! I\'ll keep you updated.',
            isFromUser: false,
            timestamp: DateTime.now(),
          ));
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _makePhoneCall() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.phone, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Call Provider'),
          ],
        ),
        content: Text('Call ${widget.providerName} at ${widget.providerPhone}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling ${widget.providerPhone}...')),
              );
            },
            child: Text('Call Now'),
          ),
        ],
      ),
    );
  }

  void _trackProvider() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening live tracking...'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            // Navigate to live tracking screen
          },
        ),
      ),
    );
  }

  void _emergencySOS() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.emergency, color: Colors.red),
            SizedBox(width: 8),
            Text('Emergency SOS'),
          ],
        ),
        content: Text('This will immediately alert emergency services and your contacts. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Emergency SOS activated! Help is on the way.'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: Text('Send SOS'),
          ),
        ],
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Send Attachment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.photo, color: AppTheme.primaryColor),
              title: Text('Photo'),
              subtitle: Text('Take or select a photo'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.location_on, color: Colors.red),
              title: Text('My Location'),
              subtitle: Text('Share your current location'),
              onTap: () {
                Navigator.pop(context);
                _shareMyLocation();
              },
            ),
            ListTile(
              leading: Icon(Icons.videocam, color: Colors.green),
              title: Text('Video'),
              subtitle: Text('Record or select a video'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _shareMyLocation() {
    setState(() {
      messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: '📍 I\'m sharing my current location with you.',
        isFromUser: true,
        timestamp: DateTime.now(),
        messageType: MessageType.location,
      ));
    });
    _scrollToBottom();
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'location':
        _shareMyLocation();
        break;
      case 'sos':
        _emergencySOS();
        break;
      case 'cancel':
        _showCancelDialog();
        break;
      case 'report':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report submitted to support team')),
        );
        break;
    }
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Service'),
        content: Text('Are you sure you want to cancel this service request? Cancellation charges may apply.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Keep Service'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Service request cancelled')),
              );
            },
            child: Text('Cancel Service'),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String id;
  final String text;
  final bool isFromUser;
  final DateTime timestamp;
  final MessageType messageType;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isFromUser,
    required this.timestamp,
    this.messageType = MessageType.text,
    this.isRead = false,
  });
}

enum MessageType {
  text,
  system,
  location,
  image,
  document,
  video,
}