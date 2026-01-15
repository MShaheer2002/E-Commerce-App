import 'dart:developer';

import 'package:ProductPlug/core/common_widgets.dart/common_widgets.dart';
import 'package:ProductPlug/core/themes/constantsColors.dart';
import 'package:ProductPlug/presentation/providers/cache_provider.dart';
import 'package:ProductPlug/presentation/providers/profile_setup_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';

class ProfileSetupView extends StatefulWidget {
  const ProfileSetupView({super.key});

  @override
  State<ProfileSetupView> createState() => _ProfileSetupViewState();
}

class _ProfileSetupViewState extends State<ProfileSetupView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = context.read<ProfileSetupProvider>();
      final cache = context.read<CacheProvider>();
      provider.loadUserProfile(cache);
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // Background
            const Positioned.fill(
              child: Background(),
            ),

            // Content
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: height - MediaQuery.of(context).padding.top,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: height * 0.03),
                      child: Column(
                        children: [
                          SizedBox(height: height * 0.02),

                          // Profile Image
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
                                onPressed: (provider.isLoading ||
                                        provider.isUploading)
                                    ? () {}
                                    : () {
                                        if (provider.validateForm()) {
                                          provider
                                              .saveUserProfile(
                                                  context.read<CacheProvider>())
                                              .then((_) {
                                            if (context.mounted) {
                                              context.pop();
                                            }
                                          });
                                        } else {
                                          Fluttertoast.showToast(
                                            msg: 'Please fill required fields!',
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                          );
                                        }
                                      },
                                child:
                                    provider.isLoading || provider.isUploading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'Update Profile',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
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

            // Upload Progress Overlay
            Consumer<ProfileSetupProvider>(
              builder: (context, provider, _) {
                if (provider.isUploading) {
                  return Container(
                    color: Colors.black54,
                    child: Center(
                      child: Card(
                        margin: const EdgeInsets.all(20),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              Text(
                                'Uploading image...',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              if (provider.uploadProgress > 0)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    '${(provider.uploadProgress * 100).toStringAsFixed(0)}%',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------- Profile Image Picker ---------------------------
class ProfileImagePicker extends StatelessWidget {
  const ProfileImagePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileSetupProvider>(
      builder: (context, provider, _) {
        log("[Profile Setup Provider] ${provider.imageUrl}");

        return Stack(
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
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
                    : provider.imageUrl != null && provider.imageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: provider.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey[600],
                              ),
                            ),
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
                    border: Border.all(color: Colors.white, width: 2),
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
    BuildContext context,
    ProfileSetupProvider provider,
  ) {
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

        // CustomTextField(
        //   controller: provider.emailController,
        //   hintText: 'Email',
        //   keyboardType: TextInputType.emailAddress,
        //   icon: Icons.email_outlined,
        //   readOnly: true,
        // ),
        // const SizedBox(height: 16),

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
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonFormField<String>(
                initialValue:
                    prov.selectedGender.isEmpty ? null : prov.selectedGender,
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

        // Phone Field
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
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
            initialCountryCode: 'US',
            onChanged: (phone) {
              // provider.phoneController.text = phone.completeNumber;
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
    BuildContext context,
    ProfileSetupProvider provider,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: KprimaryColor),
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
