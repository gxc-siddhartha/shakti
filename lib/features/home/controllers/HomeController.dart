import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shakti/core/models/ScheduleModel.dart';
import 'package:shakti/core/models/SubjectModel.dart';
import 'package:shakti/core/models/UserModel.dart';
import 'package:shakti/features/auth/controllers/AuthController.dart';
import 'package:shakti/features/home/repositories/HomeRepository.dart';

class HomeController extends GetxController {
  final HomeRepository _homeRepository = Get.find<HomeRepository>();

  // Observables
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  RxList<SubjectModel> subjects = <SubjectModel>[].obs;
  RxList<ScheduleModel> schedules = <ScheduleModel>[].obs;

  // User data
  final Rx<UserModel> activeUser = UserModel.empty().obs;

  @override
  void onInit() {
    super.onInit();
    // Get the active user from AuthController if available
    final authController = Get.find<AuthController>(tag: null);
  }
}
