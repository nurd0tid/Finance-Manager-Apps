import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../controllers/auth_controller.dart';
import '../utils/validations.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authController = Get.find<AuthController>(); // Use AuthController
  final isPasswordVisible = false.obs; // Observable variable

  String? fullNameError;
  String? emailError;
  String? passwordError;

  void showCustomSnackbar({required String message, required bool isSuccess}) {
    Get.snackbar(
      isSuccess ? 'Wohooo!' : 'Error', // Title dinamis
      '', // Kosongkan karena kita menggunakan messageText
      backgroundColor: Colors.grey[100],
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      titleText: Text(
        isSuccess ? 'Wohooo!' : 'Error', // Judul yang ditampilkan
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
          color: isSuccess ? Colors.green : Colors.red,
        ),
      ),
      messageText: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center, // Konten berada di tengah
        children: [
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                color: Color(0xFF1E1E2D),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isSuccess ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSuccess ? Icons.check : Icons.close,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161622),
      body: Stack(
        children: [
          // Back Arrow
          Positioned(
            top: MediaQuery.of(context).padding.top + 16, // Adjust position to below the system bar
            left: 16,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Image.asset(
                'assets/arrow-back.png',
                width: 42,
                height: 42,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60), // Beri jarak untuk Back Arrow
                      // Title
                      const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Full Name Input
                      const Text(
                        'Full Name',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          color: Color(0xFFA2A2A7),
                        ),
                      ),
                      TextField(
                        controller: fullNameController,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: SvgPicture.asset(
                            'assets/icons/email.svg',
                            width: 24,
                            height: 24,
                            fit: BoxFit.scaleDown,
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 2,
                            minHeight: 2,
                          ),
                          border: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color.fromARGB(255, 228, 228, 230)),
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color.fromARGB(255, 228, 228, 230)),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF0066FF)),
                          ),
                          errorText: fullNameError,
                          errorStyle: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                        onChanged: (_) {
                          setState(() {
                            fullNameError = Validations.validateFullName(fullNameController.text);
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email Input
                      const Text(
                        'Email Address',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          color: Color(0xFFA2A2A7),
                        ),
                      ),
                      TextField(
                        controller: emailController,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: SvgPicture.asset(
                            'assets/icons/email.svg',
                            width: 24,
                            height: 24,
                            fit: BoxFit.scaleDown,
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 2,
                            minHeight: 2,
                          ),
                          border: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color.fromARGB(255, 228, 228, 230)),
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color.fromARGB(255, 228, 228, 230)),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF0066FF)),
                          ),
                          errorText: emailError,
                          errorStyle: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                        onChanged: (_) {
                          setState(() {
                            emailError = Validations.validateEmail(emailController.text);
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password Input
                      const Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          color: Color(0xFFA2A2A7),
                        ),
                      ),
                      Obx(() => TextField(
                            controller: passwordController,
                            obscureText: !isPasswordVisible.value,
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              prefixIcon: SvgPicture.asset(
                                'assets/icons/locked.svg',
                                width: 24,
                                height: 24,
                                fit: BoxFit.scaleDown,
                              ),
                              prefixIconConstraints: const BoxConstraints(
                                minWidth: 2,
                                minHeight: 2,
                              ),
                              suffixIcon: IconButton(
                                icon: SvgPicture.asset(
                                  'assets/icons/eye.svg',
                                ),
                                onPressed: () {
                                  isPasswordVisible.toggle();
                                },
                              ),
                              border: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Color.fromARGB(255, 228, 228, 230)),
                              ),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Color.fromARGB(255, 228, 228, 230)),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF0066FF)),
                              ),
                              errorText: passwordError,
                              errorStyle: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                            onChanged: (_) {
                              setState(() {
                                passwordError = Validations.validatePassword(passwordController.text);
                              });
                            },
                          )),
                      const SizedBox(height: 32),

                      // Sign Up Button
                      Obx(() => ElevatedButton(
                            onPressed: authController.isLoading.value
                                ? null
                                : () async {
                                    final fullName = fullNameController.text.trim();
                                    final email = emailController.text.trim();
                                    final password = passwordController.text.trim();

                                    // Validasi input
                                    setState(() {
                                      fullNameError = Validations.validateFullName(fullName);
                                      emailError = Validations.validateEmail(email);
                                      passwordError = Validations.validatePassword(password);
                                    });

                                    if (fullNameError == null && emailError == null && passwordError == null) {
                                      final success = await authController.register(fullName, email, password);
                                      if (success) {
                                        showCustomSnackbar(
                                          message: 'Registration successful!',
                                          isSuccess: true,
                                        );
                                        // Clear form setelah berhasil
                                        fullNameController.clear();
                                        emailController.clear();
                                        passwordController.clear();
                                      } else {
                                        showCustomSnackbar(
                                          message: 'Registration failed. Please try again.',
                                          isSuccess: false,
                                        );
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: authController.isLoading.value ? const Color(0xFFF4F4F4) : const Color(0xFF0066FF),
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: authController.isLoading.value
                                ? CircularProgressIndicator(color: Colors.grey[300])
                                : const Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                          )),
                      const SizedBox(height: 16),

                      // Already have an account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account.",
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              color: Color(0xFFA2A2A7),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Get.toNamed('/login'),
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                color: Color(0xFF0066FF),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
