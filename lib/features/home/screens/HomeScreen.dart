import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shakti/core/helpers/HelperWidgets.dart';
import 'package:shakti/features/home/controllers/HomeController.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _homeController = Get.find<HomeController>();

  // Method to handle navigation tab changes
  void showIntroductionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // This allows the bottom sheet to take up more space
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height:
              MediaQuery.of(context).size.height *
              0.85, // Take up most of the screen
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: IntroductionScreen(
              pages: [
                PageViewModel(
                  title: "Welcome",
                  body: "This is the first page of the introduction screen.",
                ),
                PageViewModel(
                  title: "Feature Overview",
                  body: "Learn about the main features of our app.",
                ),
                // Add more pages as needed
              ],
              onDone: () {
                context.pop(); // Close the bottom sheet
              },
              onSkip: () {
                context.pop(); // Close the bottom sheet
              },
              showSkipButton: true,
              skip: const Text("Skip"),
              next: const Text("Next"),
              done: const Text("Done"),
              dotsDecorator: DotsDecorator(
                size: const Size.square(10.0),
                activeSize: const Size(20.0, 10.0),
                activeColor: Theme.of(context).colorScheme.primary,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                spacing: const EdgeInsets.symmetric(horizontal: 3.0),
                activeShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Image.asset("assets/brand/logo.png", height: 40),
        actions: [],
      ),
      body: // Replace the body section with this code after creating the BounceAnimationWidget
          Obx(
        () =>
            _homeController.isLoading.value
                ? SizedBox(
                  height: screenHeight,
                  width: screenWidth,
                  child: Center(child: CupertinoActivityIndicator()),
                )
                : PopUpAnimationWidget(
                  delay: Duration(milliseconds: 200),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Greeting section with bounce animation
                        Obx(
                          () => Container(
                            padding: EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 0,
                              top: 16,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  "Hello ${(_homeController.activeUser.value.name ?? "").split(" ").first},",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.7,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "View your overall statistics for your \nattendance below",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Overall percentage card with bounce animation
                        Obx(
                          () =>
                              _homeController.getOverallPercentage.toString() ==
                                      "0"
                                  ? Container()
                                  : Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.only(
                                            left: 16,
                                            top: 16,
                                            right: 16,
                                          ),
                                          child: CCardText(
                                            icon: SFIcons.sf_chart_pie,

                                            content: Text(
                                              _homeController
                                                  .overallPercentage
                                                  .value,
                                              style: TextStyle(
                                                fontSize: 24,
                                                // fontWeight: FontWeight.w500,
                                                // Using the primary theme color instead of conditional color
                                              ),
                                            ),
                                            iconThemeColor: Color(0xff3266BA),
                                            cardTitle: "Overall Percentage",
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                        ),

                        // Events cards with bounce animation
                        Obx(
                          () =>
                              _homeController
                                          .getTodaySchedulesCount()
                                          .toString() ==
                                      "0"
                                  ? Container(height: 0)
                                  : Row(
                                    children: [
                                      Expanded(
                                        child: Obx(
                                          () => Container(
                                            padding: EdgeInsets.only(
                                              right: 8,
                                              top: 16,
                                              left: 16,
                                            ),
                                            child: CCardText(
                                              icon: SFIcons.sf_list_clipboard,
                                              content: Text(
                                                _homeController
                                                    .getTodaySchedulesCount()
                                                    .toString(),
                                                style: TextStyle(
                                                  fontSize: 24,

                                                  // Using the primary theme color instead of conditional color
                                                ),
                                              ),
                                              iconThemeColor: Color(0xffBAA832),
                                              cardTitle: "Today's Events",
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Obx(
                                          () => Container(
                                            padding: EdgeInsets.only(
                                              right: 16,
                                              top: 16,
                                              left: 8,
                                            ),
                                            child: CCardText(
                                              icon:
                                                  SFIcons
                                                      .sf_point_topleft_down_to_point_bottomright_curvepath,
                                              content: Text(
                                                _homeController
                                                    .getRemainingTodaySchedulesCount()
                                                    .toString(),
                                                style: TextStyle(
                                                  fontSize: 24,

                                                  // Using the primary theme color instead of conditional color
                                                ),
                                              ),
                                              iconThemeColor: Color(0xff29A43B),
                                              cardTitle: "Events Left",
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                        ),

                        // Ongoing event with bounce animation
                        Obx(
                          () =>
                              _homeController.activeSchedule.value == null
                                  ? Container(
                                    height: 16,
                                  ) // Empty widget when no active schedule
                                  : Container(
                                    padding: EdgeInsets.all(16),
                                    child: CCardStats(
                                      subTitle:
                                          _homeController
                                              .getActiveScheduleTimeText(),
                                      content: Text(
                                        _homeController
                                                .activeSchedule
                                                .value
                                                ?.subject
                                                ?.subjectName ??
                                            "",
                                        style: TextStyle(fontSize: 24),
                                      ),
                                      iconThemeColor:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                      cardTitle: "Ongoing Event",
                                      icon: Icons.lock_clock,
                                    ),
                                  ),
                        ),

                        // Subjects container with bounce animation
                        Container(
                          margin: EdgeInsets.only(
                            right: 16,
                            left: 16,
                            bottom: 16,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Theme.of(context).colorScheme.surface,
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                padding: EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  top: 16,
                                  bottom: 0,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 30,
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
                                        color: Color(
                                          0xffE9762B,
                                        ).withValues(alpha: 0.15),
                                      ),
                                      child: Center(
                                        child: SFIcon(
                                          SFIcons.sf_book,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xffE9762B),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.02,
                                    ),
                                    Text(
                                      "Subjects",
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                    Spacer(),
                                    Obx(
                                      () =>
                                          _homeController.subjects.isEmpty
                                              ? Container()
                                              : TextButton(
                                                style: ButtonStyle(
                                                  elevation:
                                                      WidgetStatePropertyAll(0),
                                                ),
                                                onPressed: () {
                                                  showSubjectBottomSheet(
                                                    context,
                                                    _homeController,
                                                  );
                                                },
                                                child: Text("Add Subject"),
                                              ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(height: 1),
                              Obx(
                                () =>
                                    _homeController.subjects.isNotEmpty
                                        ? buildSubjectsList(
                                          context,
                                          _homeController,
                                        )
                                        : Container(
                                          padding: EdgeInsets.all(24),
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.search_off,
                                                size: 36,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withValues(alpha: 0.3),
                                              ),
                                              SizedBox(
                                                height:
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.height *
                                                    0.009,
                                              ),
                                              Text(
                                                textAlign: TextAlign.center,
                                                "We can't find any subjects for you to work on",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: -0.6,
                                                ),
                                              ),
                                              SizedBox(
                                                height:
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.height *
                                                    0.009,
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  showSubjectBottomSheet(
                                                    context,
                                                    _homeController,
                                                  );
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 10,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                    color:
                                                        Theme.of(
                                                          context,
                                                        ).colorScheme.primary,
                                                  ),
                                                  child: Text(
                                                    "Create Subject",
                                                    style: TextStyle(
                                                      color:
                                                          Theme.of(
                                                            context,
                                                          ).colorScheme.surface,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }
}
