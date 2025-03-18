import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
        theme.brightness == Brightness.light ? Colors.white : Colors.black;
    final border =
        widget.borderColor ?? theme.colorScheme.onSurface.withValues(alpha: .2);

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
                if (widget.leading != null)
                  Positioned(left: 4.0, child: widget.leading!),

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
  final String content;
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
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      padding: EdgeInsets.all(16),

      decoration: BoxDecoration(
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
                  borderRadius: BorderRadius.circular(100),
                  color: iconThemeColor.withValues(alpha: 0.15),
                ),
                child: Icon(icon, color: iconThemeColor, size: 20),
              ),
              SizedBox(width: screenWidth * 0.02),
              Expanded(
                child: Text(
                  cardTitle,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            content,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }
}
