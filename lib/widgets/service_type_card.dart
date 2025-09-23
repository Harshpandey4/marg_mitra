import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class ServiceTypeCard extends StatelessWidget {
  final Map<String, dynamic> serviceType;
  final VoidCallback onTap;

  const ServiceTypeCard({
    Key? key,
    required this.serviceType,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine if this is an emergency service
    final isEmergency = serviceType['category'] == 'emergency' ||
        serviceType['isEmergency'] == true ||
        (serviceType['name'] as String).toLowerCase().contains('emergency') ||
        (serviceType['name'] as String).toLowerCase().contains('sos');

    // Determine if this is a premium/verified service
    final isVerified = serviceType['isVerified'] == true;
    final hasRating = serviceType['rating'] != null;
    final responseTime = serviceType['responseTime'] ?? serviceType['estimatedTime'];

    return Card(
      elevation: isEmergency ? 8 : 4,
      shadowColor: isEmergency ? Colors.red.withOpacity(0.3) : Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isEmergency
            ? BorderSide(color: Colors.red.withOpacity(0.3), width: 1)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isEmergency
                ? LinearGradient(
              colors: [Colors.red.withOpacity(0.05), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main service info row
                Row(
                  children: [
                    // Service icon with priority styling
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isEmergency
                            ? Colors.red.withOpacity(0.15)
                            : AppConstants.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: isEmergency
                            ? Border.all(color: Colors.red.withOpacity(0.3), width: 1)
                            : null,
                      ),
                      child: Icon(
                        serviceType['icon'] as IconData,
                        color: isEmergency ? Colors.red : AppConstants.primaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Service details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Service name with emergency badge
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  serviceType['name'] as String,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: isEmergency ? Colors.red[800] : Colors.black87,
                                  ),
                                ),
                              ),
                              if (isEmergency)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    '24/7',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Service description or subtitle
                          if (serviceType['description'] != null)
                            Text(
                              serviceType['description'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                          const SizedBox(height: 6),

                          // Response time and rating row
                          Row(
                            children: [
                              // Response time with icon
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: isEmergency ? Colors.red : Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                responseTime as String? ?? 'N/A',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isEmergency ? Colors.red[700] : Colors.grey.shade700,
                                ),
                              ),

                              if (hasRating) ...[
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.star,
                                  size: 14,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  serviceType['rating'].toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],

                              if (isVerified) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.verified,
                                  size: 16,
                                  color: Colors.green,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Price section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (serviceType['basePrice'] != null && serviceType['basePrice'] > 0)
                          Text(
                            Helpers.formatCurrency(serviceType['basePrice'] as double),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isEmergency ? Colors.red[700] : AppConstants.primaryColor,
                            ),
                          )
                        else if (isEmergency)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'FREE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else
                          Text(
                            'Quote',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),

                        // Availability indicator
                        if (serviceType['availability'] != null)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: serviceType['availability'] == 'available'
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: serviceType['availability'] == 'available'
                                    ? Colors.green.withOpacity(0.3)
                                    : Colors.orange.withOpacity(0.3),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              serviceType['availability'] == 'available' ? 'Available' : 'Busy',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: serviceType['availability'] == 'available'
                                    ? Colors.green[700]
                                    : Colors.orange[700],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                // Additional features row (for non-emergency services)
                if (!isEmergency && serviceType['features'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: (serviceType['features'] as List<String>)
                          .take(3)
                          .map((feature) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          feature,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppConstants.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )).toList(),
                    ),
                  ),

                // Emergency service features
                if (isEmergency && serviceType['emergencyFeatures'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        Icon(Icons.flash_on, size: 14, color: Colors.red),
                        const SizedBox(width: 4),
                        Text(
                          'Auto-detection • Multi-agency coordination • Family alerts',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.red[700],
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
      ),
    );
  }
}