const express = require("express");
const router = express.Router();
const { getFarmReport, getDashboard } = require("../controllers/reportController");
const { protect } = require("../middleware/authMiddleware");

router.use(protect);

// GET full farm report (analytics page)
router.get("/", getFarmReport);

// GET quick dashboard stats (home screen)
router.get("/dashboard", getDashboard);

module.exports = router;
