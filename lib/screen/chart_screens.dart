import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../services/firebase_services.dart';
import '../utils/fotmatter.dart';

class ChartData {
  final String category;
  final double amount;
  final Color color;

  ChartData(this.category, this.amount, this.color);
}

class MonthlyData {
  final String month;
  final double income;
  final double expense;
  final double savings;

  MonthlyData(this.month, this.income, this.expense) : savings = income - expense;
}

class ChartScreen extends StatelessWidget {
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final firebaseService = FirebaseService();

    return Scaffold(
      appBar: AppBar(title: const Text('Grafik Keuangan')),
      body: StreamBuilder<List<Transaction>>(
        stream: firebaseService.getTransactionsStream(user.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final transactions = snapshot.data!;
          final expenseData = <ChartData>[];
          final incomeData = <ChartData>[];

          // Agregasi berdasarkan kategori
          final expenseMap = <String, double>{};
          final incomeMap = <String, double>{};

          for (var t in transactions) {
            if (t.isIncome) {
              incomeMap.update(t.category, (v) => v + t.amount,
                  ifAbsent: () => t.amount);
            } else {
              expenseMap.update(t.category, (v) => v + t.amount,
                  ifAbsent: () => t.amount);
            }
          }

          final colors = [
            Colors.blue,
            Colors.green,
            Colors.orange,
            Colors.purple,
            Colors.red,
            Colors.cyan,
            Colors.pink
          ];

          int i = 0;
          expenseMap.forEach((key, value) {
            expenseData.add(ChartData(key, value, colors[i % colors.length]));
            i++;
          });

          i = 0;
          incomeMap.forEach((key, value) {
            incomeData.add(ChartData(key, value, colors[i % colors.length]));
            i++;
          });

          // Prepare monthly data for savings chart
          final monthlyData = _prepareMonthlyData(transactions);

          return DefaultTabController(
            length: 3,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Pengeluaran'),
                    Tab(text: 'Pemasukan'),
                    Tab(text: 'Tabungan Bulanan'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildPieChart(expenseData),
                      _buildPieChart(incomeData),
                      _buildMonthlyChart(monthlyData),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPieChart(List<ChartData> data) {
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada data untuk ditampilkan',
              style: TextStyle(
                fontSize: 16, 
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mulai tambahkan transaksi untuk melihat grafik',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return SfCircularChart(
      title: ChartTitle(
        text: 'Distribusi ${data.first.category.contains('Gaji') || data.first.category.contains('Bonus') ? 'Pemasukan' : 'Pengeluaran'}',
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      legend: Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        overflowMode: LegendItemOverflowMode.wrap,
      ),
      series: <CircularSeries>[
        PieSeries<ChartData, String>(
          dataSource: data,
          xValueMapper: (ChartData data, _) => data.category,
          yValueMapper: (ChartData data, _) => data.amount,
          pointColorMapper: (ChartData data, _) => data.color,
          dataLabelMapper: (ChartData data, _) =>
              '${data.category}\n${Formatter.formatCurrency(data.amount)}',
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            textStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            labelPosition: ChartDataLabelPosition.outside,
          ),
          enableTooltip: true,
          animationDuration: 1000,
          animationDelay: 0,
          explode: true,
          explodeOffset: '10%',
        ),
      ],
      tooltipBehavior: TooltipBehavior(
        enable: true,
        format: 'point.x: point.y',
        canShowMarker: true,
        header: '',
      ),
    );
  }

  List<MonthlyData> _prepareMonthlyData(List<Transaction> transactions) {
    final Map<String, double> monthlyIncome = {};
    final Map<String, double> monthlyExpense = {};

    for (var transaction in transactions) {
      final monthKey = DateFormat('MMM yyyy').format(transaction.date);
      
      if (transaction.isIncome) {
        monthlyIncome[monthKey] = (monthlyIncome[monthKey] ?? 0) + transaction.amount;
      } else {
        monthlyExpense[monthKey] = (monthlyExpense[monthKey] ?? 0) + transaction.amount;
      }
    }

    final allMonths = <String>{...monthlyIncome.keys, ...monthlyExpense.keys}.toList();
    allMonths.sort((a, b) => DateFormat('MMM yyyy').parse(a).compareTo(DateFormat('MMM yyyy').parse(b)));

    return allMonths.map((month) {
      return MonthlyData(
        month,
        monthlyIncome[month] ?? 0,
        monthlyExpense[month] ?? 0,
      );
    }).toList();
  }

  Widget _buildMonthlyChart(List<MonthlyData> data) {
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada data untuk ditampilkan',
              style: TextStyle(
                fontSize: 16, 
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Data akan muncul setelah Anda memiliki transaksi',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(width: 0),
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      primaryYAxis: NumericAxis(
        numberFormat: NumberFormat.compactCurrency(locale: 'id', symbol: 'Rp '),
        majorGridLines: MajorGridLines(
          width: 1,
          color: Colors.grey.shade300,
        ),
        axisLine: const AxisLine(width: 0),
        labelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
      title: ChartTitle(
        text: 'Analisis Tabungan Bulanan',
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      legend: Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        overflowMode: LegendItemOverflowMode.wrap,
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        format: 'point.y',
        canShowMarker: true,
        header: '',
      ),
      series: <ChartSeries>[
        ColumnSeries<MonthlyData, String>(
          name: 'Pemasukan',
          dataSource: data,
          xValueMapper: (MonthlyData data, _) => data.month,
          yValueMapper: (MonthlyData data, _) => data.income,
          color: Colors.green.shade400,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          animationDuration: 1000,
          animationDelay: 0,
          enableTooltip: true,
          dataLabelSettings: DataLabelSettings(
            isVisible: false,
            textStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ColumnSeries<MonthlyData, String>(
          name: 'Pengeluaran',
          dataSource: data,
          xValueMapper: (MonthlyData data, _) => data.month,
          yValueMapper: (MonthlyData data, _) => data.expense,
          color: Colors.red.shade400,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          animationDuration: 1000,
          animationDelay: 200,
          enableTooltip: true,
          dataLabelSettings: DataLabelSettings(
            isVisible: false,
            textStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        LineSeries<MonthlyData, String>(
          name: 'Tabungan',
          dataSource: data,
          xValueMapper: (MonthlyData data, _) => data.month,
          yValueMapper: (MonthlyData data, _) => data.savings,
          color: Colors.blue.shade600,
          width: 4,
          animationDuration: 1000,
          animationDelay: 400,
          enableTooltip: true,
          markerSettings: MarkerSettings(
            isVisible: true,
            color: Colors.blue.shade600,
            borderColor: Colors.white,
            borderWidth: 2,
            height: 8,
            width: 8,
          ),
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            textStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }
}