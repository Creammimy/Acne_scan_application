import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_acne_scan/screens/acne_tpye.dart';
import 'package:project_acne_scan/screens/scan_screen.dart';
import 'package:project_acne_scan/screens/settings_screen.dart';
import 'package:project_acne_scan/screens/history_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final ImagePicker _picker = ImagePicker();

  String? _username;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final response = await Supabase.instance.client
          .from('users')
          .select('name, profile_image_url')
          .eq('id', user.id)
          .single();

      setState(() {
        _username = response['name'] ?? 'ผู้ใช้';
        _profileImageUrl = response['profile_image_url'];
      });
    }
  }

  Future<void> _selectFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScanScreen(imagePaths: [pickedFile.path]),
        ),
      );
    }
  }

  Future<void> _selectFromGallery() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty && images.length <= 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ScanScreen(imagePaths: images.map((e) => e.path).toList()),
        ),
      );
    } else if (images.length > 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('เลือกรูปภาพได้สูงสุด 3 รูป'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _fetchUserData,
        color: const Color(0xFFCDF8F7),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color:  const Color(0xFFCDF8F7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text(
                      "เริ่มการวิเคราะห์สิวด้วย : ",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildImageOption(
                          imagePath: 'assets/images/camera.PNG',
                          label: 'ถ่ายภาพ',
                          onTap: _selectFromCamera,
                        ),
                        _buildImageOption(
                          imagePath: 'assets/images/gallery.PNG',
                          label: 'เลือกจากคลังรูปภาพ',
                          onTap: _selectFromGallery,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              _buildInfoBox(
                imagePath: 'assets/images/acne_type.PNG',
                text: 'ชนิดของสิว',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AcneTypesScreen()),
                  );
                },
              ),
              // *** ลบกล่องพฤติกรรมที่เสี่ยงออก ***
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFCDF8F7),
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 120,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'สวัสดี ${_username ?? ''},',
            style: const TextStyle(fontSize: 24, color: Colors.black),
          ),
          const SizedBox(height: 5),
          const Text(
            'มาวิเคราะห์สิวกันเถอะ!',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey[300],
            backgroundImage: _profileImageUrl != null
                ? NetworkImage(_profileImageUrl!)
                : null,
            child: _profileImageUrl == null
                ? const Icon(Icons.person, color: Colors.white, size: 30)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildImageOption({
    required String imagePath,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Image.asset(imagePath, width: 50, height: 50),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildInfoBox({
    required String imagePath,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFCDF8F7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Image.asset(imagePath, width: 50, height: 50),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFFCDF8F7),
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'หน้าโฮม'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'ประวัติ'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'ตั้งค่า'),
      ],
      onTap: (index) {
        setState(() => _currentIndex = index);
        if (index == 1) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => HistoryScreen()));
        } else if (index == 2) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => SettingsScreen()));
        }
      },
    );
  }
}
