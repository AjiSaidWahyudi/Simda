import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simda_mobile/screens/auth/register_success_screen.dart';
import 'package:simda_mobile/theme/app_text_style.dart';
import 'package:simda_mobile/widgets/app_text_field.dart';
import 'package:simda_mobile/widgets/primary_button.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _loading = false;

  String? _passwordError;
  String? _confirmPassError;

  Future<void> _submit() async {
    // reset error
    setState(() {
      _passwordError = null;
      _confirmPassError = null;
    });

    // VALIDASI
    if (_passwordCtrl.text.isEmpty) {
      setState(() => _passwordError = 'Password wajib diisi');
      return;
    }

    if (_passwordCtrl.text.length < 6) {
      setState(() => _passwordError = 'Password minimal 6 karakter');
      return;
    }

    if (_passwordCtrl.text != _confirmPassCtrl.text) {
      setState(() => _confirmPassError = 'Konfirmasi password tidak sama');
      return;
    }

    setState(() => _loading = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final ok = await auth.register({
      'name': _nameCtrl.text.trim(),
      'username': _usernameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'password': _passwordCtrl.text.trim(),
      'device_id': 'android-device',
    });

    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const RegisterSuccessScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.blue600,
              AppColors.blue800,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),

                /// LOGO
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Image.asset(
                    'assets/logo/logo_color.png',
                    width: 72,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'SIMDA BARANG',
                  style: AppTextStyle.heading.copyWith(
                    color: AppColors.white,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Buat Akun Baru',
                  style: AppTextStyle.subtitle.copyWith(
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),

                const SizedBox(height: 40),

                /// FORM CARD
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withOpacity(0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Daftar', style: AppTextStyle.heading),

                      const SizedBox(height: 20),

                      /// NAMA
                      AppTextField(
                        controller: _nameCtrl,
                        label: 'Nama',
                        icon: Icons.person_outline,
                      ),

                      const SizedBox(height: 16),

                      /// USERNAME
                      AppTextField(
                        controller: _usernameCtrl,
                        label: 'Username',
                        icon: Icons.person_outline,
                      ),

                      const SizedBox(height: 16),

                      /// EMAIL
                      AppTextField(
                        controller: _emailCtrl,
                        label: 'Email',
                        icon: Icons.email,
                      ),

                      const SizedBox(height: 16),

                      /// PASSWORD
                      AppTextField(
                        controller: _passwordCtrl,
                        label: 'Password',
                        icon: Icons.password,
                        obscureText: true,
                        errorText: _passwordError,
                      ),

                      const SizedBox(height: 16),

                      /// KONFIRMASI PASSWORD
                      AppTextField(
                        controller: _confirmPassCtrl,
                        label: 'Konfirmasi Password',
                        icon: Icons.password,
                        obscureText: true,
                        errorText: _confirmPassError,
                      ),

                      const SizedBox(height: 24),

                      /// REGISTER BUTTON
                      PrimaryButton(
                        text: 'DAFTAR',
                        loading: _loading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// BACK TO LOGIN
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: AppTextStyle.remark.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Masuk',
                        style: AppTextStyle.button.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
