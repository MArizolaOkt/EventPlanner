import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'event_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final studentNumberController = TextEditingController();
  final majorController = TextEditingController();
  final classYearController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmationController = TextEditingController();

  bool isLoading = false;

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final response = await _apiService.registerUserRawResponse(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        studentNumber: studentNumberController.text.trim(),
        major: majorController.text.trim(),
        classYear: int.parse(classYearController.text.trim()),
        password: passwordController.text,
        passwordConfirmation: passwordConfirmationController.text,
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', 'dummy-token'); // Simpan token jika ada

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const EventPage()),
        );
      } else {
        showError('Registrasi gagal. Status: ${response.statusCode}');
      }
    } catch (e) {
      showError('Terjadi kesalahan: ${e.toString()}');
    }

    setState(() => isLoading = false);
  }

  void showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: studentNumberController,
                decoration: const InputDecoration(labelText: 'Student Number'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: majorController,
                decoration: const InputDecoration(labelText: 'Jurusan'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: classYearController,
                decoration: const InputDecoration(
                  labelText: 'Angkatan (contoh: 2022)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: passwordConfirmationController,
                decoration: const InputDecoration(
                  labelText: 'Konfirmasi Password',
                ),
                obscureText: true,
                validator: (value) => value != passwordController.text
                    ? 'Password tidak cocok'
                    : null,
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: register,
                      child: const Text("Daftar"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
