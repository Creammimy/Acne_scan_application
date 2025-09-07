import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isPrivacyAccepted = false;

  Future<void> _login() async {
    if (!_isPrivacyAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('กรุณายอมรับนโยบายความเป็นส่วนตัวก่อนเข้าสู่ระบบ'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    try {
      final supabase = Supabase.instance.client;

      final response = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (response.user == null) {
        throw Exception('ไม่สามารถเข้าสู่ระบบได้');
      }

      final uid = response.user!.id;

      final userData = await supabase.from('users').select().eq('id', uid).single();

      print("ชื่อผู้ใช้: ${userData['name']}");
      print("ลิงก์โปรไฟล์: ${userData['profile_image_url']}");

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print("Login error: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("อีเมลหรือรหัสผ่านไม่ถูกต้อง! กรุณาลองใหม่"),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _forgotPassword() async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.auth.resetPasswordForEmail(
        emailController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('ส่งลิงก์เปลี่ยนรหัสผ่านไปที่อีเมลแล้ว'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      print('Forgot password error: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('ไม่สามารถส่งลิงก์ได้ กรุณาลองใหม่'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCDF8F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.grey),
                    onPressed: () => Navigator.pushNamed(context, '/welcome'),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 70,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'FCMinimal',
                  color: Color(0xFF06D1D0),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'อีเมล',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'รหัสผ่าน',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _forgotPassword,
                  child: const Text('ลืมรหัสผ่าน?'),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: _isPrivacyAccepted,
                    onChanged: (bool? value) {
                      setState(() {
                        _isPrivacyAccepted = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/privacy-policy');
                      },
                      child: const Text.rich(
                        TextSpan(
                          text: 'ฉันเข้าใจและยอมรับ ',
                          children: [
                            TextSpan(
                              text: '"นโยบายความเป็นส่วนตัว"',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06D1D0),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'เข้าสู่ระบบ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'FCMinimal',
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("ยังไม่มีบัญชี?"),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/signup'),
                    child: const Text('ลงทะเบียน'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
