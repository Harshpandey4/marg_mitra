import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';
import '../../config/app_routes.dart';

enum JobStatus { pending, accepted, enroute, arrived, inProgress, completed, cancelled }
enum ServiceType { vehicleRepair, medicalEmergency, autoParts, accident, fuelDelivery, towing, roadside, locksmith }

class JobManagementScreen extends StatefulWidget {
  @override
  _JobManagementScreenState createState() => _JobManagementScreenState();
}

class _JobManagementScreenState extends State<JobManagementScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  // Current active job
  Job? activeJob;

  // Job lists
  List<Job> pendingJobs = [];
  List<Job> completedJobs = [];
  List<Job> cancelledJobs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeSampleData();
  }

  void _initializeSampleData() {
    // Sample active job
    activeJob = Job(
      id: '001',
      customerName: 'Harsh Sharma',
      serviceType: ServiceType.vehicleRepair,
      description: 'Engine overheating issue',
      location: 'Prayagraj',
      customerPhone: '+91 9876543210',
      estimatedPrice: 800,
      status: JobStatus.accepted,
      requestTime: DateTime.now().subtract(Duration(minutes: 15)),
      priority: 3,
      distance: '2.3 km',
    );

    // Sample pending jobs
    pendingJobs = [
      Job(
        id: '002',
        customerName: 'Priya Sharma',
        serviceType: ServiceType.fuelDelivery,
        description: 'Emergency fuel delivery',
        location: 'DLF Phase 1, Gurgaon',
        customerPhone: '+91 9876543211',
        estimatedPrice: 300,
        status: JobStatus.pending,
        requestTime: DateTime.now().subtract(Duration(minutes: 5)),
        priority: 4,
        distance: '5.1 km',
      ),
      Job(
        id: '003',
        customerName: 'Emergency Call',
        serviceType: ServiceType.medicalEmergency,
        description: 'Medical assistance needed',
        location: 'Metro Station, CP',
        customerPhone: '+91 9876543212',
        estimatedPrice: 0, // Emergency - no charge initially
        status: JobStatus.pending,
        requestTime: DateTime.now().subtract(Duration(minutes: 2)),
        priority: 5, // Highest priority
        distance: '3.7 km',
      ),
    ];

    // Sample completed jobs
    completedJobs = [
      Job(
        id: '004',
        customerName: 'Amit Singh',
        serviceType: ServiceType.towing,
        description: 'Car breakdown towing service',
        location: 'Highway Delhi-Gurgaon',
        customerPhone: '+91 9876543213',
        estimatedPrice: 1200,
        status: JobStatus.completed,
        requestTime: DateTime.now().subtract(Duration(hours: 2)),
        priority: 3,
        distance: '8.5 km',
      ),
      Job(
        id: '005',
        customerName: 'Sunita Devi',
        serviceType: ServiceType.locksmith,
        description: 'Car key locked inside',
        location: 'Connaught Place, Delhi',
        customerPhone: '+91 9876543214',
        estimatedPrice: 400,
        status: JobStatus.completed,
        requestTime: DateTime.now().subtract(Duration(hours: 4)),
        priority: 2,
        distance: '4.2 km',
      ),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        title: Text('Job Management'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.notifications_outlined),
                if (pendingJobs.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${pendingJobs.length}',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _showPendingJobsDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.red,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Active Job'),
            Tab(text: 'Pending (${pendingJobs.length})'),
            Tab(text: 'Completed (${completedJobs.length})'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveJobTab(),
          _buildPendingJobsTab(),
          _buildCompletedJobsTab(),
          _buildJobHistoryTab(),
        ],
      ),
      floatingActionButton: activeJob != null ? _buildJobActionFAB() : null,
    );
  }

  Widget _buildActiveJobTab() {
    if (activeJob == null) {
      return _buildNoActiveJobView();
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildActiveJobCard(),
          SizedBox(height: 20),
          _buildJobProgress(),
          SizedBox(height: 20),
          _buildCustomerDetails(),
          SizedBox(height: 20),
          _buildJobActions(),
        ],
      ),
    );
  }

  Widget _buildNoActiveJobView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_off_outlined, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No Active Job',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            'Accept a pending request to start working',
            style: TextStyle(color: Colors.grey[500]),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _tabController.animateTo(1),
            icon: Icon(Icons.search),
            label: Text('View Pending Jobs'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveJobCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_getServiceIcon(activeJob!.serviceType), color: Colors.white, size: 24),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ACTIVE JOB',
                        style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _getServiceName(activeJob!.serviceType),
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(activeJob!.status),
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.person, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text(activeJob!.customerName, style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(activeJob!.location, style: TextStyle(color: Colors.white70)),
                ),
                Text(activeJob!.distance, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobProgress() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Job Progress',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildProgressStep('Request Accepted', true, activeJob!.status == JobStatus.accepted),
            _buildProgressStep('En Route', activeJob!.status.index >= JobStatus.enroute.index, activeJob!.status == JobStatus.enroute),
            _buildProgressStep('Arrived at Location', activeJob!.status.index >= JobStatus.arrived.index, activeJob!.status == JobStatus.arrived),
            _buildProgressStep('Service in Progress', activeJob!.status.index >= JobStatus.inProgress.index, activeJob!.status == JobStatus.inProgress),
            _buildProgressStep('Job Completed', activeJob!.status.index >= JobStatus.completed.index, activeJob!.status == JobStatus.completed),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStep(String title, bool isCompleted, bool isActive) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? AppTheme.successColor
                  : isActive
                  ? AppTheme.primaryColor
                  : Colors.yellow[100],
            ),
            child: Icon(
              isCompleted ? Icons.check : Icons.radio_button_unchecked,
              color: Colors.white,
              size: 16,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isCompleted ? AppTheme.successColor : (isActive ? AppTheme.primaryColor : Colors.grey[600]),
              ),
            ),
          ),
          if (isActive)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'CURRENT',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomerDetails() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildDetailRow(Icons.person, 'Name', activeJob!.customerName),
            _buildDetailRow(Icons.phone, 'Phone', activeJob!.customerPhone),
            _buildDetailRow(Icons.location_on, 'Location', activeJob!.location),
            _buildDetailRow(Icons.description, 'Issue', activeJob!.description),
            _buildDetailRow(Icons.currency_rupee, 'Estimated Cost', '₹${activeJob!.estimatedPrice}'),
            _buildDetailRow(Icons.access_time, 'Request Time', _formatTime(activeJob!.requestTime)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobActions() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _callCustomer,
                    icon: Icon(Icons.phone),
                    label: Text('Call Customer'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _messageCustomer,
                    icon: Icon(Icons.message),
                    label: Text('Message'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: BorderSide(color: Colors.green),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _navigateToCustomer,
                    icon: Icon(Icons.navigation),
                    label: Text('Navigate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _updateJobStatus,
                    icon: Icon(Icons.update),
                    label: Text(_getNextActionText()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showEmergencyOptions,
                icon: Icon(Icons.emergency, color: Colors.red),
                label: Text('Emergency Options'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingJobsTab() {
    if (pendingJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No Pending Jobs',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              'New job requests will appear here',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: pendingJobs.length,
      itemBuilder: (context, index) {
        return _buildPendingJobCard(pendingJobs[index]);
      },
    );
  }

  Widget _buildPendingJobCard(Job job) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: job.priority >= 4 ? 6 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: job.priority >= 4
            ? BorderSide(color: Colors.red.withOpacity(0.3), width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getServiceColor(job.serviceType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getServiceIcon(job.serviceType),
                    color: _getServiceColor(job.serviceType),
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getServiceName(job.serviceType),
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        job.customerName,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                if (job.priority >= 4) ...[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.priority_high, size: 12, color: Colors.red),
                        SizedBox(width: 2),
                        Text(
                          job.priority == 5 ? 'CRITICAL' : 'URGENT',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 12),
            Text(
              job.description,
              style: TextStyle(color: Colors.grey[700]),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    job.location,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),
                Text(
                  job.distance,
                  style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  _formatTime(job.requestTime),
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                Spacer(),
                if (job.estimatedPrice > 0)
                  Text(
                    '₹${job.estimatedPrice}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.successColor,
                      fontSize: 16,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _declineJob(job),
                    child: Text('Decline'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _acceptJob(job),
                    child: Text(job.priority >= 4 ? 'ACCEPT NOW' : 'Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: job.priority >= 4 ? Colors.red : AppTheme.primaryColor,
                      foregroundColor: Colors.white,
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

  Widget _buildCompletedJobsTab() {
    if (completedJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No Completed Jobs',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              'Completed jobs will appear here',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: completedJobs.length,
      itemBuilder: (context, index) {
        return _buildCompletedJobCard(completedJobs[index]);
      },
    );
  }

  Widget _buildCompletedJobCard(Job job) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: AppTheme.successColor,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getServiceName(job.serviceType),
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        job.customerName,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'COMPLETED',
                    style: TextStyle(
                      color: AppTheme.successColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    job.location,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),
                Text(
                  '₹${job.estimatedPrice}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.successColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  _formatTime(job.requestTime),
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobHistoryTab() {
    List<Job> allJobs = [...completedJobs, ...cancelledJobs];

    if (allJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No Job History',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              'Your job history will appear here',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: allJobs.length,
      itemBuilder: (context, index) {
        return _buildHistoryJobCard(allJobs[index]);
      },
    );
  }

  Widget _buildHistoryJobCard(Job job) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: job.status == JobStatus.completed
                ? AppTheme.successColor.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            job.status == JobStatus.completed ? Icons.check : Icons.cancel,
            color: job.status == JobStatus.completed ? AppTheme.successColor : Colors.red,
            size: 20,
          ),
        ),
        title: Text(_getServiceName(job.serviceType)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(job.customerName),
            Text(_formatTime(job.requestTime), style: TextStyle(fontSize: 12)),
          ],
        ),
        trailing: job.estimatedPrice > 0
            ? Text('₹${job.estimatedPrice}', style: TextStyle(fontWeight: FontWeight.bold))
            : null,
      ),
    );
  }

  Widget _buildJobActionFAB() {
    return FloatingActionButton.extended(
      onPressed: _showQuickActions,
      backgroundColor: AppTheme.primaryColor,
      icon: Icon(Icons.quick_contacts_dialer, color: Colors.white),
      label: Text('Quick Actions', style: TextStyle(color: Colors.white)),
    );
  }

  // Helper Methods
  IconData _getServiceIcon(ServiceType type) {
    switch (type) {
      case ServiceType.vehicleRepair: return Icons.build;
      case ServiceType.medicalEmergency: return Icons.medical_services;
      case ServiceType.autoParts: return Icons.inventory;
      case ServiceType.accident: return Icons.warning;
      case ServiceType.fuelDelivery: return Icons.local_gas_station;
      case ServiceType.towing: return Icons.local_shipping;
      case ServiceType.roadside: return Icons.support_agent;
      case ServiceType.locksmith: return Icons.lock;
    }
  }

  Color _getServiceColor(ServiceType type) {
    switch (type) {
      case ServiceType.vehicleRepair: return AppTheme.primaryColor;
      case ServiceType.medicalEmergency: return Colors.red;
      case ServiceType.autoParts: return Colors.orange;
      case ServiceType.accident: return Colors.red[700]!;
      case ServiceType.fuelDelivery: return Colors.green;
      case ServiceType.towing: return Colors.blue;
      case ServiceType.roadside: return AppTheme.warningColor;
      case ServiceType.locksmith: return Colors.purple;
    }
  }

  String _getServiceName(ServiceType type) {
    switch (type) {
      case ServiceType.vehicleRepair: return 'Vehicle Repair';
      case ServiceType.medicalEmergency: return 'Medical Emergency';
      case ServiceType.autoParts: return 'Auto Parts';
      case ServiceType.accident: return 'Accident Support';
      case ServiceType.fuelDelivery: return 'Fuel Delivery';
      case ServiceType.towing: return 'Towing Service';
      case ServiceType.roadside: return 'Roadside Assistance';
      case ServiceType.locksmith: return 'Locksmith Service';
    }
  }

  String _getStatusText(JobStatus status) {
    switch (status) {
      case JobStatus.pending: return 'PENDING';
      case JobStatus.accepted: return 'ACCEPTED';
      case JobStatus.enroute: return 'EN ROUTE';
      case JobStatus.arrived: return 'ARRIVED';
      case JobStatus.inProgress: return 'IN PROGRESS';
      case JobStatus.completed: return 'COMPLETED';
      case JobStatus.cancelled: return 'CANCELLED';
    }
  }

  String _getNextActionText() {
    switch (activeJob!.status) {
      case JobStatus.accepted: return 'Start Journey';
      case JobStatus.enroute: return 'Mark Arrived';
      case JobStatus.arrived: return 'Start Service';
      case JobStatus.inProgress: return 'Complete Job';
      default: return 'Update Status';
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  // Action Methods
  void _acceptJob(Job job) {
    if (activeJob != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Complete current job before accepting new one'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    HapticFeedback.heavyImpact();
    setState(() {
      activeJob = job;
      activeJob!.status = JobStatus.accepted;
      pendingJobs.remove(job);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Job accepted successfully!'),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );

    _tabController.animateTo(0); // Switch to Active Job tab
  }

  void _declineJob(Job job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Decline Job'),
        content: Text('Are you sure you want to decline this job?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                pendingJobs.remove(job);
                job.status = JobStatus.cancelled;
                cancelledJobs.add(job);
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Job declined'),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text('Decline', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _updateJobStatus() {
    if (activeJob == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Job Status'),
        content: Text('Update status to ${_getNextActionText()}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                switch (activeJob!.status) {
                  case JobStatus.accepted:
                    activeJob!.status = JobStatus.enroute;
                    break;
                  case JobStatus.enroute:
                    activeJob!.status = JobStatus.arrived;
                    break;
                  case JobStatus.arrived:
                    activeJob!.status = JobStatus.inProgress;
                    break;
                  case JobStatus.inProgress:
                    activeJob!.status = JobStatus.completed;
                    completedJobs.add(activeJob!);
                    activeJob = null;
                    break;
                  default:
                    break;
                }
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Job status updated successfully'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _callCustomer() {
    if (activeJob == null) return;

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
        content: Text('Call ${activeJob!.customerName} at ${activeJob!.customerPhone}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling ${activeJob!.customerPhone}...')),
              );
            },
            child: Text('Call Now'),
          ),
        ],
      ),
    );
  }

  void _messageCustomer() {
    if (activeJob == null) return;

    // Navigate to CustomerCommunicationScreen with proper parameters
    Navigator.pushNamed(
      context,
      AppRoutes.customerCommunication,
      arguments: {
        'customerId': 'customer_${activeJob!.id}',
        'customerName': activeJob!.customerName,
        'customerPhone': activeJob!.customerPhone,
        'serviceType': _getServiceName(activeJob!.serviceType),
        'requestId': activeJob!.id,
      },
    );
  }

  void _navigateToCustomer() {
    if (activeJob == null) return;

    HapticFeedback.lightImpact();
    Navigator.pushNamed(
      context,
      AppRoutes.navigation,
      arguments: {
        'customerName': activeJob!.customerName,
        'customerAddress': activeJob!.location,
        'customerPhone': activeJob!.customerPhone,
        'serviceType': _getServiceName(activeJob!.serviceType),
      },
    ).then((result) {
      // Handle navigation result
      if (result != null && result is Map<String, dynamic>) {
        if (result['arrived'] == true) {
          setState(() {
            if (activeJob!.status == JobStatus.enroute) {
              activeJob!.status = JobStatus.arrived;
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Marked as arrived at customer location'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      }
    });
  }

  void _showQuickActions() {
    if (activeJob == null) return;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
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
            SizedBox(height: 16),
            Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.call, color: AppTheme.primaryColor),
              title: Text('Call Customer'),
              subtitle: Text(activeJob!.customerPhone),
              onTap: () {
                Navigator.pop(context);
                _callCustomer();
              },
            ),
            ListTile(
              leading: Icon(Icons.message, color: Colors.green),
              title: Text('Message Customer'),
              subtitle: Text('Open chat with ${activeJob!.customerName}'),
              onTap: () {
                Navigator.pop(context);
                _messageCustomer();
              },
            ),
            ListTile(
              leading: Icon(Icons.navigation, color: Colors.blue),
              title: Text('Start Navigation'),
              subtitle: Text('Navigate to ${activeJob!.location}'),
              onTap: () {
                Navigator.pop(context);
                _navigateToCustomer();
              },
            ),
            ListTile(
              leading: Icon(Icons.update, color: AppTheme.warningColor),
              title: Text('Update Status'),
              subtitle: Text(_getNextActionText()),
              onTap: () {
                Navigator.pop(context);
                _updateJobStatus();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEmergencyOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.emergency, color: Colors.red),
            SizedBox(width: 8),
            Text('Emergency Options'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.local_police, color: Colors.blue),
              title: Text('Call Police'),
              subtitle: Text('100'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Calling Police: 100')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.medical_services, color: Colors.red),
              title: Text('Call Ambulance'),
              subtitle: Text('108'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Calling Ambulance: 108')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.local_fire_department, color: Colors.orange),
              title: Text('Fire Department'),
              subtitle: Text('101'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Calling Fire Department: 101')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.support_agent, color: AppTheme.primaryColor),
              title: Text('Support Team'),
              subtitle: Text('Contact app support'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Connecting to support team...')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPendingJobsDialog() {
    _tabController.animateTo(1);
  }
}

// Job Model
class Job {
  final String id;
  final String customerName;
  final ServiceType serviceType;
  final String description;
  final String location;
  final String customerPhone;
  final int estimatedPrice;
  JobStatus status;
  final DateTime requestTime;
  final int priority;
  final String distance;

  Job({
    required this.id,
    required this.customerName,
    required this.serviceType,
    required this.description,
    required this.location,
    required this.customerPhone,
    required this.estimatedPrice,
    required this.status,
    required this.requestTime,
    required this.priority,
    required this.distance,
  });
}