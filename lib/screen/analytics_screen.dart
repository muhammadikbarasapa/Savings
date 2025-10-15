import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../services/firebase_services.dart';
import '../utils/fotmatter.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with TickerProviderStateMixin {
  final _firebaseService = FirebaseService();
  late TabController _tabController;
  String _selectedPeriod = 'Bulan Ini';

  final List<String> _periods = [
    'Minggu Ini',
    'Bulan Ini',
    '3 Bulan Terakhir',
    'Tahun Ini',
    'Semua Waktu',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Transaction> _filterTransactionsByPeriod(List<Transaction> transactions, String period) {
    final now = DateTime.now();
    final filtered = <Transaction>[];

    for (final transaction in transactions) {
      bool include = false;
      
      switch (period) {
        case 'Minggu Ini':
          final weekAgo = now.subtract(const Duration(days: 7));
          include = transaction.date.isAfter(weekAgo);
          break;
        case 'Bulan Ini':
          final monthAgo = DateTime(now.year, now.month, 1);
          include = transaction.date.isAfter(monthAgo);
          break;
        case '3 Bulan Terakhir':
          final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
          include = transaction.date.isAfter(threeMonthsAgo);
          break;
        case 'Tahun Ini':
          final yearStart = DateTime(now.year, 1, 1);
          include = transaction.date.isAfter(yearStart);
          break;
        case 'Semua Waktu':
          include = true;
          break;
      }
      
      if (include) {
        filtered.add(transaction);
      }
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Trends', icon: Icon(Icons.trending_up)),
            Tab(text: 'Categories', icon: Icon(Icons.pie_chart)),
            Tab(text: 'Insights', icon: Icon(Icons.lightbulb_outline)),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.calendar_today),
            onSelected: (String value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (BuildContext context) {
              return _periods.map((String period) {
                return PopupMenuItem<String>(
                  value: period,
                  child: Row(
                    children: [
                      if (_selectedPeriod == period) 
                        const Icon(Icons.check, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(period),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Transaction>>(
        stream: _firebaseService.getTransactionsStream(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          final allTransactions = snapshot.data ?? [];
          final transactions = _filterTransactionsByPeriod(allTransactions, _selectedPeriod);

          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada data untuk periode $_selectedPeriod',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mulai tambahkan transaksi untuk melihat analytics',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(transactions),
              _buildTrendsTab(transactions),
              _buildCategoriesTab(transactions),
              _buildInsightsTab(transactions),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(List<Transaction> transactions) {
    final stats = _calculateStats(transactions);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period Selector
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Text(
                  'Periode: $_selectedPeriod',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Key Metrics
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildMetricCard(
                'Total Pemasukan',
                Formatter.formatCurrency(stats['totalIncome'] ?? 0),
                Colors.green,
                Icons.trending_up,
              ),
              _buildMetricCard(
                'Total Pengeluaran',
                Formatter.formatCurrency(stats['totalExpense'] ?? 0),
                Colors.red,
                Icons.trending_down,
              ),
              _buildMetricCard(
                'Saldo Bersih',
                Formatter.formatCurrency(stats['netBalance'] ?? 0),
                (stats['netBalance'] ?? 0) >= 0 ? Colors.blue : Colors.orange,
                Icons.account_balance_wallet,
              ),
              _buildMetricCard(
                'Jumlah Transaksi',
                '${stats['transactionCount']}',
                Colors.purple,
                Icons.receipt_long,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Stats
          _buildQuickStatsCard(stats),
        ],
      ),
    );
  }

  Widget _buildTrendsTab(List<Transaction> transactions) {
    final monthlyData = _prepareMonthlyTrends(transactions);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tren Pemasukan vs Pengeluaran',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
                labelStyle: const TextStyle(fontSize: 10),
              ),
              primaryYAxis: NumericAxis(
                numberFormat: NumberFormat.compactCurrency(locale: 'id', symbol: 'Rp '),
                labelStyle: const TextStyle(fontSize: 10),
              ),
              series: <ChartSeries>[
                LineSeries<TrendData, String>(
                  name: 'Pemasukan',
                  dataSource: monthlyData,
                  xValueMapper: (TrendData data, _) => data.period,
                  yValueMapper: (TrendData data, _) => data.income,
                  color: Colors.green,
                  width: 3,
                  markerSettings: const MarkerSettings(isVisible: true),
                  animationDuration: 1000,
                ),
                LineSeries<TrendData, String>(
                  name: 'Pengeluaran',
                  dataSource: monthlyData,
                  xValueMapper: (TrendData data, _) => data.period,
                  yValueMapper: (TrendData data, _) => data.expense,
                  color: Colors.red,
                  width: 3,
                  markerSettings: const MarkerSettings(isVisible: true),
                  animationDuration: 1000,
                ),
              ],
              legend: const Legend(isVisible: true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab(List<Transaction> transactions) {
    final incomeData = _prepareCategoryData(transactions.where((t) => t.isIncome).toList());
    final expenseData = _prepareCategoryData(transactions.where((t) => !t.isIncome).toList());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Distribusi Kategori',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Income Chart
          if (incomeData.isNotEmpty) ...[
            const Text(
              'Pemasukan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: SfCircularChart(
                series: <CircularSeries>[
                  PieSeries<CategoryData, String>(
                    dataSource: incomeData,
                    xValueMapper: (CategoryData data, _) => data.category,
                    yValueMapper: (CategoryData data, _) => data.amount,
                    pointColorMapper: (CategoryData data, _) => data.color,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                    animationDuration: 1000,
                  ),
                ],
                legend: const Legend(isVisible: true),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Expense Chart
          if (expenseData.isNotEmpty) ...[
            const Text(
              'Pengeluaran',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: SfCircularChart(
                series: <CircularSeries>[
                  PieSeries<CategoryData, String>(
                    dataSource: expenseData,
                    xValueMapper: (CategoryData data, _) => data.category,
                    yValueMapper: (CategoryData data, _) => data.amount,
                    pointColorMapper: (CategoryData data, _) => data.color,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                    animationDuration: 1000,
                  ),
                ],
                legend: const Legend(isVisible: true),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInsightsTab(List<Transaction> transactions) {
    final insights = _generateInsights(transactions);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Insights & Rekomendasi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ...insights.map((insight) => _buildInsightCard(insight)),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsCard(Map<String, double> stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistik Cepat',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickStatItem(
                'Rata-rata Pemasukan/Hari',
                Formatter.formatCurrency(stats['avgIncomePerDay'] ?? 0),
                Colors.green,
              ),
              _buildQuickStatItem(
                'Rata-rata Pengeluaran/Hari',
                Formatter.formatCurrency(stats['avgExpensePerDay'] ?? 0),
                Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInsightCard(String insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.lightbulb_outline, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              insight,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, double> _calculateStats(List<Transaction> transactions) {
    double totalIncome = 0;
    double totalExpense = 0;
    int transactionCount = transactions.length;

    for (final transaction in transactions) {
      if (transaction.isIncome) {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;
      }
    }

    final netBalance = totalIncome - totalExpense;
    final days = _getDaysInPeriod(_selectedPeriod);
    final avgIncomePerDay = totalIncome / days;
    final avgExpensePerDay = totalExpense / days;

    return {
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'netBalance': netBalance,
      'transactionCount': transactionCount.toDouble(),
      'avgIncomePerDay': avgIncomePerDay,
      'avgExpensePerDay': avgExpensePerDay,
    };
  }

  int _getDaysInPeriod(String period) {
    final now = DateTime.now();
    switch (period) {
      case 'Minggu Ini':
        return 7;
      case 'Bulan Ini':
        return now.day;
      case '3 Bulan Terakhir':
        return 90;
      case 'Tahun Ini':
        return now.difference(DateTime(now.year, 1, 1)).inDays + 1;
      case 'Semua Waktu':
        return 365;
      default:
        return 30;
    }
  }

  List<TrendData> _prepareMonthlyTrends(List<Transaction> transactions) {
    final Map<String, double> monthlyIncome = {};
    final Map<String, double> monthlyExpense = {};

    for (final transaction in transactions) {
      final periodKey = DateFormat('MMM').format(transaction.date);
      
      if (transaction.isIncome) {
        monthlyIncome[periodKey] = (monthlyIncome[periodKey] ?? 0) + transaction.amount;
      } else {
        monthlyExpense[periodKey] = (monthlyExpense[periodKey] ?? 0) + transaction.amount;
      }
    }

    final allPeriods = <String>{...monthlyIncome.keys, ...monthlyExpense.keys}.toList();
    
    return allPeriods.map((period) {
      return TrendData(
        period,
        monthlyIncome[period] ?? 0,
        monthlyExpense[period] ?? 0,
      );
    }).toList();
  }

  List<CategoryData> _prepareCategoryData(List<Transaction> transactions) {
    final Map<String, double> categoryMap = {};
    
    for (final transaction in transactions) {
      categoryMap[transaction.category] = 
          (categoryMap[transaction.category] ?? 0) + transaction.amount;
    }

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.cyan,
      Colors.pink,
      Colors.teal,
    ];

    int colorIndex = 0;
    return categoryMap.entries.map((entry) {
      return CategoryData(
        entry.key,
        entry.value,
        colors[colorIndex++ % colors.length],
      );
    }).toList();
  }

  List<String> _generateInsights(List<Transaction> transactions) {
    final insights = <String>[];
    final stats = _calculateStats(transactions);

    if ((stats['netBalance'] ?? 0) < 0) {
      insights.add('Saldo Anda negatif. Pertimbangkan untuk mengurangi pengeluaran atau menambah pemasukan.');
    } else if ((stats['netBalance'] ?? 0) > (stats['totalIncome'] ?? 0) * 0.3) {
      insights.add('Excellent! Anda menabung lebih dari 30% dari total pemasukan.');
    }

    if ((stats['avgExpensePerDay'] ?? 0) > (stats['avgIncomePerDay'] ?? 0)) {
      insights.add('Pengeluaran harian rata-rata lebih tinggi dari pemasukan. Perlu evaluasi budget.');
    }

    final incomeTransactions = transactions.where((t) => t.isIncome).length;
    final expenseTransactions = transactions.where((t) => !t.isIncome).length;
    
    if (expenseTransactions > incomeTransactions * 2) {
      insights.add('Jumlah transaksi pengeluaran jauh lebih banyak. Coba fokus pada pemasukan.');
    }

    if (insights.isEmpty) {
      insights.add('Finansial Anda terlihat sehat! Terus pertahankan kebiasaan baik ini.');
    }

    return insights;
  }
}

class TrendData {
  final String period;
  final double income;
  final double expense;

  TrendData(this.period, this.income, this.expense);
}

class CategoryData {
  final String category;
  final double amount;
  final Color color;

  CategoryData(this.category, this.amount, this.color);
}
