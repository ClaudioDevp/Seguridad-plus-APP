import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // importa tu AuthService

class RegisterPage extends StatefulWidget {
  final AuthService authService;

  const RegisterPage({
    super.key,
    required this.authService,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final user = await widget.authService.register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      print(user);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator()
            else ...[
              ElevatedButton(onPressed: _register, child: const Text('Registrarse')),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Tengo una cuenta'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
