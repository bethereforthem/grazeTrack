const notificationService = require("../services/notificationService");

// GET /api/v1/notifications — get all notifications for the logged-in user
const getUserNotifications = async (req, res, next) => {
  try {
    const items = await notificationService.getNotifications(req.user.id);
    res.json({ success: true, count: items.length, data: items });
  } catch (error) {
    next(error);
  }
};

// PUT /api/v1/notifications/:id/read — mark one notification as read
const markRead = async (req, res, next) => {
  try {
    await notificationService.markAsRead(req.params.id);
    res.json({ success: true, message: "Notification marked as read" });
  } catch (error) {
    next(error);
  }
};

// PUT /api/v1/notifications/read-all — mark all notifications as read
const markAllRead = async (req, res, next) => {
  try {
    await notificationService.markAllRead(req.user.id);
    res.json({ success: true, message: "All notifications marked as read" });
  } catch (error) {
    next(error);
  }
};

module.exports = { getUserNotifications, markRead, markAllRead };
