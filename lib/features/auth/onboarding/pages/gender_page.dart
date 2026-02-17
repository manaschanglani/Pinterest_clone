import 'package:flutter/material.dart';

class GenderPage extends StatelessWidget {
  final String gender;
  final Function(String) onChanged;

  const GenderPage({
    super.key,
    required this.gender,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = ["Female", "Male", "Other"];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "What gender do you identify as?",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "This will influence the content you see. "
                "It won't be visible to others.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 15),

          /// Gender Buttons
          ...options.map(
                (option) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: GestureDetector(
                onTap: () => onChanged(option),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 16, horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: gender == option
                          ? Theme.of(context).colorScheme.primary
                          : Colors.black,
                      width: 0.5,
                    ),
                    color: gender == option
                        ? Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.08)
                        : Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: gender == option
                            ? Theme.of(context).colorScheme.primary
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
