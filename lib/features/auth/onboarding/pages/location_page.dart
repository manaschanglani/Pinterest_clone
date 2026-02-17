import 'package:flutter/material.dart';
import '../widgets/input_field.dart';

class LocationPage extends StatelessWidget {
  final TextEditingController controller;

  const LocationPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Where do you live?",
            style:
            TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10,),
          Text("This helps us find more relevant content for you. We won't show it on your profile."),
          const SizedBox(height: 15),
          InputField(hint: "Location", controller: controller),
        ],
      ),
    );
  }
}
