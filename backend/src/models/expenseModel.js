/**
 * Expense record data structure for Firestore
 * Collection: expenses/{expenseId}
 */
const ExpenseModel = {
  userId: "",       // Who recorded this expense
  type: "",         // feed | medicine | labor | equipment | other
  description: "",  // What the expense was for
  amount: 0,        // Amount spent
  animalId: "",     // Optional: link to a specific animal
  receipt: "",      // Optional: Firebase Storage URL for receipt photo
  date: "",         // ISO timestamp of when expense occurred
  createdAt: "",
};

module.exports = ExpenseModel;
