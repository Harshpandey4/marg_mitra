import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import 'request_detail_screen.dart';

class ServiceHistoryScreen extends StatefulWidget {
  const ServiceHistoryScreen({super.key});

  @override
  _ServiceHistoryScreenState createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedSortOption = 'Recent';
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _sortOptions = ['Recent', 'Oldest', 'Amount (High)', 'Amount (Low)', 'Rating'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: _showSearch ? _buildSearchField() : const Text('Service History'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _selectedSortOption = value;
              });
            },
            itemBuilder: (context) => _sortOptions
                .map((option) => PopupMenuItem(
              value: option,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getSortIcon(option),
                    size: 20,
                    color: _selectedSortOption == option
                        ? AppTheme.primaryColor
                        : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      option,
                      style: TextStyle(
                        color: _selectedSortOption == option
                            ? AppTheme.primaryColor
                            : null,
                        fontWeight: _selectedSortOption == option
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ))
                .toList(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(isTablet ? 130 : 110),
          child: Column(
            children: [
              // Stats Summary
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.02,
                  vertical: 1,
                ),
                padding: EdgeInsets.all(screenWidth * 0.01),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = constraints.maxWidth / 4;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: itemWidth,
                          child: _buildStatItem('Total', '${_getAllServices().length}', Icons.history, isTablet),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _buildStatItem('Active', '${_getActiveServices().length}', Icons.pending, isTablet),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _buildStatItem('Completed', '${_getCompletedServices().length}', Icons.check_circle, isTablet),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _buildStatItem('Earnings', '₹${_calculateTotalEarnings()}', Icons.account_balance_wallet, isTablet),
                        ),
                      ],
                    );
                  },
                ),
              ),
              TabBar(
                controller: _tabController,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppTheme.primaryColor,
                indicatorWeight: 3,
                isScrollable: screenWidth < 400,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Active',
                          style: TextStyle(fontSize: isTablet ? 16 : 14),
                        ),
                        const SizedBox(width: 4),
                        if (_getActiveServices().isNotEmpty)
                          Container(
                            padding: EdgeInsets.all(isTablet ? 6 : 4),
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${_getActiveServices().length}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isTablet ? 12 : 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Completed',
                      style: TextStyle(fontSize: isTablet ? 16 : 14),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Cancelled',
                      style: TextStyle(fontSize: isTablet ? 16 : 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildServiceList(_getFilteredAndSortedServices(_getActiveServices()), isTablet),
          _buildServiceList(_getFilteredAndSortedServices(_getCompletedServices()), isTablet),
          _buildServiceList(_getFilteredAndSortedServices(_getCancelledServices()), isTablet),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
        onPressed: () {
          _showActiveServiceActions(context);
        },
        icon: const Icon(Icons.add),
        label: Text(
          isTablet ? 'Quick Actions' : 'Actions',
          style: TextStyle(fontSize: isTablet ? 16 : 14),
        ),
        backgroundColor: AppTheme.primaryColor,
      )
          : null,
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Search services...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey),
      ),
      style: const TextStyle(color: Colors.black),
      onChanged: (value) {
        setState(() {
          _searchQuery = value.toLowerCase();
        });
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, bool isTablet) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: isTablet ? 24 : 20,
          color: AppTheme.primaryColor,
        ),
        SizedBox(height: isTablet ? 6 : 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
            maxLines: 1,
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: Colors.grey[600],
            ),
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceList(List<Map<String, dynamic>> services, bool isTablet) {
    if (services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: isTablet ? 80 : 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: isTablet ? 20 : 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                _searchQuery.isNotEmpty ? 'No matching services found' : 'No services found',
                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (_searchQuery.isNotEmpty) ...[
              SizedBox(height: isTablet ? 12 : 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                  });
                },
                child: Text(
                  'Clear Search',
                  style: TextStyle(fontSize: isTablet ? 16 : 14),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        setState(() {});
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = isTablet ? 2 : 1;
          final screenWidth = MediaQuery.of(context).size.width;

          if (isTablet && constraints.maxWidth > 800) {
            // Grid layout for tablets in landscape
            return GridView.builder(
              padding: EdgeInsets.all(screenWidth * 0.04),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: services.length,
              itemBuilder: (context, index) {
                return _buildServiceCard(services[index], index, isTablet, true);
              },
            );
          } else {
            // List layout for phones and tablets in portrait
            return ListView.builder(
              padding: EdgeInsets.all(screenWidth * 0.04),
              itemCount: services.length,
              itemBuilder: (context, index) {
                return _buildServiceCard(services[index], index, isTablet, false);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service, int index, bool isTablet, bool isGridView) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      margin: EdgeInsets.only(
        bottom: isGridView ? 0 : (isTablet ? 16 : 12),
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RequestDetailScreen(serviceData: service),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: service['isEmergency'] == true
                ? Border.all(color: AppTheme.emergencyColor, width: 2)
                : null,
          ),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Row
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isTablet ? 10 : 8),
                      decoration: BoxDecoration(
                        color: _getStatusColor(service['status']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getServiceIcon(service['serviceType']),
                        color: _getStatusColor(service['status']),
                        size: isTablet ? 24 : 20,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service['serviceType'],
                            style: TextStyle(
                              fontSize: isTablet ? 18 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'ID: ${service['id']}',
                            style: TextStyle(
                              fontSize: isTablet ? 14 : 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 10 : 8,
                            vertical: isTablet ? 6 : 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(service['status']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            service['status'],
                            style: TextStyle(
                              color: _getStatusColor(service['status']),
                              fontSize: isTablet ? 14 : 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (service['isEmergency'] == true) ...[
                          SizedBox(height: isTablet ? 6 : 4),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 8 : 6,
                              vertical: isTablet ? 4 : 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.emergencyColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'EMERGENCY',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isTablet ? 12 : 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                SizedBox(height: screenWidth * 0.03),

                // Service Details
                _buildDetailRow(Icons.person_outline, service['customerName'], isTablet),
                SizedBox(height: screenWidth * 0.015),
                _buildDetailRow(Icons.location_on_outlined, service['location'], isTablet),
                SizedBox(height: screenWidth * 0.015),
                _buildDetailRow(Icons.access_time, service['time'], isTablet),

                // Rating and Amount
                if (service['amount'] != null || service['rating'] != null) ...[
                  SizedBox(height: screenWidth * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (service['rating'] != null)
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ...List.generate(
                                5,
                                    (i) => Icon(
                                  Icons.star,
                                  size: isTablet ? 18 : 16,
                                  color: i < service['rating']
                                      ? Colors.amber
                                      : Colors.grey[300],
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.01),
                              Text(
                                '(${service['rating']}/5)',
                                style: TextStyle(
                                  fontSize: isTablet ? 14 : 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (service['amount'] != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 14 : 12,
                            vertical: isTablet ? 6 : 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.successColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '₹${service['amount']}',
                            style: TextStyle(
                              fontSize: isTablet ? 18 : 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.successColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],

                // Action Buttons
                if (!isGridView) ...[
                  if (service['status'].toLowerCase() == 'active' ||
                      service['status'].toLowerCase() == 'in progress') ...[
                    SizedBox(height: screenWidth * 0.03),
                    _buildActiveServiceButtons(service, isTablet, screenWidth),
                  ],
                  if (service['status'].toLowerCase() == 'completed') ...[
                    SizedBox(height: screenWidth * 0.03),
                    _buildCompletedServiceButtons(service, isTablet, screenWidth),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, bool isTablet) {
    return Row(
      children: [
        Icon(
          icon,
          size: isTablet ? 18 : 16,
          color: Colors.grey[600],
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.015),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
              fontSize: isTablet ? 16 : 14,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveServiceButtons(Map<String, dynamic> service, bool isTablet, double screenWidth) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _callCustomer(service),
            icon: Icon(Icons.call, size: isTablet ? 18 : 16),
            label: Text(
              'Call',
              style: TextStyle(fontSize: isTablet ? 16 : 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: isTablet ? 12 : 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.02),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _navigateToLocation(service),
            icon: Icon(Icons.navigation, size: isTablet ? 18 : 16),
            label: Text(
              'Navigate',
              style: TextStyle(fontSize: isTablet ? 16 : 14),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              padding: EdgeInsets.symmetric(vertical: isTablet ? 12 : 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedServiceButtons(Map<String, dynamic> service, bool isTablet, double screenWidth) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _messageCustomer(service),
            icon: Icon(Icons.message, size: isTablet ? 18 : 16),
            label: Text(
              'Message',
              style: TextStyle(fontSize: isTablet ? 16 : 14),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green,
              padding: EdgeInsets.symmetric(vertical: isTablet ? 12 : 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.02),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _requestFeedback(service),
            icon: Icon(Icons.star_rate, size: isTablet ? 18 : 16),
            label: Text(
              'Feedback',
              style: TextStyle(fontSize: isTablet ? 16 : 14),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange,
              padding: EdgeInsets.symmetric(vertical: isTablet ? 12 : 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getFilteredAndSortedServices(List<Map<String, dynamic>> services) {
    var filtered = services.where((service) {
      if (_searchQuery.isEmpty) return true;
      return service['serviceType'].toLowerCase().contains(_searchQuery) ||
          service['customerName'].toLowerCase().contains(_searchQuery) ||
          service['location'].toLowerCase().contains(_searchQuery) ||
          service['id'].toLowerCase().contains(_searchQuery);
    }).toList();

    // Sort based on selected option
    switch (_selectedSortOption) {
      case 'Recent':
        break;
      case 'Oldest':
        filtered = filtered.reversed.toList();
        break;
      case 'Amount (High)':
        filtered.sort((a, b) => (b['amount'] ?? 0).compareTo(a['amount'] ?? 0));
        break;
      case 'Amount (Low)':
        filtered.sort((a, b) => (a['amount'] ?? 0).compareTo(b['amount'] ?? 0));
        break;
      case 'Rating':
        filtered.sort((a, b) => (b['rating'] ?? 0).compareTo(a['rating'] ?? 0));
        break;
    }

    return filtered;
  }

  List<Map<String, dynamic>> _getAllServices() {
    return [..._getActiveServices(), ..._getCompletedServices(), ..._getCancelledServices()];
  }

  int _calculateTotalEarnings() {
    return _getCompletedServices()
        .fold(0, (sum, service) => sum + (service['amount'] ?? 0) as int);
  }

  IconData _getSortIcon(String option) {
    switch (option) {
      case 'Recent':
        return Icons.schedule;
      case 'Oldest':
        return Icons.history;
      case 'Amount (High)':
        return Icons.arrow_upward;
      case 'Amount (Low)':
        return Icons.arrow_downward;
      case 'Rating':
        return Icons.star;
      default:
        return Icons.sort;
    }
  }

  IconData _getServiceIcon(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'battery jump start':
        return Icons.battery_charging_full;
      case 'flat tire repair':
        return Icons.build;
      case 'towing service':
        return Icons.local_shipping;
      case 'fuel delivery':
        return Icons.local_gas_station;
      case 'vehicle lockout':
        return Icons.lock_open;
      default:
        return Icons.build;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'in progress':
        return AppTheme.primaryColor;
      case 'completed':
        return AppTheme.successColor;
      case 'cancelled':
        return AppTheme.emergencyColor;
      case 'pending':
        return AppTheme.warningColor;
      default:
        return Colors.grey;
    }
  }

  void _showActiveServiceActions(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(isTablet ? 24 : 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: isTablet ? 24 : 20),
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: isTablet ? 24 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: isTablet ? 24 : 20),
              ListTile(
                leading: const Icon(Icons.refresh, color: AppTheme.primaryColor),
                title: Text(
                  'Refresh Services',
                  style: TextStyle(fontSize: isTablet ? 18 : 16),
                ),
                subtitle: Text(
                  'Update service status',
                  style: TextStyle(fontSize: isTablet ? 16 : 14),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Services refreshed'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.map, color: Colors.blue),
                title: Text(
                  'View Active Services on Map',
                  style: TextStyle(fontSize: isTablet ? 18 : 16),
                ),
                subtitle: Text(
                  'See all active service locations',
                  style: TextStyle(fontSize: isTablet ? 16 : 14),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showServicesOnMap();
                },
              ),
              ListTile(
                leading: const Icon(Icons.emergency, color: Colors.red),
                title: Text(
                  'Emergency Services',
                  style: TextStyle(fontSize: isTablet ? 18 : 16),
                ),
                subtitle: Text(
                  'Access emergency contacts',
                  style: TextStyle(fontSize: isTablet ? 16 : 14),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showEmergencyOptions();
                },
              ),
              ListTile(
                leading: const Icon(Icons.filter_list, color: Colors.orange),
                title: Text(
                  'Filter Emergency Only',
                  style: TextStyle(fontSize: isTablet ? 18 : 16),
                ),
                subtitle: Text(
                  'Show only emergency services',
                  style: TextStyle(fontSize: isTablet ? 16 : 14),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _filterEmergencyServices();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showServicesOnMap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening map view of active services...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showEmergencyOptions() {
    final isTablet = MediaQuery.of(context).size.width > 600;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.emergency, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              'Emergency Options',
              style: TextStyle(fontSize: isTablet ? 20 : 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.local_police, color: Colors.blue),
              title: Text(
                'Call Police',
                style: TextStyle(fontSize: isTablet ? 18 : 16),
              ),
              subtitle: Text(
                '100',
                style: TextStyle(fontSize: isTablet ? 16 : 14),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Calling Police: 100'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.medical_services, color: Colors.red),
              title: Text(
                'Call Ambulance',
                style: TextStyle(fontSize: isTablet ? 18 : 16),
              ),
              subtitle: Text(
                '108',
                style: TextStyle(fontSize: isTablet ? 16 : 14),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Calling Ambulance: 108'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_fire_department, color: Colors.orange),
              title: Text(
                'Fire Department',
                style: TextStyle(fontSize: isTablet ? 18 : 16),
              ),
              subtitle: Text(
                '101',
                style: TextStyle(fontSize: isTablet ? 16 : 14),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Calling Fire Department: 101'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(fontSize: isTablet ? 16 : 14),
            ),
          ),
        ],
      ),
    );
  }

  void _filterEmergencyServices() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Filtering emergency services only...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _requestFeedback(Map<String, dynamic> service) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.star_rate, color: Colors.orange),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Request Feedback',
                style: TextStyle(fontSize: isTablet ? 20 : 18),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Text(
          'Would you like to request additional feedback from ${service['customerName']} for the ${service['serviceType']} service?',
          style: TextStyle(fontSize: isTablet ? 16 : 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(fontSize: isTablet ? 16 : 14),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Feedback request sent to ${service['customerName']}'),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Send Request',
              style: TextStyle(fontSize: isTablet ? 16 : 14),
            ),
          ),
        ],
      ),
    );
  }

  void _callCustomer(Map<String, dynamic> service) {
    final phoneNumber = service['customerPhone'] ?? '+91 9876543210';
    final isTablet = MediaQuery.of(context).size.width > 600;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.phone, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Call Customer',
                style: TextStyle(fontSize: isTablet ? 20 : 18),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Text(
          'Call ${service['customerName']} at $phoneNumber?',
          style: TextStyle(fontSize: isTablet ? 16 : 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(fontSize: isTablet ? 16 : 14),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Calling $phoneNumber...'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Call Now',
              style: TextStyle(fontSize: isTablet ? 16 : 14),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToLocation(Map<String, dynamic> service) {
    Navigator.pushNamed(
      context,
      '/navigation',
      arguments: {
        'customerName': service['customerName'],
        'customerAddress': service['location'],
        'customerPhone': service['customerPhone'] ?? '+91 9876543210',
        'serviceType': service['serviceType'],
      },
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        if (result['arrived'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Marked as arrived at ${service['customerName']}\'s location'),
              backgroundColor: AppTheme.successColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    });
  }

  void _messageCustomer(Map<String, dynamic> service) {
    Navigator.pushNamed(
      context,
      '/customer_communication',
      arguments: {
        'customerId': 'customer_${service['id']}',
        'customerName': service['customerName'],
        'customerPhone': service['customerPhone'] ?? '+91 9876543210',
        'serviceType': service['serviceType'],
        'requestId': service['id'],
      },
    );
  }

  // Sample data methods
  List<Map<String, dynamic>> _getActiveServices() {
    return [
      {
        'id': 'REQ001',
        'serviceType': 'Battery Jump Start',
        'customerName': 'Amit Sharma',
        'location': 'Sector 18, Noida',
        'time': 'Started 15 mins ago',
        'status': 'In Progress',
        'isEmergency': true,
        'customerPhone': '+91 9876543210',
        'description': 'Car battery completely dead, unable to start',
      },
      {
        'id': 'REQ002',
        'serviceType': 'Flat Tire Repair',
        'customerName': 'Priya Singh',
        'location': 'DLF Phase 1, Gurgaon',
        'time': 'Accepted 5 mins ago',
        'status': 'Active',
        'isEmergency': false,
        'customerPhone': '+91 9876543211',
        'description': 'Front left tire punctured, need immediate repair',
      },
      {
        'id': 'REQ007',
        'serviceType': 'Fuel Delivery',
        'customerName': 'Rajesh Verma',
        'location': 'Janakpuri, Delhi',
        'time': 'Pending for 2 mins',
        'status': 'Active',
        'isEmergency': false,
        'customerPhone': '+91 9876543212',
        'description': 'Ran out of fuel on highway, need urgent delivery',
      },
    ];
  }

  List<Map<String, dynamic>> _getCompletedServices() {
    return [
      {
        'id': 'REQ003',
        'serviceType': 'Towing Service',
        'customerName': 'Rohit Kumar',
        'location': 'Connaught Place, Delhi',
        'time': 'Today, 2:30 PM',
        'status': 'Completed',
        'amount': 450,
        'rating': 5,
        'isEmergency': false,
        'customerPhone': '+91 9876543213',
        'description': 'Vehicle breakdown, towed to nearest service center',
      },
      {
        'id': 'REQ004',
        'serviceType': 'Fuel Delivery',
        'customerName': 'Neha Agarwal',
        'location': 'Cyber City, Gurgaon',
        'time': 'Today, 11:15 AM',
        'status': 'Completed',
        'amount': 200,
        'rating': 4,
        'isEmergency': false,
        'customerPhone': '+91 9876543214',
        'description': 'Emergency fuel delivery on highway',
      },
      {
        'id': 'REQ005',
        'serviceType': 'Vehicle Lockout',
        'customerName': 'Suresh Mehta',
        'location': 'Karol Bagh, Delhi',
        'time': 'Yesterday, 6:45 PM',
        'status': 'Completed',
        'amount': 350,
        'rating': 5,
        'isEmergency': false,
        'customerPhone': '+91 9876543215',
        'description': 'Keys locked inside car, lockout service provided',
      },
      {
        'id': 'REQ008',
        'serviceType': 'Battery Jump Start',
        'customerName': 'Anita Desai',
        'location': 'Laxmi Nagar, Delhi',
        'time': 'Yesterday, 4:20 PM',
        'status': 'Completed',
        'amount': 300,
        'rating': 4,
        'isEmergency': true,
        'customerPhone': '+91 9876543216',
        'description': 'Battery jump start service completed successfully',
      },
      {
        'id': 'REQ009',
        'serviceType': 'Flat Tire Repair',
        'customerName': 'Manoj Tiwari',
        'location': 'Saket, Delhi',
        'time': 'Yesterday, 1:15 PM',
        'status': 'Completed',
        'amount': 400,
        'rating': 5,
        'isEmergency': false,
        'customerPhone': '+91 9876543217',
        'description': 'Tire repair and replacement service',
      },
    ];
  }

  List<Map<String, dynamic>> _getCancelledServices() {
    return [
      {
        'id': 'REQ006',
        'serviceType': 'Battery Jump Start',
        'customerName': 'Vikash Gupta',
        'location': 'Lajpat Nagar, Delhi',
        'time': 'Yesterday, 3:20 PM',
        'status': 'Cancelled',
        'isEmergency': false,
        'customerPhone': '+91 9876543218',
        'description': 'Customer cancelled before service arrival',
      },
      {
        'id': 'REQ010',
        'serviceType': 'Towing Service',
        'customerName': 'Deepak Yadav',
        'location': 'Rohini, Delhi',
        'time': '2 days ago, 7:30 PM',
        'status': 'Cancelled',
        'isEmergency': false,
        'customerPhone': '+91 9876543219',
        'description': 'Service cancelled due to weather conditions',
      },
    ];
  }
}