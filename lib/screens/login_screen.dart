import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../controllers/auth_controller.dart';
import '../utils/validations.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authController = Get.find<AuthController>(); // Use AuthController
  final isPasswordVisible = false.obs; // Observable variable

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
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height, // Pastikan setinggi layar
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Konten berada di tengah secara vertikal
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Email Input
                  const Text(
                    'Email Address',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      color: Color(0xFFA2A2A7),
                      height: 1.0,
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
                        fit: BoxFit.scaleDown,
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 2, // Menambahkan margin kiri
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
                      height: 1.0,
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
                            fit: BoxFit.scaleDown,
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 2, // Menambahkan margin kiri
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
                        ),
                        onChanged: (_) {
                          setState(() {
                            passwordError = Validations.validatePassword(passwordController.text);
                          });
                        },
                      )),
                  const SizedBox(height: 32),

                  // Sign In Button
                  Obx(() => ElevatedButton(
                        onPressed: authController.isLoading.value
                            ? null // Disable tombol jika sedang loading
                            : () async {
                                final email = emailController.text.trim();
                                final password = passwordController.text.trim();

                                // Validasi input
                                setState(() {
                                  emailError = Validations.validateEmail(email);
                                  passwordError = Validations.validatePassword(password);
                                });

                                if (emailError == null && passwordError == null) {
                                  final success = await authController.login(email, password);
                                  if (success) {
                                    showCustomSnackbar(
                                      message: 'Login successful!',
                                      isSuccess: true,
                                    );
                                  } else {
                                    showCustomSnackbar(
                                      message: 'Invalid email or password.',
                                      isSuccess: false,
                                    );
                                  }
                                } else {
                                  showCustomSnackbar(
                                    message: 'Please fill out all fields correctly.',
                                    isSuccess: false,
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: authController.isLoading.value
                              ? const Color(0xFFF4F4F4) // Warna abu-abu jika loading
                              : const Color(0xFF0066FF),
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: authController.isLoading.value
                            ? CircularProgressIndicator(
                                color: Colors.grey[300],
                              )
                            : const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                      )),
                  const SizedBox(height: 16),

                  // New User
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "I'm a new user.",
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          color: Color(0xFFA2A2A7),
                        ),
                      ),
                      const SizedBox(width: 4), // Adjust spacing
                      TextButton(
                        onPressed: () {
                          Get.toNamed('/register');
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero, // Remove default padding
                          minimumSize: const Size(0, 0), // Avoid default minimum size
                        ),
                        child: const Text(
                          'Sign Up',
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
    );
  }
}
