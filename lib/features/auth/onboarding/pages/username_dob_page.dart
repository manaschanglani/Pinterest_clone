import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/input_field.dart';

class UsernameDobPage extends StatelessWidget {
  final TextEditingController usernameController;
  final DateTime? dob;
  final Function(DateTime) onDateSelected;

  const UsernameDobPage({
    super.key,
    required this.usernameController,
    required this.dob,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final selectedDate = dob ?? DateTime(2000, 1, 1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          InputField(
            hint: "Username",
            controller: usernameController,
          ),

          const SizedBox(height: 20),

          const Text(
            "Enter your birthdate",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          /// ROLLING DATE PICKER
          SizedBox(
            height: 180,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: selectedDate,
              minimumDate: DateTime(1900),
              maximumDate: DateTime.now(),
              onDateTimeChanged: onDateSelected,
            ),
          ),

          const SizedBox(height: 20),

          /// SAFETY TEXT
          const Text(
            "Knowing your age helps keep Pinterest safe for everyone. "
                "It won't be visible to others.",
            style: TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
