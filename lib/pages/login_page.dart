import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seguridad_plus/providers/auth_notifier_provider.dart';
import 'package:url_launcher/url_launcher.dart';

const REGISTER_URL = "https://seguridadplus.web.app/app/register";

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _login() async {
  if (!mounted) return; // evita correr si ya se desmontó

  setState(() {
    _isLoading = true;
    _error = null;
  });

  try {
    await context.read<AuthNotifierProvider>().signIn(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
  } catch (e) {
    if (mounted) {
      setState(() {
        _error = e.toString();
      });
    }
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
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
              ElevatedButton(onPressed: _login, child: const Text('Ingresar')),
              TextButton(
                onPressed: () async {
                  final Uri url = Uri.parse(REGISTER_URL);

                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'No se pudo abrir el navegador, ingresa a $REGISTER_URL para registrarte ',
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Crear cuenta'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
