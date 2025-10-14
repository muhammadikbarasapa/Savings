class Budget {
  final String id;
  final String userId;
  final String category;
  final double amount;
  final double spent;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String? description;

  Budget({
    required this.id,
    required this.userId,
    required this.category,
    required this.amount,
    required this.spent,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    this.description,
  });

  double get remaining => amount - spent;
  double get percentage => amount > 0 ? (spent / amount) * 100 : 0;
  bool get isOverBudget => spent > amount;
  bool get isNearLimit => percentage >= 80;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'category': category,
      'amount': amount,
      'spent': spent,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'isActive': isActive,
      'description': description,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      userId: map['userId'],
      category: map['category'],
      amount: map['amount'].toDouble(),
      spent: map['spent'].toDouble(),
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate']),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate']),
      isActive: map['isActive'],
      description: map['description'],
    );
  }

  Budget copyWith({
    String? id,
    String? userId,
    String? category,
    double? amount,
    double? spent,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    String? description,
  }) {
    return Budget(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      spent: spent ?? this.spent,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
    );
  }
}

class SavingsGoal {
  final String id;
  final String userId;
  final String title;
  final String description;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final DateTime createdAt;
  final bool isCompleted;
  final String? category;

  SavingsGoal({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.createdAt,
    required this.isCompleted,
    this.category,
  });

  double get progress => targetAmount > 0 ? (currentAmount / targetAmount) * 100 : 0;
  double get remaining => targetAmount - currentAmount;
  int get daysRemaining => targetDate.difference(DateTime.now()).inDays;
  bool get isOverdue => DateTime.now().isAfter(targetDate) && !isCompleted;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': targetDate.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isCompleted': isCompleted,
      'category': category,
    };
  }

  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    return SavingsGoal(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      description: map['description'],
      targetAmount: map['targetAmount'].toDouble(),
      currentAmount: map['currentAmount'].toDouble(),
      targetDate: DateTime.fromMillisecondsSinceEpoch(map['targetDate']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      isCompleted: map['isCompleted'],
      category: map['category'],
    );
  }

  SavingsGoal copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    DateTime? createdAt,
    bool? isCompleted,
    String? category,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
    );
  }
}
