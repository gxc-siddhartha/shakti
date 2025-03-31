import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:go_router/go_router.dart';
import 'package:shakti/core/models/SubjectModel.dart';
import 'package:shakti/core/router/RouterConstants.dart';
import 'package:shakti/features/home/controllers/HomeController.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField();
  }
}

InputDecoration getDropdownDecoration(String label, BuildContext context) {
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 1),
    ),
    filled: true,
    fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.04),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      ),
    ),
  );
}

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Widget title;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? borderColor;
  final double blurStrength;
  final double height;
  final bool includeStatusBar;
  final bool automaticallyImplyLeading; // New parameter for auto back button

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.borderColor,
    this.blurStrength = 20,
    this.height = kToolbarHeight,
    this.includeStatusBar = true,
    this.automaticallyImplyLeading =
        true, // Default to true like standard AppBar
  }) : super(key: key);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor =
        widget.backgroundColor ??
        (theme.brightness == Brightness.light ? Colors.white : Colors.black);
    final border =
        widget.borderColor ?? theme.colorScheme.onSurface.withOpacity(0.2);

    // Make status bar transparent and set icons to dark/light based on theme
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            theme.brightness == Brightness.light
                ? Brightness.dark
                : Brightness.light,
      ),
    );

    final statusBarHeight = MediaQuery.of(context).padding.top;
    final appBarHeight =
        widget.includeStatusBar
            ? widget.height + statusBarHeight
            : widget.height;

    // Determine if we should show a back button
    Widget? leadingWidget = widget.leading;
    if (leadingWidget == null && widget.automaticallyImplyLeading) {
      final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
      final bool canPop = parentRoute?.canPop ?? false;

      if (canPop) {
        leadingWidget = IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        );
      }
    }

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: widget.blurStrength,
          sigmaY: widget.blurStrength,
        ),
        child: Container(
          height: appBarHeight,
          decoration: BoxDecoration(
            color: bgColor,
            border: Border(bottom: BorderSide(color: border, width: 0.5)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              top: widget.includeStatusBar ? statusBarHeight : 0,
              left: 8.0,
              right: 8.0,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Leading widget (usually a back button)
                if (leadingWidget != null)
                  Positioned(left: 4.0, child: leadingWidget),

                // Centered title
                Center(child: widget.title),

                // Action buttons
                if (widget.actions != null && widget.actions!.isNotEmpty)
                  Positioned(
                    right: 4.0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: widget.actions!,
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

class CCardText extends StatelessWidget {
  final Widget content;
  final Color iconThemeColor;
  final String cardTitle;
  final IconData icon;
  const CCardText({
    super.key,
    required this.content,
    required this.iconThemeColor,
    required this.cardTitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.15),
        ),
        borderRadius: BorderRadius.circular(5),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.only(top: 16, left: 16, right: 16),
            child: Row(
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: iconThemeColor.withValues(alpha: 0.2),
                  ),
                  child: Center(
                    child: SFIcon(
                      icon,
                      color: iconThemeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                Expanded(
                  child: Container(
                    alignment: Alignment.centerLeft,
                    height: 34,
                    child: Text(
                      cardTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(),

          Container(
            padding: EdgeInsets.only(left: 16, bottom: 10, right: 16),
            child: content,
          ),
        ],
      ),
    );
  }
}

class CCardStats extends StatelessWidget {
  final Widget content;
  final Color iconThemeColor;
  final String subTitle;
  final String cardTitle;
  final IconData icon;
  const CCardStats({
    super.key,
    required this.content,
    required this.iconThemeColor,
    required this.cardTitle,
    required this.icon,
    required this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      padding: EdgeInsets.all(16),

      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.15),
        ),
        borderRadius: BorderRadius.circular(5),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: iconThemeColor.withValues(alpha: 0.15),
                ),
                child: Icon(icon, color: iconThemeColor, size: 20),
              ),
              SizedBox(width: screenWidth * 0.02),
              Text(
                cardTitle,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.2),
                ),
                child: Text(subTitle, style: TextStyle(color: iconThemeColor)),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          content,
        ],
      ),
    );
  }
}

class SubjectBottomSheet extends StatefulWidget {
  final Function(String) onCreateSubject;

  const SubjectBottomSheet({Key? key, required this.onCreateSubject})
    : super(key: key);

  @override
  _SubjectBottomSheetState createState() => _SubjectBottomSheetState();
}

class _SubjectBottomSheetState extends State<SubjectBottomSheet> {
  final TextEditingController _subjectNameController = TextEditingController();

  @override
  void dispose() {
    _subjectNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        // Add padding to avoid the keyboard
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(5),
          topRight: Radius.circular(5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create Subject',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the name of the subject that you would like to add',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _subjectNameController,

            decoration: InputDecoration(
              hintText: 'Subject Name',
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              filled: true,
              fillColor: Theme.of(
                context,
              ).colorScheme.onSurface.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              errorStyle: const TextStyle(fontSize: 10),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                final subjectName = _subjectNameController.text.trim();
                if (subjectName.isNotEmpty) {
                  widget.onCreateSubject(subjectName);
                }
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: const Text(
                'Create Subject',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Example of how to use the bottom sheet:
void showSubjectBottomSheet(
  BuildContext context,
  HomeController homeController,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder:
        (context) => SubjectBottomSheet(
          onCreateSubject: (subjectName) async {
            final SubjectModel subject = SubjectModel(
              subjectName: subjectName,
              totalEvents: 0,
              attendedEvents: 0,
              occuredEvents: 0,
              missedEvents: 0,
              percentageRequiredToCover: 0,
              currentPercentage: 0,
            );
            context.pop();
            await homeController.addSubject(subject);
            print('New subject created: $subjectName');
          },
        ),
  );
}

Widget buildSubjectsList(BuildContext context, HomeController homeController) {
  return ListView.separated(
    padding: EdgeInsets.all(0),
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    itemCount: homeController.subjects.length,
    separatorBuilder:
        (context, index) => Divider(
          height: 0.3,
          thickness: 1,
          color: Colors.grey.withOpacity(0.2),
        ),
    itemBuilder: (context, index) {
      final subject = homeController.subjects[index];

      return Container(
        // decoration: BoxDecoration(),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          title: Text(
            subject.subjectName ?? 'Unnamed Subject',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          trailing: Icon(Icons.chevron_right, color: Colors.grey),

          onTap: () {
            context.goNamed(
              RouterConstants.subjectDetailsScreenRouteName,
              extra: subject,
            );
            // Navigate to subject details
            // Get.to(() => SubjectDetailsScreen(subject: subject));
          },
        ),
      );
    },
  );
}

// Create this widget class in a separate file like lib/core/widgets/BounceAnimationWidget.dart
class BounceAnimationWidget extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const BounceAnimationWidget({
    super.key,
    required this.child,
    this.delay = const Duration(milliseconds: 0),
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<BounceAnimationWidget> createState() => _BounceAnimationWidgetState();
}

class _BounceAnimationWidgetState extends State<BounceAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    // Add delay if needed
    if (widget.delay.inMilliseconds > 0) {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        // Clamp opacity value between 0.0 and 1.0 to avoid assertion error
        final safeOpacity = _bounceAnimation.value.clamp(0.0, 1.0);

        return Transform.scale(
          scale:
              0.6 +
              (_bounceAnimation.value * 0.4), // Start from 0.2 and go to 1.0
          child: Opacity(opacity: safeOpacity, child: widget.child),
        );
      },
    );
  }
}

class PopUpAnimationWidget extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const PopUpAnimationWidget({
    Key? key,
    required this.child,
    this.delay = const Duration(milliseconds: 0),
    this.duration = const Duration(
      milliseconds: 500,
    ), // Faster default duration
  }) : super(key: key);

  @override
  State<PopUpAnimationWidget> createState() => _PopUpAnimationWidgetState();
}

class _PopUpAnimationWidgetState extends State<PopUpAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _blurAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    // Scale animation: start small (0.75) and grow to full size (1.0)
    _scaleAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutQuint, // Faster easing curve
      ),
    );

    // Opacity animation: fade in from 0.0 to 1.0
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.5, curve: Curves.easeOut), // Complete faster
      ),
    );

    // Blur animation: start blurred (5.0) and clear to sharp (0.0)
    _blurAnimation = Tween<double>(
      begin: 200,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuint));

    // Add delay if needed
    if (widget.delay.inMilliseconds > 0) {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: ClipRect(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: _blurAnimation.value,
                  sigmaY: _blurAnimation.value,
                ),
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}
