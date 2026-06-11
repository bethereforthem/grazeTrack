/**
 * Expense Service — business logic for farm expense records
 */

const { db } = require("../config/firebase");

/**
 * Get all expenses (role-filtered)
 */
const getAllExpenses = async (userId, role) => {
  let query = db.collection("expenses");
  if (role !== "Admin") {
    query = query.where("userId", "==", userId);
  }
  const snapshot = await query.get();
  const records = snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
  return records.sort((a, b) => (b.date || "").localeCompare(a.date || ""));
};

/**
 * Get a single expense record by ID
 */
const getExpenseById = async (expenseId) => {
  const doc = await db.collection("expenses").doc(expenseId).get();
  if (!doc.exists) {
    const err = new Error("Expense record not found");
    err.statusCode = 404;
    throw err;
  }
  return { id: doc.id, ...doc.data() };
};

/**
 * Create a new expense record
 */
const createExpense = async (expenseData, userId) => {
  const ref = db.collection("expenses").doc();
  const record = {
    ...expenseData,
    userId,
    createdAt: new Date().toISOString(),
  };
  await ref.set(record);
  return { id: ref.id, ...record };
};

/**
 * Update an expense record
 */
const updateExpense = async (expenseId, updates) => {
  const ref = db.collection("expenses").doc(expenseId);
  await ref.update(updates);
  const updated = await ref.get();
  return { id: updated.id, ...updated.data() };
};

/**
 * Delete an expense record
 */
const deleteExpense = async (expenseId) => {
  await db.collection("expenses").doc(expenseId).delete();
};

/**
 * Get total expenses for a user in a given date range
 * @param {string} userId
 * @param {string} startDate - ISO date string
 * @param {string} endDate - ISO date string
 */
const getTotalExpensesInRange = async (userId, startDate, endDate) => {
  // Get all user expenses then filter by date range in memory to avoid composite index
  const snapshot = await db
    .collection("expenses")
    .where("userId", "==", userId)
    .get();
  return snapshot.docs
    .filter((doc) => {
      const date = doc.data().date || "";
      return date >= startDate && date <= endDate;
    })
    .reduce((sum, doc) => sum + (doc.data().amount || 0), 0);
};

/**
 * Get expenses grouped by type (for pie chart in reports)
 */
const getExpensesByType = async (userId, role) => {
  let query = db.collection("expenses");
  if (role !== "Admin") {
    query = query.where("userId", "==", userId);
  }
  const snapshot = await query.get();
  const grouped = {};
  snapshot.docs.forEach((doc) => {
    const { type, amount } = doc.data();
    grouped[type] = (grouped[type] || 0) + (amount || 0);
  });
  return grouped;
};

module.exports = {
  getAllExpenses,
  getExpenseById,
  createExpense,
  updateExpense,
  deleteExpense,
  getTotalExpensesInRange,
  getExpensesByType,
};
