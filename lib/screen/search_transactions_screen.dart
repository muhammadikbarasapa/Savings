import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_services.dart';
import '../models/transaction_model.dart';
import '../widgets/transaction_card.dart';
import '../utils/fotmatter.dart';
import 'edit_transaction_screen.dart';

class SearchTransactionsScreen extends StatefulWidget {
  const SearchTransactionsScreen({super.key});

  @override
  State<SearchTransactionsScreen> createState() => _SearchTransactionsScreenState();
}

class _SearchTransactionsScreenState extends State<SearchTransactionsScreen> {
  final _firebaseService = FirebaseService();
  final _searchController = TextEditingController();
  String _selectedFilter = 'Semua';
  String _selectedCategory = 'Semua Kategori';
  DateTime? _startDate;
  DateTime? _endDate;
  double _minAmount = 0;
  double _maxAmount = 10000000;

  final List<String> _categories = [
    'Semua Kategori',
    'Gaji',
    'Bonus',
    'Freelance',
    'Investasi',
    'Makanan',
    'Transportasi',
    'Belanja',
    'Hiburan',
    'Kesehatan',
    'Pendidikan',
    'Tagihan',
    'Lainnya',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Transaction> _filterTransactions(List<Transaction> transactions) {
    var filtered = transactions.where((transaction) {
      // Search by title
      if (_searchController.text.isNotEmpty) {
        if (!transaction.title.toLowerCase().contains(_searchController.text.toLowerCase())) {
          return false;
        }
      }

      // Filter by type
      if (_selectedFilter == 'Pemasukan' && !transaction.isIncome) {
        return false;
      } else if (_selectedFilter == 'Pengeluaran' && transaction.isIncome) {
        return false;
      }

      // Filter by category
      if (_selectedCategory != 'Semua Kategori' && transaction.category != _selectedCategory) {
        return false;
      }

      // Filter by date range
      if (_startDate != null && transaction.date.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null && transaction.date.isAfter(_endDate!)) {
        return false;
      }

      // Filter by amount range
      if (transaction.amount < _minAmount || transaction.amount > _maxAmount) {
        return false;
      }

      return true;
    }).toList();

    // Sort by date (newest first)
    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Transaksi'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari berdasarkan judul transaksi...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 16),

                // Filter Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Semua', _selectedFilter),
                      _buildFilterChip('Pemasukan', _selectedFilter),
                      _buildFilterChip('Pengeluaran', _selectedFilter),
                      const SizedBox(width: 8),
                      _buildDropdownFilter(),
                      const SizedBox(width: 8),
                      _buildDateRangeFilter(),
                      const SizedBox(width: 8),
                      _buildAmountRangeFilter(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Results Section
          Expanded(
            child: StreamBuilder<List<Transaction>>(
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
                final filteredTransactions = _filterTransactions(allTransactions);

                if (filteredTransactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          allTransactions.isEmpty 
                              ? 'Belum ada transaksi'
                              : 'Tidak ada transaksi yang sesuai dengan filter',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          allTransactions.isEmpty
                              ? 'Mulai tambahkan transaksi'
                              : 'Coba ubah kriteria pencarian',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Summary
                final totalIncome = filteredTransactions
                    .where((t) => t.isIncome)
                    .fold(0.0, (sum, t) => sum + t.amount);
                final totalExpense = filteredTransactions
                    .where((t) => !t.isIncome)
                    .fold(0.0, (sum, t) => sum + t.amount);

                return Column(
                  children: [
                    // Summary Card
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade50, Colors.blue.shade100],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryItem('Ditemukan', '${filteredTransactions.length}', Colors.blue),
                          _buildSummaryItem('Pemasukan', Formatter.formatCurrency(totalIncome), Colors.green),
                          _buildSummaryItem('Pengeluaran', Formatter.formatCurrency(totalExpense), Colors.red),
                        ],
                      ),
                    ),

                    // Transactions List
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = filteredTransactions[index];
                          return TransactionCard(
                            transaction: transaction,
                            onDelete: () async {
                              await _firebaseService.deleteTransaction(transaction.id);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
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
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String selectedFilter) {
    final isSelected = selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = label;
          });
        },
        selectedColor: Colors.blue.shade100,
        checkmarkColor: Colors.blue,
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  Widget _buildDropdownFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          items: _categories.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(
                category,
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedCategory = value;
              });
            }
          },
          icon: const Icon(Icons.keyboard_arrow_down, size: 16),
        ),
      ),
    );
  }

  Widget _buildDateRangeFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: InkWell(
        onTap: _selectDateRange,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.date_range, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              _startDate == null 
                  ? 'Tanggal' 
                  : '${_startDate!.day}/${_startDate!.month} - ${_endDate?.day}/${_endDate?.month ?? '...'}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountRangeFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: InkWell(
        onTap: _selectAmountRange,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.attach_money, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              _minAmount == 0 && _maxAmount == 10000000
                  ? 'Jumlah'
                  : '${_minAmount.toInt() / 1000}K - ${_maxAmount.toInt() / 1000}K',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
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
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _selectAmountRange() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        double tempMin = _minAmount;
        double tempMax = _maxAmount;
        
        return AlertDialog(
          title: const Text('Filter Jumlah'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Jumlah Minimum (Rp)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  tempMin = double.tryParse(value) ?? 0;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Jumlah Maksimum (Rp)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  tempMax = double.tryParse(value) ?? 10000000;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _minAmount = tempMin;
                  _maxAmount = tempMax;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Terapkan'),
            ),
          ],
        );
      },
    );
  }
}
