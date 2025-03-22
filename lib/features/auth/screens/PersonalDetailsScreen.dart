import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shakti/core/helpers/ImagePickerHelper.dart';
import 'package:shakti/features/auth/controllers/AuthController.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final AuthController _authController = Get.find<AuthController>();

  String name = "";

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  XFile? _selectedImage;
  String? _nameError;
  String? _ageError;
  String? _cityError;
  String? _stateError;
  String? _imageError;

  bool get isFormValid =>
      _selectedImage != null &&
      _nameError == null &&
      _ageError == null &&
      _cityError == null &&
      _stateError == null &&
      _nameController.text.isNotEmpty;

  void _validateName(String value) {
    setState(() {
      if (value.isEmpty) {
        _nameError = 'Name is required';
      } else if (value.length < 2) {
        _nameError = 'Name must be at least 2 characters';
      } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
        _nameError = 'Name can only contain letters and spaces';
      } else {
        _nameError = null;
        name = value;
      }
    });
  }

  Future<void> _pickImage() async {
    final image = await ImageHelper.instance.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _imageError = null;
      });
    }
  }

  Future<void> _takePhoto() async {
    final photo = await ImageHelper.instance.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    if (photo != null) {
      setState(() {
        _selectedImage = photo;
        _imageError = null;
      });
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Text(
                          'Personal Details',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'We need some personal details about you, so that we can understand your background.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.5),
                            height: 1.5,
                          ),
                        ),

                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05,
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                TextButton(
                                  onPressed: _showImagePickerOptions,
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(200),
                                      border:
                                          _imageError != null
                                              ? Border.all(
                                                color: Colors.red,
                                                width: 2,
                                              )
                                              : null,
                                      image:
                                          _selectedImage != null
                                              ? DecorationImage(
                                                image: FileImage(
                                                  File(_selectedImage!.path),
                                                ),
                                                fit: BoxFit.cover,
                                              )
                                              : null,
                                    ),
                                    child:
                                        _selectedImage == null
                                            ? Center(
                                              child: Icon(
                                                Icons.camera_alt,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                              ),
                                            )
                                            : null,
                                  ),
                                ),
                                if (_imageError != null)
                                  Text(
                                    _imageError!,
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.error,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.height * 0.01,
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  TextField(
                                    controller: _nameController,
                                    onChanged: _validateName,
                                    decoration: InputDecoration(
                                      hintText: 'Name',
                                      errorText: _nameError,
                                      hintStyle: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.5),
                                      ),
                                      filled: true,
                                      fillColor: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.05),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 16,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05,
                        ),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                isFormValid
                                    ? () async {
                                      if (_formKey.currentState!.validate()) {
                                        _authController
                                            .activeUser
                                            .value = _authController
                                            .activeUser
                                            .value
                                            .copyWith(name: name);
                                        _authController
                                            .selectedImage
                                            .value = File(_selectedImage!.path);

                                        await _authController.registerUser(
                                          context: context,
                                        );

                                        print(
                                          "Step 2 Completed: User Registration Progressed - Values: ${_authController.activeUser.value.toString()}, Password: ${_authController.password.value}",
                                        );
                                      }
                                    }
                                    : null,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,

                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: const Text(
                              'Next',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Obx(
              () =>
                  _authController.isLoading.value
                      ? Container(
                        color: Theme.of(
                          context,
                        ).colorScheme.surface.withOpacity(0.2),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      )
                      : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
