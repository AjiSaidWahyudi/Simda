import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simda_mobile/screens/main_screen.dart';
import 'package:simda_mobile/theme/app_text_style.dart';
import 'package:simda_mobile/widgets/app_text_field.dart';
import 'package:simda_mobile/widgets/primary_button.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    if (_usernameCtrl.text.trim().isEmpty ||
        _passwordCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username dan password wajib diisi')),
      );
      return;
    }

    setState(() => _loading = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final ok = await auth.login(
      _usernameCtrl.text.trim(),
      _passwordCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username atau password salah')),
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
                  'Sistem Inventaris Daerah',
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
                      Text('Masuk', style: AppTextStyle.heading),

                      const SizedBox(height: 20),

                      /// USERNAME
                      AppTextField(
                        controller: _usernameCtrl,
                        label: 'Username',
                        icon: Icons.person_outline,
                      ),

                      const SizedBox(height: 16),

                      /// PASSWORD
                      AppTextField(
                        controller: _passwordCtrl,
                        label: 'Password',
                        icon: Icons.password,
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),

                      /// LOGIN BUTTON
                      PrimaryButton(
                        text: 'LOGIN',
                        loading: _loading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// REGISTER
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Belum punya akun? ',
                      style: AppTextStyle.remark.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Daftar',
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
