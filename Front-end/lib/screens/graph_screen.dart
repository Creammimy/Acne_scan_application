import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GraphScreen extends StatefulWidget {
  final String userId;

  const GraphScreen({required this.userId, super.key});

  @override
  _GraphScreenState createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> allResults = [];
  bool isLoading = true;
  String selectedRange = 'week';
  Set<String> selectedTypes = {};
  bool showTotalAcne = true;
  bool showComparison = true;
  bool showTrendLine = false;
  bool _isExpanded = false;
  bool _firstLoad = true;

  // สีสำหรับกราฟ
  final List<Color> graphColors = [
    Colors.red,
    Colors.orange,
    Colors.blue,
    Colors.purple,
    Colors.green,
    Colors.teal,
    Colors.brown,
    Colors.pink,
    Colors.indigo,
    Colors.cyan,
  ];

  // ชื่อประเภทสิวภาษาไทย
  static const Map<String, String> typeNameTH = {
    'Pustula': 'สิวตุ่มหนอง',
    'blackhead': 'สิวหัวดำ',
    'whitehead': 'สิวหัวขาว',
    'papula': 'สิวตุ่มแดง',
    'nodules': 'สิวไต',
    'fungal acne': 'สิวเชื้อรา',
    'acne fulminans': 'สิวอักเสบรุนแรง',
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => isLoading = true);
      await fetchAcneData();
      if (_firstLoad && mounted) {
        _showFirstTimeTooltip();
        _firstLoad = false;
      }
    } catch (e) {
      _showErrorSnackbar('เกิดข้อผิดพลาดในการโหลดข้อมูล');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showFirstTimeTooltip() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('แตะกราฟเพื่อดูค่าที่แต่ละจุด | ปรับช่วงเวลาได้ที่เมนูด้านบน'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'เข้าใจแล้ว',
          onPressed: () {},
        ),
      ),
    );
  }

  Future<void> fetchAcneData() async {
    final response = await supabase
        .from('results_info')
        .select('created_at, summary')
        .eq('user_id', widget.userId)
        .order('created_at', ascending: true);

    if (mounted) {
      setState(() {
        allResults = response.map<Map<String, dynamic>>((entry) {
          final summaryData = entry['summary'];
          final summaryMap = _parseSummaryData(summaryData);

          return {
            'created_at': entry['created_at'],
            'total': (summaryMap['total'] ?? 0) as int,
            'types': summaryMap['types'] != null
                ? Map<String, dynamic>.from(summaryMap['types'])
                : <String, dynamic>{},
          };
        }).toList();
      });
    }
  }

  Map<String, dynamic> _parseSummaryData(dynamic summaryData) {
    if (summaryData is String) {
      return jsonDecode(summaryData) as Map<String, dynamic>;
    } else if (summaryData is Map) {
      return Map<String, dynamic>.from(summaryData);
    }
    return {};
  }

  List<Map<String, dynamic>> filterResultsByRange(String range) {
    if (allResults.isEmpty) return [];

    final now = DateTime.now();
    DateTime startDate;

    switch (range) {
      case 'week':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'month':
        startDate = now.subtract(const Duration(days: 30));
        break;
      case '3months':
        startDate = now.subtract(const Duration(days: 90));
        break;
      case 'year':
        startDate = now.subtract(const Duration(days: 365));
        break;
      case 'all':
      default:
        return allResults;
    }

    return allResults
        .where((e) => DateTime.parse(e['created_at']).isAfter(startDate))
        .toList();
  }

  double calculateYInterval(List<FlSpot> spots) {
    if (spots.isEmpty) return 1;
    final maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    return (maxY / 5).ceilToDouble().clamp(1, double.infinity);
  }

  Widget _buildLineChart({
    required List<FlSpot> spots,
    required List<String> labels,
    required String title,
    required Color color,
    required String summary,
    bool showTrend = false,
  }) {
    final interval = calculateYInterval(spots);
    final lineBars = <LineChartBarData>[
      LineChartBarData(
        spots: spots,
        isCurved: true,
        color: color,
        barWidth: 3,
        belowBarData: BarAreaData(show: true, color: color.withOpacity(0.2)),
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) =>
              FlDotCirclePainter(radius: 4, color: color, strokeWidth: 2),
        ),
      ),
    ];

    if (showTrend && spots.length > 1) {
      lineBars.add(_createTrendLine(spots, color));
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () => setState(() => _isExpanded = !_isExpanded),
                ),
              ],
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState:
                  _isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              firstChild: Column(
                children: [
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 250,
                    child: LineChart(
                      LineChartData(
                        minX: 0,
                        maxX: spots.isEmpty ? 1 : spots.last.x,
                        minY: 0,
                        maxY: spots.isEmpty
                            ? 1
                            : spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.1,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          horizontalInterval: interval,
                          verticalInterval: 1,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.grey[300]!,
                            strokeWidth: 1,
                            dashArray: const [4],
                          ),
                          getDrawingVerticalLine: (value) => FlLine(
                            color: Colors.grey[300]!,
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: interval,
                              getTitlesWidget: (value, meta) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < labels.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      labels[index],
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.grey[400]!, width: 1),
                        ),
                        lineBarsData: lineBars,
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                           
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((spot) {
                                final index = spot.x.toInt();
                                return LineTooltipItem(
                                  '${labels[index]}\n${spot.y.toInt()} จุด',
                                  TextStyle(
                                      color: color, fontWeight: FontWeight.bold),
                                );
                              }).toList();
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryCard(summary, color),
                ],
              ),
              secondChild: _buildSummaryCard(summary, color),
            ),
          ],
        ),
      ),
    );
  }

  LineChartBarData _createTrendLine(List<FlSpot> spots, Color color) {
    final n = spots.length;
    final sumX = spots.fold(0.0, (sum, spot) => sum + spot.x);
    final sumY = spots.fold(0.0, (sum, spot) => sum + spot.y);
    final sumXY = spots.fold(0.0, (sum, spot) => sum + spot.x * spot.y);
    final sumXX = spots.fold(0.0, (sum, spot) => sum + spot.x * spot.x);

    final slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
    final intercept = (sumY - slope * sumX) / n;

    return LineChartBarData(
      spots: [
        FlSpot(0, intercept),
        FlSpot(spots.last.x, intercept + slope * spots.last.x),
      ],
      isCurved: false,
      color: color.withOpacity(0.5),
      barWidth: 2,
      dashArray: const [8, 4],
      dotData: const FlDotData(show: false),
    );
  }

  Widget _buildSummaryCard(String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartExplanation() {
    return ExpansionTile(
      title: const Text('📊 วิธีอ่านกราฟ', style: TextStyle(fontWeight: FontWeight.bold)),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildExplanationItem('แกนนอน (X)', 'แสดงวันที่บันทึกข้อมูล'),
              _buildExplanationItem('แกนตั้ง (Y)', 'แสดงจำนวนสิวที่พบ'),
              _buildExplanationItem('เส้นแนวโน้ม', 'แสดงทิศทางรวมของข้อมูล (สีจาง)'),
              _buildExplanationItem('พื้นที่ใต้กราฟ', 'แสดงความหนาแน่นของข้อมูล'),
              const SizedBox(height: 8),
              Text('หมายเหตุ: แตะที่จุดบนกราฟเพื่อดูค่าที่แต่ละวัน',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExplanationItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 8, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(description, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonSection(List<Map<String, dynamic>> filteredResults) {
    if (filteredResults.length < 2) return Container();

    final half = filteredResults.length ~/ 2;
    final firstHalf = filteredResults.sublist(0, half);
    final secondHalf = filteredResults.sublist(half);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: showComparison
          ? Column(
              children: [
                _buildComparisonExplanation(),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "📈 การเปรียบเทียบช่วงเวลา",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => setState(() => showComparison = false),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildComparisonChart(firstHalf, secondHalf),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.compare),
                label: const Text("แสดงการเปรียบเทียบ"),
                onPressed: () => setState(() => showComparison = true),
              ),
            ),
    );
  }

  Widget _buildComparisonExplanation() {
    return const Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📈 การเปรียบเทียบช่วงเวลา',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('ระบบจะแบ่งข้อมูลออกเป็น 2 ช่วงเท่าๆ กันเพื่อเปรียบเทียบ:\n'
                '- ช่วงแรก: ข้อมูลครึ่งแรก\n'
                '- ช่วงหลัง: ข้อมูลครึ่งหลัง\n'
                '- % เปลี่ยนแปลง: คำนวณจาก (ช่วงหลัง - ช่วงแรก) / ช่วงแรก',
                style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonChart(
      List<Map<String, dynamic>> firstPeriod, List<Map<String, dynamic>> secondPeriod) {
    final firstTotal = firstPeriod.fold(0, (sum, item) => sum + (item['total'] as int));
    final secondTotal = secondPeriod.fold(0, (sum, item) => sum + (item['total'] as int));

    final firstPeriodTypes = _aggregateTypes(firstPeriod);
    final secondPeriodTypes = _aggregateTypes(secondPeriod);

    return Column(
      children: [
        _buildComparisonItem(
          title: "สิวทั้งหมด",
          firstValue: firstTotal,
          secondValue: secondTotal,
          icon: Icons.ac_unit,
        ),
        const Divider(),
        ...firstPeriodTypes.entries.map((entry) {
          final type = entry.key;
          final firstCount = entry.value;
          final secondCount = secondPeriodTypes[type] ?? 0;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _buildComparisonItem(
              title: typeNameTH[type] ?? type,
              firstValue: firstCount,
              secondValue: secondCount,
              icon: _getTypeIcon(type),
            ),
          );
        }).toList(),
      ],
    );
  }

  Map<String, int> _aggregateTypes(List<Map<String, dynamic>> results) {
    final types = <String, int>{};
    for (final result in results) {
      (result['types'] as Map<String, dynamic>).forEach((key, value) {
        types[key] = (types[key] ?? 0) + (value as int);
      });
    }
    return types;
  }

  Widget _buildComparisonItem({
    required String title,
    required int firstValue,
    required int secondValue,
    required IconData icon,
  }) {
    final change = secondValue - firstValue;
    final percentageChange = firstValue == 0
        ? 0.0
        : (change / firstValue * 100);

    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(
            '$firstValue',
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Text(
            '$secondValue',
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                '${percentageChange.toStringAsFixed(1)}%',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: change > 0 ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                change > 0 ? 'เพิ่มขึ้น' : 'ลดลง',
                style: TextStyle(
                  fontSize: 10,
                  color: change > 0 ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Pustula':
        return Icons.water_drop;
      case 'blackhead':
        return Icons.circle_outlined;
      case 'whitehead':
        return Icons.circle;
      case 'papula':
        return Icons.whatshot;
      case 'nodules':
        return Icons.hexagon;
      case 'fungal acne':
        return Icons.grass;
      case 'acne fulminans':
        return Icons.warning;
      default:
        return Icons.ac_unit;
    }
  }

  Widget _buildFilterChips() {
    final filteredTypes = _getAvailableTypes();
    if (filteredTypes.isEmpty) return Container();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildChip(
            label: 'ทั้งหมด',
            selected: selectedTypes.length == filteredTypes.length + 1,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  selectedTypes = {...filteredTypes, '__total__'};
                  showTotalAcne = true;
                } else {
                  selectedTypes.clear();
                  showTotalAcne = false;
                }
              });
            },
          ),
          _buildChip(
            label: 'รวมทั้งหมด',
            selected: showTotalAcne,
            icon: Icons.stacked_bar_chart,
            onSelected: (selected) {
              setState(() {
                showTotalAcne = selected;
                if (selected) {
                  selectedTypes.add('__total__');
                } else {
                  selectedTypes.remove('__total__');
                }
              });
            },
          ),
          ...filteredTypes.map((type) {
            return _buildChip(
              label: typeNameTH[type] ?? type,
              selected: selectedTypes.contains(type),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedTypes.add(type);
                  } else {
                    selectedTypes.remove(type);
                  }
                });
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool selected,
    IconData? icon,
    required ValueChanged<bool> onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: onSelected,
        avatar: icon != null ? Icon(icon, size: 16) : null,
        selectedColor: Colors.blue[200],
        checkmarkColor: Colors.blue[800],
        showCheckmark: true,
        labelStyle: TextStyle(
          color: selected ? Colors.blue[800] : Colors.grey[800],
        ),
      ),
    );
  }

  Set<String> _getAvailableTypes() {
    final types = <String>{};
    for (final result in allResults) {
      (result['types'] as Map<String, dynamic>).keys.forEach(types.add);
    }
    return types;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.data_array, size: 50, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('ไม่มีข้อมูลในช่วงเวลาที่เลือก',
              style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('ลองปรับช่วงเวลา หรือบันทึกข้อมูลใหม่',
              style: TextStyle(color: Colors.grey[500])),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('รีเฟรชข้อมูล'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'ลองอีกครั้ง',
          onPressed: _loadData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('กำลังโหลดข้อมูล...'),
            ],
          ),
        ),
      );
    }

    final filteredResults = filterResultsByRange(selectedRange);
    if (filteredResults.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("กราฟพัฒนาการการรักษาผิว"),
          backgroundColor: const Color(0xFFCDF8F7),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
            ),
          ],
        ),
        body: _buildEmptyState(),
      );
    }

    final formatter = DateFormat('dd/MM');
    final dates = filteredResults.map((e) {
      final date = DateTime.parse(e['created_at']);
      return formatter.format(date);
    }).toList();

    final totalSpots = filteredResults.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), (entry.value['total'] as num).toDouble());
    }).toList();

    final firstTotal = filteredResults.first['total'];
    final lastTotal = filteredResults.last['total'];
    final totalSummary =
        "สิวทั้งหมดของคุณมีแนวโน้ม${firstTotal > lastTotal ? 'ลดลง' : 'เพิ่มขึ้น'} "
        "${(lastTotal - firstTotal).abs()} จุด\n"
        "จาก ${dates.first} ถึง ${dates.last}";

    final typeSpots = <String, List<FlSpot>>{};
    final typeSummaries = <String, String>{};

    for (int i = 0; i < filteredResults.length; i++) {
      final types = filteredResults[i]['types'] as Map<String, dynamic>? ?? {};
      types.forEach((type, count) {
        typeSpots.putIfAbsent(type, () => []);
        typeSpots[type]!.add(FlSpot(i.toDouble(), (count as num).toDouble()));
      });
    }

    typeSpots.forEach((type, spots) {
      final first = spots.first.y;
      final last = spots.last.y;
      typeSummaries[type] =
          "สิวชนิด ${typeNameTH[type] ?? type} มีแนวโน้ม${first > last ? 'ลดลง' : 'เพิ่มขึ้น'} "
          "${(last - first).abs().toInt()} จุด";
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("กราฟพัฒนาการของใบหน้า"),
        backgroundColor: const Color(0xFFCDF8F7),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'รีเฟรชข้อมูล',
          ),
          DropdownButton<String>(
            value: selectedRange,
            underline: Container(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedRange = value;
                  _isExpanded = false;
                });
              }
            },
            items: const [
              DropdownMenuItem(value: 'week', child: Text("สัปดาห์")),
              DropdownMenuItem(value: 'month', child: Text("เดือน")),
              DropdownMenuItem(value: '3months', child: Text("3 เดือน")),
              DropdownMenuItem(value: 'year', child: Text("ปี")),
              DropdownMenuItem(value: 'all', child: Text("ทั้งหมด")),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.trending_up),
            onPressed: () => setState(() => showTrendLine = !showTrendLine),
            tooltip: 'แสดง/ซ่อน เส้นแนวโน้ม\nเส้นแนวโน้มช่วยดูทิศทางรวมของข้อมูล',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildChartExplanation(),
                  if (showTotalAcne)
                    _buildLineChart(
                      spots: totalSpots,
                      labels: dates,
                      title: "จำนวนสิวทั้งหมด (จุด)",
                      color: Colors.blue,
                      summary: totalSummary,
                      showTrend: showTrendLine,
                    ),
                  ...typeSpots.entries
                      .where((entry) => selectedTypes.contains(entry.key))
                      .mapIndexed((i, entry) {
                    return _buildLineChart(
                      spots: entry.value,
                      labels: dates,
                      title: "จำนวนสิวประเภท: ${typeNameTH[entry.key] ?? entry.key}",
                      color: graphColors[i % graphColors.length],
                      summary: typeSummaries[entry.key] ?? "",
                      showTrend: showTrendLine,
                    );
                  }).toList(),
                  _buildComparisonSection(filteredResults),
                ],
              ),
            ),
          ),
        ],
      ),
      
    );
  }
}

extension MapIndexed<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(int index, E item) f) {
    int index = 0;
    return map((item) => f(index++, item));
  }
}