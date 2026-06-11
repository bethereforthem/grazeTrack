/**
 * Expense Controller — handles farm expense requests
 */

const expenseService = require("../services/expenseService");

// GET /api/v1/expenses
const getAllExpenses = async (req, res, next) => {
  try {
    const records = await expenseService.getAllExpenses(req.user.id, req.user.role);
    res.json({ success: true, count: records.length, data: records });
  } catch (error) {
    next(error);
  }
};

// GET /api/v1/expenses/:id
const getExpense = async (req, res, next) => {
  try {
    const record = await expenseService.getExpenseById(req.params.id);
    res.json({ success: true, data: record });
  } catch (error) {
    next(error);
  }
};

// GET /api/v1/expenses/summary  — grouped by type
const getExpenseSummary = async (req, res, next) => {
  try {
    const grouped = await expenseService.getExpensesByType(req.user.id, req.user.role);
    res.json({ success: true, data: grouped });
  } catch (error) {
    next(error);
  }
};

// POST /api/v1/expenses
const createExpense = async (req, res, next) => {
  try {
    const record = await expenseService.createExpense(req.body, req.user.id);
    res.status(201).json({ success: true, data: record });
  } catch (error) {
    next(error);
  }
};

// PUT /api/v1/expenses/:id
const updateExpense = async (req, res, next) => {
  try {
    const record = await expenseService.updateExpense(req.params.id, req.body);
    res.json({ success: true, data: record });
  } catch (error) {
    next(error);
  }
};

// DELETE /api/v1/expenses/:id
const deleteExpense = async (req, res, next) => {
  try {
    await expenseService.deleteExpense(req.params.id);
    res.json({ success: true, message: "Expense record deleted" });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getAllExpenses,
  getExpense,
  getExpenseSummary,
  createExpense,
  updateExpense,
  deleteExpense,
};
