import 'package:e_commerce_app/core/common_widgets.dart/common_widgets.dart';
import 'package:e_commerce_app/core/themes/constantsColors.dart';
import 'package:e_commerce_app/presentation/providers/profile_setup_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';

// Profile Setup Screen
class ProfileSetup extends StatelessWidget {
  const ProfileSetup({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileSetupProvider(),
      child: const ProfileSetupView(),
    );
  }
}

class ProfileSetupView extends StatelessWidget {
  const ProfileSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevents background from moving
      body: GestureDetector(
        onTap: () =>
            FocusScope.of(context).unfocus(), // Dismiss keyboard on tap outside
        child: Stack(
          children: [
            // Background that doesn't move
            const Positioned.fill(
              child: Background(),
            ),

            // Content
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: height - MediaQuery.of(context).padding.top,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: height * 0.03,
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: height * 0.02),

                          // Profile Image Section
                          const ProfileImagePicker(),

                          SizedBox(height: height * 0.04),

                          // Form Fields
                          const ProfileForm(),

                          const Spacer(),

                          SizedBox(height: height * 0.02),

                          // Update Button
                          Consumer<ProfileSetupProvider>(
                            builder: (context, provider, _) {
                              return CustomButton(
                                onPressed: () {
                                  if (provider.validateForm()) {
                                    provider.updateProfile();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Profile updated successfully!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Please fill all required fields'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                child: const Text(
                                  'Update Profile',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            },
                          ),

                          SizedBox(height: height * 0.02),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Profile Image Picker Widget
class ProfileImagePicker extends StatelessWidget {
  const ProfileImagePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileSetupProvider>(
      builder: (context, provider, _) {
        return Stack(
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: provider.profileImage != null
                    ? Image.file(
                        provider.profileImage!,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey[600],
                        ),
                      ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _showImageSourceDialog(context, provider),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: KprimaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showImageSourceDialog(
      BuildContext context, ProfileSetupProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: KprimaryColor),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  provider.pickImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: KprimaryColor),
                title: const Text('Take a Photo'),
                onTap: () {
                  provider.pickImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Profile Form Widget
class ProfileForm extends StatelessWidget {
  const ProfileForm({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileSetupProvider>(context, listen: false);

    return Column(
      children: [
        CustomTextField(
          icon: Icons.person_outline,
          hintText: "Name",
          controller: provider.nameController,
        ),
        const SizedBox(height: 16),

        CustomTextField(
          controller: provider.emailController,
          hintText: 'Email',
          keyboardType: TextInputType.emailAddress,
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 16),

        GestureDetector(
          onTap: () => _selectDate(context, provider),
          child: AbsorbPointer(
            child: CustomTextField(
              controller: provider.dobController,
              hintText: 'Date of Birth',
              icon: Icons.calendar_month,
            ),
          ),
        ),
        const SizedBox(height: 16),

        Consumer<ProfileSetupProvider>(
          builder: (context, prov, _) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonFormField<String>(
                value: prov.selectedGender.isEmpty ? null : prov.selectedGender,
                decoration: const InputDecoration(
                  hintText: 'Gender',
                  border: InputBorder.none,
                ),
                items: ['Male', 'Female', 'Other']
                    .map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) prov.setGender(value);
                },
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        // Phone Number Field with Country Code
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IntlPhoneField(
            controller: provider.phoneController,
            decoration: const InputDecoration(
              hintText: 'Phone Number',
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            initialCountryCode: 'PK',
            onChanged: (phone) {
              provider.setPhoneNumber(phone.completeNumber);
            },
          ),
        ),
        const SizedBox(height: 16),

        CustomTextField(
          icon: Icons.location_on_outlined,
          controller: provider.addressController,
          hintText: 'Address',
        ),
      ],
    );
  }

  Future<void> _selectDate(
      BuildContext context, ProfileSetupProvider provider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: KprimaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      provider.setDateOfBirth(picked);
    }
  }
}
