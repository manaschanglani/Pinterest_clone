import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/provider/auth_provider.dart';

class EmailPage extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final Function(bool) onValidChanged;

  const EmailPage({
    super.key,
    required this.controller,
    required this.onValidChanged,
  });

  @override
  ConsumerState<EmailPage> createState() => _EmailPageState();
}

class _EmailPageState extends ConsumerState<EmailPage> {
  bool _isValidFormat = false;
  bool _emailExists = false;
  bool _checking = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_validateEmail);
  }

  void _validateEmail() {
    final email = widget.controller.text.trim();

    final emailRegex =
    RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");

    final validFormat = emailRegex.hasMatch(email);

    setState(() {
      _isValidFormat = validFormat;
      _emailExists = false;
    });

    widget.onValidChanged(false);

    if (validFormat) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 600), () async {
        setState(() => _checking = true);

        final exists = await ref
            .read(authRepositoryProvider)
            .emailExists(email);

        if (!mounted) return;

        setState(() {
          _emailExists = exists;
          _checking = false;
        });

        widget.onValidChanged(!exists);
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.controller.removeListener(_validateEmail);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showError =
        !_isValidFormat && widget.controller.text.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "What's your email?",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: showError || _emailExists
                    ? Colors.red
                    : Colors.black,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Email",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: widget.controller,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    fillColor: Colors.white,
                    hintText: "Enter your email",
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          if (_checking)
            const Text(
              "Checking email...",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),

          if (showError)
            const Text(
              "Please enter a valid email address.",
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),

          if (_emailExists)
            const Text(
              "Email already exists. Please log in instead.",
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
        ],
      ),
    );
  }
}
