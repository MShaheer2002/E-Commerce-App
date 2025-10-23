
// Provider Class
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileSetupProvider extends ChangeNotifier {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String _selectedGender = '';
  String _completePhoneNumber = '';
  DateTime? _dateOfBirth;

  File? get profileImage => _profileImage;
  String get selectedGender => _selectedGender;
  String get completePhoneNumber => _completePhoneNumber;

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image != null) {
        _profileImage = File(image.path);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void setGender(String gender) {
    _selectedGender = gender;
    notifyListeners();
  }

  void setPhoneNumber(String phoneNumber) {
    _completePhoneNumber = phoneNumber;
    notifyListeners();
  }

  void setDateOfBirth(DateTime date) {
    _dateOfBirth = date;
    dobController.text = '${date.day}/${date.month}/${date.year}';
    notifyListeners();
  }

  bool validateForm() {
    return nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        dobController.text.isNotEmpty &&
        _selectedGender.isNotEmpty &&
        _completePhoneNumber.isNotEmpty &&
        addressController.text.isNotEmpty;
  }

  void updateProfile() {
    // Implement your profile update logic here
    debugPrint('Profile Updated!');
    debugPrint('Name: ${nameController.text}');
    debugPrint('Email: ${emailController.text}');
    debugPrint('DOB: ${dobController.text}');
    debugPrint('Gender: $_selectedGender');
    debugPrint('Phone: $_completePhoneNumber');
    debugPrint('Address: ${addressController.text}');
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    dobController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }
}
