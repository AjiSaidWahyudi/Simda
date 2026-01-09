import 'package:flutter/material.dart';
import 'package:simda_mobile/theme/app_text_style.dart';
import 'package:simda_mobile/widgets/app_text_field.dart';
import 'package:simda_mobile/widgets/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (_emailCtrl.text.isEmpty) {
      setState(() => _error = 'Email wajib diisi');
      return;
    }

    setState(() => _loading = true);

    // TODO: panggil API forgot password
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link reset password telah dikirim ke email'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Lupa Password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Masukkan email yang terdaftar',
              style: AppTextStyle.subtitle,
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: _emailCtrl,
              label: 'Email',
              icon: Icons.email,
              errorText: _error,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'KIRIM',
              loading: _loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
