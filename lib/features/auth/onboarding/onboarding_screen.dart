import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/provider/auth_provider.dart';

import 'pages/email_page.dart';
import 'pages/password_page.dart';
import 'pages/username_dob_page.dart';
import 'pages/gender_page.dart';
import 'pages/location_page.dart';
import 'pages/topics_page.dart';
import 'widgets/dot_indicator.dart';
import 'widgets/onboarding_button.dart';

class SignUpOnboardingScreen extends ConsumerStatefulWidget {
  const SignUpOnboardingScreen({super.key});

  @override
  ConsumerState<SignUpOnboardingScreen> createState() =>
      _SignUpOnboardingScreenState();
}

class _SignUpOnboardingScreenState
    extends ConsumerState<SignUpOnboardingScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  // Validation states
  bool _emailValid = false;
  bool _passwordValid = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _locationController = TextEditingController();

  String _gender = '';
  DateTime? _dob;
  final List<String> _selectedTopics = [];

  // ------------------------------------------------
  // Navigation
  // ------------------------------------------------

  void _nextPage() {
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // ------------------------------------------------
  // Sign Up
  // ------------------------------------------------

  Future<void> _finishSignUp() async {
    await ref.read(authStateProvider.notifier).signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      username: _usernameController.text.trim(),
      gender: _gender,
      location: _locationController.text.trim(),
      dob: _dob!,
      topics: _selectedTopics,
    );
  }

  // ------------------------------------------------
  // Button Enable Logic
  // ------------------------------------------------

  bool get _canProceed {
    switch (_currentPage) {
      case 0:
        return _emailValid;

      case 1:
        return _passwordValid;

      case 2:
        return _usernameController.text.isNotEmpty && _dob != null;

      case 3:
        return _gender.isNotEmpty;

      case 4:
        return _locationController.text.isNotEmpty;

      case 5:
        return _selectedTopics.length >= 3;

      default:
        return false;
    }
  }

  // ------------------------------------------------
  // UI
  // ------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            /// TOP BAR (Back + Dots)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_currentPage == 0) {
                        Navigator.of(context).pop();
                      } else {
                        _previousPage();
                      }
                    },
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 20,
                      color: Colors.black,
                    ),
                  ),

                  Expanded(
                    child: Center(
                      child: DotIndicator(currentPage: _currentPage),
                    ),
                  ),

                  const SizedBox(width: 20),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// PAGES
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  EmailPage(
                    controller: _emailController,
                    onValidChanged: (valid) {
                      setState(() => _emailValid = valid);
                    },
                  ),

                  PasswordPage(
                    controller: _passwordController,
                    onValidChanged: (valid) {
                      setState(() => _passwordValid = valid);
                    },
                  ),

                  UsernameDobPage(
                    usernameController: _usernameController,
                    dob: _dob,
                    onDateSelected: (date) {
                      setState(() => _dob = date);
                    },
                  ),

                  GenderPage(
                    gender: _gender,
                    onChanged: (value) {
                      setState(() => _gender = value);
                    },
                  ),

                  LocationPage(
                    controller: _locationController,
                    onChanged: () => setState(() {}),
                  ),


                  TopicsPage(
                    selectedTopics: _selectedTopics,
                    onToggle: (topic) {
                      setState(() {
                        if (_selectedTopics.contains(topic)) {
                          _selectedTopics.remove(topic);
                        } else {
                          _selectedTopics.add(topic);
                        }
                      });
                    },
                  ),
                ],
              ),
            ),

            /// BOTTOM BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: OnboardingButton(
                isLastPage: _currentPage == 5,
                enabled: _canProceed,
                onPressed: _canProceed
                    ? (_currentPage == 5
                    ? _finishSignUp
                    : _nextPage)
                    : null,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
