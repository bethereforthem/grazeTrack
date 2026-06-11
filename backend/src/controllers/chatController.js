const chatService = require("../services/chatService");

// POST /api/v1/chat/thread  — get or create thread
const getOrCreateThread = async (req, res, next) => {
  try {
    const { listingId, sellerId } = req.body;
    // listingId is optional — omit it for a direct farmer-to-farmer chat
    if (!sellerId) {
      return res.status(400).json({
        success: false,
        message: "sellerId is required",
      });
    }
    const thread = await chatService.getOrCreateThread(
      listingId,
      req.user.id,
      sellerId
    );
    res.json({ success: true, data: thread });
  } catch (error) {
    next(error);
  }
};

// GET /api/v1/chat/threads  — all threads for current user
const getUserThreads = async (req, res, next) => {
  try {
    const threads = await chatService.getUserThreads(req.user.id);
    res.json({ success: true, count: threads.length, data: threads });
  } catch (error) {
    next(error);
  }
};

// POST /api/v1/chat/thread/:threadId/message  — send message
const sendMessage = async (req, res, next) => {
  try {
    const { content } = req.body;
    if (!content || !content.trim()) {
      return res
        .status(400)
        .json({ success: false, message: "Message content is required" });
    }
    const message = await chatService.sendMessage(
      req.params.threadId,
      req.user.id,
      req.user.name,
      content.trim()
    );
    res.status(201).json({ success: true, data: message });
  } catch (error) {
    next(error);
  }
};

// GET /api/v1/chat/thread/:threadId/messages
const getMessages = async (req, res, next) => {
  try {
    const limit = parseInt(req.query.limit) || 50;
    const messages = await chatService.getMessages(
      req.params.threadId,
      req.user.id,
      limit
    );
    res.json({ success: true, count: messages.length, data: messages });
  } catch (error) {
    next(error);
  }
};

// PUT /api/v1/chat/thread/:threadId/read — mark messages as read
const markAsRead = async (req, res, next) => {
  try {
    await chatService.markAsRead(req.params.threadId, req.user.id);
    res.json({ success: true, message: "Messages marked as read" });
  } catch (error) {
    next(error);
  }
};

// PUT /api/v1/chat/message/:messageId — edit a message (sender only)
const editMessage = async (req, res, next) => {
  try {
    const { content } = req.body;
    if (!content || !content.trim()) {
      return res.status(400).json({ success: false, message: "Content is required" });
    }
    const message = await chatService.editMessage(
      req.params.messageId,
      req.user.id,
      content
    );
    res.json({ success: true, data: message });
  } catch (error) {
    next(error);
  }
};

// DELETE /api/v1/chat/message/:messageId — delete a message (sender only)
const deleteMessage = async (req, res, next) => {
  try {
    await chatService.deleteMessage(req.params.messageId, req.user.id);
    res.json({ success: true, message: "Message deleted" });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getOrCreateThread,
  getUserThreads,
  sendMessage,
  getMessages,
  markAsRead,
  editMessage,
  deleteMessage,
};
