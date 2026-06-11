const express = require("express");
const router = express.Router();
const {
  getOrCreateThread,
  getUserThreads,
  sendMessage,
  getMessages,
  markAsRead,
  editMessage,
  deleteMessage,
} = require("../controllers/chatController");
const { protect } = require("../middleware/authMiddleware");

router.use(protect);

router.post("/thread", getOrCreateThread);
router.get("/threads", getUserThreads);
router.post("/thread/:threadId/message", sendMessage);
router.get("/thread/:threadId/messages", getMessages);
router.put("/thread/:threadId/read", markAsRead);
router.put("/message/:messageId", editMessage);       // edit own message
router.delete("/message/:messageId", deleteMessage);   // delete own message

module.exports = router;
