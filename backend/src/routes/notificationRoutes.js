const express = require("express");
const router = express.Router();
const { protect } = require("../middleware/authMiddleware");
const {
  getUserNotifications,
  markRead,
  markAllRead,
} = require("../controllers/notificationController");

router.get("/", protect, getUserNotifications);
router.put("/read-all", protect, markAllRead);
router.put("/:id/read", protect, markRead);

module.exports = router;
