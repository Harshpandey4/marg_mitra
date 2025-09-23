import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DocumentVerificationScreen extends StatefulWidget {
  const DocumentVerificationScreen({Key? key}) : super(key: key);

  @override
  State<DocumentVerificationScreen> createState() => _DocumentVerificationScreenState();
}

class _DocumentVerificationScreenState extends State<DocumentVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Controllers for text fields
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _registrationNumberController = TextEditingController();
  final TextEditingController _panNumberController = TextEditingController();
  final TextEditingController _aadharNumberController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Document images
  File? _businessLicenseImage;
  File? _panCardImage;
  File? _aadharCardImage;
  File? _profilePicture;
  File? _vehicleRegistrationImage;
  File? _drivingLicenseImage;

  // Form state
  bool _isLoading = false;
  String _selectedServiceType = 'Mechanic';
  List<String> _selectedServices = [];
  bool _isExperienceVerified = false;

  // Service types
  final List<String> _serviceTypes = [
    'Mechanic',
    'Towing Service',
    'Fuel Delivery',
    'Tire Service',
    'Battery Service',
    'Emergency Locksmith'
  ];

  // Available services
  final Map<String, List<String>> _availableServices = {
    'Mechanic': ['Engine Repair', 'Brake Service', 'AC Repair', 'Electrical Work'],
    'Towing Service': ['Light Vehicle Towing', 'Heavy Vehicle Towing', 'Accident Recovery'],
    'Fuel Delivery': ['Petrol Delivery', 'Diesel Delivery', 'Emergency Fuel'],
    'Tire Service': ['Tire Change', 'Tire Repair', 'Tire Installation'],
    'Battery Service': ['Battery Jump Start', 'Battery Replacement', 'Battery Testing'],
    'Emergency Locksmith': ['Car Unlock', 'Key Duplication', 'Lock Repair']
  };

  @override
  void dispose() {
    _businessNameController.dispose();
    _registrationNumberController.dispose();
    _panNumberController.dispose();
    _aadharNumberController.dispose();
    _experienceController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String documentType) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          switch (documentType) {
            case 'business_license':
              _businessLicenseImage = File(image.path);
              break;
            case 'pan_card':
              _panCardImage = File(image.path);
              break;
            case 'aadhar_card':
              _aadharCardImage = File(image.path);
              break;
            case 'profile_picture':
              _profilePicture = File(image.path);
              break;
            case 'vehicle_registration':
              _vehicleRegistrationImage = File(image.path);
              break;
            case 'driving_license':
              _drivingLicenseImage = File(image.path);
              break;
          }
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking image: $e');
    }
  }

  Future<void> _submitDocuments() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_profilePicture == null || _panCardImage == null || _aadharCardImage == null) {
      _showErrorSnackBar('Please upload all required documents');
      return;
    }

    if (_selectedServices.isEmpty) {
      _showErrorSnackBar('Please select at least one service');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create verification data
      Map<String, dynamic> verificationData = {
        'business_name': _businessNameController.text.trim(),
        'registration_number': _registrationNumberController.text.trim(),
        'pan_number': _panNumberController.text.trim(),
        'aadhar_number': _aadharNumberController.text.trim(),
        'experience_years': int.tryParse(_experienceController.text) ?? 0,
        'address': _addressController.text.trim(),
        'service_type': _selectedServiceType,
        'selected_services': _selectedServices,
        'submission_date': DateTime.now().toIso8601String(),
        'status': 'pending',
      };

      // Here you would typically upload images to storage and submit data to backend
      // For now, we'll simulate the process
      await _simulateDocumentSubmission(verificationData);

      _showSuccessDialog();
    } catch (e) {
      _showErrorSnackBar('Submission failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _simulateDocumentSubmission(Map<String, dynamic> data) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    // In a real app, you would:
    // 1. Upload images to cloud storage
    // 2. Submit form data to backend
    // 3. Handle response and errors

    print('Document verification data submitted: $data');
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 30),
              SizedBox(width: 10),
              Text('Success!'),
            ],
          ),
          content: const Text(
            'Your documents have been submitted successfully. Our team will review them within 24-48 hours and notify you via email.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to previous screen
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDocumentUploadCard({
    required String title,
    required String documentType,
    required File? image,
    bool isRequired = true,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isRequired)
                  const Text(
                    ' *',
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (image != null)
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    image,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: 40,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap to upload',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(documentType),
                icon: Icon(image != null ? Icons.refresh : Icons.camera_alt),
                label: Text(image != null ? 'Retake Photo' : 'Take Photo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: image != null ? Colors.orange : Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceSelection() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Services Offered *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedServiceType,
              decoration: const InputDecoration(
                labelText: 'Primary Service Type',
                border: OutlineInputBorder(),
              ),
              items: _serviceTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedServiceType = newValue;
                    _selectedServices.clear();
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Specific Services:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableServices[_selectedServiceType]?.map((service) {
                final isSelected = _selectedServices.contains(service);
                return FilterChip(
                  label: Text(service),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedServices.add(service);
                      } else {
                        _selectedServices.remove(service);
                      }
                    });
                  },
                  selectedColor: Colors.blue.shade100,
                  checkmarkColor: Colors.blue,
                );
              }).toList() ?? [],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Verification'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complete Your Profile Verification',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please provide accurate information and clear photos of your documents. All information will be verified by our team.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Personal Information
              const Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _businessNameController,
                decoration: const InputDecoration(
                  labelText: 'Business/Service Name',
                  hintText: 'Enter your business name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Business name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _registrationNumberController,
                decoration: const InputDecoration(
                  labelText: 'Business Registration Number (Optional)',
                  hintText: 'Enter registration number if available',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _panNumberController,
                      decoration: const InputDecoration(
                        labelText: 'PAN Number',
                        hintText: 'ABCDE1234F',
                        border: OutlineInputBorder(),
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(10),
                        UpperCaseTextFormatter(),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'PAN number is required';
                        }
                        if (value.length != 10) {
                          return 'PAN must be 10 characters';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _aadharNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Aadhar Number',
                        hintText: '1234 5678 9012',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(12),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Aadhar number is required';
                        }
                        if (value.length != 12) {
                          return 'Aadhar must be 12 digits';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _experienceController,
                      decoration: const InputDecoration(
                        labelText: 'Years of Experience',
                        hintText: 'e.g., 5',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Experience is required';
                        }
                        final exp = int.tryParse(value);
                        if (exp == null || exp < 1) {
                          return 'Enter valid experience';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _isExperienceVerified,
                            onChanged: (bool? value) {
                              setState(() {
                                _isExperienceVerified = value ?? false;
                              });
                            },
                          ),
                          const Expanded(
                            child: Text(
                              'Experience verified by previous employers',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Service Address',
                  hintText: 'Enter your complete service address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Address is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Service Selection
              _buildServiceSelection(),
              const SizedBox(height: 20),

              // Document Upload Section
              const Text(
                'Document Upload',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              _buildDocumentUploadCard(
                title: 'Profile Picture',
                documentType: 'profile_picture',
                image: _profilePicture,
              ),

              _buildDocumentUploadCard(
                title: 'PAN Card',
                documentType: 'pan_card',
                image: _panCardImage,
              ),

              _buildDocumentUploadCard(
                title: 'Aadhar Card',
                documentType: 'aadhar_card',
                image: _aadharCardImage,
              ),

              _buildDocumentUploadCard(
                title: 'Business License (Optional)',
                documentType: 'business_license',
                image: _businessLicenseImage,
                isRequired: false,
              ),

              if (_selectedServiceType == 'Towing Service') ...[
                _buildDocumentUploadCard(
                  title: 'Vehicle Registration',
                  documentType: 'vehicle_registration',
                  image: _vehicleRegistrationImage,
                ),
                _buildDocumentUploadCard(
                  title: 'Driving License',
                  documentType: 'driving_license',
                  image: _drivingLicenseImage,
                ),
              ],

              const SizedBox(height: 20),

              // Terms and Conditions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📋 Important Notes:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• All documents will be verified within 24-48 hours\n'
                          '• Ensure all photos are clear and readable\n'
                          '• False information may lead to account suspension\n'
                          '• You will be notified via email about verification status',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitDocuments,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const Row(
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
                      Text('Submitting...'),
                    ],
                  )
                      : const Text(
                    'Submit Documents',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom formatter to convert text to uppercase
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}