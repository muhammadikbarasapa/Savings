import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_services.dart';
import '../models/transaction_model.dart';
import '../widgets/transaction_card.dart';
import 'edit_transaction_screen.dart';

class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  final _firebaseService = FirebaseService();
  String _selectedFilter = 'Semua';
  final List<String> _filterOptions = ['Semua', 'Pemasukan', 'Pengeluaran'];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User tidak ditemukan')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua Transaksi'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (String value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (BuildContext context) {
              return _filterOptions.map((String option) {
                return PopupMenuItem<String>(
                  value: option,
                  child: Row(
                    children: [
                      if (_selectedFilter == option) 
                        const Icon(Icons.check, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(option),
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
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          List<Transaction> transactions = snapshot.data ?? [];
          
          // Filter transactions based on selected filter
          if (_selectedFilter == 'Pemasukan') {
            transactions = transactions.where((t) => t.isIncome).toList();
          } else if (_selectedFilter == 'Pengeluaran') {
            transactions = transactions.where((t) => !t.isIncome).toList();
          }

          // Sort transactions by date (newest first)
          transactions.sort((a, b) => b.date.compareTo(a.date));

          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.receipt_long,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada transaksi',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedFilter == 'Semua' 
                        ? 'Mulai catat pemasukan dan pengeluaran Anda'
                        : 'Belum ada $_selectedFilter',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          // Calculate totals for the filtered data
          double totalIncome = 0;
          double totalExpense = 0;
          for (var transaction in transactions) {
            if (transaction.isIncome) {
              totalIncome += transaction.amount;
            } else {
              totalExpense += transaction.amount;
            }
          }

          return Column(
            children: [
              // Summary Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(
                      'Total Pemasukan',
                      totalIncome,
                      Colors.green,
                      Icons.trending_up,
                    ),
                    _buildSummaryItem(
                      'Total Pengeluaran',
                      totalExpense,
                      Colors.red,
                      Icons.trending_down,
                    ),
                    _buildSummaryItem(
                      'Saldo',
                      totalIncome - totalExpense,
                      totalIncome - totalExpense >= 0 ? Colors.blue : Colors.orange,
                      Icons.account_balance_wallet,
                    ),
                  ],
                ),
              ),

              // Filter indicator
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Menampilkan $_selectedFilter (${transactions.length} transaksi)',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ),

              // Transactions List
              Expanded(
                child: ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return TransactionCard(
                      transaction: transaction,
                      onDelete: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await _firebaseService.deleteTransaction(transaction.id);
                        if (mounted) {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Transaksi berhasil dihapus'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditTransactionScreen(
                              transaction: transaction,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryItem(String label, double value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _formatCurrency(value),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double amount) {
    return 'Rp${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]}.',
    )}';
  }
}
