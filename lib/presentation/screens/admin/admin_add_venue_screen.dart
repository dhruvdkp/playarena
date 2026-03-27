import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gamebooking/core/constants/app_colors.dart';
import 'package:gamebooking/data/models/venue_model.dart';
import 'package:gamebooking/data/services/firestore_service.dart';

class AdminAddVenueScreen extends StatefulWidget {
  final String? venueId;
  const AdminAddVenueScreen({super.key, this.venueId});

  @override
  State<AdminAddVenueScreen> createState() => _AdminAddVenueScreenState();
}

class _AdminAddVenueScreenState extends State<AdminAddVenueScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _priceController = TextEditingController();
  final _peakPriceController = TextEditingController();
  final _happyHourPriceController = TextEditingController();
  final _rulesController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploading = false;

  String _openTime = '06:00';
  String _closeTime = '23:00';
  final List<String> _imageUrls = [];
  final Set<SportType> _selectedSports = {};
  final Set<Amenity> _selectedAmenities = {};
  bool _isLoading = false;
  bool _isEditing = false;
  VenueModel? _existingVenue;

  @override
  void initState() {
    super.initState();
    if (widget.venueId != null) {
      _isEditing = true;
      _loadVenue();
    }
  }

  Future<void> _loadVenue() async {
    setState(() => _isLoading = true);
    try {
      final data = await _firestoreService.getVenueById(widget.venueId!);
      if (data != null) {
        final venue = VenueModel.fromJson(data);
        _existingVenue = venue;
        _nameController.text = venue.name;
        _descriptionController.text = venue.description;
        _addressController.text = venue.address;
        _cityController.text = venue.city;
        _contactPhoneController.text = venue.contactPhone;
        _priceController.text = venue.pricePerHour.toStringAsFixed(0);
        _peakPriceController.text = venue.peakPricePerHour.toStringAsFixed(0);
        _happyHourPriceController.text = venue.happyHourPrice.toStringAsFixed(
          0,
        );
        _openTime = venue.openTime;
        _closeTime = venue.closeTime;
        _imageUrls.addAll(venue.imageUrls);
        _selectedSports.addAll(venue.sportTypes);
        _selectedAmenities.addAll(venue.amenities);
        _rulesController.text = venue.rules;
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _contactPhoneController.dispose();
    _priceController.dispose();
    _peakPriceController.dispose();
    _happyHourPriceController.dispose();
    _rulesController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isOpen) async {
    final parts = (isOpen ? _openTime : _closeTime).split(':');
    final initial = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accentYellow,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        if (isOpen) {
          _openTime = formatted;
        } else {
          _closeTime = formatted;
        }
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        await _uploadImage(File(pickedFile.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickMultipleImages() async {
    try {
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      for (final file in pickedFiles) {
        await _uploadImage(File(file.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick images: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    setState(() => _isUploading = true);
    try {
      final fileName =
          'venues/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final ref = FirebaseStorage.instance.ref().child(fileName);
      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      setState(() {
        _imageUrls.add(downloadUrl);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
    setState(() => _isUploading = false);
  }

  Future<void> _saveVenue() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedSports.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one sport'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final venueData = {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'address': _addressController.text.trim(),
      'city': _cityController.text.trim(),
      'latitude': _existingVenue?.latitude ?? 23.0225,
      'longitude': _existingVenue?.longitude ?? 72.5714,
      'imageUrls': _imageUrls,
      'sportTypes': _selectedSports.map((e) => e.name).toList(),
      'amenities': _selectedAmenities.map((e) => e.name).toList(),
      'rating': _existingVenue?.rating ?? 0.0,
      'totalReviews': _existingVenue?.totalReviews ?? 0,
      'pricePerHour': double.tryParse(_priceController.text) ?? 0,
      'peakPricePerHour': double.tryParse(_peakPriceController.text) ?? 0,
      'happyHourPrice': double.tryParse(_happyHourPriceController.text) ?? 0,
      'openTime': _openTime,
      'closeTime': _closeTime,
      'isVerified': _existingVenue?.isVerified ?? true,
      'ownerId': _existingVenue?.ownerId ?? 'admin',
      'contactPhone': _contactPhoneController.text.trim(),
      'availableSlots': _existingVenue?.availableSlots ?? 0,
      'totalSlots': _existingVenue?.totalSlots ?? 0,
      'rules': _rulesController.text.trim(),
    };

    try {
      if (_isEditing && widget.venueId != null) {
        await _firestoreService.updateVenue(widget.venueId!, venueData);
      } else {
        await _firestoreService.createVenue(venueData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Venue updated!' : 'Venue created!'),
            backgroundColor: AppColors.actionGreen,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
          ),
        ),
        title: Text(
          _isEditing ? 'Edit Venue' : 'Add New Venue',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _isLoading && _isEditing && _existingVenue == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accentYellow),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Basic Information'),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _nameController,
                      label: 'Venue Name',
                      hint: 'e.g. Arena Sports Hub',
                      icon: Icons.stadium,
                      validator: (v) =>
                          v?.trim().isEmpty == true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      hint: 'Describe your venue...',
                      icon: Icons.description,
                      maxLines: 3,
                      validator: (v) =>
                          v?.trim().isEmpty == true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _addressController,
                      label: 'Address',
                      hint: 'Full address',
                      icon: Icons.location_on,
                      validator: (v) =>
                          v?.trim().isEmpty == true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _cityController,
                            label: 'City',
                            hint: 'City',
                            icon: Icons.location_city,
                            validator: (v) =>
                                v?.trim().isEmpty == true ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _contactPhoneController,
                            label: 'Contact Phone',
                            hint: '+91...',
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    _sectionTitle('Images'),
                    const SizedBox(height: 12),
                    _buildImageSection(),

                    const SizedBox(height: 24),
                    _sectionTitle('Sports Available'),
                    const SizedBox(height: 12),
                    _buildSportSelector(),

                    const SizedBox(height: 24),
                    _sectionTitle('Amenities'),
                    const SizedBox(height: 12),
                    _buildAmenitySelector(),

                    const SizedBox(height: 24),
                    _sectionTitle('Pricing (\u20B9)'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _priceController,
                            label: 'Regular / hr',
                            hint: '800',
                            icon: Icons.currency_rupee,
                            keyboardType: TextInputType.number,
                            validator: (v) =>
                                v?.trim().isEmpty == true ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _peakPriceController,
                            label: 'Peak / hr',
                            hint: '1200',
                            icon: Icons.trending_up,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _happyHourPriceController,
                            label: 'Happy hr',
                            hint: '600',
                            icon: Icons.local_offer,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    _sectionTitle('Operating Hours'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimePicker('Open Time', _openTime, true),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTimePicker(
                            'Close Time',
                            _closeTime,
                            false,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    _sectionTitle('Rules & Guidelines'),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _rulesController,
                      label: 'Rules',
                      hint:
                          'e.g. No metal studs\nCarry your own water\nMax 12 players per slot',
                      icon: Icons.rule,
                      maxLines: 4,
                    ),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveVenue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.actionGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                _isEditing ? 'Update Venue' : 'Create Venue',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.accentYellow,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        // Pick image buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isUploading ? null : () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library, size: 20),
                label: const Text('Gallery'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accentYellow,
                  side: const BorderSide(color: AppColors.accentYellow),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isUploading ? null : () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt, size: 20),
                label: const Text('Camera'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accentYellow,
                  side: const BorderSide(color: AppColors.accentYellow),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isUploading ? null : _pickMultipleImages,
                icon: const Icon(Icons.collections, size: 20),
                label: const Text('Multi'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.actionGreen,
                  side: const BorderSide(color: AppColors.actionGreen),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
        // Upload progress
        if (_isUploading) ...[
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.accentYellow,
                ),
              ),
              SizedBox(width: 10),
              Text(
                'Uploading image...',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
        // Image previews
        if (_imageUrls.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _imageUrls.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        _imageUrls[index],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 100,
                          height: 100,
                          color: AppColors.card,
                          child: const Icon(
                            Icons.broken_image,
                            color: AppColors.textDisabled,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => setState(() => _imageUrls.removeAt(index)),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSportSelector() {
    final sportLabels = {
      SportType.boxCricket: ('Box Cricket', Icons.sports_cricket),
      SportType.football: ('Football', Icons.sports_soccer),
      SportType.pickleball: ('Pickleball', Icons.sports_tennis),
      SportType.badminton: ('Badminton', Icons.sports_tennis),
      SportType.tennis: ('Tennis', Icons.sports_tennis),
    };

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: SportType.values.map((sport) {
        final selected = _selectedSports.contains(sport);
        final info = sportLabels[sport]!;
        return FilterChip(
          label: Text(info.$1),
          avatar: Icon(
            info.$2,
            size: 16,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
          selected: selected,
          onSelected: (val) {
            setState(() {
              if (val) {
                _selectedSports.add(sport);
              } else {
                _selectedSports.remove(sport);
              }
            });
          },
          selectedColor: AppColors.actionGreen,
          backgroundColor: AppColors.surface,
          checkmarkColor: Colors.white,
          labelStyle: TextStyle(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          side: BorderSide(
            color: selected ? AppColors.actionGreen : AppColors.divider,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAmenitySelector() {
    final amenityLabels = {
      Amenity.parking: ('Parking', Icons.local_parking),
      Amenity.cctv: ('CCTV', Icons.videocam),
      Amenity.shower: ('Shower', Icons.shower),
      Amenity.drinkingWater: ('Water', Icons.water_drop),
      Amenity.changingRoom: ('Changing Room', Icons.checkroom),
      Amenity.cafeteria: ('Cafeteria', Icons.local_cafe),
      Amenity.firstAid: ('First Aid', Icons.medical_services),
      Amenity.wifi: ('WiFi', Icons.wifi),
      Amenity.floodlights: ('Floodlights', Icons.light),
      Amenity.scoreboard: ('Scoreboard', Icons.scoreboard),
    };

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: Amenity.values.map((amenity) {
        final selected = _selectedAmenities.contains(amenity);
        final info = amenityLabels[amenity]!;
        return FilterChip(
          label: Text(info.$1),
          avatar: Icon(
            info.$2,
            size: 16,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
          selected: selected,
          onSelected: (val) {
            setState(() {
              if (val) {
                _selectedAmenities.add(amenity);
              } else {
                _selectedAmenities.remove(amenity);
              }
            });
          },
          selectedColor: AppColors.accentYellow.withValues(alpha: 0.8),
          backgroundColor: AppColors.surface,
          checkmarkColor: Colors.white,
          labelStyle: TextStyle(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          side: BorderSide(
            color: selected ? AppColors.accentYellow : AppColors.divider,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimePicker(String label, String time, bool isOpen) {
    return GestureDetector(
      onTap: () => _pickTime(isOpen),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Icon(
              isOpen ? Icons.access_time : Icons.access_time_filled,
              color: AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
