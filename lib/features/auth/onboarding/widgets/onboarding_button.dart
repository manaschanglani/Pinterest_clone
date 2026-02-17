import 'package:flutter/material.dart';

class OnboardingButton extends StatelessWidget {
  final bool isLastPage;
  final bool enabled;
  final VoidCallback? onPressed;

  const OnboardingButton({
    super.key,
    required this.isLastPage,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade300,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          isLastPage ? "Finish" : "Next",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
