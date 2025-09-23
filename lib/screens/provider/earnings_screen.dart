import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';

class EarningsScreen extends StatefulWidget {
  @override
  _EarningsScreenState createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _withdrawController = TextEditingController();

  double todayEarnings = 1250.0;
  double weeklyEarnings = 8750.0;
  double monthlyEarnings = 35000.0;
  double totalEarnings = 125000.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild to update earnings display
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _withdrawController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        title: Text(
          'Earnings',
          style: TextStyle(
            fontSize: isTablet ? 22 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue[100],
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(isTablet ? 40 : 30),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: screenWidth < 500,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: AppTheme.primaryColor,
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: isTablet ? 15 : 13,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                Tab(text: 'Today'),
                Tab(text: 'This Week'),
                Tab(text: 'This Month'),
                Tab(text: 'All Time'),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: screenHeight * 0.02),
          // Enhanced Earnings Summary Card
          Container(
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.8),
                  AppTheme.primaryColor.withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.06),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getPeriodText(),
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: isTablet ? 18 : 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '₹${_formatAmount(_getCurrentEarnings())}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isTablet ? 42 : 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.all(isTablet ? 16 : 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          Icons.trending_up,
                          color: Colors.white,
                          size: isTablet ? 40 : 32,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Container(
                    padding: EdgeInsets.all(isTablet ? 20 : 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildEarningStat('Services', _getServicesCount(), Icons.work_outline, isTablet),
                        _buildVerticalDivider(),
                        _buildEarningStat('Hours', _getHoursWorked(), Icons.access_time_outlined, isTablet),
                        _buildVerticalDivider(),
                        _buildEarningStat('Rating', '4.8', Icons.star_outline, isTablet),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: screenHeight * 0.02),

          // Earnings History with enhanced design
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Transaction History',
                            style: TextStyle(
                              fontSize: isTablet ? 20 : 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          Icon(
                            Icons.history,
                            color: AppTheme.primaryColor,
                            size: isTablet ? 26 : 22,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildEarningsTab('Today', _getTodayTransactions(), isTablet),
                          _buildEarningsTab('This Week', _getWeeklyTransactions(), isTablet),
                          _buildEarningsTab('This Month', _getMonthlyTransactions(), isTablet),
                          _buildEarningsTab('All Time', _getAllTransactions(), isTablet),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppTheme.successColor.withOpacity(0.4),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            _showWithdrawDialog(isTablet);
          },
          icon: Icon(
            Icons.account_balance_wallet_outlined,
            size: isTablet ? 24 : 20,
          ),
          label: Text(
            'Withdraw',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppTheme.successColor,
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withOpacity(0.3),
    );
  }

  Widget _buildEarningStat(String label, String value, IconData icon, bool isTablet) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: isTablet ? 26 : 22,
          ),
          SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontSize: isTablet ? 14 : 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsTab(String period, List<Map<String, dynamic>> transactions, bool isTablet) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: isTablet ? 80 : 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No transactions yet',
              style: TextStyle(
                fontSize: isTablet ? 20 : 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Complete services to see earnings here',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(Duration(seconds: 1));
        setState(() {});
      },
      child: ListView.builder(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return Container(
            margin: EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04,
                vertical: 8,
              ),
              leading: Container(
                padding: EdgeInsets.all(isTablet ? 12 : 10),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getServiceIcon(transaction['service']),
                  color: AppTheme.successColor,
                  size: isTablet ? 26 : 22,
                ),
              ),
              title: Text(
                transaction['service'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 18 : 16,
                  color: Colors.grey[800],
                ),
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Padding(
                padding: EdgeInsets.only(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction['customer'],
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: isTablet ? 16 : 14,
                          color: Colors.grey[500],
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            transaction['date'],
                            style: TextStyle(
                              fontSize: isTablet ? 14 : 12,
                              color: Colors.grey[500],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 12 : 10,
                      vertical: isTablet ? 6 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '₹${transaction['amount']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: isTablet ? 16 : 14,
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 8 : 6,
                      vertical: isTablet ? 4 : 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[200]!, width: 1),
                    ),
                    child: Text(
                      'Paid',
                      style: TextStyle(
                        fontSize: isTablet ? 12 : 10,
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }

  IconData _getServiceIcon(String service) {
    switch (service.toLowerCase()) {
      case 'battery jump start':
        return Icons.battery_charging_full;
      case 'towing service':
        return Icons.local_shipping;
      case 'flat tire repair':
        return Icons.build_circle;
      case 'fuel delivery':
        return Icons.local_gas_station;
      case 'vehicle lockout':
        return Icons.lock_open;
      default:
        return Icons.handyman;
    }
  }

  String _getPeriodText() {
    switch (_tabController.index) {
      case 0:
        return 'Today\'s Earnings';
      case 1:
        return 'This Week\'s Earnings';
      case 2:
        return 'This Month\'s Earnings';
      case 3:
        return 'Total Earnings';
      default:
        return 'Today\'s Earnings';
    }
  }

  String _getServicesCount() {
    switch (_tabController.index) {
      case 0:
        return '${_getTodayTransactions().length}';
      case 1:
        return '${_getWeeklyTransactions().length + _getTodayTransactions().length}';
      case 2:
        return '${_getAllTransactions().length}';
      case 3:
        return '24';
      default:
        return '${_getTodayTransactions().length}';
    }
  }

  String _getHoursWorked() {
    switch (_tabController.index) {
      case 0:
        return '6';
      case 1:
        return '18';
      case 2:
        return '45';
      case 3:
        return '120';
      default:
        return '6';
    }
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return amount.toInt().toString();
    }
  }

  double _getCurrentEarnings() {
    switch (_tabController.index) {
      case 0:
        return todayEarnings;
      case 1:
        return weeklyEarnings;
      case 2:
        return monthlyEarnings;
      case 3:
        return totalEarnings;
      default:
        return todayEarnings;
    }
  }

  List<Map<String, dynamic>> _getTodayTransactions() {
    return [
      {
        'service': 'Battery Jump Start',
        'customer': 'Amit Sharma',
        'amount': 250,
        'date': 'Today, 2:30 PM'
      },
      {
        'service': 'Towing Service',
        'customer': 'Priya Singh',
        'amount': 450,
        'date': 'Today, 11:15 AM'
      },
      {
        'service': 'Flat Tire Repair',
        'customer': 'Rohit Kumar',
        'amount': 300,
        'date': 'Today, 9:45 AM'
      },
      {
        'service': 'Fuel Delivery',
        'customer': 'Anita Desai',
        'amount': 200,
        'date': 'Today, 8:20 AM'
      },
    ];
  }

  List<Map<String, dynamic>> _getWeeklyTransactions() {
    return [
      {
        'service': 'Towing Service',
        'customer': 'Deepak Gupta',
        'amount': 500,
        'date': 'Yesterday, 6:20 PM'
      },
      {
        'service': 'Fuel Delivery',
        'customer': 'Neha Agarwal',
        'amount': 200,
        'date': 'Dec 10, 4:15 PM'
      },
      {
        'service': 'Vehicle Lockout',
        'customer': 'Vikash Kumar',
        'amount': 350,
        'date': 'Dec 9, 2:45 PM'
      },
    ];
  }

  List<Map<String, dynamic>> _getMonthlyTransactions() {
    return [
      {
        'service': 'Vehicle Lockout',
        'customer': 'Suresh Mehta',
        'amount': 350,
        'date': 'Dec 8, 1:30 PM'
      },
      {
        'service': 'Battery Jump Start',
        'customer': 'Rajesh Verma',
        'amount': 300,
        'date': 'Dec 5, 5:15 PM'
      },
    ];
  }

  List<Map<String, dynamic>> _getAllTransactions() {
    return [..._getTodayTransactions(), ..._getWeeklyTransactions(), ..._getMonthlyTransactions()];
  }

  void _showWithdrawDialog(bool isTablet) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.account_balance_wallet,
                color: AppTheme.successColor,
                size: isTablet ? 28 : 24,
              ),
            ),
            SizedBox(width: 12),
            Flexible(
              child: Text(
                'Withdraw Earnings',
                style: TextStyle(
                  fontSize: isTablet ? 22 : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Available Balance:',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      '₹${totalEarnings.toInt()}',
                      style: TextStyle(
                        fontSize: isTablet ? 22 : 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Enter Amount',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _withdrawController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  labelText: 'Amount to withdraw',
                  prefixText: '₹ ',
                  prefixStyle: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: isTablet ? 16 : 12,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[700],
                      size: isTablet ? 22 : 20,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Funds will be transferred to your registered bank account within 24 hours.',
                        style: TextStyle(
                          fontSize: isTablet ? 15 : 13,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _withdrawController.clear();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 24 : 20,
                vertical: isTablet ? 12 : 10,
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_withdrawController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter withdrawal amount'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }

              final amount = double.tryParse(_withdrawController.text) ?? 0;
              if (amount <= 0 || amount > totalEarnings) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter a valid amount'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }

              Navigator.pop(context);
              _withdrawController.clear();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Withdrawal request of ₹${amount.toInt()} submitted successfully!',
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: AppTheme.successColor,
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 4),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 24 : 20,
                vertical: isTablet ? 12 : 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Withdraw',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}