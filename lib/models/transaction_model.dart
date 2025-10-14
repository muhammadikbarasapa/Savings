class Transaction {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final bool isIncome;

  Transaction({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.isIncome,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.millisecondsSinceEpoch,
      'isIncome': isIncome,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      amount: map['amount'].toDouble(),
      category: map['category'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      isIncome: map['isIncome'],
    );
  }
}