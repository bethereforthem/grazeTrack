const express = require("express");
const router = express.Router();
const { getAllSales, getSale, recordSale } = require("../controllers/salesController");
const { protect } = require("../middleware/authMiddleware");

router.use(protect);

// GET all sales, POST record a new sale (auto-calculates profit)
router.route("/").get(getAllSales).post(recordSale);

// GET a single sale record
router.get("/:id", getSale);

module.exports = router;
