import 'package:flutter/material.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String username = "";
  String email = "";
  String? profileImageUrl;
  File? profileImage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user != null) {
      try {
        final response = await supabase
            .from('users')
            .select('name, profile_image_url')
            .eq('id', user.id)
            .single();

        setState(() {
          username = response['name'] ?? '';
          email = user.email ?? '';
          profileImageUrl = response['profile_image_url'];
        });
      } catch (e) {
        print('โหลดข้อมูลผู้ใช้ผิดพลาด: $e');
      }
    }
  }

  Future<void> _changeUsername() async {
    TextEditingController nameController = TextEditingController(text: username);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("เปลี่ยนชื่อผู้ใช้"),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(labelText: "ชื่อผู้ใช้ใหม่"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("ยกเลิก"),
          ),
          ElevatedButton(
            onPressed: () async {
              final supabase = Supabase.instance.client;
              final user = supabase.auth.currentUser;
              if (user != null) {
                try {
                  await supabase.from('users').update({
                    'name': nameController.text,
                  }).eq('id', user.id);

                  setState(() {
                    username = nameController.text;
                  });
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("เกิดข้อผิดพลาด: $e")),
                  );
                }
              }
            },
            child: Text("บันทึก"),
          ),
        ],
      ),
    );
  }

  Future<void> _changeEmail() async {
    TextEditingController emailController = TextEditingController(text: email);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("แก้ไขอีเมล"),
        content: TextField(
          controller: emailController,
          decoration: InputDecoration(labelText: "อีเมลใหม่"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("ยกเลิก"),
          ),
          ElevatedButton(
            onPressed: () async {
              final supabase = Supabase.instance.client;
              final user = supabase.auth.currentUser;
              if (user != null) {
                try {
                  await supabase.auth.updateUser(
                    UserAttributes(email: emailController.text),
                  );

                  setState(() {
                    email = emailController.text;
                  });
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("เกิดข้อผิดพลาด: $e")),
                  );
                }
              }
            },
            child: Text("บันทึก"),
          ),
        ],
      ),
    );
  }

  Future<void> _changeProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });

      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user != null && profileImage != null) {
        try {
          final filePath = 'profile_images/${user.id}_${DateTime.now().millisecondsSinceEpoch}.png';
          final fileBytes = await profileImage!.readAsBytes();

          // สำคัญ!!: ต้องมี bucket 'profiles' ใน Storage
          await supabase.storage.from('profiles').uploadBinary(
            filePath,
            fileBytes,
            fileOptions: const FileOptions(upsert: true),
          );

          final imageUrl = supabase.storage.from('profiles').getPublicUrl(filePath);

          await supabase.from('users').update({
            'profile_image_url': imageUrl,
          }).eq('id', user.id);

          setState(() {
            profileImageUrl = imageUrl;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("อัปเดตรูปโปรไฟล์เรียบร้อย")),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("เกิดข้อผิดพลาด: $e")),
          );
        }
      }
    }
  }

  void _clearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("ลบประวัติการวิเคราะห์ทั้งหมด"),
        content: Text("คุณแน่ใจหรือไม่ว่าต้องการลบประวัติทั้งหมด? การกระทำนี้ไม่สามารถย้อนกลับได้"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("ยกเลิก"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("ลบประวัติการวิเคราะห์เรียบร้อย")),
              );
            },
            child: Text("ลบ"),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("ลบบัญชีผู้ใช้"),
        content: Text("คุณแน่ใจหรือไม่ว่าต้องการลบบัญชี? การกระทำนี้ไม่สามารถย้อนกลับได้"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("ยกเลิก"),
          ),
          ElevatedButton(
            onPressed: () async {
              final supabase = Supabase.instance.client;
              try {
                await supabase.auth.signOut();
                Navigator.pushReplacementNamed(context, '/welcome');
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("เกิดข้อผิดพลาด: $e")),
                );
              }
            },
            child: Text("ลบ"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFCDF8F7),
        title: const Text('การตั้งค่า', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text("ข้อมูลส่วนตัว", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ListTile(
            leading: profileImage != null
                ? CircleAvatar(backgroundImage: FileImage(profileImage!))
                : (profileImageUrl != null
                    ? CircleAvatar(backgroundImage: NetworkImage(profileImageUrl!))
                    : CircleAvatar(child: Icon(Icons.person))),
            title: Text(username.isNotEmpty ? username : "กำลังโหลด..."),
            subtitle: Text(email.isNotEmpty ? email : "กำลังโหลด..."),
            onTap: _changeProfilePicture,
          ),
          _buildSettingOption(icon: Icons.person, text: "เปลี่ยนชื่อผู้ใช้", onTap: _changeUsername),
          _buildSettingOption(icon: Icons.email, text: "แก้ไขอีเมล", onTap: _changeEmail),
          const Divider(height: 30),

          const Text("จัดการบัญชี", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildSettingOption(icon: Icons.delete, text: "ลบประวัติการวิเคราะห์ทั้งหมด", onTap: _clearHistory),
          _buildSettingOption(icon: Icons.delete_forever, text: "ลบบัญชีผู้ใช้", onTap: _deleteAccount),
          const Divider(height: 30),

          const Text("ข้อมูลและคำแนะนำเพิ่มเติม", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildSettingOption(icon: Icons.help, text: "คำถามที่พบบ่อย (FAQ)", onTap: () {}),
          _buildSettingOption(icon: Icons.contact_support, text: "ติดต่อเรา", onTap: () {}),
          _buildSettingOption(icon: Icons.privacy_tip, text: "เงื่อนไขการใช้งานและนโยบายความเป็นส่วนตัว", onTap: () {}),
          const Divider(height: 30),

          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              ),
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text("ออกจากระบบ", style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingOption({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(text, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
