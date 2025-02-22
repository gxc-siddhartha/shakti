import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shakti/core/helpers/ImagePickerHelper.dart';
import 'package:shakti/core/router/RouterConstants.dart';
import 'package:shakti/features/auth/controllers/AuthController.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final AuthController _authController = Get.find<AuthController>();

  String name = "";
  String age = "";

  String city = "";
  String state = "";

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

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
      _nameController.text.isNotEmpty &&
      _ageController.text.isNotEmpty &&
      _cityController.text.isNotEmpty &&
      _stateController.text.isNotEmpty;

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

  void _validateAge(String value) {
    setState(() {
      if (value.isEmpty) {
        _ageError = 'Age is required';
      } else {
        try {
          final age = int.parse(value);
          if (age < 12) {
            _ageError = 'You must be at least 13 years old';
          } else if (age > 30) {
            _ageError = 'You are not valid for registration';
          } else {
            _ageError = null;
            this.age = value;
          }
        } catch (e) {
          _ageError = 'Please enter a valid number';
        }
      }
    });
  }

  void _validateCity(String value) {
    setState(() {
      if (value.isEmpty) {
        _cityError = 'City is required';
      } else if (value.length < 2) {
        _cityError = 'City name must be at least 2 characters';
      } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
        _cityError = 'City can only contain letters and spaces';
      } else {
        _cityError = null;
        city = value;
      }
    });
  }

  void _validateState(String value) {
    setState(() {
      if (value.isEmpty) {
        _stateError = 'State is required';
      } else if (value.length < 2) {
        _stateError = 'State name must be at least 2 characters';
      } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
        _stateError = 'State can only contain letters and spaces';
      } else {
        _stateError = null;
        state = value;
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
    _ageController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("")),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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

                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),

                    Row(
                      children: [
                        Column(
                          children: [
                            IconButton(
                              onPressed: _showImagePickerOptions,
                              icon: Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
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
                                  color: Theme.of(context).colorScheme.error,
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
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.5),
                                  ),
                                  filled: true,
                                  fillColor: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.05),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _ageController,
                                onChanged: _validateAge,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(3),
                                ],
                                decoration: InputDecoration(
                                  hintText: 'Age',
                                  errorText: _ageError,
                                  hintStyle: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.5),
                                  ),
                                  filled: true,
                                  fillColor: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.05),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),

                    TextField(
                      controller: _cityController,
                      onChanged: _validateCity,
                      decoration: InputDecoration(
                        hintText: 'City',
                        errorText: _cityError,
                        hintStyle: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.5),
                        ),
                        filled: true,
                        fillColor: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    TextField(
                      controller: _stateController,
                      onChanged: _validateState,
                      decoration: InputDecoration(
                        hintText: 'State',
                        errorText: _stateError,
                        hintStyle: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.5),
                        ),
                        filled: true,
                        fillColor: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            isFormValid
                                ? () {
                                  if (_formKey.currentState!.validate()) {
                                    _authController
                                        .activeUser!
                                        .value = _authController
                                        .activeUser!
                                        .value
                                        .copyWith(
                                          name: name,
                                          age: age,
                                          state: state,
                                          city: city,
                                        );
                                    _authController.selectedImage.value = File(
                                      _selectedImage!.path,
                                    );

                                    print(
                                      "Step 2 Completed: User Registration Progressed - Values: ${_authController.activeUser!.value.toString()}, Password: ${_authController.password.value}",
                                    );

                                    context.goNamed(
                                      RouterConstants
                                          .educationalDetailsScreenRouteName,
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
                            borderRadius: BorderRadius.circular(12),
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

                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
