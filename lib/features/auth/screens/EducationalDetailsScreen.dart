import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shakti/core/helpers/HelperWidgets.dart';
import 'package:shakti/features/auth/controllers/AuthController.dart';

class EducationDetailsScreen extends StatefulWidget {
  const EducationDetailsScreen({super.key});

  @override
  State<EducationDetailsScreen> createState() => _EducationDetailsScreenState();
}

class _EducationDetailsScreenState extends State<EducationDetailsScreen> {
  final _authController = Get.find<AuthController>();

  String schoolName = "";
  String? selectedStandard;
  String? selectedBoard;
  final _formKey = GlobalKey<FormState>();
  final _schoolController = TextEditingController();
  bool _autovalidateMode = false;

  // For small sets, directly declaring the items is more efficient
  final List<String> standards = ["11th", "12th"];
  final List<String> boards = ["CBSE", "ICSE"];

  @override
  void dispose() {
    _schoolController.dispose();
    super.dispose();
  }

  bool get isFormValid {
    return _schoolController.text.trim().isNotEmpty &&
        selectedBoard != null &&
        selectedStandard != null;
  }

  void _handleSubmit() {
    setState(() {
      _autovalidateMode = true;
    });

    if (_formKey.currentState!.validate() && isFormValid) {
      _authController.activeUser!.value = _authController.activeUser!.value
          .copyWith(
            schoolName: schoolName,
            board: selectedBoard,
            standard: selectedStandard,
          );
      _authController.registerUser(context: context);
      print(
        "Step 3 Completed: User Registration Progressed - Values: ${_authController.activeUser!.value.toString()}, Password: ${_authController.password.value}",
      );
    }
  }

  String? _validateSchoolName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your school name';
    }
    if (value.trim().length < 3) {
      return 'School name must be at least 3 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("")),
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
                    autovalidateMode:
                        _autovalidateMode
                            ? AutovalidateMode.always
                            : AutovalidateMode.disabled,
                    child: Column(
                      children: [
                        const Text(
                          'Educational Details',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Okay, enough about you! Let\'s get started with real talk.',
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

                        TextFormField(
                          controller: _schoolController,
                          validator: _validateSchoolName,
                          decoration: InputDecoration(
                            hintText: 'Name of School',
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
                            errorStyle: const TextStyle(fontSize: 12),
                          ),
                          onChanged: (value) {
                            if (_autovalidateMode) {
                              _formKey.currentState?.validate();
                            }
                            // Using Future.microtask to avoid setState during build
                            Future.microtask(() {
                              setState(() {
                                schoolName = value;
                              });
                            });
                          },
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01,
                        ),

                        DropdownButtonFormField<String>(
                          decoration: getDropdownDecoration(
                            'Board',
                            context,
                          ).copyWith(errorStyle: const TextStyle(fontSize: 12)),
                          value: selectedBoard,
                          dropdownColor:
                              Theme.of(context).colorScheme.surfaceContainer,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.grey[400],
                          ),
                          items:
                              boards.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a board';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            // Using Future.microtask to avoid setState during build
                            Future.microtask(() {
                              setState(() {
                                selectedBoard = value;
                              });
                            });
                          },
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.015,
                        ),

                        DropdownButtonFormField<String>(
                          decoration: getDropdownDecoration(
                            'Standard',
                            context,
                          ).copyWith(errorStyle: const TextStyle(fontSize: 12)),
                          value: selectedStandard,
                          dropdownColor:
                              Theme.of(context).colorScheme.surfaceContainer,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.grey[400],
                          ),
                          items:
                              standards.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select your standard';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            // Using Future.microtask to avoid setState during build
                            Future.microtask(() {
                              setState(() {
                                selectedStandard = value;
                              });
                            });
                          },
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05,
                        ),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isFormValid ? _handleSubmit : null,
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

                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Replace the loading overlay code in EducationalDetailsScreen.dart with:
            Obx(
              () =>
                  _authController.isLoading.value
                      ? Container(
                        color: Theme.of(
                          context,
                        ).colorScheme.surface.withValues(alpha: 0.2),
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
