import 'package:flutter/material.dart';

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
