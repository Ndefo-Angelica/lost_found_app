import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../widgets/gradient_button.dart';
import '../theme/colors.dart';
import '../providers/auth_provider.dart';
import '../providers/items_provider.dart';
import '../models/item_model.dart';

class ReportItemScreen extends StatefulWidget {
  const ReportItemScreen({super.key});

  @override
  State<ReportItemScreen> createState() => _ReportItemScreenState();
}

class _ReportItemScreenState extends State<ReportItemScreen> {
  String reportType = 'lost';
  String? category;
  String? city;
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  String? date;
  
  // Image picker
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool _isUploading = false;
  
  // Location
  double? _latitude;
  double? _longitude;
  String? _currentAddress;
  bool _isGettingLocation = false;

  final List<String> categories = [
    'Electronics',
    'Accessories',
    'Documents & IDs',
    'Bags & Luggage',
    'Clothing',
    'Jewelry',
    'Keys',
    'Other',
  ];

  final List<String> cities = [
    'Yaoundé',
    'Douala',
    'Buea',
    'Bamenda',
    'Garoua',
    'Limbe',
    'Bafoussam',
    'Ngaoundéré',
  ];

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null && mounted) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        _showError('Error picking image: $e');
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);

    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            _showError('Location permissions are denied');
          }
          setState(() => _isGettingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          _showError('Location permissions are permanently denied');
        }
        setState(() => _isGettingLocation = false);
        return;
      }

      // Get current position - FIXED: Use LocationSettings
      LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
      );
      
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
        });
      }

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        Placemark place = placemarks[0];
        setState(() {
          _currentAddress = '${place.street}, ${place.locality}, ${place.country}';
          locationController.text = _currentAddress ?? '';
          
          // Auto-select city if it matches our list
          if (place.locality != null) {
            final matchedCity = cities.firstWhere(
              (c) => c.toLowerCase().contains(place.locality!.toLowerCase()),
              orElse: () => '',
            );
            if (matchedCity.isNotEmpty) {
              city = matchedCity;
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        _showError('Error getting location: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isGettingLocation = false);
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && mounted) {
      setState(() {
        date = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _submitReport() async {
    // Validate required fields
    if (titleController.text.isEmpty) {
      _showError('Please enter item title');
      return;
    }
    
    if (descriptionController.text.isEmpty) {
      _showError('Please enter description');
      return;
    }
    
    if (city == null) {
      _showError('Please select a city');
      return;
    }
    
    if (category == null) {
      _showError('Please select a category');
      return;
    }
    
    if (date == null) {
      _showError('Please select the date');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (!authProvider.isAuthenticated) {
      if (mounted) {
        _showError('Please login to report an item');
        Navigator.pushNamed(context, '/login');
      }
      return;
    }

    setState(() => _isUploading = true);

    try {
      final itemsProvider = Provider.of<ItemsProvider>(context, listen: false);
      
      // Parse date
      final dateParts = date!.split('/');
      final itemDate = DateTime(
        int.parse(dateParts[2]),
        int.parse(dateParts[1]),
        int.parse(dateParts[0]),
      );

      // Create item
      final item = ItemModel(
        id: const Uuid().v4(),
        userId: authProvider.currentUser!.id,
        title: titleController.text,
        description: descriptionController.text,
        location: city!,
        specificLocation: locationController.text.isNotEmpty 
            ? locationController.text 
            : city!,
        latitude: _latitude,
        longitude: _longitude,
        date: itemDate,
        status: reportType,
        category: category!,
        imageUrl: _selectedImage?.path, // In real app, this would be uploaded URL
        reporterName: authProvider.currentUser!.name,
        reporterPhone: authProvider.currentUser!.phone,
        reporterRating: authProvider.currentUser!.rating,
        reporterVerified: authProvider.currentUser!.verified,
        reporterReports: authProvider.currentUser!.reports,
        createdAt: DateTime.now(),
      );

      final success = await itemsProvider.createItem(item);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item reported successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pushReplacementNamed(context, '/items');
      }
    } catch (e) {
      if (mounted) {
        _showError('Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Item'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report Type
            const Text(
              'Report Type',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTypeButton(
                    type: 'lost',
                    label: 'Lost Item',
                    colors: const [AppColors.error, AppColors.errorDark],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTypeButton(
                    type: 'found',
                    label: 'Found Item',
                    colors: const [AppColors.success, AppColors.successDark],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Category
            const Text(
              'Category',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.outlineVariant),
                borderRadius: BorderRadius.circular(16),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: category,
                  hint: const Text('Select category'),
                  isExpanded: true,
                  items: categories.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      category = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // City
            const Text(
              'City in Cameroon',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.outlineVariant),
                borderRadius: BorderRadius.circular(16),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: city,
                  hint: const Text('Select city'),
                  isExpanded: true,
                  items: cities.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text('📍 $value'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      city = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Item Title
            const Text(
              'Item Title',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'e.g., Black Leather Wallet',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Description
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Provide detailed description...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Date
            Text(
              'Date ${reportType == 'lost' ? 'Lost' : 'Found'}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _selectDate,
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Select date',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  controller: TextEditingController(text: date ?? ''),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Location with GPS
            const Text(
              'Specific Location',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: locationController,
                    decoration: InputDecoration(
                      hintText: 'e.g., Near Total Station, Bastos',
                      prefixIcon: const Icon(Icons.location_on),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: _isGettingLocation
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.my_location, color: Colors.white),
                    onPressed: _isGettingLocation ? null : _getCurrentLocation,
                  ),
                ),
              ],
            ),
            if (_latitude != null && _longitude != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '📍 Coordinates: $_latitude, $_longitude',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.primary,
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Upload Image
            const Text(
              'Upload Photo',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.outlineVariant, width: 2),
                  borderRadius: BorderRadius.circular(16),
                  image: _selectedImage != null
                      ? DecorationImage(
                          image: FileImage(File(_selectedImage!.path)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _selectedImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryDark],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_photo_alternate,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Add Photo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Tap to upload image (optional)',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              image: DecorationImage(
                                image: FileImage(File(_selectedImage!.path)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    _selectedImage = null;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            GradientButton(
              text: _isUploading ? 'Submitting...' : 'Submit Report',
              onPressed: _isUploading ? null : _submitReport,
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton({
    required String type,
    required String label,
    required List<Color> colors,
  }) {
    final isSelected = reportType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          reportType = type;
        });
      },
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: colors)
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colors.first : AppColors.outlineVariant,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.first.withValues(alpha: 0.3),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}