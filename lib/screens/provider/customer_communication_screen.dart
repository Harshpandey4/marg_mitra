import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';

class CustomerCommunicationScreen extends StatefulWidget {
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String serviceType;
  final String requestId;

  const CustomerCommunicationScreen({
    Key? key,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.serviceType,
    required this.requestId,
  }) : super(key: key);

  @override
  _CustomerCommunicationScreenState createState() => _CustomerCommunicationScreenState();
}

class _CustomerCommunicationScreenState extends State<CustomerCommunicationScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _typingController;
  late Animation<double> _typingAnimation;

  List<ChatMessage> messages = [];
  bool isCustomerTyping = false;
  bool isChatActive = true;
  String serviceStatus = 'En Route';
  DateTime estimatedArrival = DateTime.now().add(Duration(minutes: 15));

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
        text: 'Service request accepted! I\'m on my way to your location.',
        isFromProvider: true,
        timestamp: DateTime.now().subtract(Duration(minutes: 10)),
        messageType: MessageType.system,
      ),
      ChatMessage(
        id: '2',
        text: 'Thank you! How long will it take approximately?',
        isFromProvider: false,
        timestamp: DateTime.now().subtract(Duration(minutes: 9)),
      ),
      ChatMessage(
        id: '3',
        text: 'I\'ll reach in about 15 minutes. Traffic is light on your route.',
        isFromProvider: true,
        timestamp: DateTime.now().subtract(Duration(minutes: 8)),
      ),
      ChatMessage(
        id: '4',
        text: 'Perfect, I\'ll wait here. The car is parked safely on the side.',
        isFromProvider: false,
        timestamp: DateTime.now().subtract(Duration(minutes: 7)),
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
          _buildStatusCard(),
          Expanded(child: _buildChatArea()),
          if (isCustomerTyping) _buildTypingIndicator(),
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
              widget.customerName[0].toUpperCase(),
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.customerName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  widget.serviceType,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
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
            PopupMenuItem(value: 'location', child: Text('Share Location')),
            PopupMenuItem(value: 'emergency', child: Text('Emergency Contact')),
            PopupMenuItem(value: 'report', child: Text('Report Issue')),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
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
                child: _buildQuickAction(
                  Icons.location_on,
                  'Share Location',
                      () => _shareCurrentLocation(),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildQuickAction(
                  Icons.help_outline,
                  'Need Help?',
                      () => _showHelpOptions(),
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
            Icon(icon, color: AppTheme.primaryColor, size: 20),
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
    final isFromProvider = message.isFromProvider;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isFromProvider ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isFromProvider) _buildMessageAvatar(false),
          Flexible(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isFromProvider ? AppTheme.primaryColor : Colors.grey[200],
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomRight: isFromProvider ? Radius.circular(4) : Radius.circular(18),
                  bottomLeft: isFromProvider ? Radius.circular(18) : Radius.circular(4),
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
                            color: isFromProvider ? Colors.white70 : Colors.grey[600],
                          ),
                          SizedBox(width: 4),
                          Text(
                            'System Update',
                            style: TextStyle(
                              fontSize: 10,
                              color: isFromProvider ? Colors.white70 : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isFromProvider ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _formatMessageTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: isFromProvider ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isFromProvider) _buildMessageAvatar(true),
        ],
      ),
    );
  }

  Widget _buildMessageAvatar(bool isProvider) {
    return CircleAvatar(
      radius: 12,
      backgroundColor: isProvider ? AppTheme.primaryColor : Colors.grey[400],
      child: Icon(
        isProvider ? Icons.build : Icons.person,
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
            child: Icon(Icons.person, size: 14, color: Colors.white),
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
      case 'En Route':
        return Colors.orange;
      case 'Arrived':
        return AppTheme.successColor;
      case 'In Progress':
        return AppTheme.primaryColor;
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
        isFromProvider: true,
        timestamp: DateTime.now(),
      ));
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate customer response
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          isCustomerTyping = true;
        });
      }
    });

    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          isCustomerTyping = false;
          messages.add(ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: 'Thank you for the update!',
            isFromProvider: false,
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
            Text('Call Customer'),
          ],
        ),
        content: Text('Call ${widget.customerName} at ${widget.customerPhone}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling ${widget.customerPhone}...')),
              );
            },
            child: Text('Call Now'),
          ),
        ],
      ),
    );
  }

  void _shareCurrentLocation() {
    setState(() {
      messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: '📍 I\'m currently 2.5 km away from your location. Arriving in 12 minutes.',
        isFromProvider: true,
        timestamp: DateTime.now(),
        messageType: MessageType.location,
      ));
    });
    _scrollToBottom();
  }

  void _showHelpOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('How can we help?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.support_agent, color: AppTheme.primaryColor),
              title: Text('Contact Support'),
              subtitle: Text('Get help from our support team'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.emergency, color: Colors.red),
              title: Text('Emergency Contact'),
              subtitle: Text('Call emergency services'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.info, color: Colors.blue),
              title: Text('Service Information'),
              subtitle: Text('Learn about our services'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
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
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.location_on, color: Colors.red),
              title: Text('Location'),
              onTap: () {
                Navigator.pop(context);
                _shareCurrentLocation();
              },
            ),
            ListTile(
              leading: Icon(Icons.description, color: Colors.blue),
              title: Text('Document'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'location':
        _shareCurrentLocation();
        break;
      case 'emergency':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Emergency contacts notified')),
        );
        break;
      case 'report':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report submitted')),
        );
        break;
    }
  }
}

class ChatMessage {
  final String id;
  final String text;
  final bool isFromProvider;
  final DateTime timestamp;
  final MessageType messageType;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isFromProvider,
    required this.timestamp,
    this.messageType = MessageType.text,
  });
}

enum MessageType {
  text,
  system,
  location,
  image,
  document,
}