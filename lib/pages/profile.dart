// pages/profile.dart

import 'package:flutter/material.dart';
import 'home.dart';
import 'notification.dart';
import 'analysis.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  // Using TextEditingControllers for better control and to set initial values
  final _firstNameController = TextEditingController(text: 'Juan');
  final _lastNameController = TextEditingController(text: 'Dela Cruz');
  final _usernameController = TextEditingController(text: 'juandc');
  final _emailController = TextEditingController(text: 'juandelacruz@gmail.com');
  final _contactNumberController = TextEditingController(text: '09123456789');
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _contactNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // UI only, no database connection
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes Saved! (UI Only)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8BA3BF),
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0B1739),
        elevation: 0,
        automaticallyImplyLeading: false, // Removes back button
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          children: [
            // User Avatar section
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white.withOpacity(0.9),
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: const Color(0xFF0B1739).withOpacity(0.7),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Personal Information Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Color(0xFFF2F4F7),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('User Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0B1739))),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildTextField(_firstNameController, 'First Name', Icons.person_outline)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextField(_lastNameController, 'Last Name', Icons.person_outline)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(_usernameController, 'Username', Icons.alternate_email),
                    const SizedBox(height: 16),
                    _buildTextField(_emailController, 'Email', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 16),
                    _buildTextField(_contactNumberController, 'Contact Number', Icons.phone_outlined, keyboardType: TextInputType.phone),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Security Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Color(0xFFF2F4F7),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Update Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0B1739))),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      controller: _passwordController,
                      label: 'New Password (optional)',
                      isObscured: _obscurePassword,
                      toggleObscure: () => setState(() => _obscurePassword = !_obscurePassword)
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      label: 'Confirm New Password',
                      isObscured: _obscureConfirmPassword,
                      toggleObscure: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B1739),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                elevation: 5,
              ),
              onPressed: _saveChanges,
              child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0B1739),
        selectedItemColor: const Color(0xFF2196F3),
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Analysis'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const SafeBiteHomePage()),
            );
          } else if (index == 1) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const NotificationPage()),
            );
          } else if (index == 2) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => AnalysisPage()),
            );
          }
        },
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _inputDecoration(label, icon),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        if (label == 'Email' && !value.contains('@')) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isObscured,
    required VoidCallback toggleObscure,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscured,
      decoration: _inputDecoration(label, Icons.lock_outline).copyWith(
        suffixIcon: IconButton(
          icon: Icon(isObscured ? Icons.visibility : Icons.visibility_off, color: Color(0xFF0B1739).withOpacity(0.7)),
          onPressed: toggleObscure,
        ),
      ),
      validator: validator ?? (value) {
        if (label == 'New Password (optional)' && (value == null || value.isEmpty)) {
          return null; // Optional field can be empty
        }
        if (value == null || value.isEmpty) {
          return 'Please enter the password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF0B1739)),
      prefixIcon: Icon(icon, color: Color(0xFF0B1739).withOpacity(0.7)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0B1739), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
}