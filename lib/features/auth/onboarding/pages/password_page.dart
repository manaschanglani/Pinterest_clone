import 'package:flutter/material.dart';

class PasswordPage extends StatefulWidget {
  final TextEditingController controller;
  final Function(bool) onValidChanged;

  const PasswordPage({
    super.key,
    required this.controller,
    required this.onValidChanged,
  });

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  bool _obscure = true;

  String get _password => widget.controller.text;

  bool get _isValid =>
      _password.length >= 8 &&
          RegExp(r'[A-Za-z]').hasMatch(_password) &&
          RegExp(r'[0-9]').hasMatch(_password) &&
          RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(_password);

  double get _strength {
    int score = 0;

    if (_password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(_password)) score++;
    if (RegExp(r'[0-9]').hasMatch(_password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(_password)) score++;

    return score / 4;
  }

  Color get _strengthColor {
    if (_strength <= 0.25) return Colors.red;
    if (_strength <= 0.5) return Colors.orange;
    if (_strength <= 0.75) return Colors.yellow.shade700;
    return Colors.green;
  }

  String get _strengthText {
    if (_strength <= 0.25) return "Weak";
    if (_strength <= 0.5) return "Fair";
    if (_strength <= 0.75) return "Good";
    return "Strong";
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_listener);
  }

  void _listener() {
    setState(() {});
    widget.onValidChanged(_isValid);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _password.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Create a password",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          /// PASSWORD CONTAINER
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: hasText
                    ? (_isValid
                    ? Colors.green
                    : Theme.of(context).colorScheme.primary)
                    : Colors.black,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Password",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget.controller,
                        obscureText: _obscure,
                        decoration: const InputDecoration(
                          fillColor: Colors.white,
                          hintText: "Create a strong password",
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() => _obscure = !_obscure);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            "Use 8 or more letters, numbers and symbols",
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 14),

          if (hasText) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _strength,
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                valueColor:
                AlwaysStoppedAnimation<Color>(_strengthColor),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _strengthText,
              style: TextStyle(
                color: _strengthColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
