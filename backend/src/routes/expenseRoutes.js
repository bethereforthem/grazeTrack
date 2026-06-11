const express = require("express");
const router = express.Router();
const {
  getAllExpenses,
  getExpense,
  getExpenseSummary,
  createExpense,
  updateExpense,
  deleteExpense,
} = require("../controllers/expenseController");
const { protect } = require("../middleware/authMiddleware");

router.use(protect);

// Grouped summary by expense type (for charts)
router.get("/summary", getExpenseSummary);

// GET all expenses, POST create a new one
router.route("/").get(getAllExpenses).post(createExpense);

// GET / PUT / DELETE a single expense record
router.route("/:id").get(getExpense).put(updateExpense).delete(deleteExpense);

module.exports = router;
