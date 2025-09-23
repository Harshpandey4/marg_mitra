import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';
import 'review_screen.dart';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> with TickerProviderStateMixin {
  String selectedPaymentMethod = 'upi';
  TextEditingController upiController = TextEditingController();
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController expiryController = TextEditingController();
  TextEditingController cvvController = TextEditingController();
  TextEditingController cardHolderController = TextEditingController();

  double serviceCost = 450.0;
  double taxes = 45.0;
  double discount = 25.0;
  double total = 470.0;

  bool showCardForm = false;
  bool isProcessing = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Popular UPI apps
  List<Map<String, dynamic>> upiApps = [
    {'name': 'Google Pay', 'icon': Icons.payment, 'color': Colors.blue},
    {'name': 'PhonePe', 'icon': Icons.payment, 'color': Colors.purple},
    {'name': 'Paytm', 'icon': Icons.account_balance_wallet, 'color': Colors.indigo},
    {'name': 'BHIM', 'icon': Icons.payment, 'color': Colors.orange},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    upiController.dispose();
    cardNumberController.dispose();
    expiryController.dispose();
    cvvController.dispose();
    cardHolderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Payment',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: Icon(Icons.security, color: Colors.green),
            onPressed: () => _showSecurityInfo(),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildServiceSummaryCard(),
              SizedBox(height: 20),
              _buildPromoBanner(),
              SizedBox(height: 20),
              _buildPaymentMethodsSection(),
              SizedBox(height: 30),
              _buildPayButton(),
              SizedBox(height: 16),
              _buildSecurityFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Service Summary',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height:30),

            // Service Provider Info
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage('https://via.placeholder.com/48'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rajesh Kumar',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.local_shipping, size: 16, color: Colors.blue[700]),
                            SizedBox(width: 4),
                            Text(
                              'Towing Service',
                              style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Completed at 12:45 PM',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Completed',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Bill Breakdown
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildBillItem('Service Charge', '₹${serviceCost.toInt()}', Icons.build),
                  _buildBillItem('Taxes & Fees', '₹${taxes.toInt()}', Icons.receipt),
                  _buildBillItem('Discount', '-₹${discount.toInt()}', Icons.local_offer, isDiscount: true),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(thickness: 1),
                  ),
                  _buildBillItem(
                    'Total Amount',
                    '₹${total.toInt()}',
                    Icons.payment,
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange[100]!, Colors.orange[50]!],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.local_offer, color: Colors.orange[700]),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Special Discount Applied!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
                Text(
                  'You saved ₹25 on this booking',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Payment Method',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16),
        _buildUPIPaymentOption(),
        SizedBox(height: 12),
        _buildWalletPaymentOption(),
        SizedBox(height: 12),
        _buildCardPaymentOption(),
        SizedBox(height: 12),
        _buildCashPaymentOption(),
      ],
    );
  }

  Widget _buildUPIPaymentOption() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: selectedPaymentMethod == 'upi' ? Colors.blue[50] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selectedPaymentMethod == 'upi' ? Colors.blue : Colors.grey[300]!,
          width: selectedPaymentMethod == 'upi' ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          RadioListTile<String>(
            value: 'upi',
            groupValue: selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                selectedPaymentMethod = value!;
              });
            },
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.payment, color: Colors.blue[700], size: 20),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UPI Payment',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Pay using UPI ID or scan QR',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            activeColor: Colors.blue,
          ),
          if (selectedPaymentMethod == 'upi') ...[
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  TextField(
                    controller: upiController,
                    decoration: InputDecoration(
                      hintText: 'Enter UPI ID (e.g., user@paytm)',
                      prefixIcon: Icon(Icons.alternate_email, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Or choose from popular apps:',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: upiApps.map((app) => _buildUPIAppChip(app)).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUPIAppChip(Map<String, dynamic> app) {
    return ActionChip(
      avatar: Icon(app['icon'], color: app['color'], size: 16),
      label: Text(
        app['name'],
        style: TextStyle(fontSize: 12),
      ),
      onPressed: () {
        // Handle UPI app selection
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening ${app['name']}...'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      backgroundColor: Colors.grey[100],
    );
  }

  Widget _buildWalletPaymentOption() {
    return _buildPaymentOption(
      'wallet',
      'Digital Wallet',
      'Paytm, PhonePe, Amazon Pay',
      Icons.account_balance_wallet,
      Colors.purple,
    );
  }

  Widget _buildCardPaymentOption() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: selectedPaymentMethod == 'card' ? Colors.green[50] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selectedPaymentMethod == 'card' ? Colors.green : Colors.grey[300]!,
          width: selectedPaymentMethod == 'card' ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          RadioListTile<String>(
            value: 'card',
            groupValue: selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                selectedPaymentMethod = value!;
                showCardForm = true;
              });
            },
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.credit_card, color: Colors.blue[700], size: 20),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Credit/Debit Card',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Visa, Mastercard, RuPay accepted',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            activeColor: Colors.blue,
          ),
          if (selectedPaymentMethod == 'card') _buildCardForm(),
        ],
      ),
    );
  }

  Widget _buildCardForm() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          TextField(
            controller: cardNumberController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _CardNumberInputFormatter(),
            ],
            decoration: InputDecoration(
              hintText: '1234 5678 9012 3456',
              labelText: 'Card Number',
              prefixIcon: Icon(Icons.credit_card),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: expiryController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    _ExpiryDateInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    hintText: 'MM/YY',
                    labelText: 'Expiry',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: cvvController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '123',
                    labelText: 'CVV',
                    prefixIcon: Icon(Icons.security),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          TextField(
            controller: cardHolderController,
            decoration: InputDecoration(
              hintText: 'Enter cardholder name',
              labelText: 'Cardholder Name',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashPaymentOption() {
    return _buildPaymentOption(
      'cash',
      'Cash Payment',
      'Pay directly to service provider',
      Icons.money,
      Colors.green,
    );
  }

  Widget _buildPaymentOption(String value, String title, String subtitle, IconData icon, Color color) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: selectedPaymentMethod == value ? color.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selectedPaymentMethod == value ? color : Colors.grey[300]!,
          width: selectedPaymentMethod == value ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: selectedPaymentMethod,
        onChanged: (selectedValue) {
          setState(() {
            selectedPaymentMethod = selectedValue!;
            if (value != 'card') showCardForm = false;
          });
        },
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        activeColor: color,
      ),
    );
  }

  Widget _buildBillItem(String label, String amount, IconData icon, {bool isTotal = false, bool isDiscount = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isTotal ? AppTheme.primaryColor :
            isDiscount ? Colors.green : Colors.grey[600],
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                fontSize: isTotal ? 16 : 14,
                color: isTotal ? AppTheme.primaryColor : Colors.black87,
              ),
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? AppTheme.primaryColor :
              isDiscount ? Colors.green : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isProcessing ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isProcessing
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Processing...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.security, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Pay ₹${total.toInt()} Securely',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityFooter() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.security, color: Colors.green, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Your payment information is encrypted and secure',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSecurityInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.security, color: Colors.green, size: 32),
        title: Text('Payment Security'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• 256-bit SSL encryption'),
            Text('• PCI DSS compliant'),
            Text('• No card details stored'),
            Text('• Secure payment gateway'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _processPayment() {
    if (selectedPaymentMethod == 'upi' && upiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter UPI ID')),
      );
      return;
    }

    if (selectedPaymentMethod == 'card') {
      if (cardNumberController.text.isEmpty ||
          expiryController.text.isEmpty ||
          cvvController.text.isEmpty ||
          cardHolderController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill all card details')),
        );
        return;
      }
    }

    setState(() {
      isProcessing = true;
    });

    // Simulate payment processing
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        isProcessing = false;
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          icon: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, color: Colors.white, size: 32),
          ),
          title: Text(
            'Payment Successful!',
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your payment of ₹${total.toInt()} has been processed successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700]),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text('Transaction ID', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    Text('TXN${DateTime.now().millisecondsSinceEpoch}',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => ReviewScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Continue', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// Input formatters for card details
class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length && i < 4; i++) {
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}