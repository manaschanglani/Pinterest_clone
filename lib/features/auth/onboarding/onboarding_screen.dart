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

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _locationController = TextEditingController();

  String _gender = '';
  DateTime? _dob;
  final List<String> _selectedTopics = [];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  /// BACK BUTTON
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

                  /// Spacer to balance layout
                  const SizedBox(width: 20),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  EmailPage(controller: _emailController),
                  PasswordPage(controller: _passwordController),
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
                  LocationPage(controller: _locationController),
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

            OnboardingButton(
              isLastPage: _currentPage == 5,
              onPressed:
              _currentPage == 5 ? _finishSignUp : _nextPage,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
