const { db } = require("../config/firebase");

// Try to load Firebase Admin for FCM; gracefully degrade if not configured
let admin;
try {
  admin = require("firebase-admin");
} catch (e) {
  admin = null;
}

/**
 * Store a notification in Firestore for in-app display
 */
const storeNotification = async (userId, { title, body, data = {} }) => {
  try {
    const ref = db.collection("notifications").doc();
    await ref.set({
      userId,
      title,
      body,
      data,
      read: false,
      createdAt: new Date().toISOString(),
    });
  } catch (err) {
    // Non-critical — don't throw
    console.error("Failed to store notification:", err.message);
  }
};

/**
 * Send push notification via FCM + store in Firestore
 */
const notifyUser = async (userId, { title, body, data = {} }) => {
  // Always store in Firestore for in-app notifications
  await storeNotification(userId, { title, body, data });

  // Try FCM push if admin is available and user has an FCM token
  if (!admin) return;
  try {
    const userDoc = await db.collection("users").doc(userId).get();
    const fcmToken = userDoc.data()?.fcmToken;
    if (!fcmToken) return;

    await admin.messaging().send({
      token: fcmToken,
      notification: { title, body },
      data: Object.fromEntries(
        Object.entries(data).map(([k, v]) => [k, String(v)])
      ),
    });
  } catch (err) {
    // FCM failure is non-critical
    console.error("FCM send failed:", err.message);
  }
};

/**
 * Get all notifications for a user
 */
const getNotifications = async (userId) => {
  const snapshot = await db
    .collection("notifications")
    .where("userId", "==", userId)
    .get();
  const items = snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
  return items.sort((a, b) =>
    (b.createdAt || "").localeCompare(a.createdAt || "")
  );
};

/**
 * Mark a single notification as read
 */
const markAsRead = async (notificationId) => {
  await db.collection("notifications").doc(notificationId).update({ read: true });
};

/**
 * Mark all unread notifications for a user as read
 */
const markAllRead = async (userId) => {
  const snapshot = await db
    .collection("notifications")
    .where("userId", "==", userId)
    .where("read", "==", false)
    .get();
  const batch = db.batch();
  snapshot.docs.forEach((doc) => batch.update(doc.ref, { read: true }));
  await batch.commit();
};

module.exports = { notifyUser, storeNotification, getNotifications, markAsRead, markAllRead };
