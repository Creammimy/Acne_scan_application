import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project_acne_scan/screens/graph_screen.dart';
import 'package:project_acne_scan/screens/details_screen.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> historyData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHistoryData();
  }

  Future<void> fetchHistoryData() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      print("ยังไม่มีผู้ใช้ล็อกอิน");
      return;
    }

    final userId = user.id;

    final response = await supabase
        .from('results_info')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final List<Map<String, dynamic>> formatted = response.map((item) {
      final imageUrl = (item['image_urls'] as List).isNotEmpty
          ? item['image_urls'][0]
          : 'https://via.placeholder.com/80';

      final createdAt = DateTime.parse(item['created_at']);
      final summary = item['summary'] ?? {};
      final totalCount = summary['total'] ?? 0;

      return {
        'result_id': item['result_id'],
        'image_url': imageUrl,
        'analysis_date':
            "${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}",
        'total_acne_count': totalCount,
      };
    }).toList();

    setState(() {
      historyData = formatted;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ประวัติการวิเคราะห์ย้อนหลัง"),
        backgroundColor: Color(0xFFCDF8F7),
      ),
      body: Column(
  children: [
    Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
  onPressed: () {
    final user = supabase.auth.currentUser;
    if (user != null) {
       print('User ID: ${user.id}');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GraphScreen(userId: user.id)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("กรุณาเข้าสู่ระบบก่อน")),
      );
    }
  },
  child: Text('ดูกราฟพัฒนาการ'),
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFFCDF8F7),
  ),
),
    ),
    isLoading
        ? Center(child: CircularProgressIndicator())
        : Expanded(
            child: RefreshIndicator(
              onRefresh: fetchHistoryData,
              child: ListView.builder(
                itemCount: historyData.length,
                itemBuilder: (context, index) {
                  final data = historyData[index];
                  return Card(
                    margin: EdgeInsets.all(10),
                    child: ListTile(
                      leading: SizedBox(
                        width: 80,
                        height: 80,
                        child: Image.network(
                          data['image_url'],
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text("วันที่: ${data['analysis_date']}"),
                      subtitle: Text(
                          "จำนวนสิวทั้งหมด: ${data['total_acne_count']} จุด"),
                      onTap: () async {
                        final resultId = data['result_id'];
                        final response = await supabase
                            .from('results_info')
                            .select()
                            .eq('result_id', resultId)
                            .single();

                        if (response != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailScreen(resultData: response),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("ไม่พบข้อมูลของผลลัพธ์นี้")),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ),
  ],
),
    );
  }
}
