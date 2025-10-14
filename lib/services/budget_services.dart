import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/budget_model.dart';

class BudgetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Budget Methods
  Stream<List<Budget>> getBudgetsStream(String userId) {
    return _firestore
        .collection('budgets')
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Budget.fromMap(doc.data())).toList());
  }

  Future<void> addBudget(Budget budget) async {
    await _firestore
        .collection('budgets')
        .doc(budget.id)
        .set(budget.toMap());
  }

  Future<void> updateBudget(Budget budget) async {
    await _firestore
        .collection('budgets')
        .doc(budget.id)
        .update(budget.toMap());
  }

  Future<void> deleteBudget(String id) async {
    await _firestore.collection('budgets').doc(id).delete();
  }

  Future<void> updateBudgetSpent(String budgetId, double spent) async {
    await _firestore
        .collection('budgets')
        .doc(budgetId)
        .update({'spent': spent});
  }

  // Savings Goal Methods
  Stream<List<SavingsGoal>> getSavingsGoalsStream(String userId) {
    return _firestore
        .collection('savings_goals')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => SavingsGoal.fromMap(doc.data())).toList());
  }

  Future<void> addSavingsGoal(SavingsGoal goal) async {
    await _firestore
        .collection('savings_goals')
        .doc(goal.id)
        .set(goal.toMap());
  }

  Future<void> updateSavingsGoal(SavingsGoal goal) async {
    await _firestore
        .collection('savings_goals')
        .doc(goal.id)
        .update(goal.toMap());
  }

  Future<void> deleteSavingsGoal(String id) async {
    await _firestore.collection('savings_goals').doc(id).delete();
  }

  Future<void> updateSavingsGoalProgress(String goalId, double currentAmount) async {
    await _firestore
        .collection('savings_goals')
        .doc(goalId)
        .update({'currentAmount': currentAmount});
  }

  Future<void> markGoalAsCompleted(String goalId) async {
    await _firestore
        .collection('savings_goals')
        .doc(goalId)
        .update({'isCompleted': true});
  }

  // Helper Methods
  Future<double> calculateCategorySpent(String userId, String category, DateTime startDate, DateTime endDate) async {
    final snapshot = await _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .where('category', isEqualTo: category)
        .where('isIncome', isEqualTo: false)
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThanOrEqualTo: endDate)
        .get();

    double totalSpent = 0;
    for (var doc in snapshot.docs) {
      totalSpent += doc.data()['amount'].toDouble();
    }

    return totalSpent;
  }

  Future<List<Budget>> getBudgetsForCategory(String userId, String category) async {
    final snapshot = await _firestore
        .collection('budgets')
        .where('userId', isEqualTo: userId)
        .where('category', isEqualTo: category)
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) => Budget.fromMap(doc.data())).toList();
  }

  Future<List<SavingsGoal>> getActiveSavingsGoals(String userId) async {
    final snapshot = await _firestore
        .collection('savings_goals')
        .where('userId', isEqualTo: userId)
        .where('isCompleted', isEqualTo: false)
        .get();

    return snapshot.docs.map((doc) => SavingsGoal.fromMap(doc.data())).toList();
  }
}
